//: [Previous](@previous)

/*:
 ## Get started with Ray Tracing in cross section
 For most math problems, 2D are always a good starting point. Let's look at how ray intersect with object in 2D. We can start by taking a cross section with 3D situation that contains camera and viewing direction.
 */
/*:
 - Note:
 **Image Line**
 \
 By taking a cross section, you can consider the screen as Image Line, which is a line (As 🏞 shows in live view). The Image Line shows objects behind it (which is LineAB on live view).
 \
 \
 **Line Segment**
 \
 To make the scene simpler, there's only a line connecting Point A and Point B (As you see on live view). You can consider the Line Segment as scene object.
 \
 \
 **Camera**
 \
 To make it even simpler, we put our Camera on C(0, 0), which is the origin of the 2D coordinate system (As 📷 shows in live view).
 \
 \
 **Ray**
 \
 We pick a Point P on Image Line denotes the pixel we want to show on screen, connecting P and C gives us the viewing direction. Which is the direction of ray. And we can build the Ray from C through P until often to Line Segment. Yes, the red line is our Ray. As I discussed on first page, ray tracing is about a mathematical way to compute the intersection point with the scene. Which is Point I on the scene.
 */
/*:
 - Important:
 Mathematical Way
 \
 \
 **Implicit Line Equation**
 \
 You may know a Line Equation can be expressed as *y = k•x+b*, or *a•x + b•y +c  = 0* in Implicit way. In order not to get into the trouble of k=0, we choose the Implicit Line Equation.
 \
 Of course we can calculate a b c by substituting the coordinates of A(x1,y1) and B(x2,y2).
 \
 Which gives us *a = y1 - y2*, *b = x2 - x1* and *c = x1•y2 - x2•y1* in *a•x + b•y +•c  = 0*.
 \
 \
 **Ray Parametric Function**
 \
 You may say Ray Equation can also be expressed as implicit line equation, but we may get into the trouble in 3D, so we gonna use Parametric Function.
 \
 *R(t) = (1-t)•C + t•P*, where t is the weight averaged of C and P, which means R(t) goes through C and P. And we can also relabel C and P with R(0) and R(1) as the two equations tell us below.
 \
 *R(0) = C, t = 0*
 \
 *R(1) = P, t = 1*
 \
 \
 **Intersection**
 \
 As I saied before, we called our Intersection Point I with coordinate of I(Ix,Iy). So there must be some value of t go through I that I = R(t*)
 \
 This actually two equations. Ix = Rx(t*) and Iy = Ry(t*)
 \
 Ix = (1-t*)•Cx + t•Px 1⃣️
 \
 Iy = (1-t*)•Cy + t•Py 2⃣️
 \
 And I is also on line segment AB, so *a•Ix + b•Iy +c  = 0* 3⃣️
 \
 Simultaneous equations 1⃣️2⃣️3⃣️ gives us t* and Coordinate of I(Ix,Iy).
 */
/*:
 - Experiment:
 • Silde the red Point P on image view from top to bottom, see the image forming up on it.
 \
 • Change the positions of  A and B, the silde agian.
 \
 • Watch the parameters on screen and understand mathematical formulas behind 2D Ray Tracing
 */
//: ![2drt_1](2drt_1.png)
//: ![2drt_2](2drt_2.png)

//: [Next](@next)

import PlaygroundSupport
import SpriteKit
//import RT2D

let sceneView = SKView(frame: CGRect(x:0 , y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
if let scene = RayTracing2DScene(fileNamed: "RayTracing2DScene") {
    scene.scaleMode = .aspectFill
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView


