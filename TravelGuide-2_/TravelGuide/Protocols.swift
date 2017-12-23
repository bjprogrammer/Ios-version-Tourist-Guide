//
//  Protocols.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 4/12/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import Foundation
@objc protocol AppManagerDelegate:NSObjectProtocol {
    
    func reachabilityStatusChangeHandler(reachability:Reachability)
}