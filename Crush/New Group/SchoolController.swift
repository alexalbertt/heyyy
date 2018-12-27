//
//  SchoolController.swift
//  Crush
//
//  Created by Alex Albert on 12/30/17.
//  Copyright © 2017 Alex Albert. All rights reserved.
//

import MapKit
import UIKit

class SchoolController {
	// Our cool singleton property.
	static let shared = SchoolController()
	
	// Our fetch function will have a closure parameter called completion
	// which will return an optional array of Restaurants
	func fetchNearbySchools(completion: @escaping ([School]?) -> Void) {
		// Our search request object that will search for "Restaurants"
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = "High schools"
		
		// Intiaites a one time map based search
		let search = MKLocalSearch(request: request)
		search.start { (response, error) in
			
			// Automatically calls completion(nil) whenever we exit scope early
			defer {
				completion(nil)
			}
			
			guard error == nil else {
				print("Uh oh, a wild error has appeared: \(String(describing: error?.localizedDescription))")
				return
			}
			
			guard let response = response else {
				print("Uh oh, this is a bad response :(")
				return
			}
			
			var schools = [School]()
			
			// We loop through each item to check if it has a
			// name. At the end of the loop, we return
			// a list of Restaurants
			schools = response.mapItems.flatMap {
				guard let name = $0.name else {
					print("No name")
					return nil
				}
				
				return School(name: name, placeMark: $0.placemark)
			}
			
			completion(schools)
		}
	}
}

