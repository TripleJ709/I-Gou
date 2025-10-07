//
//  UniversityItem.swift
//  I-Gou
//
//  Created by 장주진 on 10/7/25.
//

import Foundation

struct UniversityItem {
    let universityName: String
    let department: String
    let major: String
    let myScore: Float
    let requiredScore: Float
    let deadline: String
    let status: MyUniversitiesView.Status
    
    // 상세 페이지에 보여줄 추가 정보
    let location: String
    let competitionRate: String
}
