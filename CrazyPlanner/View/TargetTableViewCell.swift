//
//  TargetTableViewCell.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/7/1.
//

import UIKit

class TargetTableViewCell: UITableViewCell {
    
    static let identifier = "CustomTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func nib() -> UINib {
        return UINib(nibName: "CustomTableViewCell", bundle: nil) 
    }
    
    
    /*
     override func awakeFromNib() {
     super.awakeFromNib()
     // Initialization code
     }
     
     override func setSelected(_ selected: Bool, animated: Bool) {
     super.setSelected(selected, animated: animated)
     
     // Configure the view for the selected state
     }
     */
    
}
