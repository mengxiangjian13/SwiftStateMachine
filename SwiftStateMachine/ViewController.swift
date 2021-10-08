//
//  ViewController.swift
//  SwiftStateMachine
//
//  Created by mengxiangjian on 2021/9/30.
//

import UIKit

enum VideoPlayState {
    case stop
    case play
    case pause
}

enum VideoPlayEvent {
    case pressPlay
    case pressPause
    case pressStop
}

typealias StateMachineDefault = StateMachine<VideoPlayState, VideoPlayEvent>
typealias TransitionDefault = Transition<VideoPlayState, VideoPlayEvent>

class ViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    
    let stateMachine = StateMachineDefault(initialState: .stop)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        registerStateTransitions()
    }
    
    func registerStateTransitions() {
        /// usage: register state transitions
        stateMachine.add(transition:
                            TransitionDefault(with: .pressPlay,
                                              from: .stop,
                                              to: .play,
                                              preBlock: {
                                                print("from stop to play: pre block")
                                              }, postBlock: {
                                                print("from stop to play: post block")
                                              }))
        
        stateMachine.add(transition:
                            TransitionDefault(with: .pressPlay,
                                              from: .pause,
                                              to: .play,
                                              preBlock: {
                                                print("from pause to play: pre block")
                                              }, postBlock: {
                                                print("from pause to play: post block")
                                              }))
        
        stateMachine.add(transition:
                            TransitionDefault(with: .pressPause,
                                              from: .play,
                                              to: .pause,
                                              preBlock: {
                                                print("from play to pause: pre block")
                                              }, postBlock: {
                                                print("from play to pause: post block")
                                              }))
        
        stateMachine.add(transition:
                            TransitionDefault(with: .pressStop,
                                              from: .play,
                                              to: .stop,
                                              preBlock: {
                                                print("from play to stop: pre block")
                                              }, postBlock: {
                                                print("from play to stop: post block")
                                              }))
        
        stateMachine.add(transition:
                            TransitionDefault(with: .pressStop,
                                              from: .pause,
                                              to: .stop,
                                              preBlock: {
                                                print("from pause to stop: pre block")
                                              }, postBlock: {
                                                print("from pause to stop: post block")
                                              }))
        
        self.showState()
    }
    
    
    @IBAction func pauseAction(_ sender: Any) {
        stateMachine.process(event: .pressPause) {
            print("enter pause state")
        } callback: {_ in
            self.showState()
        }
    }
    
    @IBAction func playAction(_ sender: Any) {
        stateMachine.process(event: .pressPlay) {
            print("enter play state")
        } callback: {_ in
            self.showState()
        }
    }
    
    @IBAction func stopAction(_ sender: Any) {
        stateMachine.process(event: .pressStop) {
            print("enter stop state")
        } callback: {_ in
            self.showState()
        }
    }
    
    private func showState() {
        switch stateMachine.currentState {
        case .pause:
            stateLabel.text = "Current State is: Pause"
        case .play:
            stateLabel.text = "Current State is: Play"
        case .stop:
            stateLabel.text = "Current State is: Stop"
        }
    }
}

