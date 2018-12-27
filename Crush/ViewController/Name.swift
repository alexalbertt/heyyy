//
//  Name.swift
//  Crush
//
//  Created by Alex Albert on 12/28/17.
//  Copyright © 2017 Alex Albert. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

var ref: DatabaseReference! = Database.database().reference()
var storageRef = Storage.storage().reference()
let uid = Auth.auth().currentUser?.uid

class Name: UIViewController {
	
	//MARK: Properties
	@IBOutlet weak var firstName: UITextField?
	@IBOutlet weak var lastName: UITextField?
	@IBOutlet weak var logFirstNameImage: UIButton?
	@IBOutlet weak var logLastNameImage: UIButton?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		logFirstNameImage?.isEnabled = false
		logFirstNameImage?.setImage(#imageLiteral(resourceName: "Unselected next"), for: .normal)
		
		logLastNameImage?.isEnabled = false
		logLastNameImage?.setImage(#imageLiteral(resourceName: "Unselected next"), for: .normal)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	@IBAction func textFieldDidChange(_ sender: Any) {
		if firstName?.text != nil && firstName?.text != ""{
			logFirstNameImage?.setImage(#imageLiteral(resourceName: "Selected next"), for: .normal)
			logFirstNameImage?.isEnabled = true
		}else{
			logFirstNameImage?.isEnabled = false
			logFirstNameImage?.setImage(#imageLiteral(resourceName: "Unselected next"), for: .normal)
		}
	}
	
	@IBAction func lastNameTextFieldDidChange(_ sender: Any) {
		if lastName?.text != nil && lastName?.text != ""{
			logLastNameImage?.setImage(#imageLiteral(resourceName: "Selected next"), for: .normal)
			logLastNameImage?.isEnabled = true
		}else{
			logLastNameImage?.isEnabled = false
			logLastNameImage?.setImage(#imageLiteral(resourceName: "Unselected next"), for: .normal)
		}
		
	}
	
	
	//MARK: Log user first name
	@IBAction func logFirstName(_ sender: Any) {
		if firstName?.text != ""{
			let userFirstName = firstName!.text
			let currentUid = uid!
			ref.child("users").child(uid!).child("first name").setValue(userFirstName)
			ref.child("users").child(uid!).child("uid").setValue(currentUid)
			performSegue(withIdentifier: "firstNameEntered", sender: Any?.self)
		}else{
			print("Alert: please use your real name")
			let realNameAlert = UIAlertController(title: "Please use your real name", message: "It's required that you use your real name.", preferredStyle: .alert)
			
			realNameAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
			
			self.present(realNameAlert, animated: true)
		}
	}
	
	//MARK: Log user last name and full name
	@IBAction func logLastName(_ sender: Any) {
		if lastName?.text != "" {
			let userLastName = lastName!.text
			//let userFullName =  userFirstName + userLastName
			ref.child("users").child(uid!).child("last name").setValue(userLastName)
			//ref.child("users").child(uid!).child("full name").setValue(userFullName)
			performSegue(withIdentifier: "lastNameEntered", sender: Any?.self)
		}else{
			print("Alert: please use your real name")
			let realNameAlert = UIAlertController(title: "Please use your real name", message: "It's required that you use your real name.", preferredStyle: .alert)
			
			realNameAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
			
			self.present(realNameAlert, animated: true)
		}
	}
	
}
