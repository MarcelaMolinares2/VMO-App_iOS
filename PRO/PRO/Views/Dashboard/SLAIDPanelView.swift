//
//  SLAIDPanelView.swift
//  PRO
//
//  Created by VMO on 16/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct SLAIDPanelView: View {
    
    let modSLAID = Config.get(key: "SLAID").value
    
    var body: some View {
        ZStack {
            if modSLAID == 1 {
            } else {
                VStack {
                    Spacer()
                    VStack(alignment: .center, spacing: 20) {
                        Text("envVisualAids")
                            .font(.system(size: 30))
                            .foregroundColor(.cTextHigh)
                        Image("ic-lock")
                            .resizable()
                            .frame(height: 60)
                            .scaledToFit()
                        Text("envVANotAvailable")
                            .font(.system(size: 16))
                            .foregroundColor(.cTextHigh)
                            .multilineTextAlignment(.center)
                        Text("envVANotAvailableRequest")
                            .font(.system(size: 15))
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
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
