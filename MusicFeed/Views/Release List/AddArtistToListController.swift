//
//  AddArtistToListController.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 12/2/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class AddArtistToListController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var selectedArtists = [Artist]()
    var searchResults = [Artist]()
    var storageController: StorageController?
    var list: ArtistList?
    
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button == saveButton else {
            return
        }
        for artist in selectedArtists {
            if !(list!.artists.contains(artist)) {
                list!.artists.append(artist)
            }
        }
        
    }
    
}
extension AddArtistToListController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchResults.count
        }
        return storageController!.artistLists[0].artists.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddArtistToListCell") as! AddArtistToListCell
        if searching {
            let artist = searchResults[indexPath.row]
            cell.setArtistLabel(artist: artist)
            cell.setArtistImage(artist: artist)
            if selectedArtists.contains(artist) {
                cell.check()
            } else {
                cell.uncheck()
            }
            
        } else {
            let artist = self.storageController!.artistLists[0][indexPath.row]
            cell.setArtistLabel(artist: artist)
            cell.setArtistImage(artist: artist)
            if selectedArtists.contains(artist) {
                cell.check()
            } else {
                cell.uncheck()
            }
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AddArtistToListCell
        let artist: Artist?
        let selectedIndex: Int?
        if (searching) {
            selectedIndex = selectedArtists.firstIndex(of: searchResults[indexPath.row])
            artist = searchResults[indexPath.row]
        } else {
            selectedIndex = selectedArtists.firstIndex(of: storageController!.artistLists[0][indexPath.row])
            artist = storageController!.artistLists[0][indexPath.row]
        }
        if (cell.checked) {
            cell.uncheck()
            selectedArtists.remove(at: selectedIndex!)
        } else {
            cell.check()
            selectedArtists.append(artist!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Artists"
        
    }
    */
}
