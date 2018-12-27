//
//  User.swift
//  Crush
//
//  Created by Alex Albert on 1/6/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

struct User {
	
	var firstName : String!
	var lastName : String!
	var gender : String!
	var matchPreference : String!
	var photoURL : String!
	var highSchool : String!
	var grade : String!
	var phoneNumber : String!
	var uid : String!
	var ref : DatabaseReference?
	var key : String!
	var likes : [String:Int]!
	var matches : [User]!
	var schoolsFoll : [String:Bool]!
	var likesFormatted: [String]! {
		get {
			return Array(likes.keys)
		}
	}
	var invites : [String:Int]!
	var invitesFormatted: [String]! {
		get{
			return Array(invites.keys)
		}
	}
	var schoolsFollowed: [String]! {
		get{
			return Array(schoolsFoll.keys)
		}
	}
	init(snapshot: DataSnapshot) {
		
		key = snapshot.key
		ref = snapshot.ref
		firstName = (snapshot.value! as! NSDictionary)["first name"] as? String ?? String()
		lastName = (snapshot.value! as! NSDictionary)["last name"] as? String ?? String()
		gender = (snapshot.value! as! NSDictionary)["gender"] as? String ?? String()
		matchPreference = (snapshot.value! as! NSDictionary)["match preference"] as? String ?? String()
		photoURL = (snapshot.value! as! NSDictionary)["pic"] as? String ?? String()
		highSchool = (snapshot.value! as! NSDictionary)["School"] as? String ?? String()
		grade = (snapshot.value! as! NSDictionary)["grade"] as? String ?? String()
		phoneNumber = (snapshot.value! as! NSDictionary)["phone number"] as? String ?? String()
		uid = (snapshot.value! as! NSDictionary)["uid"] as? String ?? String()
		likes = (snapshot.value! as! NSDictionary)["likes"] as? [String:Int] ?? [String:Int]()
		matches = (snapshot.value! as! NSDictionary)["matches"] as? [User] ?? [User]()
		invites = (snapshot.value! as! NSDictionary)["invites"] as? [String:Int] ?? [String:Int]()
		schoolsFoll = (snapshot.value! as! NSDictionary)["schools followed"] as? [String:Bool] ?? [String:Bool]()
	}
	
}

