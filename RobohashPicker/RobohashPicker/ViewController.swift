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
    
    private let viewModel = RobohashViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // TODO: add control to choose robohash set
    // TODO: add link to website
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectViewModel()
    }
    
    private func connectViewModel() {
        let input = RobohashViewModel.Input(
            enteredText: textField.publisher(for: .editingChanged)
                .map { ($0 as? UITextField)?.text }
                .eraseToAnyPublisher(),
            generateTap: generateButton.publisher(for: .touchUpInside)
                .map { _ in }
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
    }
    
    // TODO: hide keyboard on "return" or "generate"
}


