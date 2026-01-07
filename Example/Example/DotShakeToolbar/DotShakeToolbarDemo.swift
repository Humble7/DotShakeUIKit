//
//  DotShakeToolbarDemo.swift
//  GlassToolBar
//
//  Created by ChenZhen on 26/12/25.
//


import UIKit
import SwiftUI
import DotShakeToolbar

// MARK: - Main Toolbar Demo

/// Main toolbar demo with all features
class ToolbarDemoVC: UIViewController {

    private let toolbarController = GlassToolbarController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupToolbar()
    }

    private func setupUI() {
        title = "DotShakeToolbar"
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Glass Toolbar"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let descLabel = UILabel()
        descLabel.text = "Resize window to see adaptive layout"
        descLabel.font = .systemFont(ofSize: 15)
        descLabel.textColor = .secondaryLabel
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descLabel)

        addChild(toolbarController)
        view.addSubview(toolbarController.view)
        toolbarController.view.translatesAutoresizingMaskIntoConstraints = false
        toolbarController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toolbarController.view.topAnchor.constraint(equalTo: view.topAnchor),
            toolbarController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupToolbar() {
        let dualSliderView = DualSliderAccessoryView()
        dualSliderView.configure(
            value1: 0.5, value2: 0.8,
            color1: .systemBlue, color2: .systemPurple,
            circleColor: .systemBlue
        )

        let brushListView = HorizontalListAccessoryView()
        brushListView.configure(title: "Brush", items: [
            .init(icon: UIImage(systemName: "pencil.tip"), title: "Fine"),
            .init(icon: UIImage(systemName: "paintbrush"), title: "Medium"),
            .init(icon: UIImage(systemName: "paintbrush.pointed"), title: "Thick")
        ], selectedIndex: 0, configuration: .init(showsSelection: true, showsCount: true, selectionColor: .systemBlue))

        let miniPlayerView = MiniPlayerAccessoryView()
        miniPlayerView.configure(title: "Shape of You", artist: "Ed Sheeran")

        toolbarController.setItems([
            GlassToolbarItem(
                title: "Home",
                icon: UIImage(systemName: "house"),
                selectedIcon: UIImage(systemName: "house.fill"),
                priority: .essential,
                sideButton: .addButton(priority: .essential, action: { [weak self] in
                    self?.showAlert(title: "Add", message: "Add button tapped")
                }),
                accessoryProvider: dualSliderView,
                secondaryAccessoryProvider: brushListView
            ),
            GlassToolbarItem(
                title: "Discover",
                icon: UIImage(systemName: "safari"),
                selectedIcon: UIImage(systemName: "safari.fill"),
                priority: .primary
            ),
            GlassToolbarItem(
                title: "Favorites",
                icon: UIImage(systemName: "heart"),
                selectedIcon: UIImage(systemName: "heart.fill"),
                priority: .primary,
                sideButton: .styled(.danger, icon: UIImage(systemName: "trash"), action: { [weak self] in
                    self?.showAlert(title: "Delete", message: "Delete button tapped")
                })
            ),
            GlassToolbarItem(
                title: "Messages",
                icon: UIImage(systemName: "bell"),
                selectedIcon: UIImage(systemName: "bell.fill"),
                priority: .secondary,
                accessoryProvider: miniPlayerView
            ),
            GlassToolbarItem(
                title: "Settings",
                icon: UIImage(systemName: "gearshape"),
                selectedIcon: UIImage(systemName: "gearshape.fill"),
                priority: .secondary
            )
        ])
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SwiftUI Preview

private struct ToolbarDemoPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ToolbarDemoVC { ToolbarDemoVC() }
    func updateUIViewController(_ vc: ToolbarDemoVC, context: Context) {}
}

#Preview("Toolbar Demo") {
    ToolbarDemoPreview().ignoresSafeArea()
}

#Preview("Toolbar Demo - Dark") {
    ToolbarDemoPreview().ignoresSafeArea().preferredColorScheme(.dark)
}
