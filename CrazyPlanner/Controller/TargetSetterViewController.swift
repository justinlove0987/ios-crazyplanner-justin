//
//  TargetSetterViewController.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/6/21.
//

import UIKit

protocol TargetSetterViewControllerDelegate: AnyObject {
    func didFinishAddingTarget(target: Target)
    func didFinishAddingDailyTarget(dailyTarget: DailyTarget)
}

class TargetSetterViewController: UIViewController {
    
    @IBOutlet weak var targetNameTextField: UITextField!
    @IBOutlet weak var targetUnitTextField: UITextField!
    @IBOutlet weak var targetTotalAmountTextField: UITextField!
    @IBOutlet weak var targetProgressTextField: UITextField!
    @IBOutlet weak var targetDailyAmountTextField: UITextField!
    @IBOutlet weak var targetWeeklyAmountTextField: UITextField!
    @IBOutlet weak var targetDateTextField: UITextField!
    
    var delegate: TargetSetterViewControllerDelegate?
    
    var targets: [Target]!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var targetCostDaysQuotient: Int = 0
    var targetCostDaysRemainder: Int = 0
    
    let datePicker = UIDatePicker()
    var currentDate = Date()
    var textFieldDate = Date() //日期可能會從textfied或是datePicker轉變
    
    // let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        targetDailyAmountTextField.delegate = self
        targetProgressTextField.delegate = self
        
        datePicker.minimumDate = currentDate
        
        targetDailyAmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        targetDateTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        datePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .allEvents)
        
        let datePickerCreator = DatePickerCreator(view: view, textField: targetDateTextField, datePicker: datePicker)
        datePickerCreator.createDatePicker()
    }
    
    @IBAction func done(_ sender: UIButton) {
        
        var date = Date()
        
        let newTarget = Target(context: self.context)
        
        
        if targetNameTextField.text! == "" {
            let alert = UIAlertController(title: "請輸入目標名稱！", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
            
        } else {
            
            let uuid = UUID().uuidString
            newTarget.id = uuid
            newTarget.name = targetNameTextField.text!
            newTarget.unit = Int64(targetUnitTextField.text!) ?? 0
            newTarget.total = Int64(targetTotalAmountTextField.text!) ?? 0
            newTarget.progress = Int64(targetProgressTextField.text!) ?? 0
            newTarget.daily = targetDailyAmountTextField.text!
            

            while date <= textFieldDate {
                
                let newDailyTarget = DailyTarget(context: self.context)
                newDailyTarget.date = date
                newDailyTarget.id = uuid
                newDailyTarget.name = targetNameTextField.text!
                newDailyTarget.total = Int64(targetDailyAmountTextField.text!) ?? 0
                newDailyTarget.progress = 0
                newDailyTarget.section = -1
                newDailyTarget.row = -1
                
                // 增加若還沒到最終日期就加上一日
                var dateComponents = DateComponents()
                dateComponents.day = 1
                date = Calendar.current.date(byAdding: dateComponents, to: date) ?? date
                
                delegate?.didFinishAddingDailyTarget(dailyTarget: newDailyTarget)
            }
            
            let newDailyTarget = DailyTarget(context: self.context)
            newDailyTarget.date = date
            newDailyTarget.id = uuid
            newDailyTarget.name = targetNameTextField.text!
            newDailyTarget.total = Int64(targetDailyAmountTextField.text!) ?? 0
            newDailyTarget.progress = 0
            newDailyTarget.section = -1
            newDailyTarget.row = -1
            
            delegate?.didFinishAddingDailyTarget(dailyTarget: newDailyTarget)
            delegate?.didFinishAddingTarget(target: newTarget)
            
            navigationController?.popViewController(animated: true)
        }
        

        
    }
    
    func calculateFromDailyAmount() {
        
        if let total = Double(targetTotalAmountTextField.text!),  let progress = Double(targetProgressTextField.text!), let daily = Double(targetDailyAmountTextField.text!) {
            
            if daily != 0 {
                targetCostDaysQuotient = Int(floor((total - progress) / daily))
                targetCostDaysRemainder = Int((total - progress).truncatingRemainder(dividingBy: daily))
                
                var dateComponent = DateComponents()
                
                if targetCostDaysRemainder != 0 {
                    targetCostDaysQuotient += 1
                }
                
                dateComponent.day = targetCostDaysQuotient
                
                if let nextDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) {
                    textFieldDate = nextDate
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .none
                    formatter.dateFormat = "yyyy/MM/dd"
                    
                    targetDateTextField.text = formatter.string(from: nextDate)
                }
                
            } else {
                // maybe pop up a alertController
            }
            
            
        }

    }
    
    func calculateFromTargetTotalAmount() {
        
        
        if let total = Double(targetTotalAmountTextField.text!) {
            
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let components = Calendar.current.dateComponents([.day], from: currentDate, to: datePicker.date)
            
            var dateComponent = DateComponents()
            dateComponent.day = 1
            
            
            
            if var day = components.day {
                textFieldDate = datePicker.date
                if formatter.string(from: currentDate) == formatter.string(from: datePicker.date) {
                    day += 1
                } else {
                    day += 2
                }
                
                var daily = total / Double(day)
                if daily != floor(daily) {
                    daily = floor(daily) + 1
                }
                targetDailyAmountTextField.text = String(format: "%.0f", daily)
                
            }
        }
    }
    
    @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
        calculateFromTargetTotalAmount()
    }
    
    
}

extension TargetSetterViewController: UITextFieldDelegate {
    
//    func createDatePicker () {
//
//        targetDateTextField.textAlignment = .center
//
//        //toolbar
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//
//        //bar button
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
//        toolbar.setItems([doneBtn], animated: true)
//
//
//        // assign toolbar
//        targetDateTextField.inputAccessoryView = toolbar
//
//        // assign date picker to the text field
//        targetDateTextField.inputView = datePicker
//
//        // change the prefeeredDatePickerStyle to wheels
//        datePicker.preferredDatePickerStyle = .wheels
//
//        //date picker mode
//        datePicker.datePickerMode = .date
//
//    }
//
    @objc func donePressed() {
        //fomatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy/MM/dd"

        targetDateTextField.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == targetDailyAmountTextField {
            
            calculateFromDailyAmount()
            
        } else if textField == targetDateTextField {
            
            calculateFromTargetTotalAmount()
            
        }
    }
    
}
