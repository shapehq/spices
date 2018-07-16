//
//  BoolTableViewCell.swift
//  Spices
//
//  Created by Simon Støvring on 21/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import UIKit

class BoolTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .black
        return label
    }()
    let boolSwitch: UISwitch = {
        let _switch = UISwitch()
        _switch.translatesAutoresizingMaskIntoConstraints = false
        return _switch
    }()
    var valueChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        boolSwitch.addTarget(self, action: #selector(boolSwitchValueChanged), for: .valueChanged)
        contentView.addSubview(titleLabel)
        contentView.addSubview(boolSwitch)
    }
    
    private func setupLayout() {
        titleLabel.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: boolSwitch.leadingAnchor, constant: -15).isActive = true
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: readableContentGuide.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: readableContentGuide.bottomAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        boolSwitch.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor).isActive = true
        boolSwitch.topAnchor.constraint(greaterThanOrEqualTo: contentView.readableContentGuide.topAnchor).isActive = true
        boolSwitch.bottomAnchor.constraint(lessThanOrEqualTo: contentView.readableContentGuide.bottomAnchor).isActive = true
        boolSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    @objc private func boolSwitchValueChanged() {
        valueChanged?(boolSwitch.isOn)
    }
}
