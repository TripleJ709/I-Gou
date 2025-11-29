//
//  HomeRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/30/25.
//

import Foundation

protocol HomeRepository {
    func fetchHomeData() async throws -> HomeData
}
