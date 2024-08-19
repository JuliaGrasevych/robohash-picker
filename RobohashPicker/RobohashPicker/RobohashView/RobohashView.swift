//
//  RobohashView.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 19.08.2024.
//

import UIKit
import Combine

import SnapKit

class RobohashView: UIView {
    private let roboImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .red
        return view
    }()
    private let urlDescription: UILabel = {
        let view = UILabel()
        view.text = "Test"
        view.textAlignment = .center
        return view
    }()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = 6
        return view
    }()
    
    var subscriptions: [AnyCancellable] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        [roboImage, .spacer(), urlDescription].forEach(stackView.addArrangedSubview)
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview()
        }
    }
    
    func update(with robohash: RobohashCreation) {
        subscriptions.removeAll()
        // TODO: present loading
        robohash.image
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    // TODO: handle error
                },
                receiveValue: { [weak self] image in
                    self?.roboImage.image = image
                }
            )
            .store(in: &subscriptions)
        urlDescription.text = robohash.url.absoluteString
    }
}
