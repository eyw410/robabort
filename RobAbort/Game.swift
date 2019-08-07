//
//  Game.swift
//  RobAbort
//
//  Created by Elizabeth Yeoh-Wang on 8/7/19.
//  Copyright © 2019 Elizabeth Yeoh-Wang. All rights reserved.
//

import Foundation

struct Tile {
    var letter: String
    var active: Bool
}

class Player {
    var id: Int
    var score = 0
    var rack: [Tile] = []
    var pointsOnDeck = 0
    var justPassed = false
    
    init(id: Int) {
        self.id = id
    }
}

class Staging {
    private var word = [Tile]()
    
    func wipe() {
        word = []
    }
    
    func insertElement(_ element: Tile, at index: Int) {
        word.insert(element, at: index)
    }
    
    func removeElementFrom(_ index: Int) -> Tile? {
        guard index < word.count /*, check the boolean as well */ else {
            return nil
        }
        return word.remove(at: index)
    }
    
    func moveTileFrom(_ oldIndex: Int, to newIndex: Int) {
        let tile = word.remove(at: oldIndex)
        word.insert(tile, at: newIndex)
    }
    
    func getWord() -> [Tile] {
        return word
    }
}

class Game {
    private enum Constant {
        static let rackSize = 7
        static let tileDict: [String: Int] = [
            "A": 13,
            "B": 3,
            "C": 3,
            "D": 6,
            "E": 18,
            "F": 3,
            "G": 4,
            "H": 3,
            "I": 12,
            "J": 2,
            "K": 2,
            "L": 5,
            "M": 3,
            "N": 8,
            "O": 11,
            "P": 3,
            "Q": 2,
            "R": 9,
            "S": 6,
            "T": 9,
            "U": 6,
            "V": 3,
            "W": 3,
            "X": 2,
            "Y": 3,
            "Z": 2
        ]
    }
    
    var initializedTileBag: [Tile] {
        var tileBag: [Tile] = []
        for (key, value) in Constant.tileDict {
            tileBag.append(contentsOf: repeatElement(Tile(letter: key, active: true), count: value))
        }
        return tileBag
    }
    
    var tileBag = [Tile]()
    
    var whoseTurn: Player?
    
    var player1 = Player(id: 1)
    var player2 = Player(id: 2)
    
    var word = [Tile]()
    var stagingWord = Staging()
    
    func drawTile() -> Tile? {
        guard tileBag.count > 0 else {
            return nil
        }
        return tileBag.popLast()
    }
    
    func fillRack(player: Player) {
        while player.rack.count < Constant.rackSize {
            guard let newTile = drawTile() else {
                break
            }
            player.rack.append(newTile)
        }
    }
    
    func useTile(player: Player, index: Int) -> Tile? {
        guard index < player.rack.count else {
            return nil
        }
        return player.rack.remove(at: index)
    }
    
    func checkWord(_ word: [Tile]) -> Bool {
        let actualWord = word.reduce("", { (acc, tile) -> String in
            var newWord = acc
            newWord.append(tile.letter)
            return newWord
        })
        return actualWord == "hi" // instead, check if it's in the giant dictionary
    }
    
    func playWord(player: Player, word: [Tile]) -> Bool {
        guard whoseTurn === player else {
            return false
        }
        guard checkWord(word) else {
            return false
        }
        let other = player === player1 ? player2 : player1
        player.pointsOnDeck = word.count
        other.pointsOnDeck = 0
        self.word = word
        for var tile in word {
            tile.active = false
        }
        fillRack(player: player)
        player.justPassed = false
        // check if game is over here
        return true
    }
    
    func pass(player: Player) {
        guard whoseTurn === player else {
            return
        }
        let other = player === player1 ? player2 : player1
        other.score += other.pointsOnDeck
        self.word = []
        
        player.justPassed = true
    }
    
    func checkGameOver() -> Bool {
        if tileBag.count == 0 {
            if player1.rack.count == 0 || player2.rack.count == 0 || (player1.justPassed && player2.justPassed) {
                return true
            }
        }
        return false
    }
    
    func setupGame() {
        // set up tileBag
        tileBag = initializedTileBag.shuffled()
        // fill racks
        fillRack(player: player1)
        fillRack(player: player2)
        
        whoseTurn = player1
    }
}
