import UIKit
import FirebaseUI

class CustomizeAuthViewController: FUIAuthPickerViewController {
    
    
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        self.view.backgroundColor = UIColor.white
//        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        imageViewBackground.image = UIImage(named: "")
        
        // you can change the content mode:
//        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        let imageName = "Image-1"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        
        imageView.frame = CGRect(x: 240, y: 200, width: 300, height: 300)
        view.addSubview(imageView)
//        view.insertSubview(imageViewBackground, at: 0)
        
    }
    
}
