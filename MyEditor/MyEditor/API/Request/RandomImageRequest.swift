//
//  RandomImageRequest.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/10/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation

class RandomImageRequest: BaseRequest {
    required init() {
        let body: [String: Any]  = [
            "client_id": APIKey.key
        ]
        super.init(url: URLs.randomUrl, requestType: .get, body: body)
    }
}
