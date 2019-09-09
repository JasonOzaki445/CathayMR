//
//  Plants.swift
//  CustomNavigationBar
//
//  Created by Jason Chen on 2019/9/9.
//  Copyright © 2019 Jason Chen. All rights reserved.
//

import Foundation

//
// MARK: - Plants
//
// Query service creates Plants objects
class Plant {
    //
    // MARK: - Constants
    //
    var F_Name_Ch: String
    var F_Location: String?
    var F_Feature: String?
    var F_Pic01_URL: String?

    //
    // MARK: - Initialization
    //
    init(F_Name_Ch: String, F_Location: String, F_Feature: String, F_Pic01_URL: String) {
        self.F_Name_Ch = F_Name_Ch
        self.F_Location = F_Location
        self.F_Feature = F_Feature
        self.F_Pic01_URL = F_Pic01_URL
    }
}

class Plants {
    //
    // MARK - Constants
    //
    var limit: Int
    var offset: Int
    var count: Int
    var sort: String
    var results: [Plant]

    //
    // MARK - Initialization
    //
    init(limit: Int, offset: Int, count: Int, sort: String, results: [Plant]) {
        self.limit = limit
        self.offset = offset
        self.count = count
        self.sort = sort
        self.results = results
    }
}
