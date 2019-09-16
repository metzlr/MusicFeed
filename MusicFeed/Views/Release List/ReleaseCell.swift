//
//  ReleaseCell.swift
//  SpotifyAlert
//
//  Created by Reed Metzler-Gilbertz on 8/8/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class ReleaseCell: UITableViewCell {
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    
    func setAlbumLabel(album: Album) {
        artistLabel.text = album.artists[0].name
        albumLabel.text = album.name
    }
    func setAlbumImage(album: Album) {
        if let data = album.largeImageData {
            albumImageView.image = UIImage(data: data)
        }
        
        /*
        if let url = album.smallImageURL {
            albumImageView.af_setImage(
                withURL: url
                // placeholderImage: placeholderImage
            )
            
            // Could also use AlamoFireImage built in image method to make image circle
            //albumImageView.setRounded()
        } else {
            albumImageView.image = nil
        }
 */
        
    }

}

