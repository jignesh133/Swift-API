//
//  Model_store.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on December 8, 2018

import Foundation

struct Model_store : Codable {

        let catId : String
        let catName : String
        let storeAddress : String
        let storeContact : String
        let storeDetails : String
        let storeId : String
        let storeLatitude : String
        let storeLongitude : String
        let storeName : String
        let storePhotos : String
        let storeTotalRating : String
        let subcatId : String
        let subcatName : String

        enum CodingKeys: String, CodingKey {
                case catId = "cat_id"
                case catName = "cat_name"
                case storeAddress = "store_address"
                case storeContact = "store_contact"
                case storeDetails = "store_details"
                case storeId = "store_id"
                case storeLatitude = "store_latitude"
                case storeLongitude = "store_longitude"
                case storeName = "store_name"
                case storePhotos = "store_photos"
                case storeTotalRating = "store_total_rating"
                case subcatId = "subcat_id"
                case subcatName = "subcat_name"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                catId = try values.decodeIfPresent(String.self, forKey: .catId) ?? ""
                catName = try values.decodeIfPresent(String.self, forKey: .catName) ?? ""
                storeAddress = try values.decodeIfPresent(String.self, forKey: .storeAddress) ?? ""
                storeContact = try values.decodeIfPresent(String.self, forKey: .storeContact) ?? ""
                storeDetails = try values.decodeIfPresent(String.self, forKey: .storeDetails) ?? ""
                storeId = try values.decodeIfPresent(String.self, forKey: .storeId) ?? ""
                storeLatitude = try values.decodeIfPresent(String.self, forKey: .storeLatitude) ?? ""
                storeLongitude = try values.decodeIfPresent(String.self, forKey: .storeLongitude) ?? ""
                storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
                storePhotos = try values.decodeIfPresent(String.self, forKey: .storePhotos) ?? ""
                storeTotalRating = try values.decodeIfPresent(String.self, forKey: .storeTotalRating) ?? ""
                subcatId = try values.decodeIfPresent(String.self, forKey: .subcatId) ?? ""
                subcatName = try values.decodeIfPresent(String.self, forKey: .subcatName) ?? ""
        }

}
