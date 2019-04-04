//
//  ViewController.swift
//  IZA-2019-cviko-CD
//
//  Created by Martin Hruby on 01/04/2019.
//  Copyright © 2019 Martin Hruby FIT. All rights reserved.
//

import UIKit
import CoreData

//
typealias CellConfig = (NSManagedObject, UITableViewCell) -> ()

//
class BaseFRCViewController<ELEM:NSManagedObject> : NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate
{
    //
    var FRC : NSFetchedResultsController<ELEM>!
    var cconfig: CellConfig?
    
    //
    private weak var TABLE: UITableView!
    
    //
    func setup(forTable: UITableView, fr: NSFetchRequest<ELEM>)
    {
        //
        self.TABLE = forTable
        
        //
        FRC = NSFetchedResultsController(fetchRequest: fr,
                                         managedObjectContext: MOC(),
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        
        //
        FRC.delegate = self
        
        //
        try! FRC.performFetch()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        //
        let _obj = FRC.object(at: indexPath)
        
        //
        cell.textLabel?.text = (_obj.value(forKey: "name") as? String) ?? "no-name"
        
        //
        cconfig?(_obj, cell)
        
        //
        return cell
    }
    
    //
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        //
        TABLE.beginUpdates()
    }
    
    //
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //
        TABLE.endUpdates()
    }
    
    //
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        //
        let _srow = TABLE.indexPathForSelectedRow
        
        //
        switch type {
        case .update:
            //
            TABLE.reloadRows(at: [indexPath!], with: .automatic)
            
            /*
            if let __srow = _srow, __srow == indexPath! {
                //
                TABLE.selectRow(at: __srow, animated: false, scrollPosition: .none)
            }*/
        case .insert:
            //
            TABLE.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            //
            TABLE.deleteRows(at: [indexPath!], with: .automatic)
        default:
            ()
        }
    }
}

//
class MyCDViewController<ELEM:NSManagedObject>: UITableViewController {
    //
    var dsource: BaseFRCViewController<ELEM>!
    
    //
    func selfSetup(entityName: String)  {
        //
        let _fr = NSFetchRequest<ELEM>(entityName: entityName)
        
        
        //
        _fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        
        //
        dsource = BaseFRCViewController()
        dsource.setup(forTable: self.tableView, fr: _fr)
        
        //
        self.tableView.dataSource = dsource
    }
}

//
class CoursesViewController: MyCDViewController<Course> {
    //
    @IBAction func addNewOne() {
        //
        let no = Course(context: MOC())
        
        //
        no.name = "Novy predmet"
    }
    
    //
    override func viewDidLoad() {
        //
        super.viewDidLoad()
        
        //
        selfSetup(entityName: "Course")
    }
}
