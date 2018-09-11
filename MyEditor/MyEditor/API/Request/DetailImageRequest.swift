//
//  DetailImageRequest.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation

class DetailImageRequest: BaseRequest {
    required init(photo: Photo) {
        let body: [String: Any]  = [
            "client_id": APIKey.key
        ]
        super.init(url: URLs.detailUrl + photo.id, requestType: .get, body: body)
    }
}
