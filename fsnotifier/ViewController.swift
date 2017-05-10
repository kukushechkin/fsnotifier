//
//  ViewController.swift
//  fsnotifier
//
//  Created by Vladimir Kukushkin on 5/9/17.
//  Copyright © 2017 kukushechkin. All rights reserved.
//

import UIKit
import Foundation

class FSViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView : UITableView!
    var currentFolderItems : [URL] = []
    var currentFolderURL   : URL = URL(fileURLWithPath: "/")
    let theWatcher = TheWatcher()
        
    private func updateContent(folderURL : URL) {
        print("Updating table with contents of \(folderURL)")
        
        let fileManager = FileManager()
        if let newFolderContent = try? fileManager.contentsOfDirectory(at: folderURL,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) {
            currentFolderItems = newFolderContent
            print("Content for \(folderURL) is \(currentFolderItems)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        currentFolderURL = URL(fileURLWithPath: NSHomeDirectory())
        self.updateContent(folderURL: currentFolderURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentFolderItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = ".."
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell
        }
        else {
            let selectedItemURL = self.currentFolderItems[indexPath.row - 1]
            
            let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = selectedItemURL.lastPathComponent
            
            cell.accessoryType = UITableViewCellAccessoryType.none
            if(isDirectory(path: selectedItemURL)) {
                cell.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            currentFolderURL.deleteLastPathComponent()
        }
        else {
            currentFolderURL = self.currentFolderItems[indexPath.row - 1].absoluteURL
        }
        self.updateContent(folderURL: currentFolderURL)
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let selectedItemURL = self.currentFolderItems[indexPath.row - 1]
        
        // Ask if user did not grant notfications permissions
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        
        self.theWatcher.watchDirectory(path: selectedItemURL)
    }    
}

