//
//  InviteCell.swift
//  Crush
//
//  Created by Alex Albert on 1/29/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit

class InviteCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var sendInviteButton: UIButton!
	
	@IBOutlet weak var contactCellImage: UIImageView!

	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
