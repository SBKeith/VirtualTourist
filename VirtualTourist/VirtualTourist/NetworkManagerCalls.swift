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
    var session: NSURLSession {
        return NSURLSession.sharedSession()
    }
    
    // Flickr request methods
    enum Method: String {
        case Get
        case post
        case Put
        case Delete
    }
    
    // Encoded query string
    class func encodeParameters(params: [String: AnyObject]) -> String {
        let components = NSURLComponents()
        components.queryItems = params.map { NSURLQueryItem(name: $0, value: String($1)) }
        
        return components.percentEncodedQuery ?? ""
    }
    
    // Setup NSMutable Request
    func setupRequest(url: String, method: Method = .Get, params: [String: AnyObject] = [String: AnyObject](), body: AnyObject? = nil) -> NSMutableURLRequest {
        
        let url = url + "?" + NetworkManagerCalls.encodeParameters(params)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = method.rawValue.uppercaseString
        
        if body != nil {
            do {
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(body!, options: [])
            }
        }
        return request
    }
    
    // Send request and parse result
    
    func getRequest(request: NSMutableURLRequest, handler: (result: AnyObject?, error: String?) -> Void) {
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Was there an error?
            guard error == nil else {
                print("There was an error with your request: \(error)")
                handler(result: nil, error: "Connection error")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let status = (response as? NSHTTPURLResponse)?.statusCode where status != 403 else {
                print("Bad status code (403)")
                handler(result: nil, error: "Login information incorrect")
                return
            }
            
            // Any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                handler(result: nil, error: "Connection error")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                handler(result: nil, error: "Connection error")
                return
            }
            handler(result: parsedResult, error: nil)
        }
        task.resume()
    }
}