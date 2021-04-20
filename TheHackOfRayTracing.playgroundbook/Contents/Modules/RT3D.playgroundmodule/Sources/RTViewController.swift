import UIKit
import PlaygroundSupport

public class RTViewController: UIViewController {
    var frame: CGRect! = nil
    
    public func setViewSize(_ frame: CGRect) {
        self.frame = CGRect(x: 0, y: 0, width: frame.width/2, height: frame.height)
    }
    
    public override func loadView() {
        let view = UIView(frame: frame)
        view.backgroundColor = .black
        self.view = view
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGestures)))
    }
    
    @objc func handlePanGestures(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            //print("began", gesture.translation(in: self.view))
        } else if gesture.state == .changed {
            //print("changed", gesture.translation(in: self.view))
            _viewAngle += Float(gesture.translation(in: self.view).x / 4000)
            let lfy = Float(gesture.translation(in: self.view).y) / 4000
            let y = renderConfig.lookfrom.y
            //print("lfy=", lfy)
            //print("y=", y)
            if lfy > 0 && y + lfy <= 10 {
                renderConfig.lookfrom.y += lfy
            }
            if lfy < 0 && y + lfy >= 0.01 {
                renderConfig.lookfrom.y += lfy
            }
        } else if gesture.state == .ended {
            //print("ended", gesture.translation(in: self.view))
        }
    }
}
