//
//  LoginViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/13/25.
//

import UIKit
import KakaoSDKUser
import KakaoSDKAuth
import Combine

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let kakaoLoginButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.attributedTitle?.font = .systemFont(ofSize: 17, weight: .semibold)
        config.baseBackgroundColor = UIColor(red: 254/255, green: 229/255, blue: 0/255, alpha: 1.0)
        config.baseForegroundColor = .black
        config.cornerStyle = .medium
        config.image = UIImage(named: "kakao_login_large_wide")
        config.imagePadding = 8
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupButtonAction()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(kakaoLoginButton)
        
        NSLayoutConstraint.activate([
            kakaoLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            kakaoLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 50),
            kakaoLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupButtonAction() {
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func kakaoLoginButtonTapped() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 실패: \(error)")
                } else if let token = oauthToken {
                    print("카카오톡 로그인 성공!")
                    self.handleLoginSuccess(token: token)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오계정 로그인 실패: \(error)")
                } else if let token = oauthToken {
                    print("카카오계정 로그인 성공!")
                    self.handleLoginSuccess(token: token)
                }
            }
        }
    }
    
    private func handleLoginSuccess(token: OAuthToken) {
        let accessToken = token.accessToken
        
        guard let url = URL(string: "http://localhost:3000/api/auth/kakao") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["accessToken": accessToken])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("우리 서버로부터 받은 원본 응답: \(responseString)")
            }
            
            if let response = try? JSONDecoder().decode([String: String].self, from: data),
               let appToken = response["token"] {
                
                print("JWT: \(appToken)")
                UserDefaults.standard.set(appToken, forKey: "accessToken")
                
                DispatchQueue.main.async {
                    self.goToMainApp()
                }
            } else {
                print("서버로부터 받은 데이터 형식이 잘못되었습니다.")
            }
        }.resume()
    }
    
    private func goToMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        let mainTabBarController = MainTabBarController()
        window.rootViewController = mainTabBarController
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
}
