//
//  UIControl+Combine.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 20.08.2024.
//

import UIKit
import Combine

protocol CombineCompatible { }

extension UIControl: CombineCompatible { }

extension CombineCompatible where Self: UIControl {
    func publisher(for event: UIControl.Event) -> EventControlPublisher<Self> {
        return EventControlPublisher(control: self, controlEvent: event)
    }
}

struct EventControlPublisher<T: UIControl>: Publisher {
    typealias Output = T
    typealias Failure = Never
    
    let control: T
    let controlEvent: UIControl.Event
    
    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, T == S.Input {
        let subscription = Subscription(
            control: control,
            event: controlEvent,
            subscriber: subscriber
        )
        subscriber.receive(subscription: subscription)
    }
}

private extension EventControlPublisher {
    class Subscription<EventSubscriber: Subscriber, Control: UIControl>: Combine.Subscription where EventSubscriber.Input == Control, EventSubscriber.Failure == Never {
        let control: Control
        let event: UIControl.Event
        var subscriber: EventSubscriber?
        
        var currentDemand: Subscribers.Demand = .none
        
        init(control: Control, event: UIControl.Event, subscriber: EventSubscriber) {
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
