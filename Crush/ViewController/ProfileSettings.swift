//
//  ProfileSettings.swift
//  Crush
//
//  Created by Alex Albert on 2/17/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit

class ProfileSettings: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func closeSettings(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func signOut(_ sender: Any) {

		
		let signOutAlert = UIAlertController(title: "Are you sure you want to sign out?", message: nil, preferredStyle: .alert)
		
		let signOutAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){
			UIAlertAction in

			print("Signing out")
			self.performSegue(withIdentifier: "signingOut", sender: Any?.self)
			var loggedIn = "false"
			UserDefaults.standard.set(loggedIn, forKey: "loggedIn")
		}
		
		let noSignOutAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel){
			UIAlertAction in
		}
		signOutAlert.addAction(noSignOutAction)
		signOutAlert.addAction(signOutAction)
		self.present(signOutAlert, animated: true)
		
	}
	@IBAction func deactivateAccount(_ sender: Any) {
		let deactivateAlert = UIAlertController(title: "Are you sure you want to deactivate your account?", message: nil, preferredStyle: .alert)
		
		let deactivateAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){
			UIAlertAction in
			
			print("Signing out")
			self.performSegue(withIdentifier: "signingOut", sender: Any?.self)
			var loggedIn = "false"
			UserDefaults.standard.set(loggedIn, forKey: "false")
		}
		let noSignOutAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel){
			UIAlertAction in
		}
		deactivateAlert.addAction(noSignOutAction)
		deactivateAlert.addAction(deactivateAction)
		self.present(deactivateAlert, animated: true)
	}
	
}
