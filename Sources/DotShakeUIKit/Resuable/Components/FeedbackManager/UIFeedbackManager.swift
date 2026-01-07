//
//  UIFeedbackManager.swift
//  DotShakeUIKit
//
//  Created by ChenZhen on 26/6/25.
//

@MainActor
public final class UIFeedbackManager {
    public static let shared = UIFeedbackManager()

    public let loading = LoadingController()
    public let alert = AlertController()

    private init() {}
}
