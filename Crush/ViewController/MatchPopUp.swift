//
//  MatchPopUp.swift
//  Crush
//
//  Created by Alex Albert on 4/7/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import Firebase
import SAConfettiView

class MatchPopUp: UIViewController {

	var imageURL = Variables.imageURL

	@IBOutlet weak var userImage: UIImageView!
	@IBOutlet weak var matchImage: UIImageView!
	@IBOutlet weak var matchView: UIView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let confetti = SAConfettiView(frame: self.view.bounds)
		self.view.addSubview(confetti)
		self.view.sendSubview(toBack: confetti)
		
		confetti.startConfetti()
		userImage.layer.cornerRadius = userImage.frame.height / 2
		matchImage.layer.cornerRadius = matchImage.frame.height / 2
		userImage.clipsToBounds = true
		matchImage.clipsToBounds = true
		matchView.layer.cornerRadius = 8
		matchView.clipsToBounds = true
		getProfilePics()
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
			confetti.stopConfetti()
		})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

	@IBAction func startChat(_ sender: Any) {
		let tabBarController = self.tabBarController
		print("Button tapped")
		// pop to root vc
		//_ = self.navigationController?.popToRootViewController(animated: false)
		dismiss(animated: true, completion: nil)
		// switch to 2nd tab
		tabBarController?.selectedIndex = 1
	}
	
	func getProfilePics(){
		
		Storage.storage().reference(forURL: imageURL!).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
			if error == nil{
				if let data = imgData {
					self.matchImage.image = UIImage(data: data)
				}
			}else{
				print(error!.localizedDescription)
			}
		})
		
		let userRef = ref.child("users").child(uid!)
		userRef.observeSingleEvent(of: .value, with: { (snapshot) in
			let user = User(snapshot: snapshot)
			
			let userImageURL = user.photoURL
			
			Storage.storage().reference(forURL: userImageURL!).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
				if error == nil{
					if let data = imgData {
						self.userImage.image = UIImage(data: data)
					}
				}else{
					print(error!.localizedDescription)
				}
			})
			
		}){(error) in
			print(error.localizedDescription)
		}
	}
}
