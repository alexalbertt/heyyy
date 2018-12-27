//
//  Grade.swift
//  Crush
//
//  Created by Alex Albert on 12/30/17.
//  Copyright © 2017 Alex Albert. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

class Grade: UIViewController {

	let application: UIApplication = UIApplication.shared
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: Grade Picker Button
	@IBAction func gradePicker(gradeButton : UIButton) {
		var grade: String!
		switch gradeButton.tag {
		case 1:
			grade = "9th"
		case 2:
			grade = "10th"
		case 3:
			grade = "11th"
		default:
			grade = "12th"
		}
		ref.child("users").child(uid!).child("grade").setValue(grade)
		performSegue(withIdentifier: "gradeLogged", sender: Any?.self)
		var loggedIn = "true"
		UserDefaults.standard.set(loggedIn, forKey: "loggedIn")
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
			
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {(_,_) in })
			
		}else{
			let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)
		}
		
		application.registerForRemoteNotifications()
	}
}
