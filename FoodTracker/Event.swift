//
//  Meal.swift
//  FoodTrackerTests
//
//  Created by Huascar  Montero on 01/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import os.log
import UIKit

class Event: NSObject, NSCoding {
    
    // Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    var startDate: Date?
    var endDate: Date?
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
        static let startDate = "startDate"
        static let endDate = "endDate"
    }

    init?(name: String, photo: UIImage?, rating: Int, startDate: Date?, endDate: Date?) {
        
        // Initialization should fail if there is no name or if the rating is negative.
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.startDate = startDate
        self.endDate = endDate
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(startDate, forKey: PropertyKey.startDate)
        aCoder.encode(endDate, forKey: PropertyKey.endDate)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            if #available(iOS 10.0, *) {
                os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        let StartDate = aDecoder.decodeObject(forKey: PropertyKey.startDate) as? Date
        
        let EndDate = aDecoder.decodeObject(forKey: PropertyKey.endDate) as? Date
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, startDate: StartDate, endDate: EndDate)
        
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")

}
