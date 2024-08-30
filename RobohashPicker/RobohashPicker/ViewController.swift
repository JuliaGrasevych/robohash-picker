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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var copyright: UIButton!
    @IBOutlet weak var setControl: UISegmentedControl!
    @IBOutlet weak var savedLabel: UILabel!
    
    private let setControlSubject = PassthroughSubject<Int, Never>()
    
    private let viewModel = RobohashViewModel()
    private let application = UIApplication.shared
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedLabelVisibility(false)
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
        let selectedSet = setControlSubject
            .eraseToAnyPublisher()
            .merge(with: setControl.publisher(for: .valueChanged)
                .map(\.selectedSegmentIndex)
                .eraseToAnyPublisher()
            )
            .eraseToAnyPublisher()
        
        // dismiss keyboard when tap 'generate'
        generateButtonDidTap
            .sink { [textField] _ in
                textField?.resignFirstResponder()
            }
            .store(in: &subscriptions)
        
        let input = RobohashViewModel.Input(
            enteredText: textField.publisher(for: .editingChanged)
                .map(\.text)
                .eraseToAnyPublisher(),
            generateTap: returnKeyDidTap.merge(with: generateButtonDidTap)
                .eraseToAnyPublisher(),
            saveTap: saveButton.publisher(for: .touchUpInside)
                .mapVoid()
                .eraseToAnyPublisher(),
            copyrightTap: copyright.publisher(for: .touchUpInside)
                .mapVoid()
                .eraseToAnyPublisher(),
            selectedSetIndex: selectedSet
        )
        let output = viewModel.bind(input)
        
        output.generateButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: generateButton)
            .store(in: &subscriptions)
        output.saveButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
        output.robohashCreation
            .receive(on: DispatchQueue.main)
            .sink { [robohashView] result in
                robohashView?.update(with: result)
            }
            .store(in: &subscriptions)
        output.openURL
            .receive(on: DispatchQueue.main)
            .sink { [application] url in
                application.open(url)
            }
            .store(in: &subscriptions)
        
        output.setOptions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] options in
                self?.updateSetOptions(options)
            }
            .store(in: &subscriptions)
        
        output.errorAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(message: errorMessage)
            }
            .store(in: &subscriptions)
        
        output.savedAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.showSavedLabel()
            }
            .store(in: &subscriptions)
        
        output.subscriptions.forEach {
            $0.store(in: &subscriptions)
        }
    }
    
    private func updateSetOptions(_ options: [String]) {
        setControl.removeAllSegments()
        guard !options.isEmpty else { return }
        options.enumerated().forEach { index, option in
            setControl.insertSegment(withTitle: option, at: index, animated: false)
        }
        setControl.selectedSegmentIndex = 0
        setControlSubject.send(0)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    // MARK: - Saved Label
    private func savedLabelVisibility(_ isVisible: Bool) {
        savedLabel.alpha = isVisible ? 1 : 0
    }
    
    // MARK: - Animations
    private func showSavedLabel() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { [weak self] in
                self?.savedLabel.alpha = 1.0
            },
            completion: { [weak self] completed in
                guard completed else { return }
                self?.hideSavedLabel()
            }
        )
    }
    
    private func hideSavedLabel() {
        UIView.animate(
            withDuration: 0.5,
            delay: 1.0,
            animations: { [weak self] in
                self?.savedLabel.alpha = 0
            }
        )
    }
}
