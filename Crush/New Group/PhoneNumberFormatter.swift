//
//  LocalizedPhone.swift
//
//  Copyright 2015 Emily Ivie

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import Foundation

/**
    Example:::
    
    var phoneFormatter = PhoneNumberFormatter()
    @IBAction func formValueChanged(sender: UITextField) {
        sender.text = phoneFormatter.format(sender.text, hash: sender.hash)
    }
*/
public struct PhoneNumberFormatter {

    /**
        Set available locales here.
    */
    fileprivate enum AvailableLocales: String {
        case UnitedStates = "US",
             Canada = "CA"
    }
    
    /**
        Set default locale here.
    */
    fileprivate static var defaultLocale = AvailableLocales.UnitedStates
    
    fileprivate static var locale: AvailableLocales = {
        let country = Locale.current.regionCode
        return AvailableLocales(rawValue: country ?? "") ?? defaultLocale
    }()

    
    /**
        Set formats for available locales here.
        (expect a string of correct length, but match with dot (.), not digit (\d))
    */
    fileprivate let formatByLocale: [AvailableLocales: Format] = [
        .UnitedStates: (length: 10, match: "^(...)(...)(....)$", format: "($1) $2-$3"),
        .Canada: (length: 10, match: "^(...)(...)(....)$", format: "($1) $2-$3"),
    ]
    fileprivate typealias Format = (length: Int, match: String, format: String)
    
    fileprivate var lastPhoneNumbers: [Int: String] = [:]
    
    //Mark: Public functions:
    
    /**
        Turns a phone number into a pretty formatted phone number for the current locale. Strips text down to numbers before running.
        
        - parameter phoneNumber:      Any string with numbers or existing formatting
        - parameter hash:             If you are dealing with multiple phone numbers, you will need to include a unique id for each (field.hash is good)
        - returns:                Formatted phone number string
    */
    mutating public func format(_ phoneNumber: String, hash: Int = 0) -> String {
        //strip to numbers
        var numericText = phoneNumber.onlyCharacters("0123456789")
        if numericText.length == 0 {
            lastPhoneNumbers[hash] = ""
            return ""
        }
        if let formatStyle = formatByLocale[PhoneNumberFormatter.locale] {
            //if characters removed by user, change to remove numbers instead of formatting
            let lastPhoneNumber = self.lastPhoneNumbers[hash] ?? ""
            let lastNumericText = lastPhoneNumber.onlyCharacters("0123456789")
            let requestedSubtractChars = lastPhoneNumber.length - phoneNumber.length
            let actualSubtractChars = max(0, lastNumericText.length - numericText.length)
            if requestedSubtractChars > 0 && actualSubtractChars < requestedSubtractChars {
                let subtractChars = requestedSubtractChars - actualSubtractChars
                print(subtractChars)
                numericText = subtractChars >= numericText.length  ? "" : numericText.stringFrom(0, to: -1 * subtractChars)
            }
            //add formatting
            let placeholder = "*"
            if numericText.length < formatStyle.length {
                numericText = numericText.rpad(placeholder, length: formatStyle.length)
            }
            if numericText.length > formatStyle.length {
                numericText = numericText.stringFrom(0, to: formatStyle.length)
            }
            let fullyFormattedNumber = numericText.replacingOccurrences(of: formatStyle.match, with: formatStyle.format, options: NSString.CompareOptions.regularExpression, range: nil)
            if let editingNumber = fullyFormattedNumber.characters.split(maxSplits: 1, omittingEmptySubsequences: false, whereSeparator: {
                Character(placeholder) == $0
            }).first {
                let eNumber = String(editingNumber)
                lastPhoneNumbers[hash] = eNumber
                return eNumber
            }
            lastPhoneNumbers[hash] = fullyFormattedNumber
            return fullyFormattedNumber
        }
        return numericText
    }
    
    /**
        Checks phone number is a valid phone number for the current locale.
        
        - parameter phoneNumber:      A numeric phone number. Expects no formatting!
        - returns:                True if phone number matches locale pattern
    */
    public func isValid(_ phoneNumber: String) -> Bool {
        let numericText = phoneNumber.onlyCharacters("0123456789")
        if let formatStyle = formatByLocale[PhoneNumberFormatter.locale] {
            return numericText.length == formatStyle.length
        }
        return false
    }
    
    /**
        Remove prior saved values for fresh field comparison.
    */
    mutating public func reset() {
        lastPhoneNumbers = [:]
    }
}
