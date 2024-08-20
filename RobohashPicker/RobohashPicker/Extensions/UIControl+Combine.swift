//
//  UIControl+Combine.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 20.08.2024.
//

import UIKit
import Combine

extension UIControl {
    struct EventControlPublisher: Publisher {
        typealias Output = UIControl
        typealias Failure = Never
        
        let control: UIControl
        let controlEvent: UIControl.Event
        
        func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, UIControl == S.Input {
            let subscription = Subscription(
                control: control,
                event: controlEvent,
                subscriber: subscriber
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    func publisher(for event: UIControl.Event) -> EventControlPublisher {
        return EventControlPublisher(control: self, controlEvent: event)
    }
}

private extension UIControl.EventControlPublisher {
    class Subscription<EventSubscriber: Subscriber>: Combine.Subscription where EventSubscriber.Input == UIControl, EventSubscriber.Failure == Never {
        let control: UIControl
        let event: UIControl.Event
        var subscriber: EventSubscriber?
        
        var currentDemand: Subscribers.Demand = .none
        
        init(control: UIControl, event: UIControl.Event, subscriber: EventSubscriber) {
            self.control = control
            self.subscriber = subscriber
            self.event = event
            
            control.addTarget(
                self,
                action: #selector(eventRaised),
                for: event
            )
        }
        
        @objc func eventRaised() {
            guard currentDemand > 0 else { return }
            currentDemand += subscriber?.receive(control) ?? .none
            currentDemand -= 1
        }
        
        func request(_ demand: Subscribers.Demand) {
            currentDemand += demand
        }
        
        func cancel() {
            subscriber = nil
            control.removeTarget(
                self,
                action: #selector(eventRaised),
                for: event
            )
        }
        
        deinit {
            cancel()
        }
    }
}
