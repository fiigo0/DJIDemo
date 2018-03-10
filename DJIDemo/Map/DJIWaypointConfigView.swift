//
//  DJIWaypointConfigView.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 3/2/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit

protocol DJIWaypointConfigViewDelegate:class {
    func cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC:DJIWaypointConfigView)
    func finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC:DJIWaypointConfigView)
}

class DJIWaypointConfigView: UIView {

    @IBOutlet weak var altitudeTextField: UITextField?
    @IBOutlet weak var autoFlightSpeedTextField: UITextField?
    @IBOutlet weak var maxFlightSpeedTextField: UITextField?
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl?
    @IBOutlet weak var headingSegmentControl: UISegmentedControl?
 
    weak var delegate:DJIWaypointConfigViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initUI(){
        self.altitudeTextField?.text = "50"
        self.autoFlightSpeedTextField?.text = "8"
        self.maxFlightSpeedTextField?.text = "10"
        self.actionSegmentedControl?.selectedSegmentIndex = 1
        self.headingSegmentControl?.selectedSegmentIndex = 0
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        print("cancel")
        if delegate != nil {
            delegate?.cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: self)
        }
    }
    
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        print("finished")
        if delegate != nil {
            delegate?.finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: self)
        }
    }

}
