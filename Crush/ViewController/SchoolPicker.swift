//
//  SchoolPicker.swift
//  
//
//  Created by Alex Albert on 12/30/17.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth
import Firebase
import MessageUI
import SafariServices


class SchoolPicker: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate, MFMailComposeViewControllerDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var searchBar: UISearchBar!
	var filteredData = [School]()
	var isSearching = false
	
	var schools = [School]()
	var locationManager: CLLocationManager!
	var schoolDic = ""
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		
		searchBar.delegate = self
		searchBar.returnKeyType = UIReturnKeyType.done
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
	    locationManager.requestWhenInUseAuthorization()

	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			
			
			SchoolController.shared.fetchNearbySchools { (schools) in
				guard let schools = schools else {
					print("Uh oh no schools!")
					return
				}
				
				self.schools = schools
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
	}
	
	// MARK: Number of cells
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isSearching{
			return filteredData.count
		}
		return schools.count
	}
	
	//MARK: What to put in each cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath)
		
		if isSearching{
			cell.textLabel?.text = filteredData[indexPath.row].name
		}else{
			cell.textLabel?.text = schools[indexPath.row].name
		}
		return cell
	}
	//MARK: Action when cell is selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let memberDic =  true
		//Log user into school group
		if isSearching{
			schoolDic  = "\(filteredData[indexPath.row].name)"
		}else{
			schoolDic = "\(schools[indexPath.row].name)"
		}
		//Check if school exists already
		ref.child("schools").observeSingleEvent(of: .value, with: { (snapshot) in
			
			if snapshot.hasChild("\(self.schools[indexPath.row].name)"){
				
				print("true school exist")
				ref.child("schools").child("\(self.schools[indexPath.row].name)").child("members").child(uid!).setValue(memberDic)
				ref.child("users").child(uid!).child("School").setValue(self.schoolDic)
				
			}else{
				ref.child("users").child(uid!).child("School").setValue(self.schoolDic)
				ref.child("schools").child("\(self.schools[indexPath.row].name)").child("members").child(uid!).setValue(memberDic)
				print("false school doesn't exist. It has been added")
			}
			
			
		})

		performSegue(withIdentifier: "schoolLogged", sender: Any?.self)
	}
	
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchBar.text == nil || searchBar.text == "" {
			isSearching = false
			tableView.reloadData()
		}else{
			isSearching = true
			
			filteredData = schools.filter({skool -> Bool in
				
				skool.name.contains(searchText)
				
			})
			
			tableView.reloadData()
		}
	}
	
	
	@IBAction func signUpSchool(_ sender: Any) {
		let mailComposeViewController = configuredMailComposeViewController()
		if MFMailComposeViewController.canSendMail() {
			self.present(mailComposeViewController, animated: true, completion: nil)
		} else {
			self.showSendMailErrorAlert()
		}
	}
	
	func configuredMailComposeViewController() -> MFMailComposeViewController {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
		
		mailComposerVC.setToRecipients(["support@theheyyyapp.com"])
		mailComposerVC.setSubject("Add School Request Form")
		mailComposerVC.setMessageBody("Please provide school name and location:)", isHTML: false)
		
		return mailComposerVC
	}
	
	func showSendMailErrorAlert() {
		let alertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
		
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
			(result : UIAlertAction) -> Void in
			print("OK")
		}
		
		alertController.addAction(okAction)
		self.present(alertController, animated: true, completion: nil)
	}
	
	// MARK: MFMailComposeViewControllerDelegate Method
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	
	/*private func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
		 controller.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
		switch result {
		case .cancelled:
			print("Mail cancelled")
			controller.dismiss(animated: true, completion: nil)
		case .saved:
			print("Mail saved")
			controller.dismiss(animated: true, completion: nil)
		case .sent:
			print("Mail sent")
			controller.dismiss(animated: true, completion: nil)
		case .failed:
			print("Mail sent failure: \(error.localizedDescription)")
			controller.dismiss(animated: true, completion: nil)
		}
		controller.dismiss(animated: true, completion: nil)
	}*/
	
	
	
}

