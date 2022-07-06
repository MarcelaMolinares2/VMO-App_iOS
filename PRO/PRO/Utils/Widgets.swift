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
    
}

struct SearchBar: View {
    @Binding var text: String

    var placeholder: Text
    let onSearchClose: () -> Void
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
                    .foregroundColor(.cTextHigh)
                Button(action: {
                    if self.text.isEmpty {
                        onSearchClose()
                    } else {
                        self.text = ""
                    }
                }) {
                    Image("ic-close")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(.cIcon)
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

struct FAB: View {
    
    var image: String
    var size: CGFloat = Globals.UI_FAB_SIZE
    var margin: CGFloat = 24
    var action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                self.action()
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(.cFABBackground)
                    Image(image)
                        .resizable()
                        .frame(width: size - margin, height: size - margin)
                        .foregroundColor(.cFABForeground)
                }
                .frame(width: size, height: size)
            }
        }
    }
}

struct CustomImagePickerView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var uiImage: UIImage?
    let onSelectionDone: (_ done: Bool) -> Void
    
    func makeCoordinator() -> ImagePickerViewCoordinator {
        return ImagePickerViewCoordinator(uiImage: $uiImage) { done in
            onSelectionDone(done)
        }
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = context.coordinator
        return pickerController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var uiImage: UIImage?
    let onSelectionDone: (_ done: Bool) -> Void

    init(uiImage: Binding<UIImage?>, onSelectionDone: @escaping (_ done: Bool) -> Void) {
        self._uiImage = uiImage
        self.onSelectionDone = onSelectionDone
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.uiImage = image
            self.onSelectionDone(true)
        } else {
            self.onSelectionDone(false)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.onSelectionDone(false)
    }
}
