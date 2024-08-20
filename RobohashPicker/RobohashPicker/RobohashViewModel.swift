//
//  RobohashViewModel.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 20.08.2024.
//

import Foundation
import Combine

protocol ViewModelBinding {
    associatedtype Input
    associatedtype Output
    
    func bind(_ input: Input) -> Output
}

class RobohashViewModel: ViewModelBinding {
    struct Input {
        let enteredText: AnyPublisher<String?, Never>
        let generateTap: AnyPublisher<Void, Never>
    }
    struct Output {
        let generateButtonEnabled: AnyPublisher<Bool, Never>
        let robohashCreation: AnyPublisher<RobohashCreation, Error>
    }
    
    private let robohashFetcher = RobohashFetcher()
    
    func bind(_ input: Input) -> Output {
        let robohashResult = input.generateTap
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .withLatestFrom(input.enteredText)
            .compactMap { _, textInput -> String? in
                guard let text = textInput, !text.isEmpty else {
                    return nil
                }
                return text
            }
            .tryMap { [robohashFetcher] text in
                do {
                    return try robohashFetcher.fetchImage(for: text, set: .robot)
                } catch {
                    throw error
                }
            }
            .eraseToAnyPublisher()
        
        let generateButtonEnabled = input.enteredText
            .map { text in
                !(text?.isEmpty ?? true)
            }
            .prepend(Just(false))
            .eraseToAnyPublisher()
        
        return Output(
            generateButtonEnabled: generateButtonEnabled,
            robohashCreation: robohashResult
        )
    }
}
