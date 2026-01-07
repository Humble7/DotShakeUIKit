//
//  MarkerStorage.swift
//  DotShakeKnob
//
//  Created by ChenZhen on 6/1/26.
//

import Foundation

public protocol MarkerStorageProtocol: Actor {
    func save(_ markers: [KnobMarker], forKey key: String) async
    func load(forKey key: String) async -> [KnobMarker]
    func clear(forKey key: String) async
}

public actor MarkerStorage: MarkerStorageProtocol {

    public static let shared = MarkerStorage()

    private static let defaultKey = "MarkedKnob.markers"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - With Key

    public func save(_ markers: [KnobMarker], forKey key: String) async {
        do {
            let data = try JSONEncoder().encode(markers)
            defaults.set(data, forKey: key)
        } catch {
            print("MarkerStorage: Failed to save markers - \(error)")
        }
    }

    public func load(forKey key: String) async -> [KnobMarker] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([KnobMarker].self, from: data)
        } catch {
            print("MarkerStorage: Failed to load markers - \(error)")
            return []
        }
    }

    public func clear(forKey key: String) async {
        defaults.removeObject(forKey: key)
    }

    // MARK: - Default Key Convenience

    public func save(_ markers: [KnobMarker]) async {
        await save(markers, forKey: Self.defaultKey)
    }

    public func load() async -> [KnobMarker] {
        await load(forKey: Self.defaultKey)
    }

    public func clear() async {
        await clear(forKey: Self.defaultKey)
    }
}
