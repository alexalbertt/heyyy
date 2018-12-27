//
//  MatchCell.swift
//  Crush
//
//  Created by Alex Albert on 1/26/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {

	let messagesVC = MessagesVC()
	
	@IBOutlet weak var cellView: UIView!
	@IBOutlet weak var matchImg: UIImageView?
	
	@IBOutlet weak var matchName: UILabel!
	
	@IBOutlet weak var matchPhoneNumber: UILabel?
	
	@IBOutlet weak var matchTimeStamp: UILabel?
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	
	
}
