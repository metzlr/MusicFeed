//
//  ArtistListCell.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 12/1/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class CreateNewCell: UITableViewCell {
    
    @IBOutlet weak var plusImageView: UIImageView!
    
    func setPlusImage() {
        plusImageView.image = UIImage(systemName: "plus")
        plusImageView.tintColor = .lightGray
    }
    
    
}
