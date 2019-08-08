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
        word.removeAll()
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
    static let wordlist: [String: Int]? = {
        guard let filepath = Bundle.main.path(forResource: "wordlist", ofType: "txt") else {
            return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath)
            var dictionary = [String: Int]()
            for word in contents.components(separatedBy: "\n") {
                dictionary[word] = 1
            }
            return dictionary
        } catch {
            // contents could not be loaded
            return nil
        }
    }()
    
    private enum Constant {
        static let rackSize = 7
        static let tileDict: [String: Int] = [
            "A": 7,
            "B": 2,
            "C": 2,
            "D": 3,
            "E": 9,
            "F": 2,
            "G": 2,
            "H": 2,
            "I": 6,
            "J": 1,
            "K": 1,
            "L": 3,
            "M": 2,
            "N": 4,
            "O": 6,
            "P": 2,
            "Q": 1,
            "R": 5,
            "S": 3,
            "T": 5,
            "U": 3,
            "V": 2,
            "W": 2,
            "X": 1,
            "Y": 2,
            "Z": 1
        ]
    }
    
    var initializedTileBag: [Tile] {
        var tileBag: [Tile] = []
        for (key, value) in Constant.tileDict {
            tileBag.append(contentsOf: repeatElement(Tile(letter: key, active: true), count: value))
        }
        return tileBag.shuffled()
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
        tileBag = initializedTileBag
        // fill racks
        fillRack(player: player1)
        fillRack(player: player2)
        
        whoseTurn = player1
    }
}
