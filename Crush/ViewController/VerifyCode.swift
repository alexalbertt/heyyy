//
//  VerifyCode.swift
//  Crush
//
//  Created by Alex Albert on 3/18/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class VerifyCode: UIViewController {

	
	
	@IBOutlet weak var code: UITextField!
	@IBOutlet weak var verifyCodeImage: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		verifyCodeImage.isEnabled = false
		verifyCodeImage.setImage(#imageLiteral(resourceName: "Unselected next"), for: .normal)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	let phoneNum = UserDefaults.standard.string(forKey: "phoneNumber")
	let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
	
	func postToken(Token: [String: AnyObject]){
		print("FCM Token: \(Token)")
		ref.child("fcmToken").child(Messaging.messaging().fcmToken!).setValue(Token)
		ref.child("users").child(uid!).child("fcmToken").child(Messaging.messaging().fcmToken!).setValue(Token)
	}
	
	@IBAction func textFieldDidChange(_ sender: Any) {
		if code.text != nil && code.text != ""{
			verifyCodeImage.setImage(#imageLiteral(resourceName: "Selected next"), for: .normal)
			verifyCodeImage.isEnabled = true
		}else{
			verifyCodeImage.isEnabled = false
			verifyCodeImage.setImage(#imageLiteral(resourceName: "Unselected next"), for: .normal)
		}
	}
	
	@IBAction func verifyCode(_ sender: Any) {
		let credential = PhoneAuthProvider.provider().credential(
			withVerificationID: verificationID!,
			verificationCode: code.text!)
		Auth.auth().signIn(with: credential) { (user, error) in
			
			if let error = error {
				
				let invalidCodeAlert = UIAlertController(title: "The code entered is incorrect", message: "Please input the correct code", preferredStyle: .alert)
				
				invalidCodeAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
				
				self.present(invalidCodeAlert, animated: true)
				print(error)
				return
			}
			
			let token : [String: AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
			
			let userId = uid ?? user?.uid
			
			if userId != nil{
				var loggedIn = "true"
				UserDefaults.standard.set(loggedIn, forKey: "loggedIn")
				
				ref.child("users").child(userId!).child("grade").observeSingleEvent(of: .value, with: { (snapshot) in
					if snapshot.exists(){
						print("User is being signed in")
						var loggedIn = "true"
						UserDefaults.standard.set(loggedIn, forKey: "loggedIn")
						self.postToken(Token: token)
						self.performSegue(withIdentifier: "proceed", sender: self)
					}else{
						self.postToken(Token: token)
						ref.child("users").child(userId!).child("phone number").setValue(self.phoneNum!)
						self.performSegue(withIdentifier: "accountCreated", sender: self)
					}
				})
			}
		}
		
		
	}
	

}
