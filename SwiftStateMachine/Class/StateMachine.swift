//
//  StateMachine.swift
//  SwiftStateMachine
//
//  Created by mengxiangjian on 2021/9/30.
//

import Foundation

public enum TransitionResult {
    case success
    case failure
}

public class StateMachine<State: Equatable, Event: Hashable> {
    private var internalCurrentState: State
    
    /// lock queue, set/get transitions
    private let lockQueue: DispatchQueue
    
    /// work queue
    private let workQueue: DispatchQueue
    
    /// call back queue
    private let callbackQueue: DispatchQueue
    
    public var currentState: State {
        return {
            workQueue.sync {
                return internalCurrentState
            }
        }()
    }
    
    private var transitionByEvent: [Event: [Transition<State, Event>]] = [:]
    
    /// state machine initializer
    /// - Parameters:
    ///   - initialState: initial state.
    ///   - callbackQueue: call back queue. Main queue is default.
    public init(initialState: State, callbackQueue: DispatchQueue? = nil) {
        self.internalCurrentState = initialState
        self.lockQueue = DispatchQueue(label: "com.statemachine.queue.lock")
        self.workQueue = DispatchQueue(label: "com.statemachine.queue.work")
        self.callbackQueue = callbackQueue ?? DispatchQueue.main
    }
    
    /// register transition (states transitions triggered by event)
    /// - Parameter transition: transition
    public func add(transition: Transition<State, Event>) {
        lockQueue.async {
            if let transitions = self.transitionByEvent[transition.event] {
                if (transitions.filter{$0.source == transition.source}.count > 0) {
                    assertionFailure("Transition with event '\(transition.event)' and source '\(transition.source)' already existing.")
                }
                self.transitionByEvent[transition.event]?.append(transition)
            } else {
                self.transitionByEvent[transition.event] = [transition]
            }
        }
    }
    
    public typealias TransitionBlock = (TransitionResult) -> Void
    
    /// trigger event to make state transition
    /// - Parameters:
    ///   - event: event
    ///   - execution: execution closure when transitioning
    ///   - callback: call back when transition end
    public func process(event: Event,
                        execution: (() -> Void)? = nil,
                        callback:TransitionBlock?) {
        var transitions: [Transition<State, Event>]? = nil
        lockQueue.sync {
            transitions = self.transitionByEvent[event]
        }
        
        workQueue.async {
            let performTransitions = transitions?.filter {
                $0.source == self.internalCurrentState
            } ?? []
            
            if performTransitions.count == 0 {
                self.callbackQueue.async {
                    callback?(.failure)
                }
                return
            }
            
            if performTransitions.count > 1 {
                self.callbackQueue.async {
                    callback?(.failure)
                }
                return
            }
            
            let transition = performTransitions.first!
            
            self.callbackQueue.async {
                transition.preAction?()
            }
            
            self.callbackQueue.async {
                execution?();
            }
            
            self.internalCurrentState = transition.destination
            
            self.callbackQueue.async {
                transition.postAction?()
            }
            
            self.callbackQueue.async {
                callback?(.success)
            }
        }
    }
}
