//
//  APICalls.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 9/7/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import OAuth2
import Alamofire



protocol ApiResource {
    associatedtype Model
    var methodPath: String {get}
    var httpMethod: String {get}
    var parameters: [String] {get}
    //var headers: [String:String] {get}
    func makeModel(data: Data) -> [Model]?
}
extension ApiResource {
    var url: URL {
        let baseUrl = "https://api.spotify.com/v1/"
        var url = baseUrl+methodPath
        if parameters.count > 0 {
            url += "?"
            for p in parameters {
                if p != parameters.last {
                    url += p + "&"
                } else {
                    url += p
                }
            }
        }
        let noSpaceUrl = url.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        return URL(string: noSpaceUrl)!
    }
}


class APICalls {
    
    var delegate: StorageController?
    let sessionManager: SessionManager
    
    init() {
        //self.delegate = delegate
        sessionManager = SessionManager()
        
    }
    func setDelegate(_ delegate: StorageController) {
        self.delegate = delegate
        let retrier = OAuth2RetryHandler(oauth2: delegate.authClient)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
    }
    
    func getImage(url: URL, completion: @escaping (Data?) -> Void) {
        sessionManager.request(url).validate().responseData { response in
            guard let data = response.data else {
                print("Failed to get image from url")
                completion(nil)
                return
            }
            completion(data)
        }
    }
    
    func artistSearch(text: String, completion: @escaping ([Artist]?) -> Void) {
        let resource = ArtistSearchResource(searchText: text)
        
        sessionManager.request(resource.url).validate().responseJSON { [unowned self] response in
            guard let data = response.data else {
                print("Artist search failed")
                completion(nil)
                return
            }
            guard let artists = resource.makeModel(data: data) else {
                print("Wasn't able to decode request response")
                completion(nil)
                return
            }
            
            self.getArtistImages(artists: artists) { artists in
                completion(artists)
            }
        }
    }
    
    func getNewestAlbums(artist: Artist, completion: @escaping ([Album]?) -> Void) {
        
        let resource = AlbumsResource(artist: artist)
        sessionManager.request(resource.url).validate().responseJSON { [unowned self] response in
            guard let data = response.data else {
                print("Get new albums request failed for "+artist.name)
                completion(nil)
                return
            }
            guard let albums = resource.makeModel(data: data) else {
                print("Wasn't able to decode request response")
                completion(nil)
                return
            }
            
            self.getAlbumImages(albums: albums) { albums in
                completion(albums)
            }
        
        }
    }
    func getAlbumImages(albums: [Album], completion: @escaping ([Album]) -> Void) {
        let group = DispatchGroup()
        var returnAlbumList = [Album]()
        
        for i in 0..<albums.count {
            group.enter()
            var album = albums[i]
            self.getImage(url: album.urlImages.last!.url) { response in
                guard let data = response else {
                    group.leave()
                    return
                }
                album.imageData = data
                returnAlbumList.append(album)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(returnAlbumList)
        }
    }
    
    func getArtistImages(artists: [Artist], completion: @escaping ([Artist]) -> Void) {
        let group = DispatchGroup()
        var returnArtistList = [Artist]()
        
        for i in 0..<artists.count {
            group.enter()
            var artist = artists[i]
            guard let urlImages = artist.urlImages else {
                group.leave()
                continue
            }
            guard let last = urlImages.last else {
                group.leave()
                continue
            }
            self.getImage(url: last.url) { response in
                guard let data = response else {
                    group.leave()
                    return
                }
                artist.imageData = data
                returnArtistList.append(artist)
                group.leave()
            }
            
        }
        
        group.notify(queue: .main) {
            completion(returnArtistList)
        }
    }
}
