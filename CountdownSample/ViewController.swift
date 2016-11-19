//
//  ViewController.swift
//  CountdownSample
//
//  Created by Kazuya Ueoka on 2016/11/19.
//
//

import UIKit
import CountdownLabel

class ViewController: UIViewController {
    @IBOutlet var countdownLabel: CountdownLabel!
    @IBOutlet weak var finishedImageView: UIImageView!
    @IBOutlet weak var finishedImageWidth: NSLayoutConstraint!
    lazy var countdownManager: CountdownManager = {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date: Date = formatter.date(from: "2016/12/25 00:00:00")!
        
        return CountdownManager(with: date)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.finishedImageView.isHidden = true
        self.countdownManager.intervalPerSeconds = 5
        self.countdownManager.timerUpdate { [weak self] (text: String) in
            self?.countdownLabel.text = text
        }
        
        self.countdownManager.timerFinish({ [weak self] in
            self?.countdownLabel.isHidden = true
            self?.finishedImageView.isHidden = false
            
            guard let strongSelf = self else {
                return
            }
            
            self?.finishedImageView.removeConstraint(strongSelf.finishedImageWidth)
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: strongSelf.finishedImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: strongSelf.view, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0)
            ])
            UIView.animate(withDuration: 1.0, animations: { 
                strongSelf.view.layoutIfNeeded()
            })
        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.countdownManager.activate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.countdownManager.inactivate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

