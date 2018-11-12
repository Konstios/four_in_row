
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var gameLogo: SKLabelNode!
    var firstPlayerLabel: SKLabelNode!
    var secondPlayerLabel: SKLabelNode!
    var winNode: SKShapeNode!
    var gameBG: SKShapeNode!
    var firstPlayerCircle: SKShapeNode!
    var secondPlayerCircle: SKShapeNode!
    var playButton: SKShapeNode!
    var newGameButton: SKShapeNode!
    
    var game: GameManager!

    var playerPositions: [(Int, Int)] = []

    var coinsPositionsFP: [(Int, Int)] = []
    var coinsPositionsSP: [(Int, Int)] = []

    var varsFP: [[Variant]] = []
    var varsSP: [[Variant]] = []
    
    var gameArray: [BoardItem] = []
    
    var inProcess: Bool = false
    var isGameComplete: Bool = false
    
    var currentPlayer: Player!
    
    let numRows = 6
    let numCols = 7
    
    let fontName = "ArialRoundedMTBold"
    let standartFontSize: CGFloat = 45
    let titleFontSize: CGFloat = 60
    
    let animationDuration = 0.5
    
    override func sceneDidLoad() {
        currentPlayer = Player.allPlayers[0]
    }
    
    override func didMove(to view: SKView) {
        initializeMenu()
        game = GameManager(scene: self)
        initializeGameView()
        varsFP = winVariants()
        varsSP = winVariants()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name ==  Node.name.play {
                    startGame()
                } else if ((node.name != nil) && (node.name !=  Node.name.play) && (node.name !=  Node.name.newGame) && !inProcess){
                    if !isGameComplete{
                        presOnNode(node: node)
                    }
                } else if node.name == Node.name.newGame {
                    pressRestart()
                    
                } else if node.name == Node.name.restart {
                    if isGameComplete {return}
                    pressRestart()
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        game.update(time: currentTime)
    }
    
    private func initializeMenu() {
        self.addGameLogo()
        self.addPlayButton()
    }
    
    func addGameLogo() {
        gameLogo = SKLabelNode(fontNamed: fontName)
        self.addLabel(text: "FOUR IN ROW", fontSize: titleFontSize, position: CGPoint(x: 0, y: (frame.size.height / 2) - 200), fontColor: SKColor.red, toNode: gameLogo)
    }
    
    func addFirstPlayerLabel() {
        firstPlayerLabel = SKLabelNode(fontNamed: fontName)
        self.addLabel(text: Player.allPlayers[0].name, fontSize: standartFontSize, position: CGPoint(x: -((frame.size.width / 2) - 100), y: (frame.size.height / 2) - 200), fontColor: Player.allPlayers[0].color, toNode: firstPlayerLabel)
        firstPlayerCircle = SKShapeNode(circleOfRadius: 10 )
        activePlayerCircle(position: CGPoint(x: -((frame.size.width / 2) - 100), y: (frame.size.height / 2) - 250), toNode: firstPlayerCircle)
        firstPlayerCircle.isHidden = false
    }
    
    func addSecondPlayerLabel() {
        secondPlayerLabel = SKLabelNode(fontNamed: fontName)
        self.addLabel(text: Player.allPlayers[1].name, fontSize: standartFontSize, position: CGPoint(x: (frame.size.width / 2) - 100, y: (frame.size.height / 2) - 200), fontColor: Player.allPlayers[1].color, toNode: secondPlayerLabel)
        secondPlayerCircle = SKShapeNode(circleOfRadius: 10 )
        activePlayerCircle(position: CGPoint(x: (frame.size.width / 2) - 100, y: (frame.size.height / 2) - 250), toNode: secondPlayerCircle)
    }
    
    func addLabel(text: String, fontSize: CGFloat, position: CGPoint, fontColor: SKColor, toNode:SKLabelNode) {
        toNode.zPosition = 1
        toNode.position = position
        toNode.fontSize = fontSize
        toNode.text = text
        toNode.fontColor = fontColor
        self.addChild(toNode)
    }
    
    func activePlayerCircle(position: CGPoint, toNode:SKShapeNode){
        toNode.position = position
        toNode.strokeColor = SKColor.black
        toNode.glowWidth = 1.0
        toNode.fillColor = SKColor.red
        toNode.isHidden = true
        self.addChild(toNode)
    }
    
    func addPlayButton() {
        playButton = SKShapeNode()
        playButton.name =  Node.name.play
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.cyan
        let topCorner = CGPoint(x: -50, y: 50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        self.addChild(playButton)
        
        self.addRestartButton()
    }
    
    func addRestartButton(){
        newGameButton = SKShapeNode()
        newGameButton.name = Node.name.restart
        newGameButton.zPosition = 1
        newGameButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 50)
        newGameButton.fillColor = .cyan
        self.addChild(newGameButton)
        self.newGameButton.isHidden = true
        
        let text = SKLabelNode(text: "Restart")
        text.fontColor = UIColor.white
        text.position = CGPoint(x: 0, y: 50)
        text.fontSize = standartFontSize
        text.fontName = fontName
        text.verticalAlignmentMode = SKLabelVerticalAlignmentMode(rawValue: 1)!
        text.zPosition = 2
        newGameButton.addChild(text)
    }

    private func startGame() {
        gameLogo.run(SKAction.move(by: CGVector(dx: 0, dy: 100), duration: animationDuration)){
            self.addFirstPlayerLabel()
            self.addSecondPlayerLabel()
        }

        playButton.run(SKAction.scale(to: 0, duration: animationDuration)) {
            self.playButton.isHidden = true
            self.gameBG.isHidden = false
        }
        newGameButton.run(SKAction.scale(to: 0.8, duration: animationDuration)) {
            self.newGameButton.isHidden = false
        }
    }
    
    private func initializeGameView() {
        let width = frame.size.width - 200
        let height = width - width / CGFloat(numCols)
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor.darkGray
        gameBG.zPosition = 2
        gameBG.isHidden = true
        self.addChild(gameBG)
        createGameBoard(width: Int(width), height: Int(height))
    }
    
    private func createGameBoard(width: Int, height: Int) {
        
        let cellWidth: CGFloat = CGFloat(width/numCols)
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2)
    
        for i in 0...numRows - 1 {
            for j in 0...numCols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.name = "\(x),\(y)"
                cellNode.position = CGPoint(x: x, y: y)
                let item = BoardItem(node: cellNode, x: i, y: j)
                gameArray.append(item)
                gameBG.addChild(cellNode)
                x += cellWidth
            }
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
    }
    
    func changePlayer() {
        if currentPlayer == Player.allPlayers[0] {
            currentPlayer = Player.allPlayers[1]
            secondPlayerCircle.isHidden = false
            firstPlayerCircle.isHidden = true
        } else {
            currentPlayer = Player.allPlayers[0]
            secondPlayerCircle.isHidden = true
            firstPlayerCircle.isHidden = false
        }
    }
    
    private func winVariants() -> [[Variant]] {
        var varsArray: [[Variant]] = []
        for i in 0...numRows - 1 {
            for j in 0...numCols - 1 {
                if i+4 <= numRows {
                    var variant: [Variant] = []
                    for a in i...i+3 {
                        variant.append(Variant.init(x: a, y: j, check: false))
                    }
                    varsArray.append(variant)
                }
                if j+4 <= numCols {
                    var variant: [Variant] = []
                    for a in j...j+3 {
                        variant.append(Variant.init(x: i, y: a, check: false))
                    }
                    varsArray.append(variant)
                }
            }
        }
        for i in 0...numRows - 4 {
            for j in 0...numCols - 4 {
                var variant: [Variant] = []
                for d in 0...3{
                    variant.append(Variant.init(x: i+d, y: j+d, check: false))
                }
                varsArray.append(variant)
            }
        }
        for i in 3...numRows - 1 {
            for j in 0...numCols - 4 {
                var variant: [Variant] = []
                for d in 0...3{
                    variant.append(Variant.init(x: i-d, y: j+d, check: false))
                }
                varsArray.append(variant)
            }
        }
        return varsArray
    }
    
    func check(positions:[(Int, Int)],vars:[[Variant]]) {
        for variants in vars {
            for variant in variants {
                for coin in positions {
                    if variant.x == coin.0 && variant.y == coin.1{
                        variant.check = true
                    }
                }
            }
        }
    }
    
    func isWin() {
        for variants in varsFP {
            var checkedVariantsFP = 0
            for variant in variants {
                if variant.check{
                    checkedVariantsFP += 1
                }
            }
            if checkedVariantsFP == 4{
                addWinNode(text: "\(Player.allPlayers[0].name) WIN")
            }
        }
        for variants in varsSP {
            var checkedVariantsSP = 0
            for variant in variants {
                if variant.check{
                    checkedVariantsSP += 1
                }
            }
            if checkedVariantsSP == 4{
                addWinNode(text: "\(Player.allPlayers[1].name) WIN")
            }
        }
    }
    
    func addWinNode(text: String) {
        isGameComplete = true
        winNode = SKShapeNode(rectOf: CGSize(width: frame.width, height: frame.height))
        winNode.strokeColor = SKColor.black
        winNode.zPosition = 1000
        winNode.fillColor = SKColor.black
        winNode.alpha = 0
        winNode.isAntialiased = true
        winNode.position = CGPoint(x: 0, y: 0)
        self.addChild(winNode)
        winNode.run(SKAction.fadeAlpha(to: 0.8, duration: animationDuration))
        
        let text = SKLabelNode(text: text)
        text.fontColor = UIColor.white
        text.position = CGPoint(x: 0, y: 150)
        text.fontSize = titleFontSize
        text.fontName = fontName
        text.verticalAlignmentMode = SKLabelVerticalAlignmentMode(rawValue: 1)!
        text.zPosition = 2
        winNode.addChild(text)
        
        let newGame = SKLabelNode(text: "New Game")
        newGame.fontColor = UIColor.white
        newGame.position = CGPoint(x: 0, y: -150)
        newGame.fontSize = standartFontSize
        newGame.fontName = fontName
        newGame.verticalAlignmentMode = SKLabelVerticalAlignmentMode(rawValue: 1)!
        newGame.name =  Node.name.newGame
        newGame.zPosition = 2
        winNode.addChild(newGame)
    }
    
    func presOnNode (node:SKNode) {
        _ = gameArray.map {(item) -> BoardItem in
            if(node==item.node){
                if !game.contains(a: coinsPositionsFP, v: ((item.x,item.y))) && !game.contains(a: coinsPositionsSP, v: ((item.x,item.y))){
                    inProcess = true
                    game.initGame(x:item.x, y:item.y)
                }
            }
            return item
        }
    }
    
    func pressRestart() {
        if (winNode != nil) {
            winNode.run(SKAction.fadeAlpha(to: 0, duration: animationDuration)){
                self.winNode.removeFromParent()
                self.isGameComplete = false
            }
        }
        coinsPositionsFP.removeAll()
        coinsPositionsSP.removeAll()
        playerPositions.removeAll()
        varsFP = winVariants()
        varsSP = winVariants()
        secondPlayerCircle.isHidden = true
        firstPlayerCircle.isHidden = false
        game.renderChange()
        currentPlayer = Player.allPlayers[0]
    }
}
