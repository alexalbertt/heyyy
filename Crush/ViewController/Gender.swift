//
//  Gender.swift
//  Crush
//
//  Created by Alex Albert on 12/28/17.
//  Copyright © 2017 Alex Albert. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class Gender: UIViewController {

	@IBOutlet weak var genderBoyImage: UIButton!
	@IBOutlet weak var genderGirlImage: UIButton!
	@IBOutlet weak var matchPreferenceBoyImage: UIButton!
	@IBOutlet weak var matchPreferenceGirlImage: UIButton!
	@IBOutlet weak var matchPreferenceBothImage: UIButton!
	
	var genderSelected = false
	var matchPreferenceSelected = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: Gender Buttons
	@IBAction func genderBoy(_ sender: Any) {
		genderSelected = true
		genderBoyImage.setImage(#imageLiteral(resourceName: "Check box"), for: .normal)
		genderGirlImage.setImage(#imageLiteral(resourceName: "Main Girl"), for: .normal)
		let userGender = "boy"
		ref.child("users").child(uid!).child("gender").setValue(userGender)
		if genderSelected == true && matchPreferenceSelected == true {
			performSegue(withIdentifier: "genderEntered", sender: Any?.self)
		}
	}
	
	
	@IBAction func genderGirl(_ sender: Any) {
		genderSelected = true
		genderBoyImage.setImage(#imageLiteral(resourceName: "Main Boy"), for: .normal)
		genderGirlImage.setImage(#imageLiteral(resourceName: "Check box"), for: .normal)
		let userGender = "girl"
		ref.child("users").child(uid!).child("gender").setValue(userGender)
		if genderSelected == true && matchPreferenceSelected == true {
			performSegue(withIdentifier: "genderEntered", sender: Any?.self)
		}
	}
	
	//MARK: Match Preference Buttons
	@IBAction func matchPreferenceBoy(_ sender: Any) {
		matchPreferenceSelected = true
		matchPreferenceBoyImage.setImage(#imageLiteral(resourceName: "Check box"), for: .normal)
		matchPreferenceGirlImage.setImage(#imageLiteral(resourceName: "Main Girl"), for: .normal)
		matchPreferenceBothImage.setImage(#imageLiteral(resourceName: "Both genders"), for: .normal)
		let userMatchPreference = "boy"
		ref.child("users").child(uid!).child("match preference").setValue(userMatchPreference)
		if genderSelected == true && matchPreferenceSelected == true {
			performSegue(withIdentifier: "genderEntered", sender: Any?.self)
		}
	}
	
	@IBAction func matchPreferenceGirl(_ sender: Any) {
		matchPreferenceSelected = true
		matchPreferenceBoyImage.setImage(#imageLiteral(resourceName: "Main Boy"), for: .normal)
		matchPreferenceGirlImage.setImage(#imageLiteral(resourceName: "Check box"), for: .normal)
		matchPreferenceBothImage.setImage(#imageLiteral(resourceName: "Both genders"), for: .normal)
		let userMatchPreference = "girl"
		ref.child("users").child(uid!).child("match preference").setValue(userMatchPreference)
		if genderSelected == true && matchPreferenceSelected == true {
			performSegue(withIdentifier: "genderEntered", sender: Any?.self)
		}
	}
	
	@IBAction func matchPreferenceBoth(_ sender: Any) {
		matchPreferenceSelected = true
		matchPreferenceBoyImage.setImage(#imageLiteral(resourceName: "Main Boy"), for: .normal)
		matchPreferenceGirlImage.setImage(#imageLiteral(resourceName: "Main Girl"), for: .normal)
		matchPreferenceBothImage.setImage(#imageLiteral(resourceName: "Check box"), for: .normal)
		let userMatchPreference = "both"
		ref.child("users").child(uid!).child("match preference").setValue(userMatchPreference)
		if genderSelected == true && matchPreferenceSelected == true {
			performSegue(withIdentifier: "genderEntered", sender: Any?.self)
		}
	}
}
