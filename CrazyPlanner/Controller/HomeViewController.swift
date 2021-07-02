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
    
    var dailyTargetOrderedByDate = [DailyTargetOrderedByDate()]
    var dailyTargetNameDictionary = [String:[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        
        view.addSubview(tableView)
        configureTableViewConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(gesture)
        
        loadTargets()
        loadDailyTargets()
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getTableViewCellInfo()
        
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
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print(indexPath)
            }
        }
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
    
    //MARK: - delegate Methods
    
    func didFinishAddingTarget(target: Target) {
        targets.append(target)
        saveTargets()
    }
    
    func didFinishAddingDailyTarget(dailyTarget: DailyTarget) {
        
        dailyTargets.append(dailyTarget)
        getTableViewCellInfo()
        saveTargets()
        
    }
    
    
    func didFinishEditingTarget(dailyTarget: DailyTarget) {
        saveTargets()
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
            let sort = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [sort]
            dailyTargets =  try context.fetch(request)
        } catch {
            print("Error fetching Data from context \(error)")
        }
    }
    
}

// MARK: - table view data source methods

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        
        return header
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sortedKeys = Array(dailyTargetNameDictionary.keys).sorted(by: <) // ["01", "02", "03"]
        
        return sortedKeys[section]
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return dailyTargetNameDictionary.count
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        let sortedDic = dailyTargetNameDictionary.sorted { $0.key < $1.key }
        
        return sortedDic[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let sortedDic = dailyTargetNameDictionary.sorted { $0.key < $1.key }
        
        if sortedDic[indexPath.section].value.count - 1 >= indexPath.row {
            cell.textLabel?.text = sortedDic[indexPath.section].value[indexPath.row]
        }
        
        cell.showsReorderControl = true
        
        
        return cell
    }
    
    func getTableViewCellInfo() {
        
        dailyTargetOrderedByDate = [DailyTargetOrderedByDate()]
        dailyTargetNameDictionary = [String:[String]]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        
        for dailyTarget in dailyTargets {
            let date = formatter.string(from: dailyTarget.date ?? Date())
            
            // dailyTargetOrderedByDate[]
            
            
            
            //此處考慮建立structure
            if var _ = dailyTargetNameDictionary[date] {
                dailyTargetNameDictionary[date]!.append(dailyTarget.name ?? "")
            } else {
                dailyTargetNameDictionary[date] = []
                dailyTargetNameDictionary[date]!.append(dailyTarget.name ?? "")
            }
        }
    }
    
    
    func calculateRowIndexInTableView(indexPath: IndexPath) -> Int {
        
        var rowNumber = indexPath.row
        
        for index in 0 ..< indexPath.section {
            rowNumber += self.tableView.numberOfRows(inSection: index)
        }
        
        return rowNumber
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
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
        dragItem.localObject = dailyTargets[row].name
        return [ dragItem ]
        
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceRow = calculateRowIndexInTableView(indexPath: sourceIndexPath)
        var destinationRow = calculateRowIndexInTableView(indexPath: destinationIndexPath)
        
        
        if destinationIndexPath.section > sourceIndexPath.section { // 
            destinationRow -= 1
        }
        
        let dateString = Array(dailyTargetNameDictionary.keys.sorted(by: <))[destinationIndexPath.section]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let date = dateFormatter.date(from: dateString) {
            dailyTargets[sourceRow].date = date
        }
        
        // 此處需要先更動資料庫才行
        let mover = dailyTargets.remove(at: sourceRow)
        dailyTargets.insert(mover, at: destinationRow)
        
        
        getTableViewCellInfo()
        
        let sourceRows = tableView.numberOfRows(inSection: sourceIndexPath.section)

        if sourceRows == 1 {
            
            tableView.deleteSections([sourceIndexPath.section], with: .automatic)
            
        }
        
        saveTargets()
        
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
