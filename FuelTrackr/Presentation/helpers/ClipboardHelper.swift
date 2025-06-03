//
//  ClipboardHelper.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/06/2025.
//


// ClipboardHelper.swift
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

enum ClipboardHelper {
    static func copy(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        #endif
    }
}