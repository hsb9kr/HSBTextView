//
//  HSBTextView.swift
//  TextView
//
//  Created by 홍상보 on 2018. 9. 10..
//  Copyright © 2018년 hsb9kr. All rights reserved.
//

import UIKit

protocol HSBTextViewDelegate {
	func detect(textView: HashTagTextView, string: String?, prefix: String?)
	func didTouch(textView: HashTagTextView, string: String, prefix: String, URL: URL, range: NSRange)
}

public class HashTagTextView: UITextView {
	
	var didTouchClosure: ((_ string: String, _ prefix: String, _ URL: URL, _ range: NSRange) -> Void)?
	var detectClosure: ((_ string: String?, _ prefix: String?) -> Void)?
	var prefixes = ["@", "#"]
	var tags = [String]()
	var textViewDelegate: HSBTextViewDelegate?
	override public var text: String! {
		didSet {
			attributedText = detect(string: text)
		}
	}
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		delegate = self
		attributedText = detect(string: text)
	}
	
	fileprivate func detect(string: String) -> NSMutableAttributedString {
		
		let regex = try? NSRegularExpression(pattern: "[\(prefixes.joined())]\\w+", options: [.caseInsensitive])
		
		let attributeString = NSMutableAttributedString(string: string, attributes: [
			.font : UIFont.systemFont(ofSize: font?.pointSize ?? 14),
			.foregroundColor : textColor ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
			])
		
		guard let words = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).map ({ (result) -> String in
			let startIndex = string.index(string.startIndex, offsetBy: result.range.location)
			let endIndex = string.index(string.startIndex, offsetBy: result.range.location + result.range.length)
			
			return String(string[startIndex..<endIndex])
		}) else {
			return attributeString
		}
		
		tags.removeAll()
		
		for word in words where hasPrefix(string: String(word)) {
			
			guard let range = string.range(of: word) else {
				continue
			}
			
			let nsrange = NSRange(location: range.lowerBound.encodedOffset, length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
			attributeString.addAttributes([.link : ""], range: nsrange)
			tags.append(String(word))
		}
		
		return attributeString
	}
	
	fileprivate func detect(string: String, range: NSRange) {
		
		let endIndex = string.index(string.startIndex, offsetBy: range.location + range.length)
		
		let substring = string[string.startIndex..<endIndex]
		let regex = try? NSRegularExpression(pattern: "[\(prefixes.joined())]\\w+", options: [.caseInsensitive])
		
		guard let words = regex?.matches(in: String(substring), options: [], range: NSRange(location: 0, length: substring.count)).map ({ (result) -> String in
			let startIndex = substring.index(substring.startIndex, offsetBy: result.range.location)
			let endIndex = substring.index(substring.startIndex, offsetBy: result.range.location + result.range.length)
			
			return String(substring[startIndex..<endIndex])
		}), var word = words.last else {
			return
		}
		
		var prefix: String = ""
		for characters in prefixes {
			
			if word.hasPrefix(characters) {
				prefix = characters
			}
		}
		
		word = word.replacingOccurrences(of: prefix, with: "")
		detectClosure?(word, prefix)
		textViewDelegate?.detect(textView: self, string: word, prefix: prefix)
	}
	
	fileprivate func hasPrefix(string: String) -> Bool {
		
		for prefix in prefixes where string.hasPrefix(prefix) {
			
			return true
		}
		
		return false
	}
}

extension HashTagTextView: UITextViewDelegate {
	
	public func textViewDidChange(_ textView: UITextView) {
		
		guard let string = textView.text else {
			return
		}
		
		let range = textView.selectedRange
		
		textView.attributedText = detect(string: string)
		
		textView.selectedRange = range
		
		detect(string: string, range: range)
	}
	
	@available(iOS 10.0, *)
	public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		
		guard let string = textView.text else {
			return false
		}
		
		let startIndex = string.index(string.startIndex, offsetBy: characterRange.location)
		let endIndex = string.index(startIndex, offsetBy: characterRange.length)
		let substring = string[startIndex..<endIndex]
		
		for character in prefixes where substring.hasPrefix(character) {
			
			let word = substring.replacingOccurrences(of: character, with: "")
			textViewDelegate?.didTouch(textView: textView as! HashTagTextView, string: word, prefix: character, URL: URL, range: characterRange)
			didTouchClosure?(word, character, URL, characterRange)
		}
		
		return false
	}
}
