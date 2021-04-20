import SceneKit

public class Line2D {
    public var a: CGFloat!
    public var b: CGFloat!
    public var c: CGFloat!
    
    public init() {
        
    }
    
    //a=y1-y2
    //b=x2-x1
    //c=x1y2-x2y1
    
    public init(pointA: CGPoint, pointB: CGPoint) {
        let y1 = pointA.y
        let y2 = pointB.y
        let x1 = pointA.x
        let x2 = pointB.x
        a = y1 - y2
        b = x2 - x1
        c = x1*y2-x2*y1
    }
}
