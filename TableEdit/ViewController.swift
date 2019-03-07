//
//  ViewController.swift
//  TableEdit
//
//  Created by yaojinhai on 2019/3/7.
//  Copyright © 2019年 yaojinhai. All rights reserved.
//

import UIKit

class ViewController: JHSBaseViewController {

    var sectionList = [String:[PersonModel]]();
    var sectionKeys = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "列表操作";
        
        createTable(delegate: self);
        baseTable.allowsSelectionDuringEditing = true;
        baseTable.allowsMultipleSelectionDuringEditing = true;
        baseTable.allowsMultipleSelection = true;
        baseTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        baseTable.separatorStyle = .singleLine;
        
        
        let selectedAll = UIBarButtonItem(title: "全选", style: .done, target: self, action: #selector(buttonItemAction(_:)));
        selectedAll.tag = ViewTagSense.selectedAllTag.rawValue;
        
        let edit = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(buttonItemAction(_:)));
        edit.tag = ViewTagSense.editTag.rawValue;
        self.navigationItem.rightBarButtonItems = [edit,selectedAll];
        
        resetPersonModel();
        
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonItemAction(_:)));
        addItem.tag = ViewTagSense.addTag.rawValue;
        navigationItem.leftBarButtonItem = addItem;
        
    }
    
    // 给数据按照字母分组，并排序
    func resetPersonModel() -> Void {
        let modelList = PersonModel.createPersons();

        for item in modelList {
            
            var pList = sectionList[item.firstPY] ?? [PersonModel]();
            pList.append(item);
            sectionList[item.firstPY] = pList;
            if !sectionKeys.contains(item.firstPY) {
                sectionKeys.append(item.firstPY);
            }
        }
        sectionKeys.sort { (first, second) -> Bool in
            return first.compare(second) == ComparisonResult.orderedAscending;
        }
    }
    
    @objc override func buttonItemAction(_ item: UIBarButtonItem) {
       
        if item.tag == ViewTagSense.editTag.rawValue {
            item.title = !baseTable.isEditing ? "完成" : "编辑";
            baseTable.setEditing(!baseTable.isEditing, animated: true);
            baseTable.reloadData();
            
        }else if item.tag == ViewTagSense.selectedAllTag.rawValue {
            if !baseTable.isEditing {
                return;
            }
            for key in sectionKeys.enumerated() {
                guard let list = sectionList[key.element] else{
                    continue;
                }
                for item in list.enumerated() {
                    baseTable.selectRow(at: IndexPath.init(item: item.offset, section: key.offset), animated: true, scrollPosition: .none);
                }
            }
        }else if item.tag == ViewTagSense.addTag.rawValue {
            let ctrl = AddPersonViewController();
            ctrl.finishedDone = {
                (model: PersonModel) -> Void in
                self.addModelTo(model: model);
            }
            present(ctrl, animated: true) {
                
            };
        }
        
    }
    
    func deleteModelBy(indexPath: IndexPath) -> Void {
        let key = sectionKeys[indexPath.section];
        guard var list = sectionList[key] else {
            return;
        }
        list.remove(at: indexPath.row);
        if list.count == 0 {
            sectionList.removeValue(forKey: key);
            sectionKeys.remove(at: indexPath.section);
            baseTable.deleteSection(section: indexPath.section);
        }else {
            sectionList[key] = list;
            baseTable.deleteRows(indexPaths: [indexPath]);
        }
        
    }
    
    func addModelTo(model: PersonModel) -> Void {
        let key = model.firstPY;
        if let idx = sectionKeys.firstIndex(of: key) {
            var list = sectionList[key] ?? [PersonModel]();
            list.insert(model, at: 0);
            sectionList[key] = list;
            if list.count == 1 {
                baseTable.insertSection(section: idx);
            }else {
                baseTable.insertRows(indexPaths: [IndexPath.init(row: 0, section: idx)]);
            }
            
        }else {
            sectionKeys.append(key);
            sectionKeys.sort { (first, second) -> Bool in
                return first.compare(second) == ComparisonResult.orderedAscending;
            }
            addModelTo(model: model);
        }
    }
    
    //
    


}
// MARK: - Table View operation
extension ViewController {
    // MAEK: - table view delegate implement
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count;
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = sectionList[sectionKeys[section]]?.count ?? 0;
        return count;
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionKeys[section];
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delAction = UITableViewRowAction(style: .default, title: "删除") { (action, deleIndex) in
            self.deleteModelBy(indexPath: indexPath);
        };
        return [delAction];
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        let list = sectionList[sectionKeys[indexPath.section]];
        let model = list![indexPath.row];
        cell.textLabel?.text = model.name;
        cell.selectionStyle = tableView.isEditing ? .blue : .none;
        cell.selectionStyle = .none;
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index;
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionKeys;
    }
}


class PersonModel: BaseModel {
    var name = "";
    var isSelected = false;
    private var namePY: String!
    var firstPY: String {
        if namePY == nil {
            namePY = name.firstPinYin;
        }
        return namePY;
    }
    class func createPersons() -> [PersonModel] {
        let path = Bundle.main.path(forResource: "PersonList", ofType: "plist");
        let dict = NSDictionary(contentsOfFile: path!)!;
        var list = [PersonModel]();
        for idx in dict {
            let p = PersonModel();
            p.name = idx.key as? String ?? "未命名";
            list.append(p);
        }
        return list;
    }
}


