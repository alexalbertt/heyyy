//
//  ChatFunctions.swift
//  Crush
//
//  Created by Alex Albert on 2/19/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Firebase

struct ChatFunctions {
	
	
	
	private var dataBaseRef: DatabaseReference! {
		return Database.database().reference()
	}
	
	func startChat(user1: User, user2: User)-> String{
		
		let userId1 = user1.uid
		let userId2 = user2.uid
		
		var chatRoomId: String = ""
		
		
		
		let comparison = userId1?.compare(userId2!).rawValue
		
		let members = [user1.firstName,user2.firstName]
		
		if comparison! < 0 {
			
			chatRoomId = userId1! + userId2!
		}else {
			chatRoomId = userId2! + userId1!
			
		}
		
		self.createChatRoom(user1: user1, user2: user2, members: members as! [String], chatRoomId: chatRoomId)
		
		return chatRoomId
	}
	
	private func createChatRoom(user1: User, user2: User, members: [String], chatRoomId: String){
		
		let chatRoomRef = dataBaseRef.child("ChatRooms").queryOrdered(byChild: "chatRoomId").queryEqual(toValue: chatRoomId)
		
		chatRoomRef.observe(.value, with: { (snapshot) in
			var createChatRoom = true
			
			if snapshot.exists(){
				
				for chatRoom in snapshot.children {
					let child = chatRoom as? DataSnapshot
					if let checkChatRoomId = child?.key{
						if checkChatRoomId == chatRoomId {
						createChatRoom = false
						print("Chat room already created")
					}
				}
				}
				
			
			
			if createChatRoom {
				print("Chat room being created")
				self.createNewChatRoom(user1: user1, user2: user2, members: members, chatRoomId: chatRoomId)
				
			}
			}
		})
		
		
		
	}
	
	
	private func createNewChatRoom(user1: User, user2: User, members: [String], chatRoomId: String){
		let chatRoom = ChatRoom(firstName: user1.firstName, other_FirstName: user2.firstName, userId: user1.uid, other_UserId: user2.uid, members: members, chatRoomId: chatRoomId)
		
		let chatRoomRef = dataBaseRef.child("ChatRooms").child(chatRoomId).child("Messages")
		chatRoomRef.setValue(0)
		
		
	}
	
	
}
