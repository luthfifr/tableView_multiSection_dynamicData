//
//  ViewController.swift
//  tableView_multiSection_dinamis
//
//  Created by Luthfi Fathur Rahman on 5/21/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sections:Array<String> = Array <String>()
    var items = [[String]]()
    
    struct daftarProduk: Decodable{
        let prodID: Int?
        let prodName: String?
        let prodCat: String?
        
        init?(json: JSON){
            self.prodID = "id" <~~ json
            self.prodName = "name" <~~ json
            self.prodCat = "category" <~~ json
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        get_data_from_url(url: "https://imperio.co.id/project/ecommerceApp/allproducts.php")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 127.0/255.0, alpha: 1.0)
        }
        else {
            cell.backgroundColor = UIColor(red: 244.0/255.0, green: 242.0/255.0, blue: 3.0/255.0, alpha: 1.0)
        }
        
        cell.textLabel?.text = self.items[indexPath.section][indexPath.row]
        cell.textLabel?.sizeToFit()
        
        return cell
    }
    
    func get_data_from_url(url:String){
        sections.removeAll(keepingCapacity: false)
        items.removeAll(keepingCapacity: false)
        self.sections.append("")
        self.items.append([""])
        Alamofire.request(url, method:.get).validate(contentType: ["application/json"]).responseJSON{ response in
            switch response.result{
            case .success(let data):
                guard let value = data as? JSON,
                    let eventsArrayJSON = value["prodlist"] as? [JSON]
                    else { fatalError() }
                let DaftarProduk = [daftarProduk].from(jsonArray: eventsArrayJSON)
                for j in 0 ..< Int((DaftarProduk?.count)!){
                    self.sections.append((DaftarProduk?[j].prodCat!)!)
                }
                self.sections = self.removeDuplicates(array: self.sections)
                print("sections = \(self.sections.count)")
                
                //lakukan pengulangan sebanyak jumlah isi array sections.
                for k in 0 ..< self.sections.count{
                    if self.sections[k] != "" {
                        //lakukan pengulangan sebanyak isi array DaftarProduk
                        for l in 0 ..< Int((DaftarProduk?.count)!){
                            while (DaftarProduk?[l].prodCat!)! == self.sections[k] {
                                if self.items.indices.contains(k) {
                                    self.items[k].append((DaftarProduk?[l].prodName!)!)
                                } else {
                                    self.items.append([(DaftarProduk?[l].prodName!)!])
                                }
                                break
                            }
                        }
                    }
                }
                
                print("jumlah items: \((DaftarProduk?.endIndex)!)")
                //print("isi items: \(self.items)")
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                break
            case .failure(let error):
                print("Error: \(error)")
                let alert2 = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert2.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert2, animated: true, completion: nil)
                break
            }
        }
    }
    
    func removeDuplicates(array: [String])->[String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                encountered.insert(value)
                result.append(value)
            }
        }
        return result
    }


}

