import UIKit
import MetalKit
import PlaygroundSupport
import AVFoundation
import RT3D

UIScreen.main.bounds
var boundsWidth = Float(UIScreen.main.bounds.width/2)
var boundsHeight = Float(UIScreen.main.bounds.height)
_samplesPerPixel = 3
_maxDepth = 3
_imageWidth = boundsWidth
_imageHeight = boundsHeight * 0.6


if _samplesPerPixel >= 15 {
    _samplesPerPixel = 15
}

if _maxDepth >= 15 {
    _maxDepth = 15
}

// animoji video
let videoFrame = CGRect(x: 0, y: 0, width: 250, height: 250)
let url = URL(fileURLWithPath: Bundle.main.path(forResource: "wow", ofType: "mov")!)
let videoView = UIView(frame: videoFrame)
videoView.center = CGPoint(x: Int(boundsWidth)/2, y: Int(videoFrame.height)/2+20)
let player = AVQueuePlayer()
let playerLayer = AVPlayerLayer(player: player)
playerLayer.frame = videoFrame
videoView.layer.addSublayer(playerLayer)
let playerLooper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
player.play()


// title video
let titleImage = UIImageView(image: UIImage(named: "title.png"))
titleImage.frame = CGRect(x: 0, y: 0, width: titleImage.contentClippingRect.width*0.8, height: titleImage.contentClippingRect.height*0.8)
titleImage.center = CGPoint(x: Int(boundsWidth)/2, y: Int(boundsHeight)/2-180)

// ray tracing video
let v = UIView(frame: CGRect(x: 0, y: 0, width: Int(boundsWidth), height: Int(boundsHeight)))
let mtkView = MTKView(frame: CGRect(x: 0, y: Int(boundsHeight*0.4), width: Int(_imageWidth), height: Int(_imageHeight)))
let delegate = RTViewDelegate(mtkView: mtkView, option: 0)
v.backgroundColor = .black
mtkView.delegate = delegate

v.addSubview(mtkView)
v.addSubview(videoView)
v.addSubview(titleImage)

PlaygroundPage.current.liveView = v
