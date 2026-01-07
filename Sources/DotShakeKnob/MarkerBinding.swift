//
//  MarkerBinding.swift
//  DotShakeKnob
//
//  Created by ChenZhen on 6/1/26.
//

import Foundation

@MainActor
public final class MarkerBinding {

    private weak var knob: MarkedKnob?
    private let storage: MarkerStorage
    private let key: String

    public init(knob: MarkedKnob, storage: MarkerStorage = .shared, key: String) {
        self.knob = knob
        self.storage = storage
        self.key = key
    }

    public func bind() {
        guard let knob = knob else { return }

        // Load saved markers
        Task {
            let markers = await storage.load(forKey: key)
            knob.markers = markers
        }

        // Auto-save when markers change
        knob.onMarkersChanged = { [weak self] markers in
            guard let self = self else { return }
            let storage = self.storage
            let key = self.key
            let markersCopy = markers
            Task.detached {
                await storage.save(markersCopy, forKey: key)
            }
        }
    }

    public func unbind() {
        knob?.onMarkersChanged = nil
    }

    public func clear() async {
        await storage.clear(forKey: key)
        await MainActor.run {
            knob?.markers = []
        }
    }
}

// MARK: - Convenience Extension

public extension MarkedKnob {

    @MainActor
    func bindStorage(key: String, storage: MarkerStorage = .shared) -> MarkerBinding {
        let binding = MarkerBinding(knob: self, storage: storage, key: key)
        binding.bind()
        return binding
    }
}
