//
//  ViewController.swift
//  SwiftBanner
//
//  Created by 张行 on 16/8/17.
//  Copyright © 2016年 张行. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let bannerImage1 = UIImage(named: "1.jpg")!
        var banners:[UIImage] = [UIImage]()
        for i in 0...2 {
            let imageName = "\(i + 1).jpg"
            if let image = UIImage(named: imageName) {
                banners.append(image)
            }
        }
        guard banners.count > 0 else {
            return
        }
        let image1:UIImage = banners[0]
        let bannerView = SwiftBannerView(bannerImages:banners ,frame:CGRectZero)
        self.view.addSubview(bannerView!)
        bannerView?.snp_makeConstraints(closure: { (make) in
            make.left.top.right.equalTo(self.view)
            make.width.equalTo(self.view)
            make.height.equalTo(bannerView!.snp_width).multipliedBy(image1.size.height / image1.size.width * 1.00)
        })

        bannerView!.bannerImageClickComplete = {(_:SwiftBannerView, _:UIImageView, _:Int) in
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

