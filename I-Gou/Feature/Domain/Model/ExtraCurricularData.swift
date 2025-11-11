//
//  ExtraCurricularData.swift
//  I-Gou
//
//  Created by 장주진 on 11/10/25.
//

import Foundation

struct ExtraCurricularData: Codable {
    let activities: [ActivityStat]
    let readingStats: ReadingStats
    let readingList: [ReadingLog]
}

struct ActivityStat: Codable, Identifiable {
    var id: String { type }
    let type: String
    let totalHours: Int
}

struct ReadingStats: Codable {
    let totalBooks: Int
    let totalReports: Int
}

struct ReadingLog: Codable, Identifiable {
    var id: String { title }
    let title: String
    let author: String?
    let readDate: String?
}

struct AddActivityRequest: Codable {
    let type: String
    let title: String
    let hours: Int
    let activityDate: String
}

struct AddReadingRequest: Codable {
    let title: String
    let author: String?
    let readDate: String
    let hasReport: Bool
}
