/*:
 ## Welcome. Ray glow and Tracing behold!
 
 Welcome! This playgroundbook is about **Ray Tracing**, which is very common in video games in recent years. And I think it's time to brinng this huge topic to playgroundbook and show everyone the hack of it.
 
 In this playgroundbook📖, you'll learn the concept🧠 and math📐 behind it. You'll start with some basic scenes to understand the math, finally there will be a real-time **Ray Tracing** scene running on iPad to show you the magic🎩 of this rendering technique!
 */
/*:
 - Note:
 [*Ray Tracing*](https://en.wikipedia.org/wiki/Ray_tracing_(graphics))
 \
 Ray tracing is a new rendering technique for generating an image by tracing the path of ray(light)💡 per pixels in an image and simulating the effects of its encounters with virtual objects. It makes ray tracing is the closest rendering technique to real physics⚛️ effects. This is why ray tracing looks so real, but it also comes at a price. High-performance graphics card and efficient code are both required.
 \
 Most early ray tracing programs could not run in **real time**, meaning that they could not reach at least 30 frames per second, so you can’t play🎮 with it.
 */
//: ![BellLabs1978](BellLabs1978.png)
/*:
 - Note:
 [*Emission theory of Vision*](https://en.wikipedia.org/wiki/Emission_theory_(vision))
 \
 Like I mentioned earlier, ray tracing needs to trace every ray emitted by the light source, calculate the color of each position on the object, and display it on the screen🖥. But this sounds like an infinite calculation. Fortunately we can think backwards, We can assume that light is emitted from the eyes👀, hits a certain point on the object and finally reaches the light source💡, and color🎨 this point on the object through the superposition of colors. This is what Emission theory of Vision tells us.
 */
//: ![EmissionTheoryOfVision](EmissionTheoryOfVision.png)
/*:
 - Note:
 *Parallel Computing*
 \
 CPU is very powerful and can help us complete a lot of calculations, but for rendering we need to complete a lot of concurrent calculations at the same time. Because graphics cards are born with many computing cores. Therefore, we need to transfer the calculations to the **graphics card**, and **MetalKit** can help us build calculations on the graphics card. With the MetalKit, I create a ray tracing engine from scratch. I use **Computer Shader** to generate real time ray tracing image and **UIGestureRecognizer** alow you to play🎮 with it. The live view gives you a first peak of it (Just look at those 🌈 color balls specular reflections on the center metal ball). Don't worry, it will be more exciting stuff comming soon.
 */
/*:
 ## Contents
 
 1. [What's Ray Tracing](1)
 2. [Ray equation in 2D](2)
 3. [Ray Tracing in 3D](3)
 4. [Real-Time Ray Tracing](4)
 5. [What' next](5)
 */

//: [Next](@next)

//#-hidden-code
import UIKit
import MetalKit
import PlaygroundSupport
import AVFoundation
//import RT3D

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
//#-end-hidden-code
