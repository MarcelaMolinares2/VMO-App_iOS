//
//  PanelGenericViews.swift
//  PRO
//
//  Created by VMO on 18/11/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI

struct PanelListHeader: View {
    
    @State var total: Int
    let onFiltersTapped: () -> Void
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Text(String(format: NSLocalizedString("envTotalPanel", comment: ""), String(total)))
                .foregroundColor(.cTextMedium)
                .font(.system(size: 12))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            Button(action: {
                onFiltersTapped()
            }) {
                Text("envFilters")
                    .font(.system(size: 13))
                    .foregroundColor(.cTextLink)
                    .padding(.horizontal, 10)
            }
        }
    }
    
}

struct BottomNavigationBarDynamic: View {
    let onTabSelected: (_ tab: String) -> Void
    
    @Binding var currentTab: String
    @Binding var tabs: [DynamicFormTab]
    var staticTabs: [String] = []
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { i in
                    Image("ic-dynamic-tab-\(i)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(tabs.count + 1), alignment: .center)
                        .foregroundColor(currentTab == tabs[i].key ? .cPrimary : .cAccent)
                        .onTapGesture {
                            onTabSelected(tabs[i].key)
                        }
                }
                if staticTabs.contains("LOCATIONS") {
                    Image("ic-map")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: geometry.size.width / CGFloat(tabs.count + 1), alignment: .center)
                        .foregroundColor(currentTab == "LOCATIONS" ? .cPrimary : .cAccent)
                        .onTapGesture {
                            onTabSelected("LOCATIONS")
                        }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
    }
    
}

struct PanelInfoDialog: View {
    
    @State var panel: Panel
    
    @State var headerColor = Color.cPrimary
    @State var headerIcon = "ic-home"
    
    var body: some View {
        VStack {
            HStack {
                Text(panel.name ?? "")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .foregroundColor(.white)
                Image(headerIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34, alignment: .center)
                    .padding(4)
            }
            .background(headerColor)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            initUI()
        }
    }
    
    func initUI() {
        self.headerColor = PanelUtils.colorByPanelType(panel: panel)
        self.headerIcon = PanelUtils.imageByPanelType(panel: panel)
    }
    
}
