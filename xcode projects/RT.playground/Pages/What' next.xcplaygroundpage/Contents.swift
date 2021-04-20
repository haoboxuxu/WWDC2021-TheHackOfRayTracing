//: [Previous](@previous)

/*:
 #### This is the another scenes of Ray Tracing 🌛
 I used random numbers and filtering algorithms to generate the universe🌌 scene, it’s cool, right? Like previous page, run and have fun. Swipe the screen with your finger👆🏼 to soar🦅 in a ray-traced scene.
 - Callout(What's next of Ray Tracing):
 Due to the limited time, I did not expand on more complex content such as how ray reflects and refracts, as well as materials and anti-aliasing. It involves more 3D mathematics and some radiometrics. But it doesn't matter, you know the basics of ray tracing and see the cool effects it can achieve.
 */
/*:
 - Callout(If you want to know more):
 There are two sessions about this on WWDC videos, if you are interested. The demo in the video is an offline rendering. The video also discusses about acceleration of ray tracing, because the intersection calculation is a very cumbersome calculation, and MetalKit provides us with more APIs of acceleration. But it doesn't matter, the concept is similar.
 \
 [Metal for Ray Tracing Acceleration](https://developer.apple.com/videos/play/wwdc2018/606/)
 \
 [Ray Tracing with Metal](https://developer.apple.com/videos/play/wwdc2019/613/)
 */
//#-hidden-code
import UIKit
import MetalKit
import PlaygroundSupport
//import RT3D
//#-end-hidden-code
_samplesPerPixel = /*#-editable-code*/8/*#-end-editable-code*/
_maxDepth = /*#-editable-code*/8/*#-end-editable-code*/
//#-hidden-code
let rtvc = RTViewController()
rtvc.setViewSize(UIScreen.main.bounds)
_imageWidth = Float(UIScreen.main.bounds.width/2)
_imageHeight = Float(UIScreen.main.bounds.height)
let mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: Int(_imageWidth), height: Int(_imageHeight)))
let delegate = RTViewDelegate(mtkView: mtkView, option: 2)
rtvc.view.addSubview(mtkView)
PlaygroundPage.current.liveView = rtvc
//#-end-hidden-code
