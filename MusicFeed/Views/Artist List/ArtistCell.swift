//
//  ArtistCell.swift
//  SpotifyAlert
//
//  Created by Reed Metzler-Gilbertz on 8/10/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class ArtistCell: UITableViewCell {

    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var artistImageView: UIImageView!
    
    
    func setArtistLabel(artist: Artist) {
        artistLabel.text = artist.name

    }
    func setArtistImage(artist: Artist) {
        if let data = artist.profileImageData {
            artistImageView.image = UIImage(data: data)
            artistImageView.setRounded()

        }
    }
    
}

