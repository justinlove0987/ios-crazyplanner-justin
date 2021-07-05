//
//  DatePickerCreator.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/7/3.
//

import UIKit


class DatePickerCreator {
    
    let textField: UITextField?
    let datePicker: UIDatePicker?
    let view: UIView?
    
    init(view: UIView ,textField: UITextField, datePicker: UIDatePicker) {
        self.textField = textField
        self.datePicker = datePicker
        self.view = view
    }
    
    func createDatePicker () {
        
        
        textField?.textAlignment = .center
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        
        // assign toolbar
        textField?.inputAccessoryView = toolbar
        
        // assign date picker to the text field
        textField?.inputView = datePicker
        
        // change the prefeeredDatePickerStyle to wheels
        datePicker?.preferredDatePickerStyle = .wheels
        
        //date picker mode
        datePicker?.datePickerMode = .date
        
    }
    
    @objc func donePressed() {
        //fomatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy/MM/dd"
        
        textField?.text = formatter.string(from: datePicker?.date ?? Date())
        print(formatter.string(from: datePicker?.date ?? Date()))
        
        view?.endEditing(true)
    }
    
}
