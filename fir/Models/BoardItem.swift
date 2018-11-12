
import Foundation
import SpriteKit

class BoardItem{
    let node: SKShapeNode
    let x: Int
    let y: Int
    
    init(node: SKShapeNode, x: Int, y: Int) {
        self.node = node
        self.x = x
        self.y = y
    }
}
