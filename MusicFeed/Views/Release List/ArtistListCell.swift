//
//  ArtistListCell.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 12/1/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class ArtistListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    
    func setListLabel(list: ArtistList) {
        nameLabel.text = list.name
        
    }
    
    func check() {
        if checkImage.image == nil {
            checkImage.image = UIImage(systemName: "checkmark")
        }
        checkImage.isHidden = false
    }
    func uncheck() {
        checkImage.isHidden = true
    }
    
    
}
