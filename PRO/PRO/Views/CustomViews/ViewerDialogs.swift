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

struct ImageViewerDialog: View {
    
    var table: String
    var field: String
    var id: Int
    var localId: ObjectId
    
    @State private var image: Image? = Image("ic-gallery")
    
    var body: some View {
        VStack {
            image!
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.cAccent)
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

struct ImageViewerWrapperView: View {
    
    var table: String
    var field: String
    var id: Int
    var localId: ObjectId
    var height: CGFloat = 180
    
    @State private var image: Image? = Image("ic-gallery")
    
    var body: some View {
        VStack {
            if let i = image {
                i
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.cAccent)
                    .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            } else {
                Button(action: {
                    //shouldPresentImageViewer = true
                }) {
                    Text("envPreviewResource")
                }
                .frame(height: 40)
                .buttonStyle(BorderlessButtonStyle())
                /*.popover(isPresented: $shouldPresentImageViewer) {
                    ImageViewerDialog(table: options.table, field: field.key, id: options.item, localId: options.objectId)
                }*/
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
