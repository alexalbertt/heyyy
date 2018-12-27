//
//  AboutVC.swift
//  Crush
//
//  Created by Alex Albert on 1/6/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class AboutVC: UIViewController, MFMailComposeViewControllerDelegate  {


	let appID = "1369679488"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	
	@IBAction func sendFeedback(_ sender: Any) {
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
		mailComposerVC.setSubject("Feedback For heyyy")
		mailComposerVC.setMessageBody("Feature request or bug report?", isHTML: false)
		
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
	
	@IBAction func rateUs(_ sender: Any) {
		if let checkURL = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)") {
			open(url: checkURL)
		} else {
			print("invalid url")
		}
	}
	
	func open(url: URL) {
		UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
				print("Open \(url): \(success)")
			})
		
	}
	
	@IBAction func safety(_ sender: Any) {
		let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
			print("Cancel")
		}
		actionSheetController.addAction(cancelActionButton)
		
		let communityActionButton = UIAlertAction(title: "Community Guidelines", style: .default) { action -> Void in
			let url = URL(string: "https://www.theheyyyapp.com/community")
			let config = SFSafariViewController.Configuration()
			config.entersReaderIfAvailable = true
			let vc = SFSafariViewController(url: url!, configuration: config)
			self.present(vc, animated: true, completion: nil)
		}
		actionSheetController.addAction(communityActionButton)
		
		let termsActionButton = UIAlertAction(title: "Terms of Use", style: .default) { action -> Void in
			let url = URL(string: "https://www.theheyyyapp.com/terms-of-use")
			let config = SFSafariViewController.Configuration()
			config.entersReaderIfAvailable = true
			let vc = SFSafariViewController(url: url!, configuration: config)
			self.present(vc, animated: true, completion: nil)
		}
		actionSheetController.addAction(termsActionButton)
		let privacyActionButton = UIAlertAction(title: "Privacy Policy", style: .default) { action -> Void in
			let url = URL(string: "https://www.theheyyyapp.com/privacy")
			let config = SFSafariViewController.Configuration()
			config.entersReaderIfAvailable = true
			let vc = SFSafariViewController(url: url!, configuration: config)
			self.present(vc, animated: true, completion: nil)
		}
		actionSheetController.addAction(privacyActionButton)
		self.present(actionSheetController, animated: true, completion: nil)
	}
	
	@IBAction func openSnapchat(_ sender: Any) {
		let snapchat = URL(string: "snapchat://add/heyyy_app")!
		
		if UIApplication.shared.canOpenURL(snapchat) {
			UIApplication.shared.open(snapchat, options: ["":""], completionHandler: nil)
		} else {
			print("Snapchat not installed")
			let alert = UIAlertController(title: "Snapchat not installed", message: "", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	@IBAction func openInstagram(_ sender: Any) {
		let instagram = URL(string: "instagram://user?username=heyyyapp")!
		
		if UIApplication.shared.canOpenURL(instagram) {
			UIApplication.shared.open(instagram, options: ["":""], completionHandler: nil)
		} else {
			print("Instagram not installed")
			let alert = UIAlertController(title: "Instagram not installed", message: "", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	@IBAction func openTwitter(_ sender: Any) {
		let twitter = URL(string: "twitter://user?screen_name=theheyyyapp")!
		
		if UIApplication.shared.canOpenURL(twitter) {
			UIApplication.shared.open(twitter, options: ["":""], completionHandler: nil)
		} else {
			print("Twitter not installed")
			let alert = UIAlertController(title: "Twitter not installed", message: "", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			
		}

	}
	
}
