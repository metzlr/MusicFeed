//
//  APICalls.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 9/1/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

// FOR AUTH - CAN EITHER ADD CLIENT ID/SECRET ONTO END OF PARAMS USING '&' OR AS HEADER. IF ITS A HEADER IT NEEDS TO BE ENCODED



import Foundation
import OAuth2
import UIKit



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



protocol NetworkRequest: class {
    associatedtype Model
    func load(withCompletion completion: @escaping (Model?) -> Void)
    func decode(_ data: Data) -> Model?
}
extension NetworkRequest {
    func load(url: URL, httpMethod: String, parameters: [String] = [], headers: [String:String] = [:], oAuth: OAuth2? = nil, withCompletion completion: @escaping (Model?) -> Void) {
        
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        for (title,value) in headers {
            request.addValue(value, forHTTPHeaderField: title)
        }
                
        let task = session.dataTask(with: request) { [weak self] (data,response,error) in
            guard let data = data else {
                print("NETWORK REQUEST FAILED")
                print(error)
                completion(nil)
                return
            }
            guard let decoded = self?.decode(data) else {
                //let string = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                //print(string)
                /*
                guard let oAuth = oAuth else {
                    print("Request failed and no oAuth provided")
                    completion(nil)
                    return
                }
                oAuth.authorize() { [weak self] json, error in
                    if error != nil {
                        print(error!)
                    } else {
                        self?.load(url: url, httpMethod: httpMethod, parameters: parameters, headers: headers, oAuth: oAuth) { response in
                            guard let loadResponse = response else {
                                print("Load after reauth failed")
                                completion(nil)
                                return
                            }
                            completion(loadResponse)
                        }
                    }
                }
                */
                return
            }
            
            completion(self?.decode(data))
        }
        task.resume()
                
            
        /*
        loader.perform(request: request ) { [weak self] response in
            do {
                let data = try response.responseData()
                DispatchQueue.main.async {
                    completion(self?.decode(data))
                    
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    print(error)
                    completion(nil)
                }
            }
        }
        */
        
    }
}


class ApiRequest<Resource: ApiResource> {
    let resource: Resource
    let oAuth: OAuth2
    
    init(resource: Resource, oAuth: OAuth2) {
        self.resource = resource
        self.oAuth = oAuth
    }
}
extension ApiRequest: NetworkRequest {
    
    func decode(_ data: Data) -> [Resource.Model]? {
        return resource.makeModel(data: data)
        
    }
    
    func load(withCompletion completion: @escaping ([Resource.Model]?) -> Void) {
        let headers = ["Authorization":"Bearer \(oAuth.accessToken!)"]
        
        load(url: resource.url, httpMethod: resource.httpMethod, parameters: resource.parameters, headers: headers, withCompletion: completion)
    }
}

class ImageRequest {
    let url: URL
    //let loader: OAuth2DataLoader
    
    init(url: URL) {
        self.url = url
        //self.loader = loader
    }
}
extension ImageRequest: NetworkRequest {
    func decode(_ data: Data) -> Data? {
        return data
    }
    
    func load(withCompletion completion: @escaping (Data?) -> Void) {
        load(url: url, httpMethod: "GET", withCompletion: completion)
    }
}



/*

func getArtistAlbums(artist: Artist, loader: OAuth2DataLoader, completion: @escaping ([Album]?) -> Void) {
    let resource = AlbumsResource(artist: artist)
    
    let configuration = URLSessionConfiguration.ephemeral
    let session = URLSession(configuration: configuration)
    
    //let url = URL(string: "https://accounts.spotify.com/api/token")!
    var request = URLRequest(url: resource.url)
    request.httpMethod = resource.httpMethod
    
    /*
    var bodyParams = ""
    for p in parameters {
        bodyParams += p
    }
     */
    
    
    //let loader = OAuth2DataLoader(oauth2: oauth)
    
    //let group = DispatchGroup()
    //group.enter()
    
    let task = session.dataTask(with: request) { (data,response,error) in
        guard let data = data else {
            print(error)
            completion(nil)
            return
        }
        let decoded = resource.makeModel(data: data)
        guard let albums = decoded else {
            completion(nil)
            return
        }
        completion(albums)
        //group.leave()
        
    }
    task.resume()
    
    
    
    /*
    loader.perform(request: request) { response in
        do {
            let data = try response.responseData()
            DispatchQueue.main.async {
                
                let group = DispatchGroup()
                let decoded = resource.makeModel(data: data)
                guard let albums = decoded else {
                    completion(nil)
                    return
                }
                
                var copy = albums.map{$0}
                for i in 0..<albums.count {
                    var album = albums[i]
                    let imgURL = album.urlImages.last!.url
                    group.enter()
                    loader.perform(request: URLRequest(url: imgURL)) { response in
                        do {
                            let data = try response.responseData()
                            DispatchQueue.main.async {
                                album.imageData = data
                                copy[i] = album
                                group.leave()
                            }
                        }
                        catch let error {
                            DispatchQueue.main.async {
                                print(error)
                                completion(nil)
                            }
                        }
                    }
                }
                print(copy)
                
                group.notify(queue: .main) {
                    
                    completion(copy)
                }
                
            }
        }
        catch let error {
            DispatchQueue.main.async {
                print(error)
                completion(nil)
            }
        }
    }
    */
    
}


func getArtistSearch(text: String, oauth: OAuth2, completion: @escaping ([Artist]?) -> Void) {
    let resource = ArtistSearchResource(searchText: text)
    
    var request = URLRequest(url: resource.url)
    request.httpMethod = resource.httpMethod
    
    let loader = OAuth2DataLoader(oauth2: oauth)
    
    loader.perform(request: request) { response in
        do {
            
            let data = try response.responseData()
            
            DispatchQueue.main.async {
            
                let group = DispatchGroup()
                let decoded = resource.makeModel(data: data)
                guard let artists = decoded else {
                    completion(nil)
                    return
                }
                var copy = artists.map{$0}
                for i in 0..<artists.count {
                    var artist = artists[i]
                    guard let urlImages = artist.urlImages, urlImages.count > 0 else {
                        continue
                    }
                    let imgURL = urlImages.last!.url
                    group.enter()
                    loader.perform(request: URLRequest(url: imgURL)) { response in
                        do {
                            let data = try response.responseData()
                            DispatchQueue.main.async {
                                artist.imageData = data
                                copy[i] = artist
                                group.leave()
                            }
                        }
                        catch let error {
                            DispatchQueue.main.async {
                                print(error)
                                completion(nil)
                            }
                        }
                    }
                }
                group.notify(queue: .main) {
                    completion(copy)
                }
                
            }
        }
        catch let error {
            DispatchQueue.main.async {
                print(error)
                completion(nil)
            }
        }
    }
    
}
*/

/*

//let configuration = URLSessionConfiguration.ephemeral
//let session = URLSession(configuration: configuration)

//let url = URL(string: "https://accounts.spotify.com/api/token")!
var request = URLRequest(url: url)
request.httpMethod = httpMethod

var bodyParams = ""
for p in parameters {
    bodyParams += p
}

//request.httpBody = bodyParams.data(using: String.Encoding.ascii, allowLossyConversion: true)

/*
 for (title,value) in headers {
 request.addValue(value, forHTTPHeaderField: title)
 }
 */

loader.perform(request: request) { [weak self] response in
    do {
        let data = try response.responseData()
        DispatchQueue.main.async {
            completion(self?.decode(data))
            
        }
    }
    catch let error {
        DispatchQueue.main.async {
            print(error)
            completion(nil)
        }
    }
}


/*
 let task = session.dataTask(with: request) { [weak self] (data,response,error) in
 guard let data = data else {
 print("NETWORK REQUEST FAILED")
 print(response)
 print(error)
 completion(nil)
 return
 }
 
 completion(self?.decode(data))
 }
 task.resume()
 */

*/
