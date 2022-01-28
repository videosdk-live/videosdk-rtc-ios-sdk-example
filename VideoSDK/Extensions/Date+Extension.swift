//
//  Date+Extension.swift
//  VideoSDK_Example
//
//  Created by Rushi Sangani on 27/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

/// UTC DateFormatter
public let UTCDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
    formatter.timeZone = TimeZone(identifier: "UTC")!
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

public extension Date {
    
    init?(string: String) {
        guard let date = UTCDateFormatter.date(from: string) else { return nil }
        self = date
    }
}
