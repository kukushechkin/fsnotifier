//
//  Helpers.swift
//  fsnotifier
//
//  Created by Vladimir Kukushkin on 5/9/17.
//  Copyright © 2017 kukushechkin. All rights reserved.
//

import Foundation

func isDirectory(path: URL) -> Bool {
    if let v = try? path.resourceValues(forKeys: [.isDirectoryKey]) {
        if v.isDirectory! {
            return true;
        }
    }
    return false;
}
