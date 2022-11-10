//
//  PanelCardView.swift
//  PRO
//
//  Created by VMO on 4/12/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct PanelSummaryView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var panel: Panel
    var onClosePressed: () -> Void
    
    @State private var tabs: [String] = []
    @State private var form: DynamicForm = DynamicForm(tabs: [])
    @State private var options: DynamicFormFieldOptions = DynamicFormFieldOptions(table: "", op: .view, panelType: "")
    @State private var contactControl: [PanelContactControlModel] = []
    @State private var locations: [PanelLocationModel] = []
    @State private var visitingHours: [PanelVisitingHourModel] = []
    
    @StateObject var tabRouter = TabRouter()
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            /*HStack {
                Button(action: {
                    onClosePressed()
                }) {
                    Image("ic-close")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.cIcon)
                        .frame(width: 20, height: 20, alignment: .center)
                }
                .frame(width: 44, height: 44, alignment: .center)
            }*/
            PanelFormHeaderView(panel: panel)
            ZStack(alignment: .bottom) {
                TabView(selection: $tabRouter.current) {
                    VStack {
                        PanelItemMapView(item: panel)
                            .frame(height: 200)
                        CustomForm {
                            ForEach($form.tabs) { $tab in
                                DynamicFormSummaryView(form: $form, tab: $tab, options: options)
                            }
                            ScrollViewFABBottom()
                        }
                    }
                    .tag("BASIC")
                    .tabItem {
                        Text("envInformation".localized())
                        Image("ic-basic")
                    }
                    if tabs.contains("visiting-hours") {
                        PanelFormVisitingHoursView(items: $visitingHours)
                            .padding()
                            .disabled(true)
                            .tag("visiting-hours")
                            .tabItem {
                                Text("envTabVisitingHours")
                                Image("ic-calendar")
                            }
                    }
                    if tabs.contains("contact-control") {
                        PanelFormContactControlView(items: $contactControl)
                            .disabled(true)
                            .tag("contact-control")
                            .tabItem {
                                Text("envTabContactControl")
                                Image("ic-contact-control")
                            }
                    }
                    PanelRecordListView(viewRouter: viewRouter, panel: panel)
                        .tag("RECORD")
                        .tabItem {
                            Text("envVisits".localized())
                            Image("ic-visit")
                        }
                }
                .tabViewStyle(DefaultTabViewStyle())
                HStack(alignment: .bottom) {
                    Spacer()
                    FAB(image: "ic-edit") {
                        onClosePressed()
                        FormEntity(objectId: panel.objectId, type: panel.type, options: [ "tab": "BASIC" ])
                            .go(path: PanelUtils.formByPanelType(panel: panel), router: viewRouter)
                    }
                }
                .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
                .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        options.objectId = panel.objectId
        options.item = panel.id
        options.op = .view
        options.panelType = panel.type
        
        PanelUtils.dynamicFormByPanel(realm: realm, panel: panel, form: &form, options: &options)
        
        switch panel.type {
            case "M":
                tabs = ["visiting-hours", "contact-control"]
            case "F":
                tabs = ["visiting-hours"]
            case "C":
                tabs = ["visiting-hours"]
            case "P":
                tabs = []
            case "T":
                tabs = []
            default:
                break
        }
        
        tabRouter.current = "BASIC"
        
        ContactControlTypeDao(realm: realm).all().forEach { ccType in
            var status = false
            if let cc = panel.contactControl.first(where: { ccp in
                ccp.contactControlTypeId == ccType.id
            }) {
                status = cc.status == 1
            }
            contactControl.append(PanelContactControlModel(contactControlType: ccType, status: status))
        }
        for day in 0..<7 {
            if let vh = panel.visitingHours.first(where: { pvh in
                pvh.dayOfWeek == day
            }) {
                visitingHours.append(PanelVisitingHourModel(dayOfWeek: vh.dayOfWeek, amHourStart: vh.amHourStart, amHourEnd: vh.amHourEnd, pmHourStart: vh.pmHourStart, pmHourEnd: vh.pmHourEnd, amStatus: vh.amStatus == 1, pmStatus: vh.pmStatus == 1))
            } else {
                visitingHours.append(PanelVisitingHourModel(dayOfWeek: day))
            }
        }
    }
    
}

struct DetailCardView: View {
    var sections: [SectionCard]!
    var body: some View {
        List {
            ForEach(sections, id: \.title) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.details, id: \.title) {  detail in
                        switch detail.type {
                        case .text:
                            DetailCardTextView(detail: detail)
                        case .email:
                            DetailCardEmailView(detail: detail)
                        case .phone:
                            DetailCardPhoneView(detail: detail)
                        case .image:
                            Text("1")
                        case .url:
                            DetailCardURLView(detail: detail)
                        }
                    }
                }
            }
        }
    }
}

struct DetailCardTextView: View {
    var detail: SectionDetail!
    
    var body: some View {
        VStack {
            Text(detail.title)
                .fontWeight(.medium)
                .lineLimit(1)
                .font(.system(size: 14))
                .foregroundColor(.cPrimaryLight)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Text(detail.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "--" : detail.content)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
        }
        .padding(.vertical, 4)
    }
}

struct DetailCardLocationView: View {
    var detail: SectionDetail!
    var body: some View {
        HStack {
            DetailCardTextView(detail: detail)
                .frame(minWidth: 0, maxWidth: .infinity)
            Image("ic-map")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cPrimary)
                .frame(width: 32, height: 32, alignment: .center)
        }
    }
}

struct DetailCardEmailView: View {
    var detail: SectionDetail!
    var body: some View {
        HStack {
            DetailCardTextView(detail: detail)
                .frame(minWidth: 0, maxWidth: .infinity)
            Image("ic-envelope")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cPrimary)
                .frame(width: 32, height: 32, alignment: .center)
        }
    }
}

struct DetailCardPhoneView: View {
    var detail: SectionDetail!
    var body: some View {
        HStack {
            DetailCardTextView(detail: detail)
                .frame(minWidth: 0, maxWidth: .infinity)
            Image("ic-phone-call")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cPrimary)
                .frame(width: 32, height: 32, alignment: .center)
        }
    }
}

struct DetailCardURLView: View {
    var detail: SectionDetail!
    var body: some View {
        HStack {
            DetailCardTextView(detail: detail)
                .frame(minWidth: 0, maxWidth: .infinity)
            Image("ic-url")
                .resizable()
                .scaledToFit()
                .foregroundColor(.cPrimary)
                .frame(width: 32, height: 32, alignment: .center)
        }
    }
}
