//
//  School.swift
//  Crush
//
//  Created by Alex Albert on 12/30/17.
//  Copyright © 2017 Alex Albert. All rights reserved.
//

import MapKit
import UIKit

class School {
	// The name of our restaurant
	var name: String
	
	// A placemark will give us the restaurant's coordinates
	var placeMark: MKPlacemark
	
	init(name: String, placeMark: MKPlacemark) {
		self.name = name
		self.placeMark = placeMark
	}
}
