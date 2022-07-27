//
//  joinRoom.swift
//  VideoSDK_Example
//
//  Created by ANSUYA on 11/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

// MARK: - EarningDetailsStruct
struct RoomsStruct: Codable {
    let createdAt, updatedAt, roomID: String?
    let links: Links?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case createdAt, updatedAt
        case roomID = "roomId"
        case links, id
    }
}

// MARK: - Links
struct Links: Codable {
    let getRoom, getSession: String?

    enum CodingKeys: String, CodingKey {
        case getRoom = "get_room"
        case getSession = "get_session"
    }
}
