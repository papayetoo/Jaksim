//
//  CalendarViewController.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/15.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: CalendarView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CalendarViewController begin")
        self.calendarView.currentDate = Date()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
