//
//  ReleaseLoadingView.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 9/20/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import UIKit

class ReleaseLoadingView: UIViewController {
    
    @IBOutlet weak var progressLabel: UILabel!
    
    var currArtist: Int = 0
    var totalArtists: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func setTotal(total: Int) {
        totalArtists = total
        updateProgressLabel()
    }
    func incCurrArtist() {
        currArtist += 1
        updateProgressLabel()
    }
    func updateProgressLabel() {
        progressLabel.text = "\(currArtist) of \(totalArtists) Artists"
    }
    
}
