//
//  APIService.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 25/10/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import Foundation

<<<<<<< HEAD
=======
let LOCAL_SERVER_URL = "https://dev-ios-api.zujonow.com"

>>>>>>> da4f5e8d577141b9b4a2514a23d7835bff88ca3b
enum EndPoint {
    case getToken
    case createMeeting(String)
    case validateMeeting(String, String)
    
    var baseURL: URL {
<<<<<<< HEAD
        URL(string: AUTH_URL)!
=======
        URL(string: LOCAL_SERVER_URL)!
>>>>>>> da4f5e8d577141b9b4a2514a23d7835bff88ca3b
    }
    
    var value: String {
        switch self {
        case .getToken:
            return "get-token"
        case .createMeeting:
            return "create-meeting"
        case .validateMeeting(let meetingId, _):
            return "validate-meeting/\(meetingId)"
        }
    }
    
    var method: String {
        switch self {
        case .createMeeting, .validateMeeting:
            return "POST"
        default:
            return "GET"
        }
    }
    
    var body: Data? {
        switch self {
        case .getToken:
            return nil
        
        case .createMeeting(let token):
            let params = ["token": token]
            return try? JSONSerialization.data(withJSONObject: params, options: [])
            
        case .validateMeeting(_, let token):
            let params = ["token": token]
            return try? JSONSerialization.data(withJSONObject: params, options: [])
        }
    }
    
    var request: URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(value))
        request.httpMethod = method
        request.httpBody = body
        return request
    }
}


class APIService {
    
    class func getToken(completion: @escaping (Result<String, Error>) -> Void) {
        let request = EndPoint.getToken.request
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let token = data.toJSON()["token"] as? String {
                completion(.success(token))
            } else if let err = error {
                completion(.failure(err))
            }
        }
        .resume()
    }
    
    class func createMeeting(token: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = EndPoint.createMeeting(token).request
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let meetingId = data.toJSON()["meetingId"] as? String {
                completion(.success(meetingId))
            } else if let err = error {
                completion(.failure(err))
            }
        }
        .resume()
    }
    
    class func validateMeeting(id: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = EndPoint.validateMeeting(id, token).request
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let meetingId = data.toJSON()["meetingId"] as? String {
                completion(.success(meetingId))
            } else if let err = error {
                completion(.failure(err))
            }
        }
        .resume()
    }
}
