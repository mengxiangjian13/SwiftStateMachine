//
//  File.swift
//  SwiftStateMachine
//
//  Created by mengxiangjian on 2021/9/30.
//

import Foundation

public typealias ExecutionBlock = (() -> Void)
public struct Transition <State, Event> {
    
    /// Event that trigger this transition
    public let event: Event
    public let source: State
    public let destination: State
    let preAction: ExecutionBlock?
    let postAction: ExecutionBlock?
    
    /// Transition initializer
    /// - Parameters:
    ///   - event: event that triggers state transition
    ///   - from: state from
    ///   - to: state to
    ///   - preBlock: transition pre action
    ///   - postBlock: transition post action
    init(with event:Event,
         from: State,
         to: State,
         preBlock: ExecutionBlock?,
         postBlock: ExecutionBlock?) {
        self.event = event
        self.source = from
        self.destination = to
        self.preAction = preBlock
        self.postAction = postBlock
    }
    
    func executePreAction() {
        preAction?()
    }
    
    func executePostAction() {
        postAction?()
    }
}
