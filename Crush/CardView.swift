//
//  CardView.swift
//  Crush
//
//  Created by Alex Albert on 1/6/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit

/*@IBDesignable*/ class CardView: UIView {

	
	@IBOutlet weak var cardImageView: UIImageView!
	@IBOutlet weak var cardNameLabel: UILabel!
	
	@IBOutlet weak var cardGradeSchoolLabel: UILabel!
	
	var view:UIView!
	
	/*@IBInspectable
	var cardNameLabelText: String? {
		get {
			return cardNameLabel.text
		}
		set(cardNameLabelText) {
			cardNameLabel.text = cardNameLabelText
		}
	}
	@IBInspectable
	var cardGradeSchoolLabelText: String? {
		get {
			return cardGradeSchoolLabel.text
		}
		set(cardGradeSchoolLabelText) {
			cardGradeSchoolLabel.text = cardGradeSchoolLabelText
		}
	}
	
	@IBInspectable
	var cardCustomImage:UIImage? {
		get {
			return cardImageView.image
		}
		set(cardCustomImage) {
			cardImageView.image = cardCustomImage
		}
	}*/
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		view = loadViewFromNib()
		view.frame = bounds
		addSubview(view)
	}
	
	func loadViewFromNib() -> UIView {
		let bundle = Bundle(for:type(of: self))
		let nib = UINib(nibName: "Card", bundle: bundle)
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		
		return view
	}

}
