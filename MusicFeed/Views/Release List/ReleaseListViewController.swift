//
//  ViewController.swift
//  SpotifyAlert
//
//  Created by Reed Metzler-Gilbertz on 8/4/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//



import UIKit
import Alamofire
import Network


class ReleaseListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBAction func refreshButtonTapped(_ sender: Any) {
        if NetStatus.shared.isConnected {
            getAlbums()
        }
    }
    
    
    @IBOutlet weak var loadingLabel1: UILabel!
    @IBOutlet weak var loadingLabel2: UILabel!
    
    
    
    var releaseForDetail: Album?
    var storageController: StorageController?
    
    var daySection = [Album]()
    var weekSection = [Album]()
    var monthSection = [Album]()
    var sections = [[Album]]()
    
    var spinnerView: SpinnerViewController?
    var releaseProgressView: ReleaseLoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingLabel1.textColor = .clear
        self.loadingLabel2.textColor = .clear
        
        NetStatus.shared.startMonitoring()
        NetStatus.shared.netStatusChangeHandler = {
            DispatchQueue.main.async { [unowned self] in
                if !NetStatus.shared.isConnected {
                    self.tableView.allowsSelection = false
                    self.storageController!.state = .noConnection
                    self.tableView.reloadData()
                } else {
                    self.storageController!.state = .rest
                    self.tableView.allowsSelection = true
                    self.tableView.reloadData()
                }
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        storageController!.apiRequests.setDelegate(storageController!)
        
        
        if NetStatus.shared.isConnected {
            spinnerView = SpinnerViewController()
            //releaseProgressView =  (UIStoryboard(name: "Main",bundle: nil)).instantiateViewController(withIdentifier: "ReleaseLoadingView") as? ReleaseLoadingView
            createSpinnerView(child: spinnerView!)
            storageController?.authClient.authorize() { json, error in
                if error != nil {
                    print(error!)
                } else {
                    print("Successfully authorized")
                    self.storageController!.readArtistsFromFile() {
                        print("Artits read from file")
                        print("Getting releases")
                        self.getAlbums()
                    }
                }
                
            }
        }
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    // The selection action that presents detail view is set up in the storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReleaseDetailController {
            
            let indexPath = tableView.indexPathForSelectedRow!
            vc.release = sections[indexPath.section][indexPath.row]
            //vc.release = storageController!.releases[indexPath.row]
            //tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func updateProgressLabel(currArtist: Int, totalArtists: Int) -> String {
        return "\(currArtist) of \(totalArtists) Artists"
    }
    
    
    func getAlbums() {
        
        
        // Even need releases in storage?
        //self.storageController!.releases = [Album]()
        self.daySection = [Album]()
        self.monthSection = [Album]()
        self.weekSection = [Album]()
        self.sections = [[Album]]()
        
        if NetStatus.shared.isConnected {
            
            DispatchQueue.main.async {
                if self.spinnerView!.parent == nil {
                    self.createSpinnerView(child: self.spinnerView!)
                }
                /*
                if self.releaseProgressView!.parent == nil {
                    self.createReleaseLoadingView(child: self.releaseProgressView!)
                }
                */
                //self.loadingLabel1.isEnabled = true
                //self.loadingLabel2.isEnabled = true
                self.loadingLabel1.textColor = .darkGray
                self.loadingLabel2.textColor = .darkGray
            }
            var currArtist: Int = 0
            //var totalArtists: Int = self.storageController!.artists.count
            
            let currDate = Date()
            
            let group = DispatchGroup()
            //self.releaseProgressView!.setTotal(total: self.storageController!.artists.count)
            for artist in self.storageController!.artists {
                group.enter()
                storageController!.apiRequests.getNewestAlbums(artist: artist) { [unowned self] response in
                    guard let releases = response else {
                        return
                    }
                    currArtist += 1
                    self.loadingLabel2.text = self.updateProgressLabel(currArtist: currArtist, totalArtists: self.storageController!.artists.count)
                    for release in releases {
                        switch Int(currDate.timeIntervalSince(release.releaseDate)) {
                        case 0..<TimeDuration.day:
                            self.daySection.append(release)
                        case TimeDuration.day..<TimeDuration.week:
                            self.weekSection.append(release)
                        case TimeDuration.week..<TimeDuration.month:
                            self.monthSection.append(release)
                        default:
                            self.monthSection.append(release)
                        }
                    }
                    
                    self.sections = [self.daySection,self.weekSection,self.monthSection]
                    group.leave()
                   
                }
            }
            group.notify(queue: .main) {
                self.loadingLabel1.textColor = .clear
                self.loadingLabel2.textColor = .clear
                self.removeSpinnerView(child: self.spinnerView!)
                //self.spinnerView = nil
                var sortedSections = [[Album]]()
                for section in self.sections {
                    var copy = section.map{$0}
                    //copy.sort(by: {$0.artists[0].name < $1.artists[0].name})
                    copy.sort(by: {currDate.timeIntervalSince($0.releaseDate) < currDate.timeIntervalSince($1.releaseDate)})
                    sortedSections.append(copy)
                }
                self.sections = sortedSections
                self.tableView.reloadData()
                print("Done getting releases")
                
                
            }
        }
            
            
        
    }
    
}

extension ReleaseListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if storageController!.state == .rest {
            let section = self.sections[section]
            return section.count
        } else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReleaseCell") as! ReleaseCell
        if storageController!.state == .rest {
            
            let section = self.sections[indexPath.section]
            let album = section[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.setAlbumLabel(album: album)
            cell.setAlbumImage(album: album)
        } else {
            cell.artistLabel.text = storageController!.state.rawValue
            cell.albumLabel.text = nil
            cell.albumImageView.image = nil
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionTitle: String?
        
        if sections[section].count > 0 {
            switch section {
            case 0:
                sectionTitle = "Today"
            case 1:
                sectionTitle = "This Week"
            case 2:
                sectionTitle = "This Month"
            default:
                sectionTitle = "Unknown"
            }
        } else {
            sectionTitle = nil
        }
    
        return sectionTitle
    }
    
    
}



