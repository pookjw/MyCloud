//
//  MyCloudApp.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import SwiftUI
import ObjectiveC

#if os(macOS)
fileprivate var oldIMP: IMP!
fileprivate func swizzle() {
    let ToolbarPlatformDelegate: AnyClass = objc_lookUpClass("_TtC7SwiftUI23ToolbarPlatformDelegate")!
    let method = class_getInstanceMethod(ToolbarPlatformDelegate, #selector(NSToolbarDelegate.toolbar(_:itemForItemIdentifier:willBeInsertedIntoToolbar:)))!
    oldIMP = method_getImplementation(method)
    
    let newIMPFunc: @convention(c) (AnyObject, Selector, NSToolbar, NSToolbarItem.Identifier, ObjCBool) -> NSToolbarItem? = { `self`, _cmd, toolbar, itemIdentifier, flag in
        let oldIMPFunc = unsafeBitCast(oldIMP, to: (@convention(c) (AnyObject, Selector, NSToolbar, NSToolbarItem.Identifier, ObjCBool) -> NSToolbarItem?).self)
        let item = oldIMPFunc(self, _cmd, toolbar, itemIdentifier, flag)
        
        if let item, itemIdentifier.rawValue == "com.apple.SwiftUI.navigationStack.back" {
            // SwiftUI.SwiftUISegmentedControl
            let control = item.view!.subviews.first!.subviews.first! as! NSSegmentedControl
            control.sizeToFit()
            item.view!.setFrameSize(control.bounds.size)
        }
        
        return item
    }
    
    method_setImplementation(method, unsafeBitCast(newIMPFunc, to: IMP.self))
}
#endif

@main
struct MyCloudApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var cloudService = CloudService()
    
    init() {
#if os(macOS)
        swizzle()
#endif
        appDelegate.cloudService = cloudService
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(cloudService)
        }
    }
}
