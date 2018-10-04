//
//  HSBTextView.swift
//  TextView
//
//  Created by 홍상보 on 2018. 9. 10..
//  Copyright © 2018년 hsb9kr. All rights reserved.
//

import UIKit

public protocol HSBTextViewDelegate {
	func detect(textView: HashTagTextView, hashTagInfo: HashTagInfo)
	func didTouch(textView: HashTagTextView, hashTagInfo: HashTagInfo, URL: URL, range: NSRange)
}

public class HashTagTextView: UITextView {
	
	public var didTouchClosure: ((_ hashTagInfo: HashTagInfo, _ URL: URL, _ range: NSRange) -> Void)?
	public var detectClosure: ((_ hashTagInfo: HashTagInfo) -> Void)?
	public var prefixes = ["@", "#"]
	public var tags = [HashTagInfo]()
	public var textViewDelegate: HSBTextViewDelegate?
	
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
		
		guard let words = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).map ({ (result) -> HashTagInfo in
			let startIndex = string.index(string.startIndex, offsetBy: result.range.location)
			let endIndex = string.index(string.startIndex, offsetBy: result.range.location + result.range.length)
			
			var name = String(string[startIndex..<endIndex])
			let (_, prefix) = self.hasPrefix(string: name)
			let range = NSRange(location: startIndex.encodedOffset, length: endIndex.encodedOffset - startIndex.encodedOffset)
			name = name.replacingOccurrences(of: prefix ?? "", with: "")
			return HashTagInfo(prefix: prefix ?? "", name: name, range: range)
		}) else {
			return attributeString
		}
		
		tags = words
		
		for tag in tags {
			attributeString.addAttributes([.link : ""], range: tag.range)
		}
		
		return attributeString
	}
	
	fileprivate func detect(string: String, range: NSRange) {
		
		let endIndex = string.index(string.startIndex, offsetBy: range.location + range.length)
		
		let substring = string[string.startIndex..<endIndex]
		let regex = try? NSRegularExpression(pattern: "[\(prefixes.joined())]\\w+", options: [.caseInsensitive])
		var searchRange: NSRange?
		
		guard let words = regex?.matches(in: String(substring), options: [], range: NSRange(location: 0, length: substring.count)).map ({ (result) -> String in
			let startIndex = substring.index(substring.startIndex, offsetBy: result.range.location)
			let endIndex = substring.index(substring.startIndex, offsetBy: result.range.location + result.range.length)
			searchRange = NSRange(location: startIndex.encodedOffset, length: endIndex.encodedOffset - startIndex.encodedOffset)
			return String(substring[startIndex..<endIndex])
		}), var word = words.last else {
			return
		}
		
		let (hasPrefix, prefix) = self.hasPrefix(string: word)
		
		guard hasPrefix, let aPrefix = prefix else {
			return
		}
		
		word = word.replacingOccurrences(of: aPrefix, with: "")
		let hashTagInfo = HashTagInfo(prefix: aPrefix, name: word, range: searchRange!)
		detectClosure?(hashTagInfo)
		textViewDelegate?.detect(textView: self, hashTagInfo: hashTagInfo)
	}
	
	fileprivate func hasPrefix(string: String) -> (Bool, String?) {
		
		for prefix in prefixes where string.hasPrefix(prefix) {
			
			return (true, prefix)
		}
		
		return (false, nil)
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
			let hashTagInfo = HashTagInfo(prefix: character, name: word, range: characterRange)
			textViewDelegate?.didTouch(textView: textView as! HashTagTextView, hashTagInfo: hashTagInfo, URL: URL, range: characterRange)
			didTouchClosure?(hashTagInfo, URL, characterRange)
		}
		
		return false
	}
}
