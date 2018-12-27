//
//  schoolFollower.swift
//  Crush
//
//  Created by Alex Albert on 6/3/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SchoolFollower: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate {

	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	var filteredData = [School]()
	var isSearching = false
	
	var schools = [School]()
	var locationManager: CLLocationManager!
	var schoolDic = ""
	var schoolsFollowed = [String]()
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
				guard var schools = schools else {
					print("Uh oh no schools!")
					return
				}
				ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
					let user = User(snapshot: snapshot)
					for school in user.schoolsFollowed{
						self.schoolsFollowed.append(school)
					}
					print(self.schoolsFollowed)
					self.schools = schools.filter{$0.name != user.highSchool}
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
					
				})
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "schoolsFollowedCell", for: indexPath)
		cell.selectionStyle = .none
		
		if isSearching{
		cell.textLabel?.text = filteredData[indexPath.row].name
			if schoolsFollowed.contains(filteredData[indexPath.row].name){
				cell.accessoryType = UITableViewCellAccessoryType.checkmark
			}
		}else{
		cell.textLabel?.text = schools[indexPath.row].name
			if schoolsFollowed.contains(schools[indexPath.row].name){
				cell.accessoryType = UITableViewCellAccessoryType.checkmark
			}
		}
		return cell
	}
	//MARK: Action when cell is selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark{
			tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
			if isSearching{
				schoolDic  = "\(filteredData[indexPath.row].name)"
			}else{
				schoolDic = "\(schools[indexPath.row].name)"
			}
			
			ref.child("users").child(uid!).child("schools followed").child(schoolDic).removeValue()
			
			
			
		}else{
		
		tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
		
		if isSearching{
		schoolDic  = "\(filteredData[indexPath.row].name)"
		}else{
		schoolDic = "\(schools[indexPath.row].name)"
		}
		ref.child("users").child(uid!).child("schools followed").child(schoolDic).setValue(true)
		}
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
	
	
	
	
	@IBAction func closeView(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
