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
        button.setTitle("카카오로 시작하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(red: 254/255, green: 229/255, blue: 0/255, alpha: 1.0)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "kakao_logo"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
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
            // 버튼을 화면 하단 근처에 배치
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
                } else {
                    print("카카오톡 로그인 성공!")
                    if let token = oauthToken {
                        self.handleLoginSuccess(token: token)
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오계정 로그인 실패: \(error)")
                } else {
                    print("카카오계정 로그인 성공!")
                    if let token = oauthToken {
                        self.handleLoginSuccess(token: token)
                    }
                }
            }
        }
    }
    
    private func handleLoginSuccess(token: OAuthToken) {
        let accessToken = token.accessToken
        print("✅ 카카오로부터 받은 액세스 토큰: \(accessToken)")
        DispatchQueue.main.async {
            self.goToMainApp()
        }
    }
    
    private func goToMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        let mainTabBarController = MainTabBarController()
        sceneDelegate.window?.rootViewController = mainTabBarController
        sceneDelegate.window?.makeKeyAndVisible()
    }
}
