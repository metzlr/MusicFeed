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
    
    var oauth2 = OAuth2ImplicitGrant(settings: [
        "client_id": "08037a6d6c044109a99a46b267ed48f3",
        "keychain": false,
        "authorize_uri": "https://accounts.spotify.com/authorize",
        "scope": "user-follow-read",
        "redirect_uris": ["spotifyalert-rmg://oauth/callback"]
        ] as OAuth2JSON)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        
        
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
            
            oauth2.authorize(params: ["show_dialog": "true"]) { [unowned self]
                json, error in
                if error != nil {
                    print(error!)
                } else {
                    print(self.oauth2.accessToken)
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

