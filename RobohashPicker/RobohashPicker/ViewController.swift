//
//  ViewController.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 19.08.2024.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var robohashView: RobohashView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var copyright: UIButton!
    
    private let viewModel = RobohashViewModel()
    private let application = UIApplication.shared
    private var subscriptions = Set<AnyCancellable>()
    
    // TODO: add control to choose robohash set
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectViewModel()
    }
    
    private func connectViewModel() {
        let returnKeyDidTap = textField.publisher(for: .editingDidEndOnExit)
            .mapVoid()
            .eraseToAnyPublisher()
        let generateButtonDidTap = generateButton.publisher(for: .touchUpInside)
            .mapVoid()
            .share()
            .eraseToAnyPublisher()
        // dismiss keyboard when tap 'generate'
        generateButtonDidTap
            .sink { [textField] _ in
                textField?.resignFirstResponder()
            }
            .store(in: &subscriptions)
        
        let input = RobohashViewModel.Input(
            enteredText: textField.publisher(for: .editingChanged)
                .map { $0.text }
                .eraseToAnyPublisher(),
            generateTap: returnKeyDidTap.merge(with: generateButtonDidTap)
                .eraseToAnyPublisher(),
            copyrightTap: copyright.publisher(for: .touchUpInside)
                .mapVoid()
                .eraseToAnyPublisher()
        )
        let output = viewModel.bind(input)
        
        output.generateButtonEnabled
            .assign(to: \.isEnabled, on: generateButton)
            .store(in: &subscriptions)
        output.robohashCreation
            .sink(
                receiveCompletion: { completion in
                    // TODO: handle error
                },
                receiveValue: { [robohashView] result in
                    robohashView?.update(with: result)
                }
            )
            .store(in: &subscriptions)
        output.openURL
            .sink { [application] url in
                application.open(url)
            }
            .store(in: &subscriptions)
    }
}


