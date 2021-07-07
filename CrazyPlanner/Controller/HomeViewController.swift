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
        
        // 從CoreData讀取資料
        loadDailyTargets()
        loadTargets()

        
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
            if let targetEditorVC = segue.destination as? DailyTargetEditorViewController, let indexPath = sender as? IndexPath {
                let selectedRow = calculateRowIndexInTableView(indexPath: indexPath)
                targetEditorVC.selectedDailyTarget = dailyTargets[selectedRow]
                targetEditorVC.delegate = self
            }
        } else if segue.identifier == "goToListModeVC" {
            if let listModeVC = segue.destination as? ListModeViewController {
                listModeVC.targets = targets
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAddTarget", sender: self)
    }
    
    
    @IBAction func listModeButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToListModeVC", sender: self)
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

extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToEditTarget", sender: indexPath)
        
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
