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

extension RobohashError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedToRequest:
            return "Failed to create Robohash request"
        case .invalidImage:
            return "Failed to retrieve Robohash image"
        }
    }
}

protocol RobohashFetching {
    func fetchImage(for text: String, set: RobohashSet) -> AnyPublisher<RobohashCreation, Error>
}

class RobohashFetcher: RobohashFetching {
    func fetchImage(for text: String, set: RobohashSet) -> AnyPublisher<RobohashCreation, Error> {
#warning("Test values")
        if text == "fail" {
            return Fail(error: RobohashError.failedToRequest)
                .eraseToAnyPublisher()
        }
        guard var urlComponents = URLComponents(string: "https://robohash.org") else {
            return Fail(error: RobohashError.failedToRequest)
                .eraseToAnyPublisher()
        }
        urlComponents.path = "/\(text)"
        if let setURLParameter = set.urlParameter {
            urlComponents.queryItems = [URLQueryItem(name: "set", value: setURLParameter)]
        }
        guard let url = urlComponents.url else {
            return Fail(error: RobohashError.failedToRequest)
                .eraseToAnyPublisher()
        }
        
        let task = URLSession.shared.dataTaskPublisher(for: url)
        return task
            .tryMap { data, response in
#warning("Test values")
                if text == "img" {
                    return RobohashCreation(
                        image: .failed(RobohashError.invalidImage),
                        url: url
                    )
                }
                guard let image = UIImage(data: data) else {
                    return RobohashCreation(
                        image: .failed(RobohashError.invalidImage),
                        url: url
                    )
                }
                return RobohashCreation(
                    image: .loaded(image),
                    url: url
                )
            }
            .prepend(RobohashCreation(image: .loading, url: url))
            .eraseToAnyPublisher()
    }
}
