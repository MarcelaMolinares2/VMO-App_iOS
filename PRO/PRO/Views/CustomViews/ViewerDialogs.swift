//
//  ViewerDialogs.swift
//  PRO
//
//  Created by VMO on 16/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import SwiftUI
import RealmSwift
import Amplify

struct ImageViewerDialog: View {
    
    var table: String
    var field: String
    var id: Int
    var localId: ObjectId
    
    @State private var image: Image?
    
    @State private var serverLoading = false
    
    var body: some View {
        VStack {
            if serverLoading {
                Spacer()
                LottieView(name: "gallery_animation", loopMode: .loop, speed: 1)
                    .frame(width: 300, height: 200)
                Spacer()
            } else {
                if let i = image {
                    i
                        .resizable()
                        .scaledToFit()
                } else {
                    Spacer()
                    LottieView(name: "not_found_animation", loopMode: .loop, speed: 1)
                        .frame(width: 300, height: 200)
                    Text("errResourceNF".localized())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.cTextHigh)
                        .padding(.horizontal, 30)
                    Spacer()
                }
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        let media = MediaUtils.item(table: table, field: field, id: id, localId: localId)
        media.ext = "jpg"
        
        if FileUtils.exists(media: media) {
            image = Image(uiImage: UIImage(contentsOfFile: MediaUtils.mediaURL(media: media).path) ?? UIImage())
        } else {
            print(MediaUtils.awsPath(media: media))
            serverLoading = true
            Amplify.Storage.downloadData(
                key: MediaUtils.awsPath(media: media),
                resultListener: { (event) in
                    switch event {
                        case let .success(data):
                            if let uiImage = UIImage(data: data) {
                                image = Image(uiImage: uiImage)
                            }
                            print("Completed: \(data)")
                        case let .failure(storageError):
                            print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    }
                    DispatchQueue.main.async {
                        serverLoading = false
                    }
                })
        }
    }
    
}

struct ImageViewerWrapperView: View {
    @Binding var value: String
    var defaultIcon: String
    var table: String
    var field: String
    var id: Int
    var localId: ObjectId
    var couldOpenPicker = true
    var height: CGFloat = 180
    let onButtonTapped: () -> Void
    
    @State private var modalDialog = false
    
    @State private var image: Image?
    
    var body: some View {
        VStack {
            if value == "Y" {
                if let i = image {
                    i
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cAccent)
                        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
                } else {
                    if couldOpenPicker {
                        Button {
                            onButtonTapped()
                        } label: {
                            Image(defaultIcon)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.cIcon)
                                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                        }
                    }
                    Button(action: {
                        modalDialog = true
                    }) {
                        Text("envPreviewResource")
                    }
                    .frame(height: 40)
                    .buttonStyle(BorderlessButtonStyle())
                    .popover(isPresented: $modalDialog) {
                        ImageViewerDialog(table: table, field: field, id: id, localId: localId)
                    }
                }
            } else {
                if couldOpenPicker {
                    Button {
                        onButtonTapped()
                    } label: {
                        Image(defaultIcon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cIcon)
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                    }
                }
            }
        }
        .onChange(of: value, perform: { newValue in
            load()
        })
    }
    
    func load() {
        let media = MediaUtils.item(table: table, field: field, id: id, localId: localId)
        media.ext = "jpg"
        image = nil
        if FileUtils.exists(media: media) {
            image = Image(uiImage: UIImage(contentsOfFile: MediaUtils.mediaURL(media: media).path) ?? UIImage())
        }
    }
    
}
