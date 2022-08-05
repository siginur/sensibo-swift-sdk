//
//  API.swift
//  
//
//  Created by Alexey Siginur on 05/08/2022.
//

import Foundation

private let server = "https://home.sensibo.com/api/v2"
typealias JSON = [String: AnyHashable]

class API {
    
    static let shared = API()
    
    private let session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        return URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    }()

    private init() {}
    
    func send(method: HTTPMethod, path: String, params: [String: String]? = nil, callback: @escaping (Result<JSON, Error>) -> Void) {
        var params = params ?? [:]
        params["apiKey"] = Sensibo.apiKey
        guard
            let paramsString = params.queryParameters,
            let url = URL(string: "\(server)\(path)?\(paramsString)")
        else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                callback(.failure(error))
                return
            }
            guard let data = data else {
                callback(.failure(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Data is nil"))))
                return
            }
            
            let json: JSON?
            do {
                json = try JSONSerialization.jsonObject(with: data) as? JSON
            } catch {
                callback(.failure(error))
                return
            }
            guard let json = json else {
                callback(.failure(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unable to parse JSON data"))))
                return
            }
            
            callback(.success(json))
        })
        task.resume()
    }
    
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}

enum SensiboError: Error {
    
}

extension Dictionary {
    var queryParameters: String? {
        var parts: [String] = []
        for (key, value) in self {
            guard
                let encodedKey = String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let encodedValue = String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else {
                return nil
            }
            parts.append("\(encodedKey)=\(encodedValue)")
        }
        return parts.joined(separator: "&")
    }
}
