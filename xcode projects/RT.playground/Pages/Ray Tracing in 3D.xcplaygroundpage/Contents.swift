//: [Previous](@previous)

/*:
 ## Dive in Ray Tracing in 3D
 We have learned and understood the Ray Parametric Function and Implicit Equation and the algorithm for finding Intersection points in 2D ray tracing. It time to dive in and understand Ray Tracing in 3D
 */
/*:
 - Note:
 **Ray Parametric Function**
 \
 We set the Ray Parametric Function in 3D as: *R(t) = C + t•P* , where C is the origin and P is the direction. It is indeed slightly different from 2D, but don’t worry, the essence is exactly the same.
 \
 \
 **Implicit Sphere Equation**
 \
 The sphere is a 3D object familiar to everyone. It has simple implicit equation and it's a good start. So why not.
 \
 For any point R(x,y,z) in space, distance to center of specific sphere is subtraction of vectors (R - O) where O is center of sphere, therefore:
 \
 *(R - O)•(R - O) = (x-Ox)^2 + (y-Oy)^2 + (z-Oz)^2*, which is *(R - O)•(R - O) = r^2* in vector form. Meaning that point R was on the sphere if satisfies the equation.
 \
 For point R we can substitute Ray Parametric Function in it, which gives us *(C + t•P  - O)•(C + t•P  - O) = r^2*
 \
 Expand the equation and we get:
 \
 *t^2•P•P + 2•t•P•(C - O) + (C - O)•(C - O) - r^2 = 0*
 \
 Does it look unfamiliar? Yes, this is a quadratic equation in one variable. Solving for the unknown t and we can move to next.
 \
 \
 **Intersection**
 \
 It’s very easy to calculate the position of Intersection point. By solving for the unknown t , we can know how far and where the ray position is, because other variables are known. Just it in Ray Parametric Function and we get Intersection point I = C + t•P.
 */
//: ![IntersectionSphere](IntersectionSphere.png)
/*:
 ## Put colors per pixel on screen
 The live view shows how Ray interest which sphere in the scene from the camera and colors every individual pixel on screen📺. The the little dots represent pixels.
 */
/*:
### 🕹 Move the ball 🔴 through D-pad ⬅️⬆️⬇️➡️
- Experiment:
 Part of the code on this page is already an implementation of ray tracing. You can 🕹 the position of the 🔴 through the D-pad and watch the changes of each pixel on each frame of the 📺, which is real-time.
 */

//: [Next](@next)

//#-hidden-code
import PlaygroundSupport
import SceneKit
import UIKit
//import RT3DVis
let rtvis = RT3DVisualizationVC()
PlaygroundPage.current.liveView = rtvis
//#-end-hidden-code
