//
//  SupportView.swift
//  PRO
//
//  Created by VMO on 30/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        VStack {
            HeaderToggleView(couldSearch: false, title: "modSupport", icon: Image("ic-support"), color: Color.cPrimary)
            ScrollView {
                VStack {
                    Button(action: {
                        
                    }) {
                        ZStack(alignment: .leading) {
                            Image("ic-help")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 60, minHeight: 30, maxHeight: 30, alignment: .center)
                                .foregroundColor(.cPrimary)
                            Text("modSupport")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.cPrimary)
                                .frame(minHeight: 40, maxHeight: 40)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.cCard)
                                .shadow(color: .cAccent, radius: 2, x: 0, y: 2)
                        )
                    }
                    .padding(.vertical, 30)
                    VStack {
                        Text("modShare")
                            .padding(.top, 10)
                            .foregroundColor(.cPrimary)
                        HStack {
                            VStack {
                                Image("ic-log")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cPrimary)
                                Text("envData")
                                    .foregroundColor(.cPrimary)
                                    .lineLimit(1)
                            }
                            VStack {
                                Image("ic-gallery")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
                                    .foregroundColor(.cPrimary)
                                Text("envImages")
                                    .foregroundColor(.cPrimary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.cCard)
                            .shadow(color: .cAccent, radius: 2, x: 0, y: 2)
                    )
                    Button(action: {
                        
                    }) {
                        ZStack(alignment: .leading) {
                            Image("ic-delete")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 60, minHeight: 26, maxHeight: 26, alignment: .center)
                                .foregroundColor(.white)
                            Text("envDelete")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .frame(minHeight: 40, maxHeight: 40)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.cDanger)
                                .shadow(color: .cAccent, radius: 2, x: 0, y: 2)
                        )
                    }
                    .padding(.vertical, 30)
                }
                .padding(.horizontal, 30)
            }
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
