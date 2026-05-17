//
//  PlayerView.swift
//  VenusHacksProject
//
//  Created by slmrc on 5/17/26.
//

import AVKit
import SwiftUI

#if canImport(UIKit)
import UIKit

// Fullscreen, no-controls video layer — exactly like Instagram Reels
struct PlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(player: player)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.player = player
    }
}

final class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
#else
struct PlayerView: View {
    let player: AVPlayer

    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(contentMode: .fill)
    }
}
#endif
