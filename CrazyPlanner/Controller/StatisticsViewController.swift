//
//  StatusViewController.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/6/18.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController, UIPickerViewDataSource {

    
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var targetTotalAmountLabel: UILabel!
    @IBOutlet weak var targetCompletedAmoutLabel: UILabel!
    @IBOutlet weak var targetLeftAmountLabel: UILabel!
    
    var targets = [Target]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        loadTargets()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadTargets()
        
        pickerView.reloadAllComponents()
        
        let targetTotalAmount = targets[0].total ?? "0"
        let targetCompletedAmount = targets[0].progress ?? "0"
        
        targetTotalAmountLabel.text = targetTotalAmount
        targetCompletedAmoutLabel.text = targetCompletedAmount
        
        if let totalAmount = Int(targetTotalAmount), let completedAmount = Int(targetCompletedAmount) {
            targetLeftAmountLabel.text = String(totalAmount - completedAmount)
            
            DispatchQueue.main.async {
                self.progressBar.progress = CGFloat(completedAmount) / CGFloat(totalAmount)
            }
        }
    }
    
    func loadTargets(with request: NSFetchRequest<Target> = Target.fetchRequest()) {
        do{
            targets =  try context.fetch(request)
        } catch {
            print("Error fetching Data from context \(error)")
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return targets.count
    }


}

extension StatisticsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return targets[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let targetTotalAmount = targets[row].total ?? "0"
        let targetCompletedAmount = targets[row].progress ?? "0"
        
        targetTotalAmountLabel.text = targetTotalAmount
        targetCompletedAmoutLabel.text = targetCompletedAmount
        
        if let totalAmount = Int(targetTotalAmount), let completedAmount = Int(targetCompletedAmount) {
            targetLeftAmountLabel.text = String(totalAmount - completedAmount)
            
            DispatchQueue.main.async {
                self.progressBar.progress = CGFloat(completedAmount) / CGFloat(totalAmount)
            }
        }

    }
    
}
