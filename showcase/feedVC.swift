//
//  feedVC.swift
//  showcase
//
//  Created by shengxiang guo on 1/26/16.
//  Copyright © 2016 shengxiang guo. All rights reserved.
//

import UIKit

class feedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var  tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("postCell") as! postCell
    }
}
