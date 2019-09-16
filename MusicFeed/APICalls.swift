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
    
    private var delegate: StorageController?
    let clientSessionManager: SessionManager
    let implicitSessionManager: SessionManager
    var reqDelay: Double = 0.0
    
    let queue = DispatchQueue(label: "com.spotiy.api", qos: .background, attributes: .concurrent)
    
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
    
    func getImage(url: URL, queue: DispatchQueue, completion: @escaping (Data?) -> Void) {
        clientSessionManager.request(url).validate().responseData(queue: queue) { response in
            let code = response.response?.statusCode
            if code == 429 {
                if let retryTimeString = response.response?.allHeaderFields["retry-after"] as? String {
                    
                    let retryTime = Int(retryTimeString)!
                    self.reqDelay = Double(retryTime)
                    self.getImage(url: url, queue: queue) { response in
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
        //let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
        clientSessionManager.request(resource.url).validate().responseJSON(queue: queue) { [unowned self] response in
            guard let data = response.data else {
                print("Artist search failed")
                completion(nil)
                return
            }
            guard let artists = resource.makeModel(data: data) else {
                print("Wasn't able to decode request response")
                print(String(data: data, encoding: .utf8)!)
                completion(nil)
                return
            }
            
            
            
            self.getArtistImages(artists: artists, queue: self.queue) { artists in
                completion(artists)
                print("done")
            }
        }
    }
    
    func getNewestAlbums(artist: Artist, completion: @escaping ([Album]?) -> Void) {
        //print(reqDelay)
        let resource = AlbumsResource(artist: artist)
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + reqDelay) {
        queue.asyncAfter(deadline: .now() + reqDelay) {
            
            self.clientSessionManager.request(resource.url).validate().responseJSON(queue: self.queue) { [unowned self] response in
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
                            //album.releaseDate.addTimeInterval(TimeDuration.day)
                            newAlbums.append(album)
                        }
                    }
                    self.getAlbumImages(albums: newAlbums, queue: self.queue) { finalAlbums in
                        completion(finalAlbums)
                    }
                }
                
            
            }
        }
    }
    func getAlbumImages(albums: [Album], queue: DispatchQueue, completion: @escaping ([Album]) -> Void) {
        let group = DispatchGroup()
        var returnAlbumList = [Album]()
        
        for i in 0..<albums.count {
            group.enter()
            var album = albums[i]
            queue.asyncAfter(deadline: .now() + reqDelay) {
                self.getImage(url: album.urlImages.first!.url, queue: queue) { response in
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
    
    func getArtistImages(artists: [Artist], queue: DispatchQueue, completion: @escaping ([Artist]) -> Void) {
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
            //DispatchQueue.main.asyncAfter(deadline: .now() + reqDelay) {
            queue.asyncAfter(deadline: .now() + reqDelay) {
                self.getImage(url: last.url, queue: queue) { response in
                    guard let data = response else {
                        group.leave()
                        return
                    }
                    artist.profileImageData = data
                    returnArtistList[i] = artist
                    group.leave()
                }
            }
        
        }
        group.notify(queue: queue) {
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
        
        //let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
        implicitSessionManager.request(resource.url).responseJSON(queue: queue) { [unowned self] response in
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
            
            self.getArtistImages(artists: artists, queue: self.queue) { [unowned self] artists in
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
