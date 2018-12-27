//
//  invitePopUp.swift
//  Crush
//
//  Created by Alex Albert on 2/17/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import Alamofire

class invitePopup: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

	var cards = CardsVC()
	let cardsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardsVC")
	var phoneNumbersArray = [String]()
	var contactStore = CNContactStore()
	var contacts = [ContactStruct]()
	let sections : [String] = ["Contacts on Crush", "From School", "Contacts to Invite"]
	var contactsOnApp = [User]()
	var usersInSchool = [User]()
	var extraPhoneNumbers = [User]()
	var sectionData: [Int: [AnyObject]] = [:]
	
	
	@IBOutlet weak var invitePopUp: UIView!
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var searchBar: UISearchBar!
	var filteredData = [ContactStruct]()
	var isSearching = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		contactStore.requestAccess(for: .contacts) { (success, error) in
			if success{
				print("Contact Authorization Successful")
				self.tableView.delegate = self
				self.tableView.dataSource = self
				
				self.fetchContacts()
				self.getAllUsers()
			}
		}
		searchBar.delegate = self
		searchBar.returnKeyType = UIReturnKeyType.done

		invitePopUp.layer.cornerRadius = 15
		invitePopUp.layer.masksToBounds = true
    }
	
	override func viewDidAppear(_ animated: Bool) {
		tableView.reloadData()
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//MARK: Invite Popup
	
	
	func fetchContacts(){
		let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
		let request = CNContactFetchRequest(keysToFetch: key)
		try! contactStore.enumerateContacts(with: request) { (contact, stoppingPointer) in
			let name = contact.givenName
			let familyName = contact.familyName
			let fullName = contact.givenName + contact.familyName
			let number = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
			let contactImage = contact.imageData
			
			self.phoneNumbersArray.append(number)
			
			let contactToAppend = ContactStruct(givenName: name, familyName: familyName, fullName: fullName, phoneNumber: number, contactImage: contactImage)
			
			self.contacts.append(contactToAppend)
		}
	}
	
	
	func getAllUsers(){
		self.sectionData = [0: self.contactsOnApp as Array<AnyObject>, 1: self.usersInSchool as Array<AnyObject>, 2: self.contacts as Array<AnyObject>]
		ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
			let user = User(snapshot: snapshot)
			let currentUserSchool = user.highSchool!
			print(user.invitesFormatted)
			for child in user.invitesFormatted {
				let checkInvites = child
				if let alreadyInvited = self.contacts.index(where: {$0.phoneNumber == checkInvites}){
					self.contacts.remove(at: alreadyInvited)
					self.sectionData = [0: self.contactsOnApp as Array<AnyObject>, 1: self.usersInSchool as Array<AnyObject>, 2: self.contacts as Array<AnyObject>]
					self.tableView.reloadData()
					print("Table loaded")
				}
			}
			
			ref.child("schools").child(currentUserSchool).child("members").observeSingleEvent(of: .value, with: { (snap) in
				
				for child in snap.children{
					
					let child = child as? DataSnapshot
					if let otherUsers = child?.key {
						ref.child("users").child(otherUsers).observeSingleEvent(of: .value, with: { (snappy) in
							let personInSchool = User(snapshot: snappy)
							print(personInSchool.phoneNumber)
							if personInSchool.uid != uid! && self.phoneNumbersArray.contains(personInSchool.phoneNumber) {
								//If contacts does have user
								self.contactsOnApp.append(personInSchool)
								
								if let itemToRemoveIndex = self.contacts.index(where: {$0.phoneNumber == personInSchool.phoneNumber}) {
									self.contacts.remove(at: itemToRemoveIndex)
								}
								
								
								
							}else if personInSchool.uid != uid! {
								//If contacts doesn't have user
								self.usersInSchool.append(personInSchool)
								print("Added")
								
							}
							self.sectionData = [0: self.contactsOnApp as Array<AnyObject>, 1: self.usersInSchool as Array<AnyObject>, 2: self.contacts as Array<AnyObject>]
							self.tableView.reloadData()
							
						})
					}
					
					
				}
			})
		})
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[2]
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isSearching {
			return filteredData.count
		}
		
		return contacts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "InvitePopUpCell") as! InvitePopUpCell
		
		if isSearching {
			cell.contactNameLabel.text! = filteredData[indexPath.row].givenName + " " + filteredData[indexPath.row].familyName
		}else{
		cell.contactNameLabel.text! = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
		}
		
		
		cell.contactInviteButton.isHidden = false
		//	cell.contactCellImage.image = UIImage(data: contacts[indexPath.row].contactImage!)
		
		cell.contactInviteButton.tag = indexPath.row
		cell.contactInviteButton.addTarget(self, action: #selector(sendInvite(sender:)), for: .touchUpInside)
		
		
		return cell
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchBar.text == nil || searchBar.text == "" {
			isSearching = false
			tableView.reloadData()
		}else{
			isSearching = true
			
			filteredData = contacts.filter({contact -> Bool in
				
				contact.fullName.contains(searchText)
				
			})
			
			tableView.reloadData()
		}
	}
	
	@IBAction func sendInvite(sender: UIButton){
		//Implement something that takes person out of contacts after invite
		print("Button tapped")
		dismiss(animated: true, completion: nil)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationIdentifier"), object: nil)
		let numberToSendSMS = contacts[sender.tag].phoneNumber
		print(numberToSendSMS)
		ref.child("users").child(uid!).child("invites").child("\(numberToSendSMS)").setValue(true)
		
		let headers = ["Content-Type": "application/x-www-form-urlencoded"]
		let parameters: Parameters = ["To": numberToSendSMS,"Body":  "Someone from your school likes you😏. Download heyyy to see who it is: https://itunes.com/app/heyyy-make-friends-in-school"]
		Alamofire.request("https://rebel-library-7451.twil.io/sms", method: .post, parameters: parameters, headers: headers).response { response in print(response)}

	}
	@IBAction func closePopUp(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
}
