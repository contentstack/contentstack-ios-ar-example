//
//  UINavigationController+Additions.swift
//  ContentstackAR
//
//  Created by Uttam Ukkoji on 19/06/18.
//  Copyright © 2018 Contentstack. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        return self.topViewController!.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController!.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.topViewController!.preferredInterfaceOrientationForPresentation
    }
}
