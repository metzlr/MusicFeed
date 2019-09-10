 //
 //  TableViewController.swift
 //  SpotifyAlert
 //
 //  Created by Reed Metzler-Gilbertz on 8/17/19.
 //  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
 //
 
 import UIKit
 import OAuth2
 
 
 class OtherScreenController: UITableViewController {
    
    var storageController: StorageController?
    var spinnerView: SpinnerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        
        storageController!.authImplicit.authConfig.authorizeEmbedded = true
        storageController!.authImplicit.authConfig.authorizeContext = self
        
        
    }
    /*
     override func viewDidAppear(_ animated: Bool) {
     
     }
     */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //super.tableView(tableView, didSelectRowAt: indexPath)
        if indexPath.row == 0 {
            
            storageController!.authImplicit.authorize(params: ["show_dialog": "true"]) { [unowned self]
                json, error in
                if error != nil {
                    print(error!)
                } else {
                    print("Successfully authorized user")
                    self.spinnerView = SpinnerViewController()
                    self.createSpinnerView(child: self.spinnerView!)
                    self.storageController!.apiRequests.userFollowersCall() { [unowned self] response in
                        guard let artists = response else {
                            return
                        }
                        
                        var duplicateCount = 0
                        for artist in artists {
                            if self.storageController!.artists.contains(where: {$0 == artist}) {
                                duplicateCount += 1
                            } else {
                                self.storageController!.artists.append(artist)
                            }
                        }
                        self.removeSpinnerView(child: self.spinnerView!)
                        self.spinnerView = nil
                        self.storageController!.saveArtistsToFile()
                        
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
                        let alert: UIAlertController
                        if duplicateCount > 0 {
                            
                            if duplicateCount > 1 {
                                alert = UIAlertController(title: "Notice", message: "\(duplicateCount) Artists from this profile have already been added", preferredStyle: .alert)
                            } else {
                                alert = UIAlertController(title: "Notice", message: "1 Artist from this profile has already been added", preferredStyle: .alert)
                            }
                            
                        } else {
                            alert = UIAlertController(title: "Success", message: "Artists imported from profile", preferredStyle: .alert)
                        }
                        alert.addAction(dismissAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
        
        
    }
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "importArtistsCell", for: indexPath)
     
     
     return cell
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
 }

