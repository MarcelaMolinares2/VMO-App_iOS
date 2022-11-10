//
//  ActivitySummaryView.swift
//  PRO
//
//  Created by Fernando Garcia on 12/01/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import BottomSheetSwiftUI
import GoogleMaps

struct ActivitySummaryView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Binding var activity: DifferentToVisit
    @Binding var modalSummary: Bool
    
    @State private var route = 0
    @State private var modalPanelType = false
    @State private var assistants = [PanelItemModel]()
    
    let realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $route) {
                ActivitySummaryBasicView(activity: $activity)
                    .tag(0)
                    .tabItem {
                        Text("envBasic")
                        Image("ic-basic")
                    }
                PanelSelectWrapperView(realm: realm, types: [], members: $assistants, modalPanelType: $modalPanelType)
                .tag(1)
                .tabItem {
                    Text("envAssistants")
                    Image("ic-client")
                }
            }
            .tabViewStyle(DefaultTabViewStyle())
            HStack(alignment: .bottom) {
                Spacer()
                if activity.userId == JWTUtils.sub() {
                    FAB(image: "ic-edit") {
                        FormEntity(objectId: activity.objectId).go(path: "DTV-FORM", router: viewRouter)
                    }
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        assistants.removeAll()
        activity.assistants.forEach{ assistant in
            if let panel = PanelUtils.panel(type: assistant.panelType, objectId: assistant.panelObjectId, id: assistant.panelId) {
                assistants.append(PanelItemModel(objectId: panel.objectId, type: assistant.panelType))
            }
        }
    }
    
}

struct ActivitySummaryBasicView: View {
    
    @Binding var activity: DifferentToVisit
    
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_OTHER_FORM_ADDITIONAL").complement ?? "")
    @State private var dynamicForm = DynamicForm(tabs: [DynamicFormTab]())
    @State private var dynamicOptions = DynamicFormFieldOptions(table: "activity", op: .view)
    
    var body: some View {
        VStack {
            ActivitySummaryMapView(item: activity)
                .frame(maxHeight: 200)
            ScrollView {
                CustomForm {
                    CustomSection {
                        VStack{
                            Text(activity.comment)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    CustomSection {
                        HStack {
                            VStack{
                                Text(NSLocalizedString("envFrom", comment: "From"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 13))
                                Text(Utils.dateFormat(value: activity.dateFrom, toFormat: "dd MMM yyy", fromFormat: "yyyy-MM-dd"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            VStack{
                                Text(NSLocalizedString("envTo", comment: "To"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 13))
                                Text(Utils.dateFormat(value: activity.dateTo, toFormat: "dd MMM yyy", fromFormat: "yyyy-MM-dd"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            Image("ic-calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 26)
                                .foregroundColor(.cIcon)
                        }
                    }
                    CustomSection {
                        HStack {
                            VStack{
                                Text(NSLocalizedString("envFrom", comment: "From"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 13))
                                Text(activity.hourFrom)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            VStack{
                                Text(NSLocalizedString("envTo", comment: "To"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 13))
                                Text(activity.hourTo)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            Image("ic-clock")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 26)
                                .foregroundColor(.cIcon)
                        }
                    }
                    ForEach($dynamicForm.tabs) { $tab in
                        DynamicFormSummaryView(form: $dynamicForm, tab: $tab, options: dynamicOptions)
                    }
                    ScrollViewFABBottom()
                }
            }
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        dynamicOptions.objectId = activity.objectId
        dynamicOptions.item = activity.id
        
        dynamicForm.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
        if !activity.fields.isEmpty {
            DynamicUtils.fillForm(form: &dynamicForm, base: activity.fields)
        }
    }
}

struct ActivitySummaryMapView: View {
    
    var item: DifferentToVisit
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    
    var body: some View {
        CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { marker in }
            .onAppear {
                markers.removeAll()
                if item.latitude > 0 && item.longitude > 0 {
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude)))
                    markers.append(marker)
                }
                fitToBounds = true
            }
    }
    
}
