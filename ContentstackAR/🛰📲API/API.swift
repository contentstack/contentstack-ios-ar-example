//
//  API.swift
//  ContentstackAR
//
//  Created by Uttam Ukkoji on 19/06/18.
//  Copyright © 2018 Contentstack. All rights reserved.
//

import Foundation
import Contentstack
enum APIManager {
    
    // Contentstack Initialisation
    static var fileManager = FileManager()
    static var 🛰 = Contentstack.stack(withAPIKey: StackConstants.🔑, accessToken: StackConstants.🗝, environmentName: StackConstants.🌅);

    static func fetchProducts📦🎁💼(_ completion: @escaping ([Any]) -> Void){
        let type : ContentType = APIManager.🛰.contentType(withName: CSARDemoConstants.📦🎁💼) // init Contentstack type with "product" name
        let productsQuery : Query = type.query() // init Contentstack query 'productQuery'
        productsQuery.cachePolicy = CachePolicy.NETWORK_ELSE_CACHE // setting Network policy for more info look CachePolicy in docs
        productsQuery.find { (type, res, err) in
            if let response = res, let results = response.getResult() {
                completion(results)
            }
        }
    }
    
    static func downloadUSDZfile(url: URL, completion: @escaping ()-> Void) {
        let filePath = APIManager.pathForDictionary.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: filePath.path) {
            completion()
        }else {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .returnCacheDataElseLoad
            let session = URLSession.init(configuration: config)
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 600.0)
            let sessionURL = session.downloadTask(with: request) { (location, urlresponse, error) in
                completion()
                if !FileManager.default.fileExists(atPath: APIManager.pathForDictionary.path) {
                    do {
                        try FileManager.default.createDirectory(atPath: APIManager.pathForDictionary.path, withIntermediateDirectories: true, attributes: nil)
                    }catch let error {
                        print(error)
                    }
                }
                try? FileManager.default.copyItem(atPath: location!.path, toPath: filePath.path)
            }
            sessionURL.resume()
        }
    }
    
    static var pathForDictionary : URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.count-1].appendingPathComponent("USDZStore")
    }()
}
