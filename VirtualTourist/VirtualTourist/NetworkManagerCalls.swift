//
//  NetworkManagerCalls.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 8/13/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation

class NetworkManagerCalls {
    
    // Session
    var session: URLSession {
        return URLSession.shared
    }
    
    // Flickr request methods
    enum Method: String {
        case Get
        case post
        case Put
        case Delete
    }
    
    // Encoded query string
    class func encodeParameters(_ params: [String: AnyObject]) -> String {
        var components = URLComponents()
        components.queryItems = params.map { URLQueryItem(name: $0, value: String(describing: $1)) }
        
        return components.percentEncodedQuery ?? ""
    }
    
    // Setup NSMutable Request
    func setupRequest(_ url: String, method: Method = .Get, params: [String: AnyObject] = [String: AnyObject](), body: AnyObject? = nil) -> NSMutableURLRequest {
        
        let url = url + "?" + NetworkManagerCalls.encodeParameters(params)
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue.uppercased()
        
        if body != nil {
            do {
                request.httpBody = try! JSONSerialization.data(withJSONObject: body!, options: [])
            }
        }
        return request
    }
    
    // Send request and parse result
    
    func getRequest(_ request: NSMutableURLRequest, handler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) {
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            // Was there an error?
            guard error == nil else {
                print("There was an error with your request: \(error)")
                handler(nil, "Connection error")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let status = (response as? HTTPURLResponse)?.statusCode, status != 403 else {
                print("Bad status code (403)")
                handler(nil, "Login information incorrect")
                return
            }
            
            // Any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                handler(nil, "Connection error")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                handler(nil, "Connection error")
                return
            }
            handler(parsedResult, nil)
        }) 
        task.resume()
    }
}
