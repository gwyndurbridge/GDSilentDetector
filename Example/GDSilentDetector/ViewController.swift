//
//  ViewController.swift
//  GDSilentDetector
//
//  Created by Gwyn Durbridge on 09/16/2017.
//  Copyright (c) 2017 Gwyn Durbridge. All rights reserved.
//

import UIKit
import GDSilentDetector

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

class ViewController: UIViewController {

    var silentChecker: GDSilentDetector!
    
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        silentChecker = GDSilentDetector()
        silentChecker.delegate = self
        
        checkSilent(self)
    }
    
    @IBAction func checkSilent(_ sender: Any) {
        if Platform.isSimulator {
            self.statusLabel.text = "Cannot detect silent switch on simulator"
        }
        else {
            silentChecker.checkSilent()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: GDSilentDetectorDelegate {
    func gotSilentStatus(isSilent: Bool) {
        DispatchQueue.main.async {
            self.statusLabel.text = isSilent ? "SILENT ENABLED" : "SILENT DISABLED"
        }
    }
}
