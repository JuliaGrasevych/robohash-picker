//
//  UIView+Spacer.swift
//  RobohashPicker
//
//  Created by Julia Grasevych on 19.08.2024.
//

import UIKit

extension UIView {
    static func spacer(color: UIColor = .clear) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
}
