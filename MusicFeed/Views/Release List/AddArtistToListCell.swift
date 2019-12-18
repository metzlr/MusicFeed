//
//  AddArtistToListCell.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 12/13/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class AddArtistToListCell: UITableViewCell {
    
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var artistImageView: UIImageView!
    
    @IBOutlet weak var checkImage: UIImageView!
    
    var checked = false
    
    func setArtistLabel(artist: Artist) {
        artistLabel.text = artist.name
        
    }
    func setArtistImage(artist: Artist) {
        if let data = artist.profileImageData {
            artistImageView.image = UIImage(data: data)
            artistImageView.setRounded()
        }
    }
    func check() {
        checkImage.image = UIImage(systemName: "checkmark.circle.fill")
        checked = true
    }
    func uncheck() {
        checkImage.image = UIImage(systemName: "circle")
        checked = false
    }
    
      
}
