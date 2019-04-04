//
//  ViewController.swift
//  democviko-CD
//
//  Created by Martin Hruby on 04/04/2019.
//  Copyright © 2019 Martin Hruby FIT. All rights reserved.
//

import UIKit
import CoreData

//
typealias MyDSConfig = (NSManagedObject, UITableViewCell) -> ()

//
class MyDS<ELEMENT:NSManagedObject> : NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    //
    var FRC: NSFetchedResultsController<ELEMENT>!
    
    //
    weak var TABLE: UITableView!
    var cellReuse: String
    
    //
    var cellDelegate: MyDSConfig
    
    //
    init(tableView: UITableView, cellReuse:String, cellDel: @escaping MyDSConfig) {
        //
        self.TABLE = tableView
        self.cellReuse = cellReuse
        self.cellDelegate = cellDel
    }
    
    //
    func startup(fr:NSFetchRequest<ELEMENT>) {
        //
        FRC = NSFetchedResultsController(fetchRequest: fr,
                                         managedObjectContext: MOC(),
                                         sectionNameKeyPath: nil, cacheName: nil)
        
        //
        FRC.delegate = self
        
        //
        do { try FRC.performFetch() }
        catch { fatalError() }
        
        //
        TABLE.reloadData()
    }
    
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        //
        return 1
    }
    
    //
    func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int
    {
        //
        return FRC.fetchedObjects!.count
    }
    
    //
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //
        let _cell = tableView.dequeueReusableCell(withIdentifier: cellReuse)!
        let _obj = FRC.object(at: indexPath)
        
        //
        cellDelegate(_obj, _cell)
        
        //
        return _cell
    }
    
    //
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //
        TABLE.beginUpdates()
    }
    
    //
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?)
    {
        //
        switch type {
        case .insert:
            //
            TABLE.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            //
            TABLE.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            TABLE.reloadRows(at: [indexPath!], with: .automatic)
        default:
            ()
        }
    }
    
    //
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //
        TABLE.endUpdates()
    }
}

//
class CousesVC: UITableViewController {
    //
    //
    var dsource: MyDS<Course>!
    
    
    @IBAction func tlacitkoNew() {
        //
        let nc = Course(context: MOC())
        
        //
        nc.name = "Novy kurz"
    }
    
    //
    func fetchRequest() -> NSFetchRequest<Course> {
        //
        //
        let fr = NSFetchRequest<Course>(entityName: "Course")
        
        //
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        //
        return fr
    }
    
    //
    override func viewDidLoad() {
        //
        super.viewDidLoad()
        
        /*
        let c1 = Course(context: MOC())
        
        //
        c1.name = "IZA"
        
        //
        let c2 = NSEntityDescription.insertNewObject(forEntityName: "Course",
                                                     into: MOC()) as! Course
        
        //
        c2.name = "IMS"
    
        //
        try! MOC().save()*/
        
        //
        dsource = MyDS(tableView: tableView, cellReuse: "cell") {
            obj, cell in
            //
            guard let _course = obj as? Course else { return }
            
            //
            cell.textLabel?.text = _course.name
        }
        
        //
        dsource.startup(fr: fetchRequest())
        
        //
        tableView.dataSource = dsource
    }
}


//
class CousesStudentsVC: UITableViewController {
    //
    var student: Student!
    
    //
    var dsource: MyDS<Course>!
    
    
    //
    func fetchRequest() -> NSFetchRequest<Course> {
        //
        //
        let fr = NSFetchRequest<Course>(entityName: "Course")
        
        //
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        //fr.predicate = NSPredicate(format: "students contains %@", student)
        
        //
        return fr
    }
    
    //
    override func viewDidLoad() {
        //
        super.viewDidLoad()
        
        //
        dsource = MyDS(tableView: tableView, cellReuse: "cell") {
            [weak self]
            obj, cell in
            //
            guard let _self = self else { return }
            guard let _course = obj as? Course else { return }
            guard let _scourse = _self.student.courses else { return }
            
            //
            cell.textLabel?.text = _course.name
            
            //
            if _scourse.contains(_self.student) {
                //
                cell.detailTextLabel?.text = "zapsano"
            } else {
                //
                cell.detailTextLabel?.text = ""
            }
        }
        
        //
        dsource.startup(fr: fetchRequest())
        
        //
        tableView.dataSource = dsource
    }
    
    //
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        //
        guard
            let _selrow = tableView.indexPathForSelectedRow
        else { return }
        
        //
        let _course = dsource.FRC.object(at: _selrow)
        
        //
        _course.addToStudents(student)
    }
}
