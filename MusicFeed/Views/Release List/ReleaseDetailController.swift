//
//  ReleaseDetailController.swift
//  SpotifyAlert
//
//  Created by Reed Metzler-Gilbertz on 8/13/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class ReleaseDetailController: UIViewController {
    
    @IBOutlet weak var releaseImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBAction func openInSpotifyTapped(_ sender: Any) {
        let spotifyURL = release!.externalURL
        if let url = URL(string: spotifyURL) {
            UIApplication.shared.open(url)
        }
    }
    
    var release: Album?
    //var storageController: StorageController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let release = self.release else {
            print("Error: No release given")
            return
        }
        setAlbumImage(album: release)
        titleLabel.text = release.name
        var type = release.type
        type.capitalizeFirstLetter()
        typeLabel.text = type
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale =  Locale(identifier: "en_US_POSIX")
        dateLabel.text = dateFormatter.string(from: release.releaseDate)
        
        var artistListString = release.artists[0].name
        for i in release.artists.startIndex+1..<release.artists.endIndex {
            let artist = release.artists[i]
            artistListString += ", \(artist.name)"
        }
        artistLabel.text = artistListString

    }
    private func setAlbumImage(album: Album) {
        if let data = album.largeImageData {
            releaseImageView.image = UIImage(data: data)
        }
        
        /*
        
        if let url = album.largeImageURL {
            releaseImageView.af_setImage(
                withURL: url
                // placeholderImage: placeholderImage
            )
            // Could also use AlamoFireImage built in image method to make image circle
            //albumImageView.setRounded()
        } else {
            releaseImageView.image = nil
        }
        */
    }

    

}

