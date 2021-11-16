//
//  ViewerDialogs.swift
//  PRO
//
//  Created by VMO on 16/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageViewerDialog: View {
    
    var table: String
    var field: String
    var id: Int
    
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
        let media = MediaUtils.item(table: table, field: field, id: id)
        media.ext = "jpg"
        if FileUtils.exists(media: media) {
            image = Image(uiImage: UIImage(contentsOfFile: MediaUtils.mediaURL(media: media).path) ?? UIImage())
        }
    }
    
}
