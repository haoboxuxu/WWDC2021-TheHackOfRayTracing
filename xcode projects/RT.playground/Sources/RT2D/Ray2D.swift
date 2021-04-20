import SceneKit

public class Ray2D {
    public var p: CGPoint! // direction
    public var c: CGPoint! // origin
    
    public init() {
        
    }
    
    public init(c: CGPoint, p: CGPoint) {
        self.c = c
        self.p = p
    }
    
    func at(_ t: CGFloat) -> CGPoint {
        // (1-t)*c + t*p
        let partA = CGPoint(x: (1-t)*c.x, y: (1-t)*c.y)
        let partB = CGPoint(x: t*p.x, y: t*p.y)
        return CGPoint(x: partA.x+partB.x, y: partA.y+partB.y)
    }
}
