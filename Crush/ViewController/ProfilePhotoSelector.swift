//
//  ProfilePhotoSelector.swift
//  Crush
//
//  Created by Alex Albert on 12/28/17.
//  Copyright © 2017 Alex Albert. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import CropViewController

class ProfilePhotoSelector: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
	
	private var image: UIImage?
	private var croppingStyle = CropViewCroppingStyle.default
	
	private var croppedRect = CGRect.zero
	private var croppedAngle = 0
	let customAspectRatio = CGSize(width: 3.00, height: 4.00)
	
	@IBOutlet weak var choosePhotoImage: UIButton!
	
	@IBOutlet weak var logProfilePhotoImage: UIButton!
	@IBOutlet weak var profilePhotoImage: UIImageView!
	
	let imagePickerController = UIImagePickerController()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		imagePickerController.delegate = self
		logProfilePhotoImage.setImage(#imageLiteral(resourceName: "Unselected next"), for: .normal)
		logProfilePhotoImage.isUserInteractionEnabled = false
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	//MARK: Choose Photo Button
	@IBAction func choosePhoto(_ sender: Any) {
		
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
	
	
	//MARK: Pick Photo
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
		profilePhotoImage.image = image
		
		//Log picture in firebase
		let imageName = NSUUID().uuidString
		let storedImage = Storage.storage().reference().child(uid!).child("\(imageName).jpg")
		
		if let profImage = profilePhotoImage.image,let uploadData = UIImageJPEGRepresentation(profImage, 0.1) {
			
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
		logProfilePhotoImage.setImage(#imageLiteral(resourceName: "Selected next"), for: .normal)
		logProfilePhotoImage.isUserInteractionEnabled = true
		
		cropViewController.dismiss(animated: true, completion: nil)
		
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	
	//MARK: Log photo into Firebase
	@IBAction func logProfilePhoto(_ sender: Any) {
		//Log picture in firebase
		let imageName = NSUUID().uuidString
		let storedImage = Storage.storage().reference().child(uid!).child("\(imageName).jpg")
		
		if let profImage = profilePhotoImage.image,let uploadData = UIImageJPEGRepresentation(profImage, 0.1) {
			
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
		}		//Perform segue
		performSegue(withIdentifier: "profilePhotoLogged", sender: Any?.self)
	}
	

}
