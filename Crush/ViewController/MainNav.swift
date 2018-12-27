//
//  MainNav.swift
//  Crush
//
//  Created by Alex Albert on 3/18/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import Firebase

class MainNav: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
		checkReachability()
		
		if Auth.auth().currentUser?.uid != nil{
			ref.child("users").child("\(Auth.auth().currentUser!.uid)").child("grade").observeSingleEvent(of: .value, with: { (snapshot) in
				if snapshot.exists(){
					self.signedIn()
				}else{
					return
				}
			})
			
		}
		
    }

	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		checkReachability()
		
		if let savedValue = UserDefaults.standard.string(forKey: "loggedIn") {
			if savedValue == "true"{
				self.signedIn()
			}else{
				return
			}
		}else{
			return
		}
		/*if Auth.auth().currentUser?.uid != nil{
			ref.child("users").child("\(Auth.auth().currentUser!.uid)").child("grade").observeSingleEvent(of: .value, with: { (snapshot) in
				if snapshot.exists(){
					self.signedIn()
				}else{
					return
				}
			})
			
		}*/
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	func signedIn(){
		performSegue(withIdentifier: "signedIn", sender: Any?.self)
		var loggedIn = "true"
		UserDefaults.standard.set(loggedIn, forKey: "loggedIn")
	}
	func checkReachability(){
		if currentReachabilityStatus == .reachableViaWiFi {
			print("User is connected to the internet via wifi.")
		}else if currentReachabilityStatus == .reachableViaWWAN{
			print("User is connected to the internet via WWAN.")
		} else {
			print("There is no internet connection")
			let alert = UIAlertController(title: "Check Internet Connection", message: "You are not connected to the internet so features will not load.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}

}
