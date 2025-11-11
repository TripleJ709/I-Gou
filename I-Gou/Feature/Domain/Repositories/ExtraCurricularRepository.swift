//
//  ExtraCurricularRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/10/25.
//

import Foundation

protocol ExtraCurricularRepository {
    func fetchExtraCurricularData() async throws -> ExtraCurricularData
    func addActivity(type: String, title: String, hours: Int, date: Date) async throws
    func addReading(title: String, author: String?, readDate: Date, hasReport: Bool) async throws
}
