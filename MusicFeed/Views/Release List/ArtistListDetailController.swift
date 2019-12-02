//
//  ArtistListDetailController.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 12/2/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class ArtistListDetailController: UIViewController {

    @IBOutlet weak var artistTable: UITableView!
    @IBOutlet weak var renameButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var selectAll: UIBarButtonItem!
    @IBOutlet weak var deselectAll: UIBarButtonItem!
    
    @IBAction func renameTapped(_ sender: Any) {
        showInputDialog()
    }
    @IBAction func editTapped(_ sender: Any) {
    }
    @IBAction func selectTapped(_ sender: Any) {
    }
    @IBAction func deselectTapped(_ sender: Any) {
    }
    
    var list: ArtistList?
    var storageController: StorageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !list!.canEdit {
            renameButton.isEnabled = false
            addButton.isEnabled = false
            
        }
        artistTable.delegate = self
        artistTable.dataSource = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController {
            for view in nc.viewControllers {
                if let vc = view as? AddArtistToListController {
                    vc.storageController = storageController!
                }
            }
            
        }
    }
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Rename", message: "Enter a name", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            let name = alertController.textFields?[0].text
            if name != "" && name != nil {
                self.list!.name = name!
            }
        
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.text = self.list!.name
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }

}
extension ArtistListDetailController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return list!.artists.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell") as! ArtistCell
        cell.setArtistLabel(artist: list!.artists[indexPath.row])
        cell.setArtistImage(artist: list!.artists[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Artists"
        
    }
    
}
