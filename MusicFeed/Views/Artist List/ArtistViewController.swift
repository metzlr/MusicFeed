//
//  ArtistSearchViewController.swift
//  SpotifyAlert
//
//  Created by Reed Metzler-Gilbertz on 8/9/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editArtistButton: UIBarButtonItem!
    @IBOutlet weak var addArtistButton: UIBarButtonItem!
    
    @IBOutlet weak var removeAllButton: UIBarButtonItem!
    @IBAction func editArtistTapped(_ sender: UIBarButtonItem) {
        
        if tableView.isEditing {
            addArtistButton.isEnabled = false
            addArtistButton.tintColor = .clear
            removeAllButton.isEnabled = false
            removeAllButton.tintColor = .clear
            editArtistButton.title = "Edit"
        } else {
            editArtistButton.title = "Done"
            addArtistButton.isEnabled = true
            addArtistButton.tintColor = nil
            removeAllButton.isEnabled = true
            removeAllButton.tintColor = nil
        }
        tableView.isEditing = !tableView.isEditing
        
    }
    @IBAction func removeAllTapped(_ sender: Any) {
        storageController!.artists = [Artist]()
        storageController!.saveArtistsToFile()
        tableView.reloadData()
    }
    
    var storageController: StorageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //navigationItem.rightBarButtonItems = [editButtonItem,addArtistButton]
        
        addArtistButton.isEnabled = false
        addArtistButton.tintColor = .clear
        
        removeAllButton.isEnabled = false
        removeAllButton.tintColor = .clear

        tableView.allowsSelection = false
        

    }
    
    @IBAction func unwindToArtistList(sender: UIStoryboardSegue) {
        if let source = sender.source as? ArtistSearchViewController, let artist = source.selectedArtist {
            let newIndexPath = IndexPath(row: storageController!.artists.count, section: 0)
            storageController!.artists.append(artist)
            storageController!.saveArtistsToFile()
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.isEditing = false
        addArtistButton.isEnabled = false
        addArtistButton.tintColor = .clear
        removeAllButton.isEnabled = false
        removeAllButton.tintColor = .clear
        editArtistButton.title = "Edit"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController {
            for view in nc.viewControllers {
                if let vc = view as? ArtistSearchViewController {
                    vc.storageController = storageController
                }
            }
            
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    

}
extension ArtistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storageController!.artists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell") as! ArtistCell
        let artist = storageController!.artists[indexPath.row]
        cell.setArtistImage(artist: artist)
        cell.setArtistLabel(artist: artist)
        
        return cell
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            storageController!.artists.remove(at: indexPath.row)
            storageController!.saveArtistsToFile()
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    // Old method that was called by programatically added edit button
    
    /*
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = !tableView.isEditing
        
        if addArtistButton.isEnabled {
            addArtistButton.isEnabled = false
            addArtistButton.tintColor = .clear
        } else {
            addArtistButton.isEnabled = true
            addArtistButton.tintColor = nil
        }
    }
 */
    
 

}

