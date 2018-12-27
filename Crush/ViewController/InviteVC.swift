//
//  InviteVC.swift
//  Crush
//
//  Created by Alex Albert on 1/4/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import Contacts
import Firebase
import Alamofire
import SDWebImage

class InviteVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

	@IBOutlet weak var tableView: UITableView!
	
	var activityIndicator = UIActivityIndicatorView()
	
	let sections : [String] = ["Contacts on heyyy", "From School", "Contacts to Invite"]
	var contactsOnApp = [User]()
	var usersInSchool = [User]()
	var extraPhoneNumbers = [User]()
	
	
	var phoneNumbersArray = [String]()
	var contactStore = CNContactStore()
	var contacts = [ContactStruct]()
	
	
	var sectionData: [Int: [AnyObject]] = [:]
	
	
	@IBOutlet weak var searchBar: UISearchBar!
	var filteredData: [Int: [AnyObject]] = [:]
	var filteredContactsData = [ContactStruct]()
	var filteredContactsOnAppData = [User]()
	var filteredUsersInSchoolData = [User]()
	var isSearching = false
	
	var refreshControl: UIRefreshControl!
	override func viewDidLoad() {
        super.viewDidLoad()
		activityIndicator.startAnimating()
		contactStore.requestAccess(for: .contacts) { (success, error) in
			if success{
				print("Contact Authorization Successful")
				self.fetchContacts()
				
				DispatchQueue.main.async {
					
					self.tableView.delegate = self
					self.tableView.dataSource = self
				}
				
			}else{
				let alert = UIAlertController(title: "Please let heyyy access your contacts", message: "In order to view people in your school and to invite contacts, heyyy needs to be able to access your contacts. You can change this in settings.", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
		}
		searchBar.delegate = self
		searchBar.returnKeyType = UIReturnKeyType.done
		
		refreshControl = UIRefreshControl()
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
		tableView.addSubview(refreshControl)
		activityIndicator.stopAnimating()
    }
	@objc func refresh(sender:AnyObject)
	{
		// Updating your data here...
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
			self.tableView.reloadData()
		}
		self.refreshControl?.endRefreshing()
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func fetchContacts(){
		contacts = [ContactStruct]()
		let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
		let request = CNContactFetchRequest(keysToFetch: key)
		try! contactStore.enumerateContacts(with: request) { (contact, stoppingPointer) in
			let name = contact.givenName
			let familyName = contact.familyName
			let fullName = contact.givenName + contact.familyName
			let number = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
			let contactImage = contact.imageData

			
			let contactToAppend = ContactStruct(givenName: name, familyName: familyName, fullName: fullName, phoneNumber: number, contactImage: contactImage)
			
			self.contacts.append(contactToAppend)
		}
		print("Contacts fetching done. Getting all users.")
		getAllUsers()
	}
	
	
	func getAllUsers(){
		print("Getting all users")
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
	
	func checkInvites(){
		ref.child("users").child(uid!).child("invites").observeSingleEvent(of: .value, with: { (snappy) in
			if snappy.exists(){
				for child in snappy.children {
					let child = child as? DataSnapshot
					if let checkInvites = child?.key {
						if let alreadyInvited = self.contacts.index(where: {$0.phoneNumber == checkInvites}){
							self.contacts.remove(at: alreadyInvited)
							self.sectionData = [0: self.contactsOnApp as Array<AnyObject>, 1: self.usersInSchool as Array<AnyObject>, 2: self.contacts as Array<AnyObject>]
							self.tableView.reloadData()
							print("Table loaded")
						}
					}
				}
			}else{

				self.sectionData = [0: self.contactsOnApp as Array<AnyObject>, 1: self.usersInSchool as Array<AnyObject>, 2: self.contacts as Array<AnyObject>]
				self.tableView.reloadData()
			}
		})
	}

	
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section]
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if isSearching {
			return (filteredData[section]!.count)
		}
		
		return (sectionData[section]!.count)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell") as! InviteCell
		var img = ""
		let whiteImage = UIImage(color: .white)
		cell.contactCellImage.image = whiteImage
		cell.contactCellImage.layer.cornerRadius = cell.contactCellImage.frame.height/2
		cell.contactCellImage.clipsToBounds = true
		if indexPath.section == 0{
			if isSearching{
				cell.nameLabel.text! = filteredContactsOnAppData[indexPath.row].firstName + " " + filteredContactsOnAppData[indexPath.row].lastName
				img = filteredContactsOnAppData[indexPath.row].photoURL
			}else{
				cell.nameLabel.text! = contactsOnApp[indexPath.row].firstName + " " +
				contactsOnApp[indexPath.row].lastName
				img = contactsOnApp[indexPath.row].photoURL
			}
			cell.sendInviteButton.isHidden = true
		}else if indexPath.section == 1{
			if isSearching{
				cell.nameLabel.text! = filteredUsersInSchoolData[indexPath.row].firstName + " " + filteredUsersInSchoolData[indexPath.row].lastName
				 img = filteredUsersInSchoolData[indexPath.row].photoURL
			}else{
				cell.nameLabel.text! = usersInSchool[indexPath.row].firstName + " " + usersInSchool[indexPath.row].lastName
				img = usersInSchool[indexPath.row].photoURL
			}
			cell.sendInviteButton.isHidden = true
		}else if indexPath.section == 2{
			if isSearching{
				cell.nameLabel.text! = filteredContactsData[indexPath.row].givenName + " " + filteredContactsData[indexPath.row].familyName
			}else{
				cell.nameLabel.text! = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
			}
			
			cell.sendInviteButton.isHidden = false
		}
		if img != ""{
		let imageURL = URL(string: img)
		cell.contactCellImage.sd_setImage(with: (imageURL), placeholderImage: nil)
		cell.contactCellImage.layer.cornerRadius = cell.contactCellImage.frame.height/2
		cell.contactCellImage.clipsToBounds = true

			
	}
		
		
		cell.sendInviteButton.tag = indexPath.row
		cell.sendInviteButton.addTarget(self, action: #selector(sendInvite(sender:)), for: .touchUpInside)
		
		
		return cell
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int{
		return sections.count
	}
	
	
	@IBAction func sendInvite(sender: UIButton){
		print("Button tapped")
		
		let numberToSendSMS = contacts[sender.tag].phoneNumber
		print(numberToSendSMS)
		ref.child("users").child(uid!).child("invites").child("\(numberToSendSMS)").setValue(true)
		let headers = ["Content-Type": "application/x-www-form-urlencoded"]
		let parameters: Parameters = ["To": numberToSendSMS,"Body":  "Someone from your school likes you😏. Download heyyy to see who it is: https://itunes.com/app/heyyy-make-friends-in-school"]
		Alamofire.request("https://rebel-library-7451.twil.io/sms", method: .post, parameters: parameters, headers: headers).response { response in print(response)}
		sectionData = [:]
		contactsOnApp = [User]()
		usersInSchool = [User]()
		extraPhoneNumbers = [User]()
		getAllUsers()
		//checkInvites()
	}
	
	
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchBar.text == nil || searchBar.text == "" {
			isSearching = false
			
			/*sectionData = [:]
			contactsOnApp = [User]()
			usersInSchool = [User]()
			extraPhoneNumbers = [User]()
			
			

			getAllUsers()*/
			tableView.reloadData()

		}else{
			isSearching = true
			
			filteredContactsData = contacts.filter({contact -> Bool in
				
				contact.fullName.contains(searchText)
				
			})
			
			filteredContactsOnAppData = contactsOnApp.filter({contact -> Bool in
				
				contact.firstName.contains(searchText) || contact.lastName.contains(searchText)
				
			})
			
			filteredUsersInSchoolData = usersInSchool.filter({contact -> Bool in
				
				contact.firstName.contains(searchText) || contact.lastName.contains(searchText)
				
			})
			self.filteredData = [0: self.filteredContactsOnAppData as Array<AnyObject>, 1: self.filteredUsersInSchoolData as Array<AnyObject>, 2: self.filteredContactsData as Array<AnyObject>]
			
			
			tableView.reloadData()
		}
	}

}
public extension UIImage {
	public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
}
