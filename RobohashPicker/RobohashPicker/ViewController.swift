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
    
    // TODO: move all logic to view models
    // TODO: add control to choose robohash set
    // TODO: add link to website
    private let robohashFetcher = RobohashFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func generate(_ sender: UIButton) {
        // TODO: disable generate button when no test is entered
        // TODO: hide keyboard on "return" or "generate"
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        do {
            let result = try robohashFetcher.fetchImage(for: text, set: .robot)
            robohashView.update(with: result)
        } catch {
            print("error fetching: \(error.localizedDescription)")
        }
    }
}

