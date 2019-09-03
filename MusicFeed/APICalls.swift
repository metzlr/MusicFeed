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
    func load(url: URL, httpMethod: String, parameters: [String], loader: OAuth2DataLoader, withCompletion completion: @escaping (Model?) -> Void) {
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
    }
}


class ApiRequest<Resource: ApiResource> {
    let resource: Resource
    let loader: OAuth2DataLoader
    
    init(resource: Resource, loader: OAuth2DataLoader) {
        self.resource = resource
        self.loader = loader
    }
}
extension ApiRequest: NetworkRequest {
    
    func decode(_ data: Data) -> [Resource.Model]? {
        return resource.makeModel(data: data)
        
    }
    
    func load(withCompletion completion: @escaping ([Resource.Model]?) -> Void) {
        load(url: resource.url, httpMethod: resource.httpMethod, parameters: resource.parameters, loader: loader, withCompletion: completion)
    }
}


extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}






