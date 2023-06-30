//
//  Course.swift
//  Networking
//
//  Created by Alexey Efimov on 08.02.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import Foundation


struct Course: Codable {
    let name: String
    let imageUrl: URL
    let numberOfLessons: Int
    let numberOfTests: Int
}

struct SwiftbookInfo: Decodable {
    let courses: [Course]
    let websiteDescription: String
    let websiteName: String
}
