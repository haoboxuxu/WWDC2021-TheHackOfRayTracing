import PlaygroundSupport
import SpriteKit
import RT2D

let sceneView = SKView(frame: CGRect(x:0 , y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
if let scene = RayTracing2DScene(fileNamed: "RayTracing2DScene") {
    scene.scaleMode = .aspectFill
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
