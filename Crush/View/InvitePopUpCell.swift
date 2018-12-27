//
//  InvitePopUpCell.swift
//  Crush
//
//  Created by Alex Albert on 2/11/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit

class InvitePopUpCell: UITableViewCell {

	
	
	

	@IBOutlet weak var contactNameLabel: UILabel!
	@IBOutlet weak var contactInviteButton: UIButton!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
