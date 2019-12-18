//
//  SetupSearchController.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 11/30/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import UIKit

class SetupSearchController: UIViewController {
    
    @IBOutlet weak var listPreviewTable: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
        

    var storageController: StorageController?
    
    var selectedList: ArtistList?
    var detailList: ArtistList?
    var selectedCellIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchButton.isEnabled = false
    
        
        listPreviewTable.dataSource = self
        listPreviewTable.delegate = self
        listPreviewTable.allowsSelection = true
        
        //selectedList = storageController!.artistLists[0]

    }
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "New List", message: "Enter a name", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            var name = alertController.textFields?[0].text
            if name == nil || name == "" {
                name = "New List"
            }
            let newList = ArtistList(name: name!, canEdit: true)
            if let index = self.storageController!.artistLists.firstIndex(of: newList) {
                newList.name = self.storageController!.artistLists[index].name + " (1)"
            }
            self.storageController!.artistLists.append(newList)
            self.listPreviewTable.reloadData()
        
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ArtistListDetailController  {
            vc.list = detailList
            vc.storageController = self.storageController!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.listPreviewTable.reloadData()
        
    }

   
}

extension SetupSearchController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard indexPath.row > 0 else {
            return
        }
        detailList = self.storageController!.artistLists[indexPath.row - 1]
        performSegue(withIdentifier: "ListAccessoryTapped", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row > 0) { // Selected a list
            if selectedCellIndex != nil {
                let previousCell = tableView.cellForRow(at: selectedCellIndex!) as! ArtistListCell
                //previousCell!.accessoryType = .none
                previousCell.uncheck()
            }
            selectedCellIndex = indexPath
            let newCell = tableView.cellForRow(at: indexPath) as! ArtistListCell
            newCell.check()
            //newCell!.accessoryType = .checkmark
            selectedList = self.storageController!.artistLists[indexPath.row-1]
            searchButton.isEnabled = true
        } else { // Selected create new
            showInputDialog()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.storageController!.artistLists.count + 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if (indexPath.row == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateNewCell") as! CreateNewCell
            cell.setPlusImage()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistListCell") as! ArtistListCell
            cell.setListLabel(list: self.storageController!.artistLists[indexPath.row-1])
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Select an Artist List"
        
    }
    
}

/*
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
*/
