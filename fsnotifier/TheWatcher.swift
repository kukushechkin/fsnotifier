//
//  TheWatcher.swift
//  fsnotifier
//
//  Created by Vladimir Kukushkin on 5/9/17.
//  Copyright © 2017 kukushechkin. All rights reserved.
//

import Foundation
import UserNotificationsUI

class TheWatcher : NSObject, DirectoryWatcherDelegate {
    var directoryWatchers  = [URL: DirectoryWatcher]();
    var fileWatchers       = [URL: [DirectoryWatcher]]();
    let lockQueue          = DispatchQueue(label: "TheWatcher.LockQueue")

    private func watchFilesInFolder(folder : URL) {
        let fileManager = FileManager()
        if let filesInFolder = try? fileManager.contentsOfDirectory(at: folder,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) {
            // Drop all old watchers
            // FIXME: not-yet-handled events will be lost
            self.fileWatchers[folder] = [];
            for file in filesInFolder {
                print("Add watcher for file \(file)")
                if let dw = DirectoryWatcher.watchFolder(withPath: file.path, delegate:self),
                   var fw = self.fileWatchers[folder] {
                    fw.append(dw)
                }
                else {
                    print("Failed to add watcher")
                }
            }
        }
    }
    
    func watchDirectory(path: URL) { 
        lockQueue.sync() {
            if(self.directoryWatchers[path] == nil) {
                print("Setup listening for changes in \(path)")
                self.directoryWatchers[path] = DirectoryWatcher.watchFolder(withPath: path.path, delegate:self)
            }
            if(isDirectory(path: path)) {
                self.watchFilesInFolder(folder: path)
            }
        }
    }
    
    func directoryDidChange(_ folderWatcher: DirectoryWatcher) {
        print("Path changed: \(folderWatcher.dir)");
        let changedURL = URL(fileURLWithPath: folderWatcher.dir)
        
        DispatchQueue.main.async {
            // TODO: handle gracefully multiple notifications in short period
            let notification : UILocalNotification = UILocalNotification()
            notification.alertBody = "\(changedURL.lastPathComponent) contents changed"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
        
        watchDirectory(path: changedURL)
    }
}
