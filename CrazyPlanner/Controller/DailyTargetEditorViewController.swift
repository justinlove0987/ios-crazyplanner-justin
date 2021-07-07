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

class DailyTargetEditorViewController: UIViewController {
    
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var reviseDateTextField: UITextField!

    let datePicker = UIDatePicker()
    let formatter = DateFormatter()
    
    var delegate: TargetEditorViewControllerDelegate?
    var selectedDailyTarget: DailyTarget?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy/MM/dd"
        
        
        if let dailyTarget = selectedDailyTarget {
            reviseDateTextField.text = formatter.string(from: dailyTarget.date ?? Date())
        }
        
        datePicker.date = selectedDailyTarget?.date ?? Date()
        
        let datePickerCreator = DatePickerCreator(view: view, textField: reviseDateTextField, datePicker: datePicker)
        datePickerCreator.createDatePicker()
        
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
        addOrSubtractProgress(number: +1)
    }
    
    @IBAction func subtractButtonPressed(_ sender: UIButton) {
        addOrSubtractProgress(number: -1)
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        addOrSubtractProgress(number: 0)
    }
    
    
    @IBAction func done(_ sender: UIButton) {
        
        let selectedDailyTargetDate = formatter.string(from: selectedDailyTarget?.date ?? Date())
        let datePickerDate = formatter.string(from: datePicker.date)
        
        if selectedDailyTargetDate != datePickerDate {
            selectedDailyTarget?.date = datePicker.date
            // selectedDailyTarget?.section = -1
            // selectedDailyTarget?.row = -1
        }
        
        if let  dailyTarget = selectedDailyTarget {
            delegate?.didFinishEditingTarget(dailyTarget: dailyTarget)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func addOrSubtractProgress(number: Int64) {
        
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
    
    @objc func donePressed() {
        //fomatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy/MM/dd"

        reviseDateTextField.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
}
























