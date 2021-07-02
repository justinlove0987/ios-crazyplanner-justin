//
//  CustomTableViewHeader.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/7/2.
//

import UIKit


class TableHeader: UITableViewHeaderFooterView {
    
    static let identifier = "TableHeader"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Select"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 0,
                             y: contentView.frame.size.height-10-label.frame.size.height,
                             width: contentView.frame.size.width,
                             height: label.frame.size.height)
    }
    
}
