//
//  Publisher+MapVoid.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 22.08.2024.
//

import Foundation
import Combine

extension Publisher {
    func mapVoid() -> Publishers.Map<Self, Void> {
        self.map { _ in }
    }
}
