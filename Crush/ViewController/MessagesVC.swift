//
//  MessagesVC.swift
//  
//
//  Created by Alex Albert on 1/4/18.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MessageKit
import JSQMessagesViewController
import SDWebImage

struct LatestMessage {
	var text: String!
	var time: String!
	var senderId: String!
	var status: String!
}

class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var matches = [User]()
	var latestMessages = [String:LatestMessage]()
	
	var chatRoomIdentity : String = ""
	var senderDisName : String = ""
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var topView: UIView!
	
	var refreshControl: UIRefreshControl!
	var imageView : UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		self.tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.isHidden = false
		topView.isHidden = false
		observeMatches()
		refreshControl = UIRefreshControl()
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
		tableView.addSubview(refreshControl)
	}
	
	@objc func refresh(sender:AnyObject)
	{
		self.tableView.reloadData()
		self.refreshControl?.endRefreshing()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.isNavigationBarHidden = true
		self.tabBarController?.tabBar.isHidden = false
		observeMatches()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	func assignbackground(background: UIImage){
		imageView = UIImageView(frame: view.bounds)
		imageView.contentMode =  UIViewContentMode.scaleAspectFill
		imageView.clipsToBounds = true
		imageView.image = background
		imageView.center = view.center
		view.addSubview(imageView)
		self.view.sendSubview(toBack: imageView)
	}
	
	func hideBackground(){
		self.imageView.removeFromSuperview()
	}
	
	func observeMatches(){
		ref.child("users").child(uid!).child("matches").observeSingleEvent(of: .value, with: { (snapshot) in
			
			if snapshot.exists(){
				var matchDict = [User]()
				for match in snapshot.children{
					let match = match as? DataSnapshot
					if let matchUID = match?.key {
						ref.child("users").child(matchUID).observeSingleEvent(of: .value, with: { (snap) in
							
							let matchInfo = User(snapshot: snap)
							matchDict.append(matchInfo)
							print("Number of matches to display: \(matchDict.count)")
							self.matches = matchDict
							self.tableView.reloadData()
							self.getMessagePreview()
						})
					}
				}
			}
			
		})
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell") as? MatchCell{
			let matchUser = matches[indexPath.row]
			cell.matchName.text = matchUser.firstName + " " + matchUser.lastName
			cell.layer.backgroundColor = UIColor.clear.cgColor
			cell.separatorInset = UIEdgeInsets.zero
			cell.layoutMargins = UIEdgeInsets.zero
			
			let filteredMessageKey = Array(latestMessages.keys).filter({
				return $0.range(of: matchUser.uid, options: .caseInsensitive) != nil
			}).first
			
			if let filteredMessageKey = filteredMessageKey, let filteredMessage = latestMessages [filteredMessageKey] {
				cell.matchPhoneNumber?.text = filteredMessage.text
				if filteredMessage.status != "read" && filteredMessage.senderId != uid!{
					cell.matchPhoneNumber?.textColor = UIColor.black
				}else{
					cell.matchPhoneNumber?.textColor = UIColor.gray
				}
				cell.matchTimeStamp?.text = filteredMessage.time
				
			}else{
				
				cell.matchPhoneNumber?.textColor = UIColor.black
				cell.matchTimeStamp?.text = "Now"
				cell.matchPhoneNumber?.text = "Start a chat!"
			}
			
			cell.cellView.layer.cornerRadius = 8.0
			
			
			cell.matchImg?.sd_setImage(with: URL(string: matchUser.photoURL), placeholderImage: nil)
			cell.matchImg?.layer.cornerRadius = (cell.matchImg?.frame.height)! / 2
			cell.matchImg?.clipsToBounds = true
			
			return cell
		}else{
			return MatchCell()
		}
	}
	
	func getMessagePreview(){
		if matches.count == 0 { return }
		latestMessages.removeAll()
		ref.child("ChatRooms").observeSingleEvent(of: .value, with: { (snapshot) in
			if snapshot.exists(){
				
				let snapshotDictionary = snapshot.value as! NSDictionary
				
				let filteredKeys = snapshotDictionary.allKeys.filter({
					($0 as! String).range(of: uid!, options: .caseInsensitive) != nil
				})
				
				for key in filteredKeys {
					guard let messagesDictionary = (snapshotDictionary[key] as! NSDictionary)["Messages"] as? NSDictionary else { continue }
					let sortedArray = messagesDictionary.allValues.sorted(by: {
						(($0 as! Dictionary<String, AnyObject>)["time"] as! NSInteger) < (($1 as! Dictionary<String, AnyObject>)["time"] as! NSInteger)})
					if let latestMessageDictionary = (sortedArray.last as? NSDictionary) {
						let time = latestMessageDictionary["time"] as! Double
						let timeNow = Date().timeIntervalSince1970
						let date = timeNow - time
						let timeSince = self.secondsToHours(seconds: Int(date))
						
						
						self.latestMessages[key as! String] = (LatestMessage(text: latestMessageDictionary["text"] as! String, time: timeSince,  senderId: latestMessageDictionary["sender_id"] as! String, status: latestMessageDictionary["sender_id"] as! String))
					}
				}
				self.tableView.reloadData()
			}
		})
	}
	
	func secondsToHours (seconds : Int) -> (String) {
		if seconds < 60 {
			return "Just now"
		}else if seconds >= 60 && seconds < 3600{
			let min = (seconds / 60)
			return "\(min) min ago"
		}else if seconds >= 3600 && seconds < 86400{
			let hrs = seconds / 3600
			return "\(hrs) hrs ago"
		}else{
			let days = seconds / 86400
			return "\(days) days ago"
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int{
		var numOfSections: Int = 0
		if matches.count != 0
		{
			tableView.isHidden = false
			topView.isHidden = false
			tableView.separatorStyle = .singleLine
			numOfSections = 1
			tableView.backgroundColor = UIColor.white
			hideBackground()
			
		}
		else
		{
			assignbackground(background: #imageLiteral(resourceName: "No matches background"))
			tableView.isHidden = true
			topView.isHidden = true
		}
		return numOfSections
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let chatFunctions = ChatFunctions()
		
		ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
			let userOne = User(snapshot: snapshot)
			self.chatRoomIdentity = chatFunctions.startChat(user1: userOne , user2: self.matches[indexPath.row])
			
			Variables.chatRoomID = self.chatRoomIdentity
			Variables.recipientName = self.matches[indexPath.row].firstName
			Variables.recipientUid  = self.matches[indexPath.row].uid
			self.navigationController?.pushViewController(ConvoVC(), animated: true)
		})
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return matches.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	
	
}

