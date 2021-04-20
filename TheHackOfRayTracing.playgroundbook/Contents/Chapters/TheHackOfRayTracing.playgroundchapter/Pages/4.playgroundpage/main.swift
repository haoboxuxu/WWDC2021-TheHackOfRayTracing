//: [Previous](@previous)

/*:
 ### This is the final scene of Ray Tracing🌞
 * Callout(Observe specular reflection and refraction):
 Specular🪞 reflection and refraction are difficult to achieve with traditional raster rendering. Ray tracing can do this, but most of them are offline rendering and you can't play🎮 with it. But with the power acceleration of Metalkit⌨️, I can do real-time Ray-tracing on the iPad. How 🆒 it is!
 \
 Swipe the screen with your finger👆🏼 to soar🦅 in a ray-traced scene.
 */
/*:
### Adjust the parameters
- Experiment:
 This has certain performance requirements for your equipment⚠️. Adjust🔧 samplesPerPixel and maxDepth and observe the Specular reflection and refraction effects of the Ray-tracing scene. If you're using an iPad that's not a Pro model, I recommend you lower the parameters to keep the FPS steady⚖️. (I have capped the parameters by up to 15)
 */
//#-hidden-code
import UIKit
import MetalKit
import PlaygroundSupport
import RT3D
//#-end-hidden-code
_samplesPerPixel = /*#-editable-code*/8/*#-end-editable-code*/
_maxDepth = /*#-editable-code*/8/*#-end-editable-code*/
//#-hidden-code
_imageWidth = Float(UIScreen.main.bounds.width/2)
_imageHeight = Float(UIScreen.main.bounds.height)
let rtvc = RTViewController()
rtvc.setViewSize(UIScreen.main.bounds)
let mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: Int(_imageWidth), height: Int(_imageHeight)))
let delegate = RTViewDelegate(mtkView: mtkView, option: 1)
rtvc.view.addSubview(mtkView)
PlaygroundPage.current.liveView = rtvc
//#-end-hidden-code

//: [Next](@next)
