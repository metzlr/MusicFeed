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
    let clientSessionManager: SessionManager
    let implicitSessionManager: SessionManager
    var reqDelay: Double = 0.0
    
    init() {
        clientSessionManager = SessionManager()
        implicitSessionManager = SessionManager()
        
    }
    func setDelegate(_ delegate: StorageController) {
        self.delegate = delegate
        let retrier1 = OAuth2RetryHandler(oauth2: delegate.authClient)
        clientSessionManager.adapter = retrier1
        clientSessionManager.retrier = retrier1
        
        let retrier2 = OAuth2RetryHandler(oauth2: delegate.authImplicit)
        implicitSessionManager.adapter = retrier2
        implicitSessionManager.retrier = retrier2
    }
    
    func getImage(url: URL, completion: @escaping (Data?) -> Void) {
        clientSessionManager.request(url).validate().responseData { response in
            let code = response.response?.statusCode
            if code == 429 {
                if let retryTimeString = response.response?.allHeaderFields["retry-after"] as? String {
                    
                    let retryTime = Int(retryTimeString)!
                    self.reqDelay = Double(retryTime)
                    self.getImage(url: url) { response in
                        guard let data = response else {
                            print("Retry failed")
                            completion(nil)
                            return
                        }
                        self.reqDelay = 0.0
                        completion(data)
                    }
                } else {
                    print("Couldn't get retry-after string from 429 response")
                }
                
            } else {
                guard let data = response.data else {
                    print("Failed to get image from url")
                    completion(nil)
                    return
                }
                completion(data)
            }
        }
    }
    
    func artistSearch(text: String, completion: @escaping ([Artist]?) -> Void) {
        let resource = ArtistSearchResource(searchText: text)
        
        clientSessionManager.request(resource.url).validate().responseJSON { [unowned self] response in
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
        //print(reqDelay)
        let resource = AlbumsResource(artist: artist)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reqDelay) {
            self.clientSessionManager.request(resource.url).validate().responseJSON { [unowned self] response in
                let code = response.response?.statusCode
                if code == 429 {
                    if let retryTimeString = response.response?.allHeaderFields["retry-after"] as? String {
                        
                        let retryTime = Int(retryTimeString)!
                        self.reqDelay = Double(retryTime)
                        self.getNewestAlbums(artist: artist) { response in
                            guard let albums = response else {
                                print("Retry failed")
                                completion(nil)
                                return
                            }
                            self.reqDelay = 0.0
                            completion(albums)
                        }
                    } else {
                        print("Couldn't get retry-after string from 429 response")
                    }
                    
                } else {
                    guard let data = response.data else {
                        print("Get new albums request failed for "+artist.name)
                        completion(nil)
                        return
                    }
                    guard let albums = resource.makeModel(data: data) else {
                        print("Wasn't able to decode request response")
                        print(String(data: data, encoding: .utf8)!)
                        completion(nil)
                        return
                    }
                    
                    var newAlbums = [Album]()
                    let currentDate = Date()
                    for album in albums {
                        if Int(currentDate.timeIntervalSince(album.releaseDate)) <= TimeDuration.month {
                            newAlbums.append(album)
                        }
                    }
                    self.getAlbumImages(albums: newAlbums) { finalAlbums in
                        completion(finalAlbums)
                    }
                }
                
            
            }
        }
    }
    func getAlbumImages(albums: [Album], completion: @escaping ([Album]) -> Void) {
        let group = DispatchGroup()
        var returnAlbumList = [Album]()
        
        for i in 0..<albums.count {
            group.enter()
            var album = albums[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + reqDelay) {
                self.getImage(url: album.urlImages.first!.url) { response in
                    //print("i" + String(i))
                    guard let data = response else {
                        group.leave()
                        return
                    }
                    album.largeImageData = data
                    returnAlbumList.append(album)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(returnAlbumList)
        }
    }
    
    func getArtistImages(artists: [Artist], completion: @escaping ([Artist]) -> Void) {
        let group = DispatchGroup()
        var returnArtistList = artists.map{$0}
        guard artists.count > 0 else {
            completion([Artist]())
            return
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + reqDelay) {
                self.getImage(url: last.url) { response in
                    guard let data = response else {
                        group.leave()
                        return
                    }
                    artist.profileImageData = data
                    returnArtistList[i] = artist
                    //print(artist.name)
                    group.leave()
                }
            }
        
        }
        group.notify(queue: .main) {
            //print("done")
            completion(returnArtistList)
        }
    
        
        
        
    }
    func userFollowersCall(afterCode:String? = nil, completion: @escaping ([Artist]?) -> Void) {
        
        //var artistArray = [Artist]()
        
        let resource: UserFollowersResource
        if let after = afterCode {
            resource = UserFollowersResource(afterCode: after)
        } else {
            resource = UserFollowersResource()
        }
        
        
        implicitSessionManager.request(resource.url).responseJSON() { [unowned self] response in
            guard let data = response.data else {
                print("Get user followers request failed")
                completion(nil)
                return
            }
            guard let responseObjList = resource.makeModel(data: data) else {
                print(String(data: data, encoding: .utf8)!)
                completion(nil)
                return
            }
            let responseObj = responseObjList[0]
            guard let artists = responseObj.artists else {
                completion(nil)
                return
            }
            var finalArtistArray = [Artist]()
            
            self.getArtistImages(artists: artists) { [unowned self] artists in
                finalArtistArray.append(contentsOf: artists)
                guard let nextAfter = responseObj.after else {
                    completion(finalArtistArray)
                    return
                }
                self.userFollowersCall(afterCode: nextAfter) {
                    nextResponse in
                    guard let nextArtists = nextResponse else {
                        completion(nil)
                        return
                    }
                    finalArtistArray.append(contentsOf: nextArtists)
                    completion(finalArtistArray)
                }
            }
        }
    }
}
