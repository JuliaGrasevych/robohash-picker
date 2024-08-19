//
//  RobohashCreation.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 19.08.2024.
//

import Foundation
import Combine
import UIKit

struct RobohashCreation {
    let image: AnyPublisher<UIImage, Error>
    let url: URL
}

enum RobohashSet {
    case robot
    case monster
    case robotsHead
    case kitten
    case human
    
    var urlParameter: String? {
        switch self {
        case .robot:
            // this is default to Robohash
            return nil
        case .monster:
            return "set2"
        case .robotsHead:
            return "set3"
        case .kitten:
            return "set4"
        case .human:
            return "set5"
        }
    }
}
