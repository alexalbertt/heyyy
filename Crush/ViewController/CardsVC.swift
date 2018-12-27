//
//  CardsVC.swift
//  Crush
//
//  Created by Alex Albert on 1/1/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import Alamofire
import SAConfettiView
import SDWebImage

class CardsVC: UIViewController {
	
	var activityIndicator = UIActivityIndicatorView()
	
	var membersInSchool = [User]()
	var cardCount = 0
	
	var timer = Timer()
	var hrs = 0
	var min = 0
	var sec = 0
	var milliSecs = 0
	var diffHrs = 0
	var diffMins = 0
	var diffSecs = 0
	var diffMilliSecs = 0
	var oneHour = 3600
	var currentLabelTime = 0
	
	@IBOutlet weak var potentialMatchImage: UIImageView!
	@IBOutlet weak var potentialMatchName: UILabel!
	@IBOutlet weak var potentialMatchGrade: UILabel!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var skipButton: UIButton!
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var openPopUpButton: UIButton!
	@IBOutlet weak var checkBackLabel: UILabel!
	@IBOutlet weak var preferenceImage: UIButton!
	@IBOutlet weak var reportUserButton: UIButton!
	@IBOutlet weak var heyyyLogo: UIImageView!
	
	var useSetUpCard : Bool = true
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	let dispatchGroup = DispatchGroup()

	override func viewDidLoad() {
		super.viewDidLoad()
		timerLabel.isHidden = true
		activityIndicator.center = self.view.center
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = .gray
		self.view.addSubview(activityIndicator)
		
		NotificationCenter.default.addObserver(self, selector: #selector(methodOfRecievedNotification), name:NSNotification.Name(rawValue: "NotificationIdentifier"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: .UIApplicationDidEnterBackground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: .UIApplicationWillEnterForeground, object: nil)
		startUp()
		
		potentialMatchImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		self.potentialMatchImage.layer.cornerRadius = 8.0
		self.potentialMatchImage.clipsToBounds = true
		
		preferenceImage.titleLabel?.textAlignment = .center
	}
	
	@IBAction func preferenceButton(_ sender: Any) {
		
		let actionSheetController = UIAlertController(title: "Select which gender you want to talk to", message: "Gender will switch after the current card set", preferredStyle: .actionSheet)
		
		let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
			print("Cancel")
		}
		
		actionSheetController.addAction(cancelActionButton)
		
		let bothActionButton = UIAlertAction(title: "Both", style: .default) { action -> Void in
			ref.child("users").child(uid!).child("match preference").setValue("both")
			self.observePreference()
		}
		
		let girlActionButton = UIAlertAction(title: "Girls", style: .default) { action -> Void in
			ref.child("users").child(uid!).child("match preference").setValue("girl")
			self.observePreference()
		}
		
		let boyActionButton = UIAlertAction(title: "Boys", style: .default) { action -> Void in
			ref.child("users").child(uid!).child("match preference").setValue("boy")
			self.observePreference()
		}
		
		actionSheetController.addAction(boyActionButton)
		actionSheetController.addAction(girlActionButton)
		actionSheetController.addAction(bothActionButton)
		self.present(actionSheetController, animated: true, completion: nil)
		
	}
	
	func observePreference(){
		ref.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
			let user = User(snapshot: snapshot)
			if  user.matchPreference == "girl"{
				self.preferenceImage.titleLabel?.text! = "🙋‍♀️"
			}else if user.matchPreference == "boy"{
				self.preferenceImage.titleLabel?.text! = "🙋‍♂️"
			}else{
				self.preferenceImage.titleLabel?.text! = "🙋‍♂️🙋‍♀️"
			}
		}
	}
	
	@IBAction func reportUser(_ sender: Any) {
		let actionSheetController = UIAlertController(title: "Are you sure you want to report this user?", message: "We review reports within minutes of them being submitted. If a user has acted inappropriately they will be banned.", preferredStyle: .actionSheet)
		
		let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
			print("Cancel")
		}
		actionSheetController.addAction(cancelActionButton)
		
		let nudeActionButton = UIAlertAction(title: "🔞 Person is nude", style: .default) { action -> Void in
			if self.membersInSchool.count > 1{	ref.child("users").child(self.membersInSchool[self.cardCount].uid).child("reports").child("nude").setValue("true")
				ref.child("reports").child(self.membersInSchool[self.cardCount].uid).child("nude").setValue(true)
			}
			self.cardCount += 1
			if self.useSetUpCard == true{
				self.setUpCard()
			}else{
				self.setUpInviteCard()
			}
			self.reportUserAlert()
		}
		
		let drugsActionButton = UIAlertAction(title: "👊 Person has drugs or weapon", style: .default) { action -> Void in
			if self.membersInSchool.count > 1{	ref.child("users").child(self.membersInSchool[self.cardCount].uid).child("reports").child("drugs").setValue("true")
				ref.child("reports").child(self.membersInSchool[self.cardCount].uid).child("drugs").setValue(true)
			}
			self.cardCount += 1
			if self.useSetUpCard == true{
				self.setUpCard()
			}else{
				self.setUpInviteCard()
			}
			self.reportUserAlert()
		}
		
		let meanActionButton = UIAlertAction(title: "😷 Person is mean or bullying", style: .default) { action -> Void in
			if self.membersInSchool.count > 1{	ref.child("users").child(self.membersInSchool[self.cardCount].uid).child("reports").child("mean").setValue("true")
				ref.child("reports").child(self.membersInSchool[self.cardCount].uid).child("mean").setValue(true)
			}
			self.cardCount += 1
			if self.useSetUpCard == true{
				self.setUpCard()
			}else{
				self.setUpInviteCard()
			}
			self.reportUserAlert()
		}
		
		let fakeActionButton = UIAlertAction(title: "👴 Person has a fake grade/gender", style: .default) { action -> Void in
			if self.membersInSchool.count > 1{	ref.child("users").child(self.membersInSchool[self.cardCount].uid).child("reports").child("fake").setValue("true")
				ref.child("reports").child(self.membersInSchool[self.cardCount].uid).child("fake").setValue(true)
			}
			self.cardCount += 1
			if self.useSetUpCard == true{
				self.setUpCard()
			}else{
				self.setUpInviteCard()
			}
			self.reportUserAlert()
		}
		
		let otherActionButton = UIAlertAction(title: "❓ Other", style: .default) { action -> Void in
			
			if self.membersInSchool.count > 1{	ref.child("users").child(self.membersInSchool[self.cardCount].uid).child("reports").child("other").setValue("true")
			}
			self.cardCount += 1
			if self.useSetUpCard == true{
				self.setUpCard()
			}else{
				self.setUpInviteCard()
			}
			self.reportUserAlert()
		}
		actionSheetController.addAction(fakeActionButton)
		actionSheetController.addAction(nudeActionButton)
		actionSheetController.addAction(drugsActionButton)
		actionSheetController.addAction(meanActionButton)
		actionSheetController.addAction(otherActionButton)
		self.present(actionSheetController, animated: true, completion: nil)
	}
	func reportUserAlert(){
		let alert = UIAlertController(title: "User reported👍", message: "Thank you for reporting users in order to keep heyyy a safe place to hang out and meet new people. Our team will review the profile in question.", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Cool", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	@objc func methodOfRecievedNotification(){
		resetContent()
		cardCount = 0
		membersInSchool = [User]()
		useSetUpCard = false
		fetchPotentialMatches()
		
		
	}
	
	func setUpInviteCard(){
		if cardCount < 3 && cardCount < membersInSchool.count{
			activityIndicator.startAnimating()
			self.view.backgroundColor = UIColor.white
			self.preferenceImage.isHidden = false
			self.reportUserButton.isHidden = false
			self.heyyyLogo.isHidden = true
			self.potentialMatchName.isHidden = false
			self.potentialMatchGrade.isHidden = false
			self.potentialMatchImage.isHidden = false
			self.likeButton.isHidden = false
			self.skipButton.isHidden = false
			
			let potMatchName = membersInSchool[cardCount].firstName!
			potentialMatchName.text! = potMatchName
			let potMatchGrade = membersInSchool[cardCount].grade!
			potentialMatchGrade.text! = potMatchGrade
			let imageURL = URL(string: membersInSchool[cardCount].photoURL)
			self.potentialMatchImage.sd_setImage(with: (imageURL), placeholderImage: nil)
			self.activityIndicator.stopAnimating()

			
		}else if membersInSchool.count > 3 && cardCount == 3{
			print("Please wait an hour or watch an ad")
			assignbackground(background: #imageLiteral(resourceName: "You're out background"))
			startTimer()
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = false
			self.reportUserButton.isHidden = true
			self.potentialMatchName.isHidden = true
			self.potentialMatchGrade.isHidden = true
			self.potentialMatchImage.isHidden = true
			self.likeButton.isHidden = true
			self.skipButton.isHidden = true
			
		}else if membersInSchool.count == 0{
			assignbackground(background: #imageLiteral(resourceName: "No users background"))
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = false
			self.reportUserButton.isHidden = true
			self.potentialMatchName.isHidden = true
			self.potentialMatchGrade.isHidden = true
			self.potentialMatchImage.isHidden = true
			self.likeButton.isHidden = true
			self.skipButton.isHidden = true
		}else{
			assignbackground(background: #imageLiteral(resourceName: "No users background"))
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = false
			self.reportUserButton.isHidden = true
			self.potentialMatchName.isHidden = true
			self.potentialMatchGrade.isHidden = true
			self.potentialMatchImage.isHidden = true
			self.likeButton.isHidden = true
			self.skipButton.isHidden = true
		}
	}
	
	func assignbackground(background: UIImage){
		
		var imageView : UIImageView!
		imageView = UIImageView(frame: view.bounds)
		imageView.contentMode =  UIViewContentMode.scaleAspectFill
		imageView.clipsToBounds = true
		imageView.image = background
		imageView.center = view.center
		view.addSubview(imageView)
		self.view.sendSubview(toBack: imageView)
	}
	
	@IBAction func skip(_ sender: Any) {
		self.cardCount += 1
		if useSetUpCard == true{
			setUpCard()
		}else{
			setUpInviteCard()
		}
		//log skip
	}
	
	@IBAction func like(_ sender: Any) {
		activityIndicator.startAnimating()
		UIApplication.shared.beginIgnoringInteractionEvents()
		print(cardCount)
		if cardCount < membersInSchool.count{
			print("In first if statement")
			let likeDic = true
			ref.child("users").child(uid!).child("likes").child(membersInSchool[cardCount].uid).setValue(likeDic)
			ref.child("users").child(membersInSchool[cardCount].uid).child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
				if snapshot.exists(){
					print("In second if statement")
					for child in snapshot.children {
						let child = child as? DataSnapshot
						if let checkLikes = child?.key {
							if checkLikes == uid!{
								print("You have a match!")
								
								Variables.imageURL = self.membersInSchool[self.cardCount].photoURL
								ref.child("users").child(uid!).child("matches").child(self.membersInSchool[self.cardCount].uid).setValue(true)
								ref.child("users").child(self.membersInSchool[self.cardCount].uid).child("matches").child(uid!).setValue(true)
								
								let storyboard = UIStoryboard(name: "Main", bundle: nil)
								let ivc = storyboard.instantiateViewController(withIdentifier: "matchPopUp")
								ivc.modalTransitionStyle = .crossDissolve
								self.present(ivc, animated: true, completion: nil)
								
								self.cardCount += 1
								self.activityIndicator.stopAnimating()
								UIApplication.shared.endIgnoringInteractionEvents()
								if self.useSetUpCard == true{
									self.setUpCard()
								}else{
									self.setUpInviteCard()
								}
							}
							
						}else{
							print("It didn't work")
							self.cardCount += 1
							self.activityIndicator.stopAnimating()
							UIApplication.shared.endIgnoringInteractionEvents()
							if self.useSetUpCard == true{
								self.setUpCard()
							}else{
								self.setUpInviteCard()
							}
						}
					}
					print("User is not in likes")
					self.cardCount += 1
					self.activityIndicator.stopAnimating()
					UIApplication.shared.endIgnoringInteractionEvents()
					if self.useSetUpCard == true{
						self.setUpCard()
					}else{
						self.setUpInviteCard()
					}
					
				}else{
					print("Path does not exist")
					self.cardCount += 1
					self.activityIndicator.stopAnimating()
					UIApplication.shared.endIgnoringInteractionEvents()
					if self.useSetUpCard == true{
						self.setUpCard()
					}else{
						self.setUpInviteCard()
					}
				}
			})
		}else{
			print("Nope")
			self.cardCount += 1
			self.activityIndicator.stopAnimating()
			UIApplication.shared.endIgnoringInteractionEvents()
			if useSetUpCard == true{
				setUpCard()
			}else{
				setUpInviteCard()
			}
		}
	}
	
	func setPotentialMatchImageFor(_ userMatch: String) {
		switch userMatch {
		case "girl":
			self.preferenceImage.titleLabel?.text! = "🙋‍♀️"
		case "boy":
			self.preferenceImage.titleLabel?.text! = "🙋‍♂️"
		default:
			self.preferenceImage.titleLabel?.text! = "🙋‍♂️🙋‍♀️"
		}
	}
	
	func fetchPotentialMatches(){
		self.potentialMatchName.isHidden = true
		self.potentialMatchGrade.isHidden = true
		self.potentialMatchImage.isHidden = true
		self.likeButton.isHidden = true
		self.skipButton.isHidden = true
		
		ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
			let user = User(snapshot: snapshot)
			
			let currentUserMatch = user.matchPreference!
			self.setPotentialMatchImageFor(currentUserMatch)
			
			let currentUserSchool = user.highSchool!
			

			ref.child("schools").child(currentUserSchool).child("members").observeSingleEvent(of: .value , with: { (snapshot) in
				var arrayIndexCount = 0
				var otherUsersUIDS = [String]()
				
				for school in user.schoolsFollowed{
					ref.child("schools").child(school).child("members").observeSingleEvent(of: .value, with: {(snap) in
						for child in snap.children {
							let child = child as? DataSnapshot
							if let otherUser = child?.key {
								otherUsersUIDS.append(otherUser)
							}
						}
					})
				}
				
				for child in snapshot.children {
					let child = child as? DataSnapshot
					if let otherUser = child?.key {
						otherUsersUIDS.append(otherUser)
					}
				}
				otherUsersUIDS.shuffle()

				for otherUser in otherUsersUIDS{
					if !user.likesFormatted.contains(otherUser) && otherUser != uid! {
						ref.child("users").child(otherUser).observeSingleEvent(of: .value, with: { (snap) in
							let otherU = User(snapshot: snap)
							if (otherU.gender == currentUserMatch) || ("both" == currentUserMatch){
								self.membersInSchool.insert(otherU, at: arrayIndexCount)
								print(otherU.firstName! + " " + otherU.lastName! + " " + "\(arrayIndexCount)")
								arrayIndexCount += 1
								if self.useSetUpCard == true{
									self.setUpCard()
								}else{
									self.setUpInviteCard()
								}
							}else{
								print("\(otherU.firstName) is not appended")
							}
						})
					}
				}
			})
			
		}){(error) in
			print(error.localizedDescription)
		}
	}
	
	func setUpCard(){
		if cardCount < 6 && cardCount < membersInSchool.count{
			activityIndicator.startAnimating()
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = true
			self.reportUserButton.isHidden = false
			self.potentialMatchName.isHidden = false
			self.potentialMatchGrade.isHidden = false
			self.potentialMatchImage.isHidden = false
			self.likeButton.isHidden = false
			self.skipButton.isHidden = false
			let potMatchName = membersInSchool[cardCount].firstName!
			potentialMatchName.text! = potMatchName
			let potMatchGrade = membersInSchool[cardCount].grade!
			potentialMatchGrade.text! = potMatchGrade
			let imageURL = URL(string: membersInSchool[cardCount].photoURL)
			self.potentialMatchImage.sd_setImage(with: (imageURL), placeholderImage: nil)
			self.activityIndicator.stopAnimating()

			
		}else if membersInSchool.count > 7 && cardCount == 6{
			print("Please wait an hour or watch an ad")
			assignbackground(background: #imageLiteral(resourceName: "You're out background"))
			startTimer()
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = false
			self.reportUserButton.isHidden = true
			self.potentialMatchName.isHidden = true
			self.potentialMatchGrade.isHidden = true
			self.potentialMatchImage.isHidden = true
			self.likeButton.isHidden = true
			self.skipButton.isHidden = true
			
		}else if membersInSchool.count == 0{
			assignbackground(background: #imageLiteral(resourceName: "No users background"))
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = false
			self.reportUserButton.isHidden = true
			self.potentialMatchName.isHidden = true
			self.potentialMatchGrade.isHidden = true
			self.potentialMatchImage.isHidden = true
			self.likeButton.isHidden = true
			self.skipButton.isHidden = true
		}else{
			assignbackground(background: #imageLiteral(resourceName: "No users background"))
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = false
			self.reportUserButton.isHidden = true
			self.potentialMatchName.isHidden = true
			self.potentialMatchGrade.isHidden = true
			self.potentialMatchImage.isHidden = true
			self.likeButton.isHidden = true
			self.skipButton.isHidden = true
		}
	}
	
	//MARK: Timer
	func startTimer (){
		self.oneHour = 3600
		self.resetContent()
		self.timerLabel.isHidden = false
		self.openPopUpButton.isHidden = false
		self.checkBackLabel.isHidden = false
		self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(CardsVC.updateLabels(t:))), userInfo: nil, repeats: true)
	}
	
	@objc func pauseWhenBackground(noti: Notification) {
		self.timer.invalidate()
		let shared = UserDefaults.standard
		shared.set(Date(), forKey: "savedTime")
		shared.set(currentLabelTime, forKey: "currentLabelTime")
	}
	
	@objc func willEnterForeground(noti: Notification) {
		startUp()
	}
	
	func startUp(){
		activityIndicator.startAnimating()
		self.preferenceImage.isHidden = false
		self.heyyyLogo.isHidden = true
		self.reportUserButton.isHidden = false
		timerLabel.isHidden = true
		openPopUpButton.isHidden = true
		checkBackLabel.isHidden = true
		if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
			timerLabel.isHidden = false
			openPopUpButton.isHidden = false
			checkBackLabel.isHidden = false
			(diffHrs, diffMins, diffSecs) = CardsVC.getTimeDifference(startDate: savedDate)
			print("Enter foreground Saved date: \(savedDate)")
			self.refresh(hours: diffHrs, mins: diffMins, secs: diffSecs)
			print(diffHrs, diffMins, diffSecs)
			removeSavedDate()
			activityIndicator.stopAnimating()
		}else{
			resetContent()
			
			self.view.backgroundColor = UIColor.white
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = true
			self.reportUserButton.isHidden = false
			self.cardCount = 0
			self.membersInSchool = [User]()
			fetchPotentialMatches()
			useSetUpCard = true
			activityIndicator.stopAnimating()
		}
	}
	
	func resetContent() {
		removeSavedDate()
		timerLabel.isHidden = true
		openPopUpButton.isHidden = true
		checkBackLabel.isHidden = true
		timer.invalidate()
		timerLabel.text = "00 : 00 : 00"
	}
	
	@objc func updateLabels(t: Timer) {
		self.oneHour -= 1
		self.sec = self.oneHour % 60
		self.min = self.oneHour / 60 % 60
		self.hrs = self.oneHour / 3600
		
		if self.sec <= 0 && self.min <= 0 && self.hrs <= 0 {
			resetContent()
			
			self.view.backgroundColor = UIColor.white
			self.timerLabel.isHidden = true
			self.openPopUpButton.isHidden = true
			checkBackLabel.isHidden = true
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = true
			self.reportUserButton.isHidden = false
			self.cardCount = 0
			self.membersInSchool = [User]()
			fetchPotentialMatches()
			useSetUpCard = true
		}else{
			assignbackground(background: #imageLiteral(resourceName: "You're out background"))
			self.preferenceImage.isHidden = false
			self.heyyyLogo.isHidden = false
			self.reportUserButton.isHidden = true
			self.potentialMatchName.isHidden = true
			self.potentialMatchGrade.isHidden = true
			self.potentialMatchImage.isHidden = true
			self.likeButton.isHidden = true
			self.skipButton.isHidden = true
		}
		
		self.timerLabel.text = String(format: "%02d : %02d : %02d", self.hrs, self.min, self.sec)
		currentLabelTime = (self.min * 60) + self.sec
	}
	
	static func getTimeDifference(startDate: Date) -> (Int, Int, Int) {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
		return(components.hour!, components.minute!, components.second!)
	}
	
	func refresh (hours: Int, mins: Int, secs: Int) {
		if let previousLabelTime = UserDefaults.standard.object(forKey: "currentLabelTime") as? Int{
			let totalDiffInSecs = (hours * 3600) + (mins * 60) + secs
			oneHour = previousLabelTime - totalDiffInSecs
			
			
			//self.hrs -= hours
			//self.min -= mins
			//self.sec -= secs
			//self.oneHour -= secs
			//previousLabelTime = 3600 - previousLabelTime
			//self.oneHour -= previousLabelTime
			
		}else{
			let totalDiffInSecs = (hours * 3600) + (mins * 60) + secs
			oneHour = 3600 - totalDiffInSecs
			//self.hrs -= hours
			//self.min -= mins
			//self.sec -= secs
			//self.oneHour -= secs
		}
		//self.timerLabel.text = String(format: "%02d : %02d : %02d", self.hrs, self.min, self.sec)
		self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(CardsVC.updateLabels(t:))), userInfo: nil, repeats: true)
		
	}
	
	func removeSavedDate() {
		if (UserDefaults.standard.object(forKey: "savedTime") as? Date) != nil {
			UserDefaults.standard.removeObject(forKey: "savedTime")
			UserDefaults.standard.removeObject(forKey: "currentLabelTime")
		}
	}
	
	
}

extension MutableCollection {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
}

