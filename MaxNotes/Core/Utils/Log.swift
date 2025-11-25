//
//  Log.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import Foundation
import os

enum Log {
    private static let subsystem =
    Bundle.main.bundleIdentifier ?? "MaxNotes"
    
    static let firestore = Logger(subsystem: subsystem, category: "Firestore")
    static let general = Logger(subsystem: subsystem, category: "General")
}
