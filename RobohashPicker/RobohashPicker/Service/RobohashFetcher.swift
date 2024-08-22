//
//  RobohashFetcher.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 19.08.2024.
//

import Foundation
import Combine
import UIKit

enum RobohashSet: CaseIterable {
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

enum RobohashError: Error {
    case failedToRequest
    case invalidImage
}

protocol RobohashFetching {
    func fetchImage(for text: String, set: RobohashSet) throws -> RobohashCreation
}

class RobohashFetcher: RobohashFetching {
    func fetchImage(for text: String, set: RobohashSet) throws -> RobohashCreation {
        guard var urlComponents = URLComponents(string: "https://robohash.org") else {
            throw RobohashError.failedToRequest
        }
        urlComponents.path = "/\(text)"
        if let setURLParameter = set.urlParameter {
            urlComponents.queryItems = [URLQueryItem(name: "set", value: setURLParameter)]
        }
        guard let url = urlComponents.url else {
            throw RobohashError.failedToRequest
        }
        
        let task = URLSession.shared.dataTaskPublisher(for: url)
        
        return RobohashCreation(
            image: task
                .tryMap { data, response in
                    guard let image = UIImage(data: data) else {
                        throw RobohashError.invalidImage
                    }
                    return image
                }
                .eraseToAnyPublisher(),
            url: url
        )
    }
}
