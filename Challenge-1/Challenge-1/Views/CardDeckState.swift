//
//  CardDeckState.swift
//  Challenge-1
//
//  Created by Giuseppe Di Donna on 21/10/2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Deck state

@MainActor
final class CardDeckState <Item: Identifiable>: ObservableObject {
    
    @Published private(set) var cards: [Item] = []
    
    @Published private(set) var topCardIndex = 0
    @Published private(set) var dragOffset: CGFloat = 0
    @Published private(set) var isCycling = false
    
    var currentCard: Item? {
        cards.isEmpty ? nil : cards[topCardIndex]
    }
    
    func load(_ items: [Item]) {
        cards = items
        topCardIndex = 0
        dragOffset = 0
        isCycling = false
    }

    func removeCurrent() {
        guard !cards.isEmpty else { return }
        cards.remove(at: topCardIndex)
        if topCardIndex >= cards.count { topCardIndex = 0 }
    }

    func dragChanged(_ value: DragGesture.Value) {
        guard !isCycling else { return }
        guard abs(value.translation.width) > abs(value.translation.height) else { return }
        dragOffset = value.translation.width
    }

    func dragEnded(_ value: DragGesture.Value, cardWidth: CGFloat, reduceMotion: Bool) {
        guard !isCycling else { return }
        guard cards.count > 1,
              abs(value.translation.width) > 50,
              abs(value.translation.width) > abs(value.translation.height) else {
            withAnimation(reduceMotion ? nil : .smooth) { dragOffset = 0 }
            return
        }
        cycleCard(direction: value.translation.width < 0 ? -1 : 1,
                  cardWidth: cardWidth,
                  reduceMotion: reduceMotion)
    }

    func cycleCard(direction: CGFloat, cardWidth: CGFloat, reduceMotion: Bool) {
        guard !isCycling, cards.count > 1 else { return }
        if reduceMotion {
            topCardIndex = (topCardIndex + 1) % cards.count
            dragOffset = 0
            return
        }

        isCycling = true
        withAnimation(.smooth(duration: direction < 0 ? 0.18 : 0.2), completionCriteria: .removed) {
            dragOffset = direction < 0 ? -cardWidth : cardWidth * 1.33
        } completion: {
            withAnimation(.smooth(duration: 0.5), completionCriteria: .removed) {
                self.topCardIndex = (self.topCardIndex + 1) % self.cards.count
                self.dragOffset = 0
            } completion: {
                self.isCycling = false
            }
        }
    }
}
