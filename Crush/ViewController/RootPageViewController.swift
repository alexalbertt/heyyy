//
//  RootPageViewController.swift
//  Crush
//
//  Created by Alex Albert on 12/26/17.
//  Copyright © 2017 Alex Albert. All rights reserved.
//
/*import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class RootPageViewController: UIPageViewController, UIPageViewControllerDataSource {
	
	
	lazy var viewControllerList:[UIViewController] = {
		
		let sb = UIStoryboard(name: "Main", bundle: nil)
		
		let vc1 = sb.instantiateViewController(withIdentifier: "MessagesVC")
		let vc2 = sb.instantiateViewController(withIdentifier: "CardsVC")
		let vc3 = sb.instantiateViewController(withIdentifier: "ProfileVC")
		let vc4 = sb.instantiateViewController(withIdentifier: "AboutVC" )
		let vc5 = sb.instantiateViewController(withIdentifier: "InviteVC")
		
		return[vc5, vc1, vc2, vc3, vc4]
	}()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		if Auth.auth().currentUser?.uid == nil{
			logout()
		}else{
			self.dataSource = self
		
			let inviteViewController = viewControllerList[0]
			let messagesViewController = viewControllerList[1]
			let cardsViewController = viewControllerList[2]
			let profileViewController = viewControllerList[3]
			let aboutViewController = viewControllerList[4]

			self.setViewControllers([cardsViewController], direction: .forward, animated: true, completion: nil)
		
	}
    }
	
	func logout(){
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let verifyPhoneVC = storyboard.instantiateViewController(withIdentifier: "enterPhoneNumber")
		present(verifyPhoneVC, animated: true, completion: nil)
		
	}
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
		let previousIndex = vcIndex - 1
		guard previousIndex >= 0 else {return nil}
		guard viewControllerList.count > previousIndex else {return nil}
		
		return viewControllerList[previousIndex]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
		let nextIndex = vcIndex + 1
		guard viewControllerList.count != nextIndex else {return nil}
		guard viewControllerList.count > nextIndex else {return nil}
		
		return viewControllerList[nextIndex]
	}


	func goNextPage() {
		let cur = self.viewControllers![0]
		let p = self.pageViewController(self, viewControllerAfter: cur)
		self.setViewControllers([p!], direction: .forward, animated: true, completion: nil)
	}
	
	func goPreviousPage() {
		let cur = self.viewControllers![0]
		let p = self.pageViewController(self, viewControllerBefore: cur)
		self.setViewControllers([p!], direction: .reverse, animated: true, completion: nil)
	}

	func goInvitePage() {
		let cur = self.viewControllers![0]
		let p = self.pageViewController(self, viewControllerBefore: cur)
		let a = self.pageViewController(self, viewControllerBefore: p!)
		let b = self.pageViewController(self, viewControllerBefore: a!)
		self.setViewControllers([b!], direction: .reverse, animated: true, completion: nil)
	}
	
	
}*/
