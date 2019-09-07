//
//  OtherModels.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 9/2/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import UIKit

struct SpotifyImage: Codable {
    let width: Int
    let height: Int
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case height
        case width
        case url
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}


enum AppStatus: String {
    case rest = "Done"
    case noReturn = "No releases found"
    case loading = "Loading new releases. Please wait"
    case rateLimitExceeded = "Too many requests, wait a little before retrying"
    case noConnection = "No internet connection"
    case unknownError = "Unknown error, try again later"
}

// Reading and Writing methods for artists


struct TimeDuration {
    static let day = 24*60*60
    static let week = TimeDuration.day * 7
    static let month = TimeDuration.day * 31
}

extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
}


