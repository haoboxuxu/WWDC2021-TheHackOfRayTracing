import SpriteKit

public class RayTracing2DScene: SKScene {
    
    var pointANode: SKSpriteNode!
    var pointBNode: SKSpriteNode!
    var pointPNode: SKSpriteNode!
    var pointINode: SKSpriteNode!
    var offsetA: CGPoint!
    var offsetB: CGPoint!
    var offsetP: CGPoint!
    var moveingA: Bool = false
    var moveingB: Bool = false
    var moveingP: Bool = false
    var lineABNode: SKSpriteNode!
    var displayNode: SKSpriteNode!
    var lineRayNode: SKSpriteNode!
    var labelA: SKLabelNode!
    var labelB: SKLabelNode!
    var labelI: SKLabelNode!
    var labelP: SKLabelNode!
    var labelLineAB: SKLabelNode!
    
    var origin = CGPoint(x: 0, y: 0)
    var imageLine = CGPoint(x: 200, y: 150)
    
    var ray: Ray2D!
    var lineAB: Line2D!
    
    var displayedTop: CGFloat = 200
    var displayedBottom: CGFloat = 200
    var lastPy: CGFloat!
    
    public override func didMove(to view: SKView) {
        
        pointANode = self.childNode(withName: "a") as? SKSpriteNode
        pointBNode = self.childNode(withName: "b") as? SKSpriteNode
        pointPNode = self.childNode(withName: "p") as? SKSpriteNode
        pointINode = self.childNode(withName: "i") as? SKSpriteNode
        lineABNode = self.childNode(withName: "lineAB") as? SKSpriteNode
        displayNode = self.childNode(withName: "display") as? SKSpriteNode
        lineRayNode = self.childNode(withName: "ray") as? SKSpriteNode
        labelA = self.childNode(withName: "labelA") as? SKLabelNode
        labelB = self.childNode(withName: "labelB") as? SKLabelNode
        labelI = self.childNode(withName: "labelI") as? SKLabelNode
        labelP = self.childNode(withName: "labelP") as? SKLabelNode
        labelLineAB = self.childNode(withName: "labelLineAB") as? SKLabelNode
        ray = Ray2D(c: self.origin, p: self.pointPNode.position)
        lineAB = Line2D(pointA: pointANode.position, pointB: pointBNode.position)
        lastPy = pointPNode.position.y
    }
    
    public override func update(_ currentTime: TimeInterval) {
        linkTwoSpriteNode(from: pointANode.position, to: pointBNode.position, with: lineABNode)
        linkTwoSpriteNode(from: origin, to: pointPNode.position, with: lineRayNode)
        lineAB = Line2D(pointA: pointANode.position, pointB: pointBNode.position)
        //    Ix=t*Px    Iy=t*Py   a*Ix+b*Iy+c=0
        let negC = -lineAB.c
        let aPx = lineAB.a*pointPNode.position.x
        let bPy = lineAB.b*pointPNode.position.y
        let t = negC / (aPx + bPy)
        pointINode.position = CGPoint(x: t*pointPNode.position.x, y: t*pointPNode.position.y)
        
        if isPointOnLineSegment(pointINode.position, pointANode.position, pointBNode.position) {
            displayedTop = max(displayedTop, pointPNode.position.y)
            displayedBottom = min(displayedBottom, pointPNode.position.y)
        } else {
            if abs(pointPNode.position.y - displayedTop) < abs(pointPNode.position.y - displayedBottom) {
                displayedTop = min(displayedTop, pointPNode.position.y)
            } else {
                displayedBottom = max(displayedBottom, pointPNode.position.y)
            }
        }
        lastPy = pointPNode.position.y
        displayNode.position.y = (displayedTop - displayedBottom) / 2 + displayedBottom
        displayNode.size.height = displayedTop - displayedBottom
        
        // hit text
        labelA.position = CGPoint(x: pointANode.position.x, y: pointANode.position.y+20)
        labelA.text = positionXYToString("A", pointANode.position, 1)
        labelB.position = CGPoint(x: pointBNode.position.x, y: pointBNode.position.y-20)
        labelB.text = positionXYToString("B", pointBNode.position, 1)
        labelI.position = CGPoint(x: pointINode.position.x-20, y: pointINode.position.y)
        labelI.text = positionXYToString("I", pointINode.position, 1)
        labelP.position = CGPoint(x: pointPNode.position.x-50, y: pointPNode.position.y)
        labelP.text = positionXYToString("P", pointPNode.position, 1)
        labelLineAB.text = line2DToString("AB", lineAB)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        let touchNodes = nodes(at: touchLocation)
        for node in touchNodes {
            if node == pointANode {
                offsetA = CGPoint(x: touchLocation.x - pointANode.position.x, y: touchLocation.y - pointANode.position.y)
                moveingA = true
                moveingB = false
                moveingP = false
            }
            
            if node == pointBNode {
                offsetB = CGPoint(x: touchLocation.x - pointBNode.position.x, y: touchLocation.y - pointBNode.position.y)
                moveingA = false
                moveingB = true
                moveingP = false
            }
            if node == pointPNode {
                offsetP = CGPoint(x: touchLocation.x - pointPNode.position.x, y: touchLocation.y - pointPNode.position.y)
                moveingA = false
                moveingB = false
                moveingP = true
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if moveingA {
            let newAPos = CGPoint(x: touchLocation.x - offsetA.x, y: touchLocation.y - offsetA.y)
            pointANode.run(SKAction.move(to: newAPos, duration: 0.01))
        }
        if moveingB {
            let newBPos = CGPoint(x: touchLocation.x - offsetB.x, y: touchLocation.y - offsetB.y)
            pointBNode.run(SKAction.move(to: newBPos, duration: 0.01))
        }
        if moveingP {
            let newPPos = CGPoint(x: touchLocation.x - offsetP.x, y: touchLocation.y - offsetP.y)
            let pointPy = clamp(value: newPPos.y, min: 50, max: 250)
            pointPNode.run(SKAction.move(to: CGPoint(x: imageLine.x, y: pointPy), duration: 0.01))
        }
    }
}
