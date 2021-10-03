//
//  Widgets.swift
//  PRO
//
//  Created by VMO on 30/10/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import UIKit
import SwiftUI

class Widgets {
    
    static func toast(message: String) {
        /*let scene = UIApplication.shared.connectedScenes.first
        if let sceneDelegate : SceneDelegate = scene?.delegate as? SceneDelegate{
            if let view = sceneDelegate.window?.rootViewController?.view{
                view.makeToast(message)
            }
        }*/
    }
    
}

struct SearchBar: View {
    @StateObject var headerRouter: TabRouter
    
    @Binding var text: String

    var placeholder: Text
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .foregroundColor(.cAccent)
            }
            HStack {
                TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                    .foregroundColor(.cPrimary)
                Button(action: {
                    if self.text.isEmpty {
                        headerRouter.current = "TITLE"
                    } else {
                        self.text = ""
                    }
                }) {
                    Image("ic-close")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
                .frame(width: 60, height: 30, alignment: .center)
            }
        }
    }
}

struct CustomTextField: View {
    
    var placeholder: Text
    var bgColor: Color
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack {
            if text.isEmpty {
                placeholder
                    .foregroundColor(.white)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                .frame(height: 40, alignment: .center)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .background(bgColor)
        .clipped()
        .cornerRadius(4)
    }
}

struct CustomSecureField: View {
    
    var placeholder: Text
    var bgColor: Color
    @Binding var text: String
    var commit: ()->() = { }
    
    var body: some View {
        ZStack {
            if text.isEmpty {
                placeholder
                    .foregroundColor(.white)
            }
            SecureField("", text: $text, onCommit: commit)
                .frame(height: 40, alignment: .center)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .background(bgColor)
        .clipped()
        .cornerRadius(4)
    }
}

struct Loader: View {
    @State var animate = false
    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(AngularGradient(gradient: .init(colors: [.cPrimary, .cAccent]), center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 45, height: 45)
                .rotationEffect(.init(degrees: self.animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(10)
        .onAppear{
            self.animate.toggle()
        }
    }
}

struct InlineLoader: View {
    @State var animate = false
    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(AngularGradient(gradient: .init(colors: [.white, .cAccent]), center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 45, height: 45)
                .rotationEffect(.init(degrees: self.animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
        }
        .padding(20)
        .cornerRadius(10)
        .onAppear{
            self.animate.toggle()
        }
    }
}

struct PageViewController: UIViewControllerRepresentable {
    
    var viewControllers: [UIViewController]
    @Binding var currentPageIndex: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers([viewControllers[currentPageIndex]], direction: .forward, animated: true)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.viewControllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return parent.viewControllers.last
            }
            return parent.viewControllers[index - 1]
            
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.viewControllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == parent.viewControllers.count {
                return parent.viewControllers.first
            }
            return parent.viewControllers[index + 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.viewControllers.firstIndex(of: visibleViewController)
            {
                parent.currentPageIndex = index
            }
        }
        
    }
    
}


struct FAB: View {
    
    var image: String
    var foregroundColor: Color
    var iconColor = Color.white
    var action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                self.action()
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(foregroundColor)
                    Image(image)
                        .resizable()
                        .frame(width: Globals.UI_FAB_SIZE - 24, height: Globals.UI_FAB_SIZE - 24)
                        .foregroundColor(iconColor)
                        .shadow(color: .gray, radius: 0.2, x: 1, y: 1)
                }
                .frame(width: Globals.UI_FAB_SIZE, height: Globals.UI_FAB_SIZE)
            }
        }
        .padding(.trailing, Globals.UI_FAB_TRAILING)
        .padding(.bottom, Globals.UI_FAB_BOTTOM)
    }
}
