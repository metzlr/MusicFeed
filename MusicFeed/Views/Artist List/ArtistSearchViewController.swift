//
//  ArtistSearchViewController.swift
//  SpotifyAlert
//
//  Created by Reed Metzler-Gilbertz on 8/9/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//


import UIKit

class ArtistSearchViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedArtist: Artist?
    var storageController: StorageController?
    
    var searchResults = [Artist]()
    
    var searchTask: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedArtist = searchResults[indexPath.row]
            
        }
    }
    func presentDuplicateAlert() {
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        let alert = UIAlertController(title: "Notice", message: "This artist is already saved", preferredStyle: .alert)
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    func artistSearch(text: String) {
        self.searchTask?.cancel()
        if NetStatus.shared.isConnected {
            let task = DispatchWorkItem {
                self.storageController!.apiRequests.artistSearch(text: text) { [unowned self] response in
                    guard let artists = response else {
                        return
                    }
                    DispatchQueue.main.async {
                    
                        self.searchResults = artists
                        self.tableView.reloadData()
                    }
                }
            }
            self.searchTask = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: task)
            
        }
    }
    
    

}
extension ArtistSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSearchCell") as! ArtistSearchCell
        let artist = searchResults[indexPath.row]
        cell.setArtistLabel(artist: artist)
        cell.setArtistImage(artist: artist)
        
        return cell
    }
}
extension ArtistSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = searchResults[indexPath.row]
        if storageController!.artists.contains(where: {$0 == artist}) {
            presentDuplicateAlert()
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            saveButton.isEnabled = true
        }
    }
}

extension ArtistSearchViewController: UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        saveButton.isEnabled = false
        if !searchText.isEmpty {
            artistSearch(text: searchText)
        }
        
    }
}




