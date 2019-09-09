//
//  Cell.swift
//  CustomNavigationBar
//
//  Created by Jason Chen on 2019/9/9.
//  Copyright © 2019 Jason Chen. All rights reserved.
//

import UIKit

//
// MARK: - Cell
//
class Cell: UITableViewCell {

    //
    // MARK: - Class Constants
    //
    static let identifier = "Cell"
    
    //
    // MARK: - IBOutlets
    //
    @IBOutlet weak var plantsImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var featureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
