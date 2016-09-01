//
//  ViewController.swift
//  TJAvatarLoadIndicator
//
//  Created by Thunyathon Jaruchotrattanasakul on 08/31/2016.
//  Copyright (c) 2016 Thunyathon Jaruchotrattanasakul. All rights reserved.
//

import UIKit
import RxSwift
import TJAvatarLoadIndicator

class ViewController: UIViewController {
    
    private var state = 0
    private var tmp: Variable<Bool>!
    @IBOutlet weak var image: TJAvatarLoadIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.centerImage = UIImage(named: "Placeholder")!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        image.startLoading()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startStop(sender: AnyObject) {
        if state == 1 {
            image.startLoading()
            state = 0
        }else {
            image.completeLoading({
                print("Complete!")
            })
            state = 1
        }
    }
    
    
}

