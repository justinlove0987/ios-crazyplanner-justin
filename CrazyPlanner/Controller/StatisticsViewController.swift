//
//  StatusViewController.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/6/18.
//

import UIKit
import Charts
import CoreData


class StatisticsViewController: UIViewController, UIPickerViewDataSource, ChartViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    let lineChart = LineChartView()
    
    var referenceTimeInterval: TimeInterval = 0
    var statisticsDatas = [StatisticsData]()
    
    var targets = [Target]()
    var dailyTargets = [DailyTarget]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        lineChart.delegate = self
        
        loadTargets()
        loadDailyTargets()
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        calculateHaveDonedailyTargetNumber(selectedTargetRow: pickerView.selectedRow(inComponent: 0))
        
        lineChart.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        lineChart.center = view.center
        lineChart.zoom(scaleX: 5, scaleY: 0, x: 0, y: 0)
        lineChart.xAxis.granularityEnabled = true
        
        view.addSubview(lineChart)
        
        if let minTimeInterval = (statisticsDatas.map { $0.date.timeIntervalSince1970 }).min() {
            referenceTimeInterval = minTimeInterval
        }
        
        // Define chart entries
        var entries = [ChartDataEntry]()
        for statisticsData in statisticsDatas {
            let timeInterval = statisticsData.date.timeIntervalSince1970
            let xValue = (timeInterval - referenceTimeInterval) / (3600 * 24)
            let yValue = statisticsData.value
            let entry = ChartDataEntry(x: Double(xValue), y: Double(yValue))
            entries.append(entry)
        }
        
        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelCount = entries.count
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.avoidFirstLastClippingEnabled = true
        lineChart.leftAxis.drawLabelsEnabled = false //取消左邊的標籤列
        //xAxis.axisMaxLabels = 10
        
        // Define chart xValues formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        
        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)
        // Set the x values date formatter
        xValuesNumberFormatter.dateFormatter = formatter // e.g. "wed 26"
        xAxis.valueFormatter = xValuesNumberFormatter

        lineChart.data = data

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadTargets()
        loadDailyTargets()
        pickerView.reloadAllComponents()
        

    }
    
    func loadTargets(with request: NSFetchRequest<Target> = Target.fetchRequest()) {
        do{
            targets =  try context.fetch(request)
        } catch {
            print("Error fetching Data from context \(error)")
        }
    }
    
    func loadDailyTargets(with request: NSFetchRequest<DailyTarget> = DailyTarget.fetchRequest()) {
        do{
            let sortBySection = NSSortDescriptor(key: "section", ascending: true)
            let sortByRow = NSSortDescriptor(key: "row", ascending: true)
            request.sortDescriptors = [sortBySection,sortByRow]
            dailyTargets =  try context.fetch(request)
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
    
    func calculateHaveDonedailyTargetNumber(selectedTargetRow: Int) {
        
        statisticsDatas = [StatisticsData]()
        
        for dailyTarget in dailyTargets {
            if targets[selectedTargetRow].id == dailyTarget.id {
                
                statisticsDatas.append(StatisticsData(date: dailyTarget.date!, value: Double(dailyTarget.progress)))
            }
        }
    }


}

extension StatisticsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return targets[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var entries = [ChartDataEntry]()
        
        calculateHaveDonedailyTargetNumber(selectedTargetRow: row)
        
        for statisticsData in statisticsDatas {
            let timeInterval = statisticsData.date.timeIntervalSince1970
            let xValue = (timeInterval - referenceTimeInterval) / (3600 * 24)
            let yValue = statisticsData.value
            let entry = ChartDataEntry(x: Double(xValue), y: Double(yValue))
            entries.append(entry)
        }
        
        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        lineChart.data = data
        
        print(statisticsDatas)
        
        // lineChart.data?.notifyDataChanged()
        lineChart.notifyDataSetChanged()
        //lineChart.invalidateIntrinsicContentSize()
//        lineChart.setNeedsLayout()
//        lineChart.setNeedsDisplay()
        
        pickerView.reloadAllComponents()
        

    }
    
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    fileprivate var referenceTimeInterval: TimeInterval?

    convenience init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
}

extension ChartXAxisFormatter: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
        let referenceTimeInterval = referenceTimeInterval
        else {
            return ""
        }

        let date = Date(timeIntervalSince1970: value * 3600 * 24 + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }

}

struct StatisticsData {
    
    let date: Date
    let value: Double
    
}
