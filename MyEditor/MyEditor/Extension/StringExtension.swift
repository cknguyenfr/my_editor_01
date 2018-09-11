//
//  StringExtension.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/12/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
