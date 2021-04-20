//
//  GameViewController.swift
//  RT_SceneKit
//
//  Created by 徐浩博 on 2021/4/6.
//

import UIKit
import SceneKit

let image_width: Int = 16
let image_height: Int = 12
let rtCam = Camera()


public class RT3DVisualizationVC: UIViewController, SCNSceneRendererDelegate {
    
    public var scnView = SCNView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width/2,height: UIScreen.main.bounds.height))
    
    @objc func dPadBtnUpAction(sender: UIButton!) {
        sender.isUserInteractionEnabled = false
        defer {
            sender.isUserInteractionEnabled = true
        }
        self.skSphere.position.y += 0.1
        self.rtSphere.center.e = simd_float3(self.rtSphere.center.x, self.rtSphere.center.y+0.1, self.rtSphere.center.z)
    }
    
    @objc func dPadBtnDownAction(sender: UIButton!) {
        sender.isUserInteractionEnabled = false
        defer {
            sender.isUserInteractionEnabled = true
        }
        self.skSphere.position.y -= 0.1
        self.rtSphere.center.e = simd_float3(self.rtSphere.center.x, self.rtSphere.center.y-0.1, self.rtSphere.center.z)
    }
    
    @objc func dPadBtnLeftAction(sender: UIButton!) {
        sender.isUserInteractionEnabled = false
        defer {
            sender.isUserInteractionEnabled = true
        }
        self.skSphere.position.x -= 0.1
        self.rtSphere.center.e = simd_float3(self.rtSphere.center.x-0.1, self.rtSphere.center.y, self.rtSphere.center.z)
    }
    
    @objc func dPadBtnRightAction(sender: UIButton!) {
        sender.isUserInteractionEnabled = false
        defer {
            sender.isUserInteractionEnabled = true
        }
        self.skSphere.position.x += 0.1
        self.rtSphere.center.e = simd_float3(self.rtSphere.center.x+0.1, self.rtSphere.center.y, self.rtSphere.center.z)
    }
    
    var rtPixelNodes:[SCNNode] = []
    var rayLine: SCNNode!
    let topRightPixelPos = SCNVector3(-0.666, 0.5, -0.5)
    
    // there parameters below is for visualization ray tracing
    let rtCameraPos = Point3(0, 0, 0)
    var rtRedSphereMaterial: BasicMaterial!
    var rtSphere: Sphere!
    var world: RTScene = RTScene()
    
    var skSphere: SCNNode!
    
    func initRtParameters() {
        rtRedSphereMaterial = BasicMaterial(albedo: Color(1, 0, 0))
        rtSphere = Sphere(center: Point3(0, 0, -1), radius: 0.5, material: rtRedSphereMaterial)
        world.objects.append(rtSphere)
    }
    
    var gameTime: Int = 0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initRtParameters()
        
        // create a new scene
        let scene = SCNScene(named: "rt_vis.scn")!
        
        // D-pad button
        let dPadBtnUp: UIButton = {
            let b = UIButton(frame: CGRect(x: self.scnView.frame.width*0.2, y: self.scnView.frame.height*0.8-30, width: 30, height: 30))
            b.setBackgroundImage(UIImage(named: "u.png"), for: UIControl.State.normal)
            b.addTarget(self, action: #selector(dPadBtnUpAction), for: .touchUpInside)
            return b
        }()
        let dPadBtnDown: UIButton = {
            let b = UIButton(frame: CGRect(x: self.scnView.frame.width*0.2, y: self.scnView.frame.height*0.8+30, width: 30, height: 30))
            b.setBackgroundImage(UIImage(named: "d.png"), for: UIControl.State.normal)
            b.addTarget(self, action: #selector(dPadBtnDownAction), for: .touchUpInside)
            return b
        }()
        let dPadBtnLeft: UIButton = {
            let b = UIButton(frame: CGRect(x: self.scnView.frame.width*0.2-30, y: self.scnView.frame.height*0.8, width: 30, height: 30))
            b.setBackgroundImage(UIImage(named: "l.png"), for: UIControl.State.normal)
            b.addTarget(self, action: #selector(dPadBtnLeftAction), for: .touchUpInside)
            return b
        }()
        let dPadBtnRight: UIButton = {
            let b = UIButton(frame: CGRect(x: self.scnView.frame.width*0.2+30, y: self.scnView.frame.height*0.8, width: 30, height: 30))
            b.setBackgroundImage(UIImage(named: "r.png"), for: UIControl.State.normal)
            b.addTarget(self, action: #selector(dPadBtnRightAction), for: .touchUpInside)
            return b
        }()
        
        // retrieve the SCNView
        view.addSubview(scnView)
        view.addSubview(dPadBtnUp)
        view.addSubview(dPadBtnDown)
        view.addSubview(dPadBtnLeft)
        view.addSubview(dPadBtnRight)
        // set the scene
        scnView.scene = scene
        scnView.backgroundColor = UIColor.black
        scnView.delegate = self
        scnView.isPlaying = true
        scnView.allowsCameraControl = true
        //scnView.showsStatistics = true // on debug
        
        rayLine = scene.rootNode.childNode(withName: "rayline", recursively: true)
        
        // setGeometry
        for _ in 0..<192 {
            let node = SCNNode(geometry: SCNSphere(radius: 0.04))
            node.geometry!.firstMaterial?.diffuse.contents = UIColor.black
            rtPixelNodes.append(node)
        }
        let step: Float = 1/12
        var rtPixelNodesIndex: Int = 0
        
        for yIndex:Int in 0..<12 {
            for xIndex:Int in 0..<16 {
                rtPixelNodes[rtPixelNodesIndex].position.x = Float(xIndex) * step + topRightPixelPos.x
                rtPixelNodes[rtPixelNodesIndex].position.y = -Float(yIndex) * step + topRightPixelPos.y
                rtPixelNodes[rtPixelNodesIndex].position.z = topRightPixelPos.z
                scene.rootNode.addChildNode(rtPixelNodes[rtPixelNodesIndex])
                rtPixelNodesIndex += 1
            }
        }
        
        skSphere = scene.rootNode.childNode(withName: "sphere", recursively: false)
    }
    
    func tracing(ray: Ray, world: RTScene) -> Color {
        var record = HitRecord()
        
        if (world.intersect(ray: ray, tMin: 0, tMax: infinity, record: &record)) {
            return (record.material as! BasicMaterial).albedo
        }
        let unit_direction = ray.direction.toUnitVector()
        let t = 0.5*(unit_direction.y + 1.0);
        return (1.0-t)*Color(1.0, 1.0, 1.0) + t*Color(0.5, 0.7, 1.0);
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if gameTime % 10 == 0 {
            let id = gameTime/10
            let frameBallColor = rt(id: id)
            rtPixelNodes[id].geometry?.firstMaterial?.diffuse.contents = UIColor.init(red: CGFloat(frameBallColor.r),
                                                                                          green: CGFloat(frameBallColor.g),
                                                                                          blue: CGFloat(frameBallColor.b),
                                                                                          alpha: 1)
            linkTwoPosition(rtPixelNodes[id].position, SCNVector3(0, 0, 1), rayLine)
        }
        
        var clear = false
        if gameTime/10 == 191 {
            clear = true
        }
        if clear {
            for id in 0..<192 {
                rtPixelNodes[id].geometry?.firstMaterial?.diffuse.contents = UIColor.black
            }
        }
        if !clear {
            gameTime += 1
        } else {
            gameTime = 0
        }
    }
    
    func rt(id: Int) -> Color {
        var frameBallColor: Color!
        var j: Int = id / image_width
        let i: Int = id - j * image_width
        j = image_height - j
        
        let u = Float(i) / Float(image_width-1)
        let v = Float(j) / Float(image_height-1)
        let ray = rtCam.getRay(u: u, v: v)
        let color = self.tracing(ray: ray, world: self.world)
        frameBallColor = color
        
        return frameBallColor
    }
    
    public func atanRotation(len1: Float, len2: Float) -> Float {
        if len2 == 0 {
            return Float.pi / 2
        }else {
            if len1 == 0{
                return 0
            }else {
                return atan(len1 / len2)
            }
        }
    }
    
    public func linkTwoPosition(_ p1: SCNVector3, _ p2: SCNVector3, _ lineNode: SCNNode) {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        let dz = p1.z - p2.z
        
        lineNode.position = SCNVector3((p1.x+p2.x)/2, (p1.y+p2.y)/2, (p1.z+p2.z)/2)
        
        var rotateX: Float = 0
        var rotateZ: Float = 0
        
        let crossLen:Float = Float(abs(sqrt(pow(dx, 2) + pow(dy, 2))))

        if dy > 0 && dx > 0 {
            rotateZ = -atanRotation(len1: dx, len2: dy)
        }
        if dy > 0 && dx < 0 {
            rotateZ = atanRotation(len1: -dx, len2: dy)
        }
        if dy < 0 && dx < 0 {
            rotateZ = -atanRotation(len1: -dx, len2: -dy)
        }
        if dy < 0 && dx > 0 {
            rotateZ = atanRotation(len1: dx, len2: -dy)
        }
        if dy == 0 {
            rotateZ = Float.pi / 2
        }
        
        if dy > 0 && dz < 0 {
            rotateX = -atanRotation(len1: -dz, len2: crossLen)
        }
        if dy > 0 && dz > 0 {
            rotateX = atanRotation(len1: dz, len2: crossLen)
        }
        if dy < 0 && dz > 0 {
            rotateX = -atanRotation(len1: dz, len2: crossLen)
        }
        if dy < 0 && dz < 0 {
            rotateX = atanRotation(len1: -dz, len2: crossLen)
        }
        if dy == 0 {
            //mod
            if dz != 0 {
                rotateX = Float.pi / 2
            }
        }
        lineNode.eulerAngles.x = Float(rotateX)
        lineNode.eulerAngles.z = Float(rotateZ)
        lineNode.scale.y = 4
    }
}
