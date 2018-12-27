//
//  PhoneVerification.swift
//  Crush
//
//  Created by Alex Albert on 12/27/17.
//  Copyright © 2017 Alex Albert. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class PhoneVerification: UIViewController{
	
	//MARK: Properties
	@IBOutlet weak var phoneNumber: UITextField!
	@IBOutlet weak var sendCodeImage: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sendCodeImage.isEnabled = false
		sendCodeImage.setImage(#imageLiteral(resourceName: "Send code unselected"), for: .normal)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	//MARK: Format phone text field
	var phoneFormatter = PhoneNumberFormatter()
	@IBAction func formatPhoneNumber(_ sender: UITextField) {
		sender.text = phoneFormatter.format(sender.text!, hash: sender.hash)
	}
	
	
	@IBAction func textFieldDidChange(_ sender: Any) {
		if phoneNumber.text != nil && phoneNumber.text != ""{
			sendCodeImage.setImage(#imageLiteral(resourceName: "Send code selected"), for: .normal)
			sendCodeImage.isEnabled = true
		}else{
			sendCodeImage.isEnabled = false
			sendCodeImage.setImage(#imageLiteral(resourceName: "Send code unselected"), for: .normal)
		}
	}
	
	
	//MARK: When send secret code button is pressed
	
	@IBAction func sendCode(_ sender: Any) {
		
		
		
		let submitPhoneNumber = "+1" + phoneNumber.text!
		if submitPhoneNumber.count > 9{
			PhoneAuthProvider.provider().verifyPhoneNumber(submitPhoneNumber, uiDelegate: nil) {(verificationID, error) in
				if error != nil {
					print(error!)
				}else{
					UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
					UserDefaults.standard.set(self.phoneNumber.text!, forKey: "phoneNumber")
					self.performSegue(withIdentifier: "phoneCode", sender: self)
				}
			}
		}else{
			let phoneNumAlert = UIAlertController(title: "Please enter your phone number", message: "You must enter your phone number to continue.", preferredStyle: .alert)
			
			phoneNumAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
			
			self.present(phoneNumAlert, animated: true)
		}
	}
	
	
}
