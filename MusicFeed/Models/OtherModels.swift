//
//  OtherModels.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 9/2/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation

struct SpotifyImage: Decodable {
    let width: Int
    let height: Int
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case height
        case width
        case url
    }
}
