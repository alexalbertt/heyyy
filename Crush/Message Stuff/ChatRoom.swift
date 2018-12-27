//
//  ChatRoom.swift
//  Crush
//
//  Created by Alex Albert on 2/19/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ChatRoom {
	
	var firstName: String!
	var other_FirstName: String!
	var userId: String!
	var other_UserId: String!
	var members: [String]!
	var chatRoomId: String!
	var ref: DatabaseReference!
	var key: String!
	
	init(firstName:String,other_FirstName: String,userId: String,other_UserId: String,members: [String],chatRoomId: String,key: String = ""){
		
		self.firstName = firstName
		self.other_FirstName = other_FirstName
		self.userId = userId
		self.other_UserId = other_UserId
		self.members = members
		self.chatRoomId = chatRoomId
		self.ref = Database.database().reference()
	}
	
	init (snapshot: DataSnapshot){
		
		self.firstName = (snapshot.value! as! NSDictionary)["first name"] as! String
		self.other_FirstName = (snapshot.value! as! NSDictionary)["other_FirstName"] as! String
		self.userId = (snapshot.value! as! NSDictionary)["userId"] as! String
		self.other_UserId = (snapshot.value! as! NSDictionary)["other_UserId"] as! String
		self.chatRoomId = (snapshot.value! as! NSDictionary)["chatRoomId"] as! String
		self.members = (snapshot.value! as! NSDictionary)["members"] as! [String]
		self.ref = snapshot.ref
		self.key = snapshot.key
		
	}
	
	func toAnyObject()-> [String: AnyObject] {
		
		return ["firstName": firstName as AnyObject, "other_FirstName": other_FirstName as AnyObject,"userId": userId as AnyObject, "other_UserId": other_UserId as AnyObject,"chatRoomId":chatRoomId as AnyObject,"members":members as AnyObject]
	}
}

