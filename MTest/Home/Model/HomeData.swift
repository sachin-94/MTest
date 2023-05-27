//
//  HomeData.swift
//  MTest
//
//  Created by Sachin George on 27/05/23.
//

import Foundation

struct HomeData: Codable {
    let status: Bool
    let homeData: [HomeDataArray]
}

struct HomeDataArray: Codable {
    let type: String
    let values: [ValueArray]
}

struct ValueArray: Codable {
    let id: Int?
    let name: String?
    let imageUrl: String?
    let bannerUrl: String?
    let image: String?
    let actualPrice: String?
    let offerPrice: String?
    let offer: Int?
    let isExpress: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, image, offer
        case imageUrl = "image_url"
        case bannerUrl = "banner_url"
        case actualPrice = "actual_price"
        case offerPrice = "offer_price"
        case isExpress = "is_express"
    }
}
