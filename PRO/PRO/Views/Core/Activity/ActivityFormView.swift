//
//  ActivityFormView.swift
//  PRO
//
//  Created by VMO on 9/12/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import CoreLocation
import AlertToast


class DifferentToVisitModel: ObservableObject {
    @Published var dateFrom: Date = Date()
    @Published var dateTo: Date = Date()
    @Published var hourFrom: Date = Date()
    @Published var hourTo: Date = Date()
    @Published var comment: String = ""
    @Published var fields: String = ""
    
    @Published var fdr: Bool = false
    @Published var fdrAvailable: Bool = true
    @Published var fdrPercentage: Float = 100
    @Published var fdrReasonId: Int = 0
}


struct ActivityFormView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var realm = try! Realm()
    
    private var dtvModel = DifferentToVisitModel()
    @State private var assistants = [PanelItemModel]()
    @State private var materials = [AdvertisingMaterialDeliveryMaterial]()
    
    @State var differentToVisit: DifferentToVisit?
    
    @State private var route = 0
    @State private var modalPanelType = false
    @State private var showToast = false
    @State private var savedToast = false
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "modActivity") {
                viewRouter.currentPage = "ACTIVITIES-VIEW"
            }
            ZStack(alignment: .bottom) {
                TabView(selection: $route) {
                    ActivityFormBasicView(realm: realm)
                        .tag(0)
                        .tabItem {
                            Text("envBasic")
                            Image("ic-basic")
                        }
                    ZStack(alignment: .bottom) {
                        PanelSelectWrapperView(realm: realm, types: ["M", "F", "C", "P", "T"], members: $assistants, modalPanelType: $modalPanelType)
                        HStack(alignment: .bottom) {
                            FAB(image: "ic-plus") {
                                modalPanelType = true
                            }
                            Spacer()
                        }
                        .padding(.bottom, Globals.UI_FAB_VERTICAL)
                        .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
                    }
                        .tag(1)
                        .tabItem {
                            Text("envAssistants")
                            Image("ic-client")
                        }
                    MaterialDeliveryFormWrapperView(realm: realm, details: $materials)
                        .tag(2)
                        .tabItem {
                            Text("envMaterial")
                            Image("ic-material")
                        }
                }
                .tabViewStyle(DefaultTabViewStyle())
                HStack(alignment: .bottom) {
                    Spacer()
                    FAB(image: "ic-cloud") {
                        validate()
                    }
                }
                .padding(.bottom, Globals.UI_FAB_VERTICAL + 50)
                .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
            }
        }
        .environmentObject(dtvModel)
        .toast(isPresenting: $showToast) {
            AlertToast(type: .error(.cError), title: NSLocalizedString("errFormEmpty", comment: ""))
        }
        .toast(isPresenting: $savedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        if let oId = viewRouter.data.objectId {
            differentToVisit = ActivityDao(realm: try! Realm()).by(objectId: oId)
            dtvModel.dateFrom = Utils.strToDate(value: differentToVisit?.dateFrom ?? "")
            dtvModel.dateTo = Utils.strToDate(value: differentToVisit?.dateTo ?? "")
            dtvModel.hourFrom = Utils.strToDate(value: differentToVisit?.hourFrom ?? "", format: "HH:mm")
            dtvModel.hourTo = Utils.strToDate(value: differentToVisit?.hourTo ?? "", format: "HH:mm")
            dtvModel.comment = differentToVisit?.comment ?? ""
            dtvModel.fields = differentToVisit?.fields ?? "{}"
            
            if differentToVisit?.requestFreeDay == 1 {
                dtvModel.fdrAvailable = false
            }
            
            assistants.removeAll()
            differentToVisit?.assistants.forEach{ assistant in
                if assistant.panelId <= 0 {
                    assistants.append(PanelItemModel(objectId: assistant.panelObjectId, type: assistant.panelType))
                } else {
                    if let panel = PanelUtils.panel(type: assistant.panelType, id: assistant.panelId) {
                        assistants.append(PanelItemModel(objectId: panel.objectId, type: assistant.panelType))
                    }
                }
            }
        }
    }
    
    func validate() {
        if dtvModel.comment.isEmpty {
            self.showToast.toggle()
            return
        }
        if dtvModel.fdr {
            if dtvModel.fdrReasonId <= 0 {
                self.showToast.toggle()
                return
            }
        }
        save()
    }
    
    func save() {
        differentToVisit?.comment = dtvModel.comment
        differentToVisit?.dateFrom = Utils.dateFormat(date: dtvModel.dateFrom)
        differentToVisit?.dateTo = Utils.dateFormat(date: dtvModel.dateTo)
        differentToVisit?.hourFrom = Utils.hourFormat(date: dtvModel.hourFrom)
        differentToVisit?.hourTo = Utils.hourFormat(date: dtvModel.hourTo)
        //differentToVisit?.fields = dtvModel.comment
        differentToVisit?.assistants.removeAll()
        assistants.forEach { pim in
            let assistant = DifferentToVisitAssistant()
            assistant.panelObjectId = pim.objectId
            assistant.panelId = PanelUtils.panel(type: pim.type, objectId: pim.objectId)?.id ?? 0
            assistant.panelType = pim.type
            differentToVisit?.assistants.append(assistant)
        }
        differentToVisit?.materials.removeAll()
        materials.forEach { material in
            let dtvMaterial = DifferentToVisitMaterial()
            dtvMaterial.materialId = material.materialId
            material.sets.forEach { materialSet in
                let dtvMaterialSet = DifferentToVisitMaterialSet()
                dtvMaterialSet.id = materialSet.id
                dtvMaterialSet.quantity = materialSet.quantity
                dtvMaterial.sets.append(dtvMaterialSet)
            }
            differentToVisit?.materials.append(dtvMaterial)
        }
        if dtvModel.fdr {
            saveFreeDayRequest()
        }
        ActivityDao(realm: try! Realm()).store(activity: differentToVisit!)
        self.goTo(page: "ACTIVITIES-VIEW")
    }
    
    func saveFreeDayRequest() {
        let freeDayRequest = FreeDayRequest()
        freeDayRequest.reasonId = dtvModel.fdrReasonId
        freeDayRequest.observations = dtvModel.comment
        freeDayRequest.requestedAt = Utils.currentDateTime()
        let dayDurationInSeconds: TimeInterval = 60*60*24
        for date in stride(from: dtvModel.dateFrom, to: dtvModel.dateTo, by: dayDurationInSeconds) {
            let detail = FreeDayRequestDetail()
            detail.date = Utils.dateFormat(date: date)
            detail.dayFull = false
            detail.dayOnlyAM = false
            detail.dayOnlyPM = false
            detail.dayCustom = true
            detail.percentage = dtvModel.fdrPercentage
            freeDayRequest.details.append(detail)
        }
        FreeDayRequestDao(realm: realm).store(freeDayRequest: freeDayRequest)
    }
    
    func goTo(page: String) {
        viewRouter.currentPage = page
    }
}

struct ActivityFormBasicView: View {
    var realm: Realm
    @EnvironmentObject var dtvModel: DifferentToVisitModel
    
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_OTHER_FORM_ADDITIONAL").complement ?? "")
    @State private var dynamicForm = DynamicForm(tabs: [DynamicFormTab]())
    @State private var dynamicOptions = DynamicFormFieldOptions(table: "activity", op: "")

    @State private var modalRequestDayReason = false
    @State private var selectedReason = [String]()
    @State private var reasonContent = NSLocalizedString("envChoose", comment: "Choose...")
    
    var body: some View {
        VStack {
            CustomForm {
                CustomSection {
                    Text("envDTVComment")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor((dtvModel.comment.isEmpty) ? .cDanger : .cTextMedium)
                        .font(.system(size: 14))
                    VStack{
                        TextEditor(text: $dtvModel.comment)
                            .frame(height: 80)
                    }
                }
                CustomSection {
                    HStack {
                        VStack{
                            Text(NSLocalizedString("envFrom", comment: "From"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            DatePicker("", selection: $dtvModel.dateFrom, displayedComponents: [.date])
                                .fixedSize()
                        }
                        .frame(maxWidth: .infinity)
                        VStack{
                            Text(NSLocalizedString("envTo", comment: "To"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            DatePicker("", selection: $dtvModel.dateTo, in: dtvModel.dateFrom..., displayedComponents: [.date])
                                .fixedSize()
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
                            DatePicker("", selection: $dtvModel.hourFrom, displayedComponents: [.hourAndMinute])
                                .fixedSize()
                        }
                        .frame(maxWidth: .infinity)
                        VStack{
                            Text(NSLocalizedString("envTo", comment: "To"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            DatePicker("", selection: $dtvModel.hourTo, in: dtvModel.hourFrom..., displayedComponents: [.hourAndMinute])
                                .fixedSize()
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
                    DynamicFormView(form: $dynamicForm, tab: $tab, options: dynamicOptions)
                }
                if dtvModel.fdrAvailable {
                    CustomSection {
                        Toggle(isOn: $dtvModel.fdr) {
                            Text(NSLocalizedString("envRequestAuthorizedDay", comment: ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                        }
                        if dtvModel.fdr {
                            VStack {
                                Text("envRequestedDayPercentage")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                HStack {
                                    Slider(value: $dtvModel.fdrPercentage, in: 0.0...100, step: 10)
                                    Text("\(Int(dtvModel.fdrPercentage))%")
                                }
                            }
                            .padding(.vertical, 5)
                            VStack {
                                Button(action: {
                                    modalRequestDayReason = true
                                }, label: {
                                    HStack{
                                        VStack{
                                            Text(NSLocalizedString("envDayRequestReason", comment: ""))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(dtvModel.fdrReasonId <= 0 ? Color.cDanger : .cTextMedium)
                                                .font(.system(size: 14))
                                            Text(reasonContent)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.cTextHigh)
                                                .font(.system(size: 16))
                                        }
                                        Spacer()
                                        Image("ic-arrow-expand-more")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 35)
                                            .foregroundColor(.cIcon)
                                    }
                                    .sheet(isPresented: $modalRequestDayReason, content: {
                                        DialogSourcePickerView(selected: $selectedReason, key: "FREE-DAY-REASON", multiple: false, title: NSLocalizedString("envDayRequestReason", comment: "Reason for authorized day")) { selected in
                                            modalRequestDayReason = false
                                            if !selected.isEmpty {
                                                dtvModel.fdrReasonId = Utils.castInt(value: selected[0])
                                                let reason = FreeDayReasonDao(realm: realm).by(id: dtvModel.fdrReasonId)
                                                reasonContent = reason?.content ?? NSLocalizedString("envChoose", comment: "")
                                            }
                                        }
                                    })
                                    .padding(.vertical, 10)
                                })
                            }
                        }
                    }
                    ScrollViewFABBottom()
                }
            }
        }
        .onAppear{
            initDynamic()
        }
    }
    
    func initDynamic() {
        dynamicForm.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
        if !dtvModel.fields.isEmpty {
            DynamicUtils.fillForm(form: &dynamicForm, base: dtvModel.fields)
        }
    }
    
}
