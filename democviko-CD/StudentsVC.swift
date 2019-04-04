//
//  StudentsVC.swift
//  democviko-CD
//
//  Created by Martin Hruby on 04/04/2019.
//  Copyright © 2019 Martin Hruby FIT. All rights reserved.
//

import Foundation
import CoreData
import UIKit


//
class StudentsVC: UITableViewController {
    //
    //
    var dsource: MyDS<Student>!
    
    
    @IBAction func tlacitkoNew() {
        //
        let ns = Student(context: MOC())
        
        //
        ns.name = "Franta"
    }
    
    //
    override func viewDidLoad() {
        //
        super.viewDidLoad()
        
        //
        let fr = NSFetchRequest<Student>(entityName: "Student")
        
        //
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        //
        dsource = MyDS(tableView: tableView, cellReuse: "cell") {
            obj, cell in
            //
            guard let _student = obj as? Student else { return }
            
            //
            cell.textLabel?.text = _student.name
        }
        
        //
        dsource.startup(fr: fr)
        
        //
        tableView.dataSource = dsource
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //
        if segue.identifier == "kurzyStudenta",
            let _dest = segue.destination as? CousesStudentsVC,
            let _select = tableView.indexPathForSelectedRow
        {
                //
            let _selStudent = dsource.FRC.object(at: _select)
            
            //
            _dest.student = _selStudent
        }
    }
}

