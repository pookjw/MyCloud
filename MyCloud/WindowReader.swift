//
//  WindowReader.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

#if os(macOS)

import SwiftUI

struct WindowReader: NSViewRepresentable {
    let windowHandler: @MainActor (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> ContentView {
        ContentView(windowHandler: windowHandler)
    }
    
    func updateNSView(_ nsView: ContentView, context: Context) {
        nsView.windowHandler = windowHandler
    }
    
    final class ContentView: NSView {
        var windowHandler: @MainActor (NSWindow?) -> Void
        
        init(windowHandler: @escaping (NSWindow?) -> Void) {
            self.windowHandler = windowHandler
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            windowHandler(window)
        }
    }
}

extension View {
    func onWindowChange(_ windowHandler: @escaping (NSWindow?) -> Void) -> some View {
        self
            .overlay { 
                WindowReader(windowHandler: windowHandler)
            }
    }
}

#endif
