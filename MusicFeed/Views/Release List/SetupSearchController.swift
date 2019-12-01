//
//  SetupSearchController.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 11/30/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class SetupSearchController: UIViewController {
    
    @IBOutlet weak var artistPreviewTable: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var listPicker: UIPickerView!
    
    @IBAction func searchTapped(_ sender: Any) {
        artistPreviewTable.reloadData()
    }
    var storageController: StorageController?
    
    var selectedList: ArtistList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listPicker.delegate = self
        listPicker.dataSource = self
        
        artistPreviewTable.dataSource = self
        artistPreviewTable.delegate = self
        
        selectedList = storageController!.artistLists[0]
        artistPreviewTable.reloadData()

    }

   
}

extension SetupSearchController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedList!.artists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSearchCell") as! ArtistSearchCell
        
        let artist = selectedList!.artists[indexPath.row]
        cell.setArtistImage(artist: artist)
        cell.setArtistLabel(artist: artist)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionTitle: String?
        
        sectionTitle = selectedList!.name
    
        return sectionTitle
    }
    
}

extension SetupSearchController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return storageController!.artistLists.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return storageController!.artistLists[row].name
    }
    
    
    
}
