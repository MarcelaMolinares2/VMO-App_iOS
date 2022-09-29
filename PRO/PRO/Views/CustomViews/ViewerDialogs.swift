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
    
    var body: some View {
        VStack {
            if let i = image {
                i
                    .resizable()
                    .scaledToFit()
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
                    Button {
                        onButtonTapped()
                    } label: {
                        Image(defaultIcon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cIcon)
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                    }
                    Button(action: {
                        print("id", id)
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
        .onAppear {
            load()
        }
    }
    
    func load() {
        let media = MediaUtils.item(table: table, field: field, id: id, localId: localId)
        media.ext = "jpg"
        if FileUtils.exists(media: media) {
            image = Image(uiImage: UIImage(contentsOfFile: MediaUtils.mediaURL(media: media).path) ?? UIImage())
        }
    }
    
}
