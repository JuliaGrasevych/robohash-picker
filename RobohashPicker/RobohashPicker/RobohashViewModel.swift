//
//  RobohashViewModel.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 20.08.2024.
//

import Foundation
import UIKit
import Combine
import Photos

protocol ViewModelBinding {
    associatedtype Input
    associatedtype Output
    
    func bind(_ input: Input) -> Output
}

class RobohashViewModel: ViewModelBinding {
    struct Input {
        let enteredText: AnyPublisher<String?, Never>
        let generateTap: AnyPublisher<Void, Never>
        let saveTap: AnyPublisher<Void, Never>
        let copyrightTap: AnyPublisher<Void, Never>
        let selectedSetIndex: AnyPublisher<Int, Never>
    }
    struct Output {
        let generateButtonEnabled: AnyPublisher<Bool, Never>
        let saveButtonEnabled: AnyPublisher<Bool, Never>
        let robohashCreation: AnyPublisher<RobohashCreation, Never>
        let openURL: AnyPublisher<URL, Never>
        let setOptions: AnyPublisher<[String], Never>
        let errorAlert: AnyPublisher<String, Never>
        let subscriptions: Set<AnyCancellable>
    }
    
    private let robohashFetcher = RobohashFetcher()
    
    func bind(_ input: Input) -> Output {
        let setOptions = Just(RobohashSet.allCases)
            .eraseToAnyPublisher()
        let setOptionsNames = setOptions
            .map { $0.map(\.name) }
            .eraseToAnyPublisher()
        
        let selectedSet = setOptions.combineLatest(input.selectedSetIndex)
            .compactMap { $0[safe: $1] }
        
        let robohashRequest = input.generateTap
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .withLatestFrom(input.enteredText)
            .compactMap { _, textInput -> String? in
                guard let text = textInput, !text.isEmpty else {
                    return nil
                }
                return text
            }
            .withLatestFrom(selectedSet)
            .removeDuplicates(by: { $0 == $1 })
            .map { [robohashFetcher] text, setOption in
                robohashFetcher.fetchImage(for: text, set: setOption)
                    .map(Result.success)
                    .catch { Just(.failure($0)) }
            }
            .switchToLatest() // switchToLatest to cancel previous request
            .share()
        
        let robohashResult = robohashRequest
            .compactMap { result -> RobohashCreation? in
                guard case let .success(creation) = result else { return nil }
                return creation
            }
            .eraseToAnyPublisher()
        
        let robohashRequestError = robohashRequest
            .compactMap { result -> String? in
                guard case let .failure(error) = result else { return nil }
                return error.localizedDescription
            }
            .eraseToAnyPublisher()
        
        let triggerPermissionsCheck = PassthroughSubject<Void, Never>()
        let photoLibraryPermissionStatus = triggerPermissionsCheck
            .prepend(())
            .map { PHPhotoLibrary.authorizationStatus(for: .addOnly).canPromptSave }
            .eraseToAnyPublisher()
        let saveError = PassthroughSubject<String, Never>()
        
        let saveSubscription = input.saveTap
            .withLatestFrom(robohashResult.compactMap(\.imageValue))
            .sink { _, image in
                Self.save(
                    image: image,
                    triggerPermissionsCheck: triggerPermissionsCheck,
                    errorAlert: saveError
                )
            }
        
        let saveButtonEnabled = robohashRequest
            .combineLatest(photoLibraryPermissionStatus)
            .map(Self.isSaveAvailable)
            .prepend(Just(false))
            .eraseToAnyPublisher()
        
        let generateButtonEnabled = input.enteredText
            .map { text in
                !(text?.isEmpty ?? true)
            }
            .prepend(Just(false))
            .eraseToAnyPublisher()
        
        let copyrightURL = input.copyrightTap
            .compactMap { URL(string: "https://robohash.org/") }
            .eraseToAnyPublisher()
        
        let errors = robohashRequestError.merge(with: saveError)
            .eraseToAnyPublisher()
        
        return Output(
            generateButtonEnabled: generateButtonEnabled,
            saveButtonEnabled: saveButtonEnabled,
            robohashCreation: robohashResult,
            openURL: copyrightURL,
            setOptions: setOptionsNames,
            errorAlert: errors,
            subscriptions: [saveSubscription]
        )
    }
    
    private static func isSaveAvailable(for requestResult: Result<RobohashCreation, Error>, permissionStatus: Bool) -> Bool {
        switch requestResult {
        case .success(let value):
            return value.imageValue == nil ? false : permissionStatus
        case .failure:
            return false
        }
    }
    
    private static func save(
        image: UIImage,
        triggerPermissionsCheck: any Subject<Void, Never>,
        errorAlert: any Subject<String, Never>
    ) {
        PHPhotoLibrary.shared().performChanges {
            _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            guard let error else { return }
            triggerPermissionsCheck.send()
            errorAlert.send(error.localizedDescription)
        }
    }
}

private extension RobohashSet {
    var name: String {
        switch self {
        case .robot:
            return "Robot"
        case .monster:
            return "Monster"
        case .robotsHead:
            return "Robohead"
        case .kitten:
            return "Kitten"
        case .human:
            return "Human"
        }
    }
}

private extension PHAuthorizationStatus {
    var canPromptSave: Bool {
        switch self {
        case .notDetermined,
                .authorized:
            return true
        case .restricted,
                .denied,
                .limited:
            return false
        @unknown default:
            return false
        }
    }
}

private extension RobohashCreation {
    var imageValue: UIImage? {
        switch image {
        case .loaded(let image):
            return image
        case .loading, .failed:
            return nil
        }
    }
}
