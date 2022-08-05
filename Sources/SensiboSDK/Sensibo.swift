//
//  Sensibo.swift
//  
//
//  Created by Alexey Siginur on 05/08/2022.
//

import Foundation

public class Sensibo {
    public static let shared = Sensibo()
    public static var apiKey = ""
    
    private init() {}
    
    public typealias RawResponse = (Result<[String: AnyHashable], Error>) -> Void
    
    public func getAllDevices(callback: @escaping RawResponse) {
        API.shared.send(method: .get, path: "/users/me/pods", callback: callback)
    }
    
    public func getDevicesInfo(deviceId: String, callback: @escaping RawResponse) {
        API.shared.send(method: .get, path: "/pods/\(deviceId)", callback: callback)
    }
    
    public func getACState(deviceId: String, callback: @escaping RawResponse) {
        API.shared.send(method: .get, path: "/pods/\(deviceId)/acStates", callback: callback)
    }
    
    public func getHistoricalMeasurements(deviceId: String, callback: @escaping RawResponse) {
        API.shared.send(method: .get, path: "/pods/\(deviceId)/historicalMeasurements", callback: callback)
    }
}
