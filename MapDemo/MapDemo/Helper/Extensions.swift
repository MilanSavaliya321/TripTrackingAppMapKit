//
//  Extensions.swift
//  MapDemo
//
//  Created by Milan on 08/10/22.
//

import Foundation

extension Date {
    func formateDate(formate: String = "HH:mm:ss") -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = formate
        let dateTime: String = formatter.string(from: self)
        return dateTime
    }
}
