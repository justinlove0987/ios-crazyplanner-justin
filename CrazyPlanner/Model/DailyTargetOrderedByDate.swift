//
//  DailyTargetOrderedByDate.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/7/2.
//

import Foundation


struct DailyTargetOrderedByDate {
    
    var sectionTitles = [String]()
    var numberOfRowsInSection = [Int]()
    
    mutating func dealwithDate(date: String) {
        
        if sectionTitles.contains(date) {
            if let index = sectionTitles.firstIndex(of: date) {
                numberOfRowsInSection[index] += 1
            }
            
        } else {
            sectionTitles.append(date)
            numberOfRowsInSection.append(1)
        }
        
        
        
    }
    
}
