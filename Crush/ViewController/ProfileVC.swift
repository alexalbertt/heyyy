//
//  ProfileVC.swift
//  Crush
//
//  Created by Alex Albert on 1/4/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import CropViewController
import SDWebImage

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CropViewControllerDelegate {

	var activityIndicator = UIActivityIndicatorView()
	
	var colors = [UIColor]()
	private var image: UIImage?
	private var croppingStyle = CropViewCroppingStyle.default
	
	private var croppedRect = CGRect.zero
	private var croppedAngle = 0
	let customAspectRatio = CGSize(width: 3.00, height: 4.00)
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var userImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var gradeSchoolLabel: UILabel!
	
	
	var likes = [User]()
	let imagePickerController = UIImagePickerController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		activityIndicator.startAnimating()
		imagePickerController.delegate = self
		colors = [hexStringToUIColor(hex: "5DD9F1")/*hexStringToUIColor(hex: "7ED8FF"), hexStringToUIColor(hex: "A1A4FF"), hexStringToUIColor(hex: "A7FF95"), hexStringToUIColor(hex: "FDB4EF"), hexStringToUIColor(hex: "EF4C56"),
		hexStringToUIColor(hex: "F1FF71")*/]
		loadUserInfo()
		observeMatches()
		self.userImageView.layer.cornerRadius = 8.0
		self.userImageView.clipsToBounds = true
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
		tapGesture.numberOfTapsRequired = 1
		
		let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(tapFunctionImage(sender:)))
		tapGestureImage.numberOfTapsRequired = 1
		
		
		gradeSchoolLabel.addGestureRecognizer(tapGesture)
		gradeSchoolLabel.isUserInteractionEnabled = true
		userImageView.addGestureRecognizer(tapGestureImage)
		activityIndicator.stopAnimating()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		observeMatches()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@objc func tapFunction(sender: UITapGestureRecognizer){

		let alert = UIAlertController(title: "Change your grade", message: "Enter the number of the grade you are in", preferredStyle: .alert)

		alert.addTextField { (textField) in
			textField.placeholder = "11"
		}

		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
			let textField = alert?.textFields?[0].text
			print("Text field: \(textField!)")
			ref.child("users").child(uid!).child("grade").setValue("\(textField!)th")
			
		}))

		self.present(alert, animated: true, completion: nil)
	}
	
	@objc func tapFunctionImage(sender: UITapGestureRecognizer){
		let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
		
		actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
			//Check if camera is available
			if UIImagePickerController.isSourceTypeAvailable(.camera){
				self.imagePickerController.sourceType = .camera
				self.present(self.imagePickerController, animated: true, completion: nil)
			}else{
				print("Camera not available")
			}
		}))
		
		actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
			self.imagePickerController.sourceType = .photoLibrary
			self.present(self.imagePickerController, animated: true, completion: nil)
		}))
		
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		self.present(actionSheet, animated: true, completion: nil)
	}
	
	func hexStringToUIColor (hex:String) -> UIColor {
		var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		if ((cString.count) != 6) {
			return UIColor.gray
		}
		
		var rgbValue:UInt32 = 0
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	func loadUserInfo(){
		let userRef = ref.child("users").child(uid!)
		userRef.observe(.value, with: { (snapshot) in
			let user = User(snapshot: snapshot)
			self.nameLabel.text = user.firstName + " " + user.lastName
			self.gradeSchoolLabel.text = "\(user.grade!) grade at \(user.highSchool!)"
			
			let imageURL = user.photoURL
			
			Storage.storage().reference(forURL: imageURL!).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
				if error == nil{
					if let data = imgData {
						self.userImageView.image = UIImage(data: data)
					}
				}else{
					print(error!.localizedDescription)
				}
			})
			
		}){(error) in
			print(error.localizedDescription)
		}
	}
	
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		
		guard let image = (info[UIImagePickerControllerOriginalImage] as? UIImage) else { return }
		
		let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
		cropController.delegate = self
		
		cropController.title = "Crop and Scale"
		cropController.aspectRatioPreset = .presetCustom
		cropController.customAspectRatio = customAspectRatio
		cropController.aspectRatioLockEnabled = true
		cropController.rotateButtonsHidden = true
		cropController.rotateClockwiseButtonHidden = true
		
		
		self.image = image
		
		
		picker.dismiss(animated: true, completion: {
			self.present(cropController, animated: true, completion: nil)
		})
	}
	
	public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
		self.croppedRect = cropRect
		self.croppedAngle = angle
		updateImageViewWithImage(image, fromCropViewController: cropViewController)
	}
	
	public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
		userImageView.image = image

		//Log picture in firebase
		let imageName = NSUUID().uuidString
		let storedImage = Storage.storage().reference().child(uid!).child("\(imageName).jpg")
		
		if let profImage = userImageView.image,let uploadData = UIImageJPEGRepresentation(profImage, 0.1) {
			
			storedImage.putData(uploadData, metadata: nil, completion: { (metadata, err) in
				if err != nil {
					print(err!)
					return
				}
				storedImage.downloadURL(completion: { (url, error) in
					if error != nil {
						print(error!)
						return
					}
					
					if let profileImageUrl = url?.absoluteString {
						ref.child("users").child(uid!).updateChildValues(["pic" : profileImageUrl], withCompletionBlock: { (error, ref) in
							if error != nil{
								print(error!)
							}
						})
					}
				})
			})
		}

		cropViewController.dismiss(animated: true, completion: nil)
		
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

	//MARK: Navigation Actions
	@IBAction func goInviteSomeone(_ sender: Any) {
		tabBarController?.selectedIndex = 0

	}
	
	func observeMatches(){
		ref.child("users").child(uid!).child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
			
			
			if snapshot.exists(){
				var matchDict = [User]()
				for match in snapshot.children{
					let match = match as? DataSnapshot
					if let matchUID = match?.key {
						ref.child("users").child(matchUID).observeSingleEvent(of: .value, with: { (snap) in
							
							let matchInfo = User(snapshot: snap)
							matchDict.append(matchInfo)
							self.likes = matchDict
							self.collectionView.reloadData()
						})
					}
				}
			}
			
		})
		
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return likes.count
	}
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		var numOfSections = 0
		if likes.count != 0{
			numOfSections = 1
		}
		return numOfSections
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikesCell", for: indexPath) as? LikesCell{
			cell.likesName.text = likes[indexPath.row].firstName
			let blueImage = UIImage(color: hexStringToUIColor(hex: "5DD9F1"))
			cell.likesImage.image = blueImage
			cell.layer.cornerRadius = 8
			cell.backgroundColor = self.colors[indexPath.row % self.colors.count]
			let img = likes[indexPath.row].photoURL
			if img != ""{
				let imageURL = URL(string: img!)
				cell.likesImage.sd_setImage(with: (imageURL), placeholderImage: nil)
				cell.likesImage.layer.cornerRadius = (cell.likesImage.frame.height) / 2
				cell.likesImage.clipsToBounds = true
				/*URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
					
					if error != nil{
						print(error!)
						return
					}
					DispatchQueue.main.async {
						let otherUserProfile = UIImage(data: data!)
						cell.likesImage.image = otherUserProfile
						cell.likesImage.layer.cornerRadius = (cell.likesImage.frame.height) / 2
						cell.likesImage.clipsToBounds = true
					}
				}).resume()*/
			}

			return cell
		}else{
			return LikesCell()
		}
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 15.0
	}
}
