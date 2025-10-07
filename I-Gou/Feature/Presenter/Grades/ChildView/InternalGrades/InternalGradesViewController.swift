//
//  InternalGradesViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class InternalGradesViewController: UIViewController {
    
    private var internalGradesView: InternalGradesView?
    private let chartDataStore = ChartDataStore()
    
    override func loadView() {
        let view = InternalGradesView(chartDataStore: chartDataStore)
        self.internalGradesView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addNewGrade(record: InternalGradeRecord) {
        chartDataStore.addGradeRecord(record)
    }
    
}
