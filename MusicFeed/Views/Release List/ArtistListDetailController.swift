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
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editToolBar: UIToolbar!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var selectAll: UIBarButtonItem!
    @IBOutlet weak var deselectAll: UIBarButtonItem!
    
    @IBAction func editTapped(_ sender: Any) {
        if (artistTable.isEditing) {
            doneEditing()
        } else {
            startEditing()
        }
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        if (!artistTable.isEditing) {
            self.performSegue(withIdentifier: "AddArtistSegue", sender: self)
        } else {
            showInputDialog()
        }
    }
    @IBAction func deleteTapped(_ sender: Any) {
        for indexPath in artistTable.indexPathsForSelectedRows! {
            let cell = artistTable.cellForRow(at: indexPath) as! ArtistCell
            let removeIndex = list!.artists.firstIndex(of: cell.artist)
            list!.artists.remove(at: removeIndex!)
            artistTable.deselectRow(at: indexPath, animated: false)
        }
        storageController!.saveArtistListsToFile()
        artistTable.reloadData()
    }
    
    @IBAction func selectTapped(_ sender: Any) {
        for i in 0..<list!.artists.count {
            artistTable.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
            //artistTable.indexPathsForSelectedRows.append(IndexPath(row: i, section: 1))
        }
    }
    @IBAction func deselectTapped(_ sender: Any) {
        for indexPath in artistTable.indexPathsForSelectedRows! {
            artistTable.deselectRow(at: indexPath, animated: false)
            //artistTable.indexPathsForSelectedRows.append(IndexPath(row: i, section: 1))
        }
    }
    
    var list: ArtistList?
    var storageController: StorageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if !list!.canEdit {
            editButton.isEnabled = false
            addButton.isEnabled = false
            //renameButton.isEnabled = false
            //renameButton.tintColor = .clear
            
        }
        artistTable.delegate = self
        artistTable.dataSource = self
        
        artistTable.allowsMultipleSelectionDuringEditing = true
        
        editToolBar.isHidden = true
        addButton.image = UIImage(systemName: "plus")
        addButton.title = nil
        //renameButton.isEnabled = false
        //renameButton.tintColor = .clear
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController {
            for view in nc.viewControllers {
                if let vc = view as? AddArtistToListController {
                    vc.storageController = storageController!
                    vc.list = list
                }
            }
            
        }
    }
    
    @IBAction func unwindToArtistListDetail(sender: UIStoryboardSegue) {
        if let source = sender.source as? AddArtistToListController {
            //let newIndexPath = IndexPath(row: storageController!.artists.count, section: 0)
            //storageController!.artists.append(artist)
            storageController!.saveArtistListsToFile()
            artistTable.reloadData()
            //tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        }
        
    }
    
    func startEditing() {
        editButton.title = "Done"
        artistTable.isEditing = true
        editToolBar.isHidden = false
        addButton.title = "Rename"
        addButton.image = nil
        //renameButton.isEnabled = true
        //renameButton.tintColor = .none
    }
    
    func doneEditing() {
        editButton.title = "Edit"
        artistTable.isEditing = false
        editToolBar.isHidden = true
        addButton.image = UIImage(systemName: "plus")
        addButton.title = nil
        //renameButton.isEnabled = false
        //renameButton.tintColor = .clear
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
        cell.setArtist(artist: list!.artists[indexPath.row])
        //cell.setArtistLabel(artist: list!.artists[indexPath.row])
        //cell.setArtistImage(artist: list!.artists[indexPath.row])
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Artists"
        
    }
    
}
