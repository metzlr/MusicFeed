//
//  LaunchViewController.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 11/30/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit


@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}


class LaunchViewController: UIViewController {
    
    var connectingView: UIViewController?
    var searchSetupView: SetupSearchController?
    
    var storageController: StorageController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        connectingView = storyboard.instantiateViewController(identifier: "ConnectingView")
        searchSetupView = storyboard.instantiateViewController(identifier: "SetupSearchController")
        searchSetupView?.storageController = storageController!
        
        
        self.add(searchSetupView!, frame: self.view.frame)
        
    }
    


}
