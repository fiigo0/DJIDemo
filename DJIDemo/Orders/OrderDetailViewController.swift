//
//  OrderDetailViewController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 3/4/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController {
    
    var order:Order!

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemNameLbl.text = order.name
        self.loadImage()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage(){
        
        switch order.name {
        case "Relay":
            self.itemImage.image = UIImage(named: "relay.jpg")
            break
        case "AAA battery":
            self.itemImage.image = UIImage(named: "battery.jpg")
            break
        case "A1 Cardone relay":
            self.itemImage.image = UIImage(named: "a1cardonerelay.jpg")
            break
        case "Circuit breaker":
            self.itemImage.image = UIImage(named: "circuitbreaker.jpg")
            break
        case "Cable 30 mts.":
            self.itemImage.image = UIImage(named: "cable30mts.jpg")
            break
        case "Cable 120 mts.":
            self.itemImage.image = UIImage(named: "cable120mts.jpg")
            break
        case "Metal screw":
            self.itemImage.image = UIImage(named: "metalscrew.jpg")
            break
        case "Control Module":
            self.itemImage.image = UIImage(named: "controlmodule.jpg")
            break
        case "Fuse 9999":
            self.itemImage.image = UIImage(named: "fuse9999.jpg")
            break
        case "Nylon screw":
            self.itemImage.image = UIImage(named: "nylonscrew.jpg")
            break
        case "Fuse 7728":
            self.itemImage.image = UIImage(named: "fuse7728.jpg")
            break
        default:
            self.itemImage.image = UIImage(named: "noimage.png")
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
