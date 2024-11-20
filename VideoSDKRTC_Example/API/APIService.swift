//
//  APIService.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 20/01/23.
//

import Foundation

enum EndPoint {
    case getToken
    case createMeeting(String)
    case validateMeeting(String, String)
    
    var baseURL: URL {
        URL(string: AUTH_URL)!
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
}
