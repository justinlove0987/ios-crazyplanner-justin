//
//  TargetEditorViewController.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/6/23.
//

import UIKit
import CoreData

protocol TargetEditorViewControllerDelegate: AnyObject {
    func didFinishEditingTarget(dailyTarget: DailyTarget)
}

class TargetEditorViewController: UIViewController {
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    var delegate: TargetEditorViewControllerDelegate?
    var selectedDailyTarget: DailyTarget?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let selectedDailyTarget = selectedDailyTarget {
            
            let total = selectedDailyTarget.total
            let progress = selectedDailyTarget.progress
            
            DispatchQueue.main.async {
                self.progressBar.progress = CGFloat(progress) / CGFloat(total)
            }
        }
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        addAndSubtractHelper(number: +1)
        
    }
    
    @IBAction func subtractButtonPressed(_ sender: UIButton) {
        
        addAndSubtractHelper(number: -1)
        
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        
        addAndSubtractHelper(number: 0)
        
    }
    
    @IBAction func done(_ sender: UIButton) {
        
        if let  selectedDailyTarget = selectedDailyTarget {
            delegate?.didFinishEditingTarget(dailyTarget: selectedDailyTarget)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func addAndSubtractHelper(number: Int32) {
        
        if let selectedDailyTarget = selectedDailyTarget {
            
            if number == 0 {
                selectedDailyTarget.progress = selectedDailyTarget.total
            } else {
                selectedDailyTarget.progress += number
            }
            
            let total = selectedDailyTarget.total
            let progress = selectedDailyTarget.progress
            
            DispatchQueue.main.async {
                self.progressBar.progress = CGFloat(progress) / CGFloat(total)
            }
            
            delegate?.didFinishEditingTarget(dailyTarget: selectedDailyTarget)
            
        }
        
        
    }
    
}
























