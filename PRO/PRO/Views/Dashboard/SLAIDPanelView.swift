//
//  SLAIDPanelView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct SLAIDPanelView: View {
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    
                }) {
                    Image("logo-header")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 44)
                }
                Spacer()
                Text("envSLAID")
                    .foregroundColor(.cPrimaryDark)
                    .multilineTextAlignment(.center)
                Spacer()
                Button(action: {
                    
                }) {
                    Image("ic-right-arrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 44, alignment: .center)
                        .padding(2)
                }
            }
            .background(
                Color.white
                    .shadow(color: .cAccent, radius: 2, y: 2)
            )
            ScrollView {
                VStack {
                    ForEach(0..<10) {_ in
                        Text("AA")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                    }
                }
            }
        }
    }
}

struct SLAIDPanelView_Previews: PreviewProvider {
    static var previews: some View {
        SLAIDPanelView()
    }
}
