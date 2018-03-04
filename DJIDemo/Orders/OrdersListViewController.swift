//
//  OrdersListViewController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 3/3/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit

class OrdersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var dataSource:[Order]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.title = "List of Orders"
        FBManager.sharedInstance.getOrders { (orders) in
            self.dataSource = orders
            self.tableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kOrderCellIdentifier, for: indexPath) as! OrderCellTableViewCell
        
        let order:Order = (dataSource?[indexPath.row])!
        cell.nameLbl.text = order.name
        cell.statusLbl.text = order.status
        
        return cell
    }

    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == ksegueIdOrderListToDetail {
            let orderDetailVC = segue.destination as! OrderDetailViewController
            orderDetailVC.order = dataSource?[(self.tableView.indexPathForSelectedRow?.row)!]
        }
        
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
    }
 

}
