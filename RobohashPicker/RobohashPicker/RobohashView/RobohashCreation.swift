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
    enum ImageContent {
        case loading
        case loaded(UIImage)
        case failed(Error)
    }
    let image: ImageContent
    let url: URL
}
