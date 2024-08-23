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
        return view
    }()
    private let urlDescription: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.lineBreakMode = .byTruncatingMiddle
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
    private let loader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.tintColor = .black
        view.hidesWhenStopped = true
        view.stopAnimating()
        return view
    }()
    
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
        addSubview(loader)
        loader.snp.makeConstraints { make in
            make.center.equalTo(stackView)
        }
    }
    
    func update(with robohash: RobohashCreation) {
        switch robohash.image {
        case .loading:
            loader.startAnimating()
            roboImage.alpha = 0.5
        case .loaded(let image):
            loader.stopAnimating()
            roboImage.image = image
            roboImage.alpha = 1.0
        case .failed(let error):
            // TODO: show error
            loader.stopAnimating()
            roboImage.image = nil
            roboImage.alpha = 1.0
        }
        urlDescription.text = robohash.url.absoluteString
    }
}
