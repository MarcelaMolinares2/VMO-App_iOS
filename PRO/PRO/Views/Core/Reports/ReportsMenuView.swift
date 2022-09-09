//
//  ReportsMenuView.swift
//  PRO
//
//  Created by VMO on 8/09/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ReportsMenuView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var userSettings: UserSettings
    
    @State var nestedMenus: [Menu] = []
    
    @State var iconSize = CGFloat(45)
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modReports") {
                viewRouter.currentPage = "MASTER"
            }
            ScrollView {
                VStack {
                    ForEach(nestedMenus, id: \.objectId) { menu in
                        Button(action: {
                            print(menu)
                        }) {
                            CustomSection {
                                HStack {
                                    Image(menu.icon.replacingOccurrences(of: "_", with: "-"))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: iconSize, minHeight: iconSize, maxHeight: iconSize, alignment: .center)
                                        .foregroundColor(.cIcon)
                                        .padding(6)
                                    VStack {
                                        Text(NSLocalizedString("env\(menu.languageTag.capitalized.replacingOccurrences(of: "-", with: ""))", comment: ""))
                                            .foregroundColor(.cTextHigh)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.system(size: 18))
                                            .lineLimit(1)
                                        Text(NSLocalizedString("env\(menu.languageTag.capitalized.replacingOccurrences(of: "-", with: ""))MenuDesc", comment: ""))
                                            .foregroundColor(.cTextMedium)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        print(viewRouter.parentMenuId)
        if let user = userSettings.userData() {
            nestedMenus = MenuDao(realm: realm).by(userType: user.type, parent: viewRouter.parentMenuId)
        }
    }
    
}
