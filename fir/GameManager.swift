
import SpriteKit

class GameManager {
    var scene: GameScene!
    
    var nextTime: Double?
    var timeExtension: Double = 0.07
    
    init(scene: GameScene) {
        self.scene = scene
    }
    func initGame(x:Int, y:Int) {
        scene.playerPositions.append((x, y))
        renderChange()
    }

    func renderChange() {
        for item:BoardItem in scene.gameArray {
            if contains(a: scene.playerPositions, v: (item.x,item.y)) {
                if contains(a: scene.coinsPositionsFP, v: (item.x, item.y)){
                    item.node.fillColor = Player.allPlayers[0].color
                } else if contains(a: scene.coinsPositionsSP, v: (item.x, item.y)) {
                    item.node.fillColor = Player.allPlayers[1].color
                } else {
                    item.node.fillColor = scene.currentPlayer.color
                }
            } else {
                item.node.fillColor = .clear
            }
        }
    }
  
    func contains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }

    func update(time: Double) {
        if nextTime == nil {
            nextTime = time + timeExtension
        } else {
            if (time >= nextTime! && scene.inProcess) {
                nextTime = time + timeExtension
                updatePlayerPosition()
            }
        }
    }
    
    func addCoinToPlayer() {
        if scene.currentPlayer == Player.allPlayers[0] {
            scene.coinsPositionsFP.append(scene.playerPositions.last!)
            scene.check(positions: scene.coinsPositionsFP, vars: scene.varsFP)
        } else {
            scene.coinsPositionsSP.append(scene.playerPositions.last!)
            scene.check(positions: scene.coinsPositionsSP, vars: scene.varsSP)
        }
        scene.isWin()
        scene.changePlayer()
    }
    
    private func updatePlayerPosition() {
        
        let yChange = 1
        
        if scene.playerPositions.count > 0 {
            
            if (scene.playerPositions.last?.0)! < scene.numRows-1 {
                
                let (x,y) = ((scene.playerPositions.last?.0)! + yChange, (scene.playerPositions.last?.1)!)
                if contains(a: scene.coinsPositionsFP, v: ((x,y))) || contains(a: scene.coinsPositionsSP, v: ((x,y))) {
                    self.addCoinToPlayer()
                    scene.inProcess = false
                    return
                }
                scene.playerPositions.removeLast()
                scene.playerPositions.append((x,y))
            } else{
                self.addCoinToPlayer()
                scene.inProcess = false
            }
        }
        
        renderChange()
    }
}
