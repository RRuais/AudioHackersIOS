//
//  internetConnection.swift
//  AudioHackers
//
//  Created by Rich Ruais on 6/12/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
