//
//  LetsGoVC.swift
//  Crush
//
//  Created by Alex Albert on 3/18/18.
//  Copyright © 2018 Alex Albert. All rights reserved.
//

import UIKit
import SafariServices

class LetsGoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func openTOS(_ sender: Any) {
		let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
			print("Cancel")
		}
		actionSheetController.addAction(cancelActionButton)
		
		
		let termsActionButton = UIAlertAction(title: "Terms of Use", style: .default) { action -> Void in
			let url = URL(string: "https://www.theheyyyapp.com/terms-of-use")
			let config = SFSafariViewController.Configuration()
			config.entersReaderIfAvailable = true
			let vc = SFSafariViewController(url: url!, configuration: config)
			self.present(vc, animated: true, completion: nil)
		}
		actionSheetController.addAction(termsActionButton)
		let privacyActionButton = UIAlertAction(title: "Privacy Policy", style: .default) { action -> Void in
			let url = URL(string: "https://www.theheyyapp.com/privacy")
			let config = SFSafariViewController.Configuration()
			config.entersReaderIfAvailable = true
			let vc = SFSafariViewController(url: url!, configuration: config)
			self.present(vc, animated: true, completion: nil)
		}
		actionSheetController.addAction(privacyActionButton)
		self.present(actionSheetController, animated: true, completion: nil)
	}
}
