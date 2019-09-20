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
    
    static let yyyyMM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let yyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
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

struct UserFollowersWrapper: Decodable {
    
    struct UserFollowerItems: Decodable {
        let items: [Artist]
        
        struct CursorItems: Decodable {
            let after: String?
        }
        let cursors: CursorItems?
    }
    let artists: UserFollowerItems
}

struct UserFollowersResponse {
    let artists: [Artist]?
    let after: String?
}

struct UserFollowersResource: ApiResource {
    
    var methodPath = "me/following"
    var httpMethod = "GET"
    var parameters = ["type=artist"]
    
    init(afterCode: String? = nil) {
        guard let after = afterCode else {
            return
        }
        parameters.append("after="+after)
    }
    func makeModel(data: Data) -> [UserFollowersResponse]? {
        let decoder = JSONDecoder()
        
        do {
            let wrapped = try decoder.decode(UserFollowersWrapper.self, from: data)
            return [UserFollowersResponse(artists: wrapped.artists.items, after: wrapped.artists.cursors?.after)]
        } catch {
            print("DECODE FAILED")
            print(error)
            return nil
        }
        
    }
}

extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
}

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    override func loadView() {
        view = UIView()
        //view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        view.backgroundColor = #colorLiteral(red: 0.5863838196, green: 0.5864852667, blue: 0.5863704681, alpha: 0.6392495599)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}



extension UIViewController {
    func createSpinnerView(child: SpinnerViewController) {
        self.addChild(child)
        child.view.frame = self.view.frame
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    func removeSpinnerView(child: SpinnerViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    func createReleaseLoadingView(child: ReleaseLoadingView) {
        self.addChild(child)
        child.view.frame = self.view.frame
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}



