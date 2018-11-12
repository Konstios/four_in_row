
import GameplayKit
import UIKit

enum CoinColor: Int {
    case none = 0
    case orange
    case cyan
}

class Player: NSObject, GKGameModelPlayer {
    var chip: CoinColor
    var color: UIColor
    var name: String
    var playerId: Int
    
    static var allPlayers = [Player(chip: .orange), Player(chip: .cyan)]
    
    var opponent: Player {
        if chip == .orange {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
    
    init(chip: CoinColor) {
        self.chip = chip
        self.playerId = chip.rawValue
        
        if chip == .orange {
            color = .orange
            name = "Orange"
        } else {
            color = .cyan
            name = "Cyan"
        }
        
        super.init()
    }
}
