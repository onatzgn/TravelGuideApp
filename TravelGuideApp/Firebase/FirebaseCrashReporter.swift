//
//  FirebaseCrashReporter.swift
//  TravelGuideApp
//
//  Created by Onat Özgen on 27.05.2025.
//

import Foundation
import FirebaseCrashlytics

enum CrashReporter {
    
    static func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    static func record(_ error: Error, context: String? = nil) {
        if let context = context {
            Crashlytics.crashlytics().log("Context: \(context)")
        }
        Crashlytics.crashlytics().record(error: error)
    }
    
    static func simulateCrash() {
        fatalError("Simulated crash triggered by developer")
    }
}
