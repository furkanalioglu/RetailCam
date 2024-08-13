//
//  Date++.swift
//  RetailCam
//
//  Created by Furkan Alioglu on 13.08.2024.
//

import Foundation
extension Date {

 static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return dateFormatter.string(from: Date())

    }
}
