//
//  Collection+SafeSubscript.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 22.08.2024.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard startIndex..<endIndex ~= index else {
            return nil
        }
        return self[index]
    }
}
