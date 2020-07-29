//
//  ExperimentsCell.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit

class ExperimentCell: UITableViewCell {

  private let currentOption: String = "Current option"

  private let blue: UIColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
  private let black40: UIColor = UIColor.black.withAlphaComponent(0.4)

  private var checkImageView: UIImageView!
  private var stackView: UIStackView!
  private var currentLabel: UILabel!
  private var descriptionLabel: UILabel!
  private var keyLabel: UILabel!

  func configure(
    with option: AppboosterExperimentOption,
    isCurrent: Bool,
    isSelected: Bool
  ) {
    descriptionLabel.text = option.description
    keyLabel.text = "\(option.value)"
    currentLabel.isHidden = !isCurrent
    let imageName = isSelected ? "checkbox-fill" : "checkbox"
    checkImageView.image = UIImage(named: imageName)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    checkImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    contentView.addSubview(checkImageView)
    checkImageView.translatesAutoresizingMaskIntoConstraints = false
    checkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
    checkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    checkImageView.setContentHuggingPriority(UILayoutPriority(rawValue: 255), for: .horizontal)

    stackView = UIStackView()
    stackView.spacing = 2
    stackView.axis = .vertical
    contentView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.leadingAnchor.constraint(equalTo: checkImageView.trailingAnchor, constant: 20).isActive = true
    stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
    stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true

    currentLabel = UILabel()
    currentLabel.text = currentOption
    currentLabel.textColor = blue
    currentLabel.font = .systemFont(ofSize: 13)
    stackView.addArrangedSubview(currentLabel)

    descriptionLabel = UILabel()
    descriptionLabel.textColor = .black
    descriptionLabel.font = .systemFont(ofSize: 17)
    descriptionLabel.numberOfLines = 0
    stackView.addArrangedSubview(descriptionLabel)

    keyLabel = UILabel()
    keyLabel.textColor = black40
    keyLabel.font = .systemFont(ofSize: 13)
    stackView.addArrangedSubview(keyLabel)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
