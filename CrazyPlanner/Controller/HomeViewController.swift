//
//  ViewController.swift
//  CrazyPlanner
//
//  Created by 曾柏瑒 on 2021/6/18.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, TargetSetterViewControllerDelegate, TargetEditorViewControllerDelegate  {
    
    private let tableView: UITableView =  {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var targets = [Target]()
    var dailyTargets = [DailyTarget]()
    
    var dateArrayForSection = [String:Int]()
    var sortedDateArrayForSection = [Dictionary<String, Int>.Element]()
    let dateFormatter = DateFormatter()
    let stringToDateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        stringToDateFormatter.dateFormat = "yyyy/MM/dd'T'HH:mm:ssZ"
        
        view.addSubview(tableView)
        configureTableViewConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        loadDailyTargets() // 從CoreData提取資料

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        calculateRowsInSection()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func configureTableViewConstraints() {
        var constraints = [NSLayoutConstraint]()
        // Add
        constraints.append(tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100))
        // Activate (Applying)
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddTarget" {
            if let targetSetterVC = segue.destination as? TargetSetterViewController {
                targetSetterVC.targets = targets
                targetSetterVC.delegate = self
            }
        } else if segue.identifier == "goToEditTarget" {
            if let targetEditorVC = segue.destination as? TargetEditorViewController, let indexPath = sender as? IndexPath {
                let selectedRow = calculateRowIndexInTableView(indexPath: indexPath)
                targetEditorVC.selectedDailyTarget = dailyTargets[selectedRow]
                targetEditorVC.delegate = self
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func Nothing(_ sender: UIButton) {
        
    }
    
    //MARK: - delegate Methods
    
    func didFinishAddingTarget(target: Target) {
        targets.append(target)
        saveTargets()
    }
    
    func didFinishAddingDailyTarget(dailyTarget: DailyTarget) {
        dailyTargets.append(dailyTarget)
        assignRowAndSectionToDailyTarget()
        
    }
    
    
    func didFinishEditingTarget(dailyTarget: DailyTarget) {
        assignRowAndSectionToDailyTarget()
    }
    
    //MARK: - Data Mainpulation Methods
    
    func saveTargets() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
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
    
    //MARK: - GetTableViewCellValue Methods
    
    func calculateRowsInSection() {
        
        dateArrayForSection = [String:Int]()
        
        for dailyTarget in dailyTargets {
            
            let date = dateFormatter.string(from: dailyTarget.date ?? Date())
            
            if let _ =  dateArrayForSection[date]   {
                dateArrayForSection[date]! += 1
            } else {
                dateArrayForSection[date] = 1
            }
        }
        sortedDateArrayForSection = dateArrayForSection.sorted { $0.key < $1.key }
    }
    
    
    func assignRowAndSectionToDailyTarget() {
        
        calculateRowsInSection()
        
        for dailyTarget in dailyTargets {
            
            let dateFromDailyTarget = dateFormatter.string(from: dailyTarget.date ?? Date())
            
            for (index,dateAndNumberOfRowsInSection) in sortedDateArrayForSection.enumerated() {
                
                let date = dateAndNumberOfRowsInSection.key
                let NumberOfRowsInSection = dateAndNumberOfRowsInSection.value
                
                if date == dateFromDailyTarget {
                    dailyTarget.section = Int64(index)
                    if dailyTarget.row == -1 {
                        dailyTarget.row = Int64(NumberOfRowsInSection) - 1
                    }
                }
            }
        }
        saveTargets()
        loadDailyTargets()
    }
    
    func calculateRowIndexInTableView(indexPath: IndexPath) -> Int {
        var rowNumber = indexPath.row
        for index in 0 ..< indexPath.section {
            rowNumber += self.tableView.numberOfRows(inSection: index)
        }
        return rowNumber
    }
    
    func getMaxRowIndexInSection(indexPath: IndexPath) -> Int {
        var rowNumber = 0
        for index in 0 ... indexPath.section {
            rowNumber += self.tableView.numberOfRows(inSection: index)
        }
        
        rowNumber -= 1
        
        return rowNumber
    }
    
    func getMinRowIndexInSection(indexPath: IndexPath) -> Int {
        var rowNumber = 0
        for index in 0 ..< indexPath.section {
            rowNumber += self.tableView.numberOfRows(inSection: index)
        }
        
        rowNumber += 1
        
        return rowNumber
    }
    
}

// MARK: - table view data source methods

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDateArrayForSection.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedDateArrayForSection[section].value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let RowIndex = calculateRowIndexInTableView(indexPath: indexPath)
        cell.textLabel?.text = dailyTargets[RowIndex].name
        cell.showsReorderControl = true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedDateArrayForSection[section].key
    }
    
}

// MARK: - table view delegate methods

extension HomeViewController: UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToEditTarget", sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        let row = calculateRowIndexInTableView(indexPath: indexPath)
        dragItem.localObject = dailyTargets[row].row
        return [ dragItem ]
        
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceRow = calculateRowIndexInTableView(indexPath: sourceIndexPath)
        let sourceRows = tableView.numberOfRows(inSection: sourceIndexPath.section)
        var destinationRow = calculateRowIndexInTableView(indexPath: destinationIndexPath)
        let maxSourceRowIndex = getMaxRowIndexInSection(indexPath: sourceIndexPath)
        let maxDestinationRowIndex = getMaxRowIndexInSection(indexPath: destinationIndexPath)
        
        if destinationIndexPath.section > sourceIndexPath.section { //
            destinationRow -= 1
        }

        calculateRowsInSection()
        
        // 更動資料庫的順序
        if sourceIndexPath.section == destinationIndexPath.section {
            
            if sourceIndexPath.row < destinationIndexPath.row { //這個是將indexPath在同一個section往下移動的狀況
                let numberOfMovedRows = destinationIndexPath.row - sourceIndexPath.row
                for rowIndex in (sourceRow + 1)...(sourceRow + numberOfMovedRows) {
                    dailyTargets[rowIndex].row -= 1
                }
            } else if sourceIndexPath.row > destinationIndexPath.row {
                let numberOfMovedRows = sourceIndexPath.row - destinationIndexPath.row
                for rowIndex in (sourceRow - numberOfMovedRows)...(sourceRow - 1) {
                    dailyTargets[rowIndex].row += 1
                }
                
            }
            
        } else if sourceIndexPath.section < destinationIndexPath.section {
            
            if sourceRow != maxSourceRowIndex { //由上而下跨section移動時，如果是上方的section就不用更改任何上方的row值
                for rowIndex in (sourceRow + 1) ... (maxSourceRowIndex) {
                    dailyTargets[rowIndex].row -= 1
                }
            }
            
            if destinationRow != maxDestinationRowIndex{
                for rowIndex in (destinationRow + 1)...maxDestinationRowIndex {
                    dailyTargets[rowIndex].row += 1
                }
            }
            
            if sourceRows == 1 {
                for dailyTarget in dailyTargets {
                    if dailyTarget.section >= destinationIndexPath.section {
                        dailyTarget.section -= 1
                    }
            }
            }
            
            
            
        } else {
            
        }
        
        let dateString = sortedDateArrayForSection[destinationIndexPath.section].key + "T01:15:00+0000"

        dailyTargets[sourceRow].date = stringToDateFormatter.date(from: dateString)
        dailyTargets[sourceRow].section = Int64(destinationIndexPath.section)
        dailyTargets[sourceRow].row = Int64(destinationIndexPath.row)
        
        
        for dailyTarget in dailyTargets {
            print(dailyTarget.name)
            print(dateFormatter.string(from: dailyTarget.date ?? Date()))
            print(dailyTarget.section)
            print(dailyTarget.row)
        }
        
        // 寫入資料庫
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        loadDailyTargets()
        calculateRowsInSection()
        

        if sourceRows == 1 {
            tableView.deleteSections([sourceIndexPath.section], with: .automatic)
        }
        
        tableView.reloadData()
        
    }
    
    
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Dictionary where Value: RangeReplaceableCollection {
    public mutating func append(element: Value.Iterator.Element, toValueOfKey key: Key) -> Value? {
        var value: Value = self[key] ?? Value()
        value.append(element)
        self[key] = value
        return value
    }
}
