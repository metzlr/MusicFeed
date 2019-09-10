//
//  OldApiReferences.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 9/9/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation


// RELEASE LIST VIEW CONTROLLER


/*
 let group = DispatchGroup()
 
 for artist in storageController!.artists {
 let resource = AlbumsResource(artist: artist)
 let request = ApiRequest(resource: resource, oAuth: storageController!.authClient)
 self.storageController!.netRequests.append(request)
 //self.group.enter()
 group.enter()
 request.load() { [unowned self] response in
 guard let albums = response else {
 return
 }
 for album in albums {
 if Int(currentDate.timeIntervalSince(album.releaseDate)) <= TimeDuration.month {
 self.storageController!.releases.append(album)
 }
 }
 
 self.storageController!.releases.sort()
 //self.group.leave()
 group.leave()
 //self.tableView.reloadData()
 }
 }
 group.notify(queue: .main) {
 self.storageController!.netRequests.removeAll()
 print("done")
 self.tableView.reloadData()
 }
 */
//let loader = OAuth2DataLoader(oauth2: storageController!.authClient)
/*
 for artist in storageController!.artists {
 getArtistAlbums(artist: artist, loader: storageController!.loader) {[unowned self] response in
 guard let albums = response else {
 return
 }
 for album in albums {
 if Int(currentDate.timeIntervalSince(album.releaseDate)) <= TimeDuration.month {
 print(album.name)
 self.storageController!.releases.append(album)
 
 }
 }
 
 self.storageController!.releases.sort()
 self.tableView.reloadData()
 }
 }
 */

/*
 let dispatchGroup = DispatchGroup()
 
 for artist in storageController!.artists {
 
 dispatchGroup.enter()
 
 let resource = AlbumsResource(artist: artist)
 let request = ApiRequest(resource: resource, loader: storageController!.loader)
 storageController!.netRequests.append(request)
 request.load() { [unowned self] albums in
 guard let albums = albums else {
 return
 }
 
 for album in albums {
 if Int(currentDate.timeIntervalSince(album.releaseDate)) <= TimeDuration.month {
 self.storageController!.releases.append(album)
 
 }
 }
 
 self.storageController!.releases.sort()
 
 let albumsCopy = self.storageController!.releases.map {$0}
 for i in 0..<albumsCopy.count {
 dispatchGroup.enter()
 var album = albumsCopy[i]
 let imgRequest = ImageRequest(url: album.urlImages.last!.url, loader: self.storageController!.loader)
 self.storageController!.netRequests.append(imgRequest)
 imgRequest.load() { [unowned self]
 image in
 guard let image = image else {
 return
 }
 
 album.imageData = image
 self.storageController!.releases[i] = album
 
 dispatchGroup.leave()
 }
 }
 
 dispatchGroup.leave()
 
 
 
 }
 }
 
 dispatchGroup.notify(queue: DispatchQueue.main) {
 print(self.storageController!.releases.count)
 self.tableView.reloadData()
 self.storageController!.netRequests.removeAll()
 
 }
 */


// ARTIST SEARCH VIEW CONTROLLER

/*
 if NetStatus.shared.isConnected {
 
 let resource = ArtistSearchResource(searchText: text)
 let request = ApiRequest(resource: resource, oAuth: storageController!.authClient)
 self.storageController!.netRequests.append(request)
 request.load() { response in
 guard let artists = response else {
 return
 }
 self.searchResults = artists
 let group = DispatchGroup()
 var artistsCopy = artists.map {$0}
 for i in 0..<self.searchResults.count {
 group.enter()
 var artist = self.searchResults[i]
 //print(artist.name + " "+String(i))
 guard let urlImages = artist.urlImages, artist.urlImages!.count > 0 else {
 continue
 }
 let imgRequest = ImageRequest(url: urlImages.last!.url)
 self.storageController!.netRequests.append(imgRequest)
 imgRequest.load() { [unowned self]
 image in
 guard let image = image else {
 return
 }
 
 artist.imageData = image
 //print(artist.name + " "+String(i))
 artistsCopy[i] = artist
 
 
 group.leave()
 }
 }
 group.notify(queue: .main) {
 self.storageController!.netRequests.removeAll()
 self.searchResults = artistsCopy
 self.tableView.reloadData()
 }
 //group.leave()
 }
 /*
 getArtistSearch(text: text, oauth: storageController!.authClient) {[unowned self] response in
 guard let artists = response else {
 return
 }
 self.searchResults = artists
 self.tableView.reloadData()
 
 }
 */
 
 /*
 //dispatchGroup.enter()
 let resource = ArtistSearchResource(searchText: text)
 let request = ApiRequest(resource: resource, loader: storageController!.loader)
 storageController!.netRequests.append(request)
 request.load() { [unowned self] artists in
 guard let artists = artists else {
 return
 }
 self.searchResults = artists
 self.tableView.reloadData()
 
 /*
 let artistsCopy = artists.map {$0}
 for i in 0..<self.searchResults.count {
 dispatchGroup.enter()
 var artist = self.searchResults[i]
 print(artist.name + " "+String(i))
 guard let urlImages = artist.urlImages, artist.urlImages!.count > 0 else {
 continue
 }
 let imgRequest = ImageRequest(url: urlImages.last!.url, loader: self.storageController!.loader)
 self.storageController!.netRequests.append(imgRequest)
 imgRequest.load() { [unowned self]
 image in
 guard let image = image else {
 return
 }
 
 artist.imageData = image
 print(artist.name + " "+String(i))
 self.searchResults[i] = artist
 
 
 dispatchGroup.leave()
 }
 }
 dispatchGroup.leave()
 */
 }
 /*
 dispatchGroup.notify(queue: .main) {
 self.storageController!.netRequests.removeAll()
 print("req done")
 self.tableView.reloadData()
 }
 */
 
 */
 
 }
 */

