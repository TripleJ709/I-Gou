//
//  KeychainService.swift
//  I-Gou
//
//  Created by 장주진 on 11/12/25.
//

import Foundation
import KeychainAccess

final class KeychainService {
    
    // 1. 앱 전역에서 하나의 인스턴스만 사용 (싱글톤)
    static let shared = KeychainService()
    
    // 2. 키체인을 초기화합니다. (bundleId로 앱을 고유하게 식별)
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.igou.default")
    
    // 3. 토큰을 저장할 '키' 이름
    private let jwtTokenKey = "jwtAuthToken"
    
    // 4. (로그인 성공 시 호출) 토큰을 키체인에 저장하는 함수
    func saveToken(_ token: String) {
        do {
            try keychain.set(token, key: jwtTokenKey)
            print("Keychain: 토큰 저장 성공")
        } catch let error {
            print("Keychain: 토큰 저장 실패 - \(error)")
        }
    }
    
    // 5. (APIService가 호출) 키체인에서 토큰을 읽어오는 함수
    func getToken() -> String? {
        do {
            return try keychain.get(jwtTokenKey)
        } catch let error {
            print("Keychain: 토큰 읽기 실패 - \(error)")
            return nil
        }
    }
    
    // 6. (로그아웃 시 호출) 키체인에서 토큰을 삭제하는 함수
    func deleteToken() {
        do {
            try keychain.remove(jwtTokenKey)
            print("Keychain: 토큰 삭제 성공")
        } catch let error {
            print("Keychain: 토큰 삭제 실패 - \(error)")
        }
    }
}
