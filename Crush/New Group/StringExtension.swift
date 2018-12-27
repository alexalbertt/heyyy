//
//  StringExtension.swift
//
//  created 2015 Emily Ivie (cobbled together from many StackOverflow answers).
//  No license, everyone free to use.

import Foundation

// uhg, worst Swift 3.0 decision ever. Stupid people don't grok optionals.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

extension String {
    /**
        Pads the left side of a string with the specified string up to the specified length.
        Does not clip the string if too long.
    
        - parameter padding:   The string to use to create the padding (if needed)
        - parameter length:    Integer target length for entire string
        - returns: The padded string
    */
    func lpad(_ padding: String, length: Int) -> (String) {
        if self.characters.count > length {
            return self
        }
        return "".padding(toLength: length - self.characters.count, withPad:padding, startingAt:0) + self
    }
    /**
        Pads the right side of a string with the specified string up to the specified length.
        Does not clip the string if too long.
    
        - parameter padding:   The string to use to create the padding (if needed)
        - parameter length:    Integer target length for entire string
        - returns: The padded string
    */
    func rpad(_ padding: String, length: Int) -> (String) {
        if self.characters.count > length { return self }
        return self.padding(toLength: length, withPad:padding, startingAt:0)
    }
    /**
        Returns string with left and right spaces trimmed off.
    
        - returns: Trimmed String
    */
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    /**
        Shortcut for getting length (since Swift keeps cahnging this).
    
        - returns: Int length of string
    */
    var length: Int {
        return self.characters.count
    }
    /**
        Returns character at a specific position from a string.
        
        - parameter index:               The position of the character
        - returns: Character
    */
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    /**
        Returns substring extracted from a string at start and end location.
    
        - parameter start:               Where to start (-1 acceptable)
        - parameter end:                 (Optional) Where to end (-1 acceptable) - default to end of string
        - returns: String
    */
    func stringFrom(_ start: Int, to end: Int? = nil) -> String {
        var maximum = self.characters.count
        
        let i = start < 0 ? self.endIndex : self.startIndex
        let ioffset = min(maximum, max(-1 * maximum, start))
        let startIndex = self.index(i, offsetBy: ioffset)
        
        maximum -= start
        
        let j = end < 0 ? self.endIndex : self.startIndex
        let joffset = min(maximum, max(-1 * maximum, end ?? 0))
        let endIndex = end != nil && end! < self.characters.count ? self.index(j, offsetBy: joffset) : self.endIndex
        return self.substring(with: (startIndex ..< endIndex))
    }
    /**
        Returns substring composed of only the allowed characters.
    
        - parameter allowed:             String list of acceptable characters
        - returns: String
    */
    func onlyCharacters(_ allowed: String) -> String {
        let search = allowed.characters
        return characters.filter({ search.contains($0) }).reduce("", { $0 + String($1) })
    }
    /**
        Simple pattern matcher. Requires full match (ie, includes ^$ implicitly).
        
        - parameter pattern:             Regex pattern (includes ^$ implicitly)
        - returns: true if full match found
    */
    func matches(_ pattern: String) -> Bool {
        let test = NSPredicate(format:"SELF MATCHES %@", pattern)
        return test.evaluate(with: self)
    }
}
