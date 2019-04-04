//
//  StudentsViewController.swift
//  IZA-2019-cviko-CD
//
//  Created by Martin Hruby on 01/04/2019.
//  Copyright © 2019 Martin Hruby FIT. All rights reserved.
//

import Foundation
import CoreData
import UIKit

//
class StudentZapsaneCoursesVC: CoursesViewController {
    //
    var student: Student!
    
    //
    override func selfSetup(entityName: String)  {
        //
        let _fr = NSFetchRequest<Course>(entityName: entityName)
        let _pred = NSPredicate(format: "students contains %@", student)
        
        //
        _fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        //_fr.predicate = _pred
        
        
        //
        dsource = BaseFRCViewController()
        dsource.setup(forTable: self.tableView, fr: _fr)
        dsource.cconfig = { [weak self] obj, cell in
            //
            guard
                let _obj = obj as? Course,
                let _scourses = self?.student.courses else { return  }
            
            //
            if _scourses.contains(_obj) {
                //
                cell.detailTextLabel?.text = "jo"
            } else {
                //
                cell.detailTextLabel?.text = "ne"
            }
        }
        
        //
        self.tableView.dataSource = dsource
    }
    
    //
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        //
        guard
            let _obj = dsource.FRC.object(at: indexPath) as? Course else { return  }
        
        //
        guard let _stc = student.courses else { return }
        
        //
        if _stc.contains(_obj) {
            //
            student.removeFromCourses(_obj)
        } else {
            //
            student.addToCourses(_obj)
        }
    }
}

//
class StudentsViewController: MyCDViewController<Student> {
    //
    @IBAction func addNewOne() {
        //
        let avc = UIAlertController(title: "Novy student", message: "Zadejte jmeno", preferredStyle: .alert)
        
        //
        avc.addTextField { (txtf: UITextField) in
            //
            txtf.placeholder = "nejake jmeno"
        }
        
        //
        let ava = UIAlertAction(title: "Vytvor", style: .default) { (UIAlertAction) in
            //
            if let _tf = avc.textFields?.first,
                let _cont = _tf.text, _cont.isEmpty == false {
                //
                let _ns = Student(context: MOC())
                
                //
                _ns.name = _cont
            }
        }
        
        //
        avc.addAction(ava)
        
        //
        self.present(avc, animated: false)
    }
    
    //
    override func viewDidLoad() {
        //
        super.viewDidLoad()
        
        //
        selfSetup(entityName: "Student")
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?)
    {
        //
        if
            segue.identifier == "zapsane",
            let _idx = tableView.indexPathForSelectedRow,
            let _dest = segue.destination as? StudentZapsaneCoursesVC
        {
            //
            _dest.student = dsource.FRC.object(at: _idx)
        }
    }
}
