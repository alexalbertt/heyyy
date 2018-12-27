//
//  ConvoVC.swift
//  Crush
//
//  Created by Alex Albert on 2/19/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import AVKit
import Photos
import FirebaseMessaging

class ConvoVC: JSQMessagesViewController {
	
	
	var chatRoomId = Variables.chatRoomID
	var recipientName = Variables.recipientName
	var recipientUid = Variables.recipientUid
	private lazy var messageRef: DatabaseReference = ref.child("ChatRooms").child(chatRoomId!).child("Messages")
	private var newMessageRefHandle: DatabaseHandle?
	
	private lazy var userIsTypingRef: DatabaseReference = ref.child("ChatRooms").child(chatRoomId!).child("typingIndicator").child(self.senderId)
	
	private var localTyping = false
	
	var isTyping: Bool {
		get {
			return localTyping
		}
		set {
			
			localTyping = newValue
			userIsTypingRef.setValue(newValue)
		}
	}
	
	private lazy var usersTypingQuery: DatabaseQuery =
		ref.child("ChatRooms").child(chatRoomId!).child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
	
	
	lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://crush-28e47.appspot.com/")
	private let imageURLNotSetKey = "NOTSET"
	private var photoMessageMap = [String: JSQPhotoMediaItem]()
	private var updatedMessageRefHandle: DatabaseHandle?
	
	var outgoingBubbleImageView: JSQMessagesBubbleImage!
	var incomingBubbleImageView: JSQMessagesBubbleImage!
	
	var messages = [JSQMessage]()
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print("View loaded")
		print(chatRoomId!)
		senderId = uid!
		senderDisplayName = uid!
		
		self.navigationItem.title = recipientName!
		
		let factory = JSQMessagesBubbleImageFactory()
		
		incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
		outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
		
		collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
		collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
		observeMessages()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.navigationController?.isNavigationBarHidden = false
		self.tabBarController?.tabBar.isHidden = true
		setupBackButton()
		observeTyping()
	}
	
	
	private func observeMessages() {
		messageRef = ref.child("ChatRooms").child(chatRoomId!).child("Messages")
		
		let messageQuery = messageRef.queryLimited(toLast:25)
		
		newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) in
			
			let messageData = snapshot.value as! Dictionary<String, AnyObject>
			
			
			if  let data        = snapshot.value as? [String: AnyObject],
				let id          = data["sender_id"] as? String,
				let name        = data["name"] as? String,
				let text        = data["text"] as? String,
				let time        = data["time"] as? TimeInterval,
				!text.isEmpty
			{
				if id != uid! {
					let updateRead  = ref.child("ChatRooms").child(self.chatRoomId!).child("Messages").child(snapshot.key)
					updateRead.updateChildValues(["status":"read"])
				}
				if let message = JSQMessage(senderId: id, senderDisplayName: name, date: Date(timeIntervalSince1970: time), text: text)
				{
					self.messages.append(message)
					
					self.finishReceivingMessage()
				}
			
			}else if let id = messageData["senderId"] as! String!,
				let photoURL = messageData["photoURL"] as! String! {
				
				if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
					
					self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
					
					if photoURL.hasPrefix("gs://") {
						self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
					}
				}
			}else {
				print("Error! Could not decode message data")
			}
		})
		updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
			let key = snapshot.key
			if snapshot.exists(){
				if let messageData = snapshot.value as? Dictionary<String, String>{
					if let photoURL = messageData["photoURL"] as String! {
						// The photo has been updated.
						if let mediaItem = self.photoMessageMap[key] {
							self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
						}
					}
				}
			
		}
		})
	}
	
	func setupBackButton() {
		let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
		navigationItem.leftBarButtonItem = backButton
	}
	@objc func backButtonTapped() {
		
		let tabBarController = self.tabBarController
		
		_ = self.navigationController?.popToRootViewController(animated: false)
		
		tabBarController?.selectedIndex = 1
		
	}
	
	
	func addMessage(withId id: String, name: String, text: String){
		
		let message = JSQMessage(senderId:id, displayName: name, text: text)
		messages.append(message!)
		
		
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
		let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
		
		let message = messages[indexPath.item]
		
		if message.senderId == senderId {
			cell.textView?.textColor = UIColor.white
		} else {
			cell.textView?.textColor = UIColor.black
		}
		
		return cell
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
		return messages[indexPath.item]
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
		
	}
	
	
	
	override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
		let messageRef = ref.child("ChatRooms").child(chatRoomId!).child("Messages").childByAutoId()
		let userMessageRef = ref.child("users").child(recipientUid!).child("chats").child(uid!).childByAutoId()
		let currentTime = Date()
		let currentTimePassed = currentTime.timeIntervalSince1970
		let timeInt = Int(currentTimePassed)
		
		let message = ["sender_id": senderId, "name": senderDisplayName, "text": text, "time" : timeInt, "status":"unread"] as [String : Any]
		
		messageRef.setValue(message)
		userMessageRef.setValue(message)
		finishSendingMessage()
		JSQSystemSoundPlayer.jsq_playMessageSentSound()
		self.finishSendingMessage()
		isTyping = false
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
		let message = messages[indexPath.item]
		if message.senderId == senderId {
			return outgoingBubbleImageView
		}else {
			return incomingBubbleImageView
		}
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
		return nil
	}
	
	override func textViewDidChange(_ textView: UITextView) {
		super.textViewDidChange(textView)
		// If the text is not empty, the user is typing
		isTyping = textView.text != ""
		
	}
	
	//MARK: Observe Typing
	private func observeTyping() {
		let typingIndicatorRef = ref.child("ChatRooms").child(chatRoomId!).child("typingIndicator")
		userIsTypingRef = typingIndicatorRef.child(senderId)
		userIsTypingRef.onDisconnectRemoveValue()
		
		
		usersTypingQuery.observe(.value) { (data: DataSnapshot) in
			// 2 You're the only one typing, don't show the indicator
			if data.childrenCount == 1 && self.isTyping {
				return
			}
			
			// 3 Are there others typing?
			self.showTypingIndicator = data.childrenCount > 0
			self.scrollToBottom(animated: true)
		}
	}
	
	
	//MARK: Send Photos
	func sendPhotoMessage() -> String? {
		let itemRef = messageRef.childByAutoId()
		
		let messageItem = [
			"photoURL": imageURLNotSetKey,
			"senderId": senderId!,
			]
		
		itemRef.setValue(messageItem)
		
		JSQSystemSoundPlayer.jsq_playMessageSentSound()
		
		finishSendingMessage()
		return itemRef.key
	}
	
	func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
		let itemRef = messageRef.child(key)
		itemRef.updateChildValues(["photoURL": url])
	}
	
	override func didPressAccessoryButton(_ sender: UIButton) {
		let alert = UIAlertController(title: "Pictures are unavailable right now:(", message: "We are experiencing a few bugs at the moment with pictures. Don't worry, they will be back soon!", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
		/*let picker = UIImagePickerController()
		picker.delegate = self
		
		let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
		
		actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
			//Check if camera is available
			if UIImagePickerController.isSourceTypeAvailable(.camera){
				picker.sourceType = .camera
				self.present(picker, animated: true, completion: nil)
			}else{
				print("Camera not available")
			}
		}))
		
		actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
			picker.sourceType = .photoLibrary
			self.present(picker, animated: true, completion: nil)
		}))
		
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		self.present(actionSheet, animated: true, completion: nil)*/
	}
	
	private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
		if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
			messages.append(message)
			
			if (mediaItem.image == nil) {
				photoMessageMap[key] = mediaItem
			}
			
			collectionView.reloadData()
		}
	}
	
	private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
		
		let storageRef = Storage.storage().reference(forURL: photoURL)
		
		
		storageRef.getData(maxSize: INT64_MAX){ (data, error) in
			if let error = error {
				print("Error downloading image data: \(error)")
				return
			}
			
			
			storageRef.getMetadata(completion: { (metadata, metadataErr) in
				if let error = metadataErr {
					print("Error downloading metadata: \(error)")
					return
				}
				
				
				if (metadata?.contentType == "image/gif") {
					mediaItem.image = UIImage.gifWithData(data!)
				} else {
					mediaItem.image = UIImage.init(data: data!)
				}
				self.collectionView.reloadData()
				
				
				guard key != nil else {
					return
				}
				self.photoMessageMap.removeValue(forKey: key!)
			})
		}
	}
	deinit {
		if let refHandle = newMessageRefHandle {
			messageRef.removeObserver(withHandle: refHandle)
		}
		
		if let refHandle = updatedMessageRefHandle {
			messageRef.removeObserver(withHandle: refHandle)
		}
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "h:mm a MM-dd"
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.amSymbol = "AM"
		dateFormatter.pmSymbol = "PM"
		let message = messages[indexPath.item]
		let dateString = dateFormatter.string(from:message.date as Date)
		
		return NSAttributedString.init(string: dateString)
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
		return 30.0
	}
}


// MARK: Image Picker Delegate
extension ConvoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [String : Any]) {
		
		picker.dismiss(animated: true, completion:nil)
		
		
		if let photoReferenceUrl = info[UIImagePickerControllerPHAsset] as? URL {
			// Handle picking a Photo from the Photo Library
			
			let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
			let asset = assets.firstObject
			
			
			if let key = sendPhotoMessage() {
				
				asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
					let imageFileURL = contentEditingInput?.fullSizeImageURL
					
					
					let path = "\(uid!)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
					
					
					self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
						if let error = error {
							print("Error uploading photo: \(error.localizedDescription)")
							return
						}
						
						self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
					}
				})
			}
		} else {
			// Handle picking a Photo from the Camera - TODO
			
			let image = info[UIImagePickerControllerOriginalImage] as! UIImage
			
			if let key = sendPhotoMessage() {
				
				let imageData = UIImageJPEGRepresentation(image, 1.0)
				
				let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
				
				let metadata = StorageMetadata()
				metadata.contentType = "image/jpeg"
				
				storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
					if let error = error {
						print("Error uploading photo: \(error)")
						return
					}
					
					self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
				}
			}
		}
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion:nil)
	}
}

