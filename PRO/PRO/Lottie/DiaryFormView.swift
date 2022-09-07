//
//  DiaryFormView.swift
//  PRO
//
//  Created by VMO on 25/08/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import UniformTypeIdentifiers

class DiaryActivityModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var hourFrom: Date = Date()
    @Published var hourTo: Date = Date()
    @Published var comment: String = ""
}

class DiaryItemWrapper: ObservableObject, Identifiable {
    var id = UUID()
    @Published var time: Date
    
    init(time: Date) {
        self.time = time
    }
    
}

enum DiaryFormLayout {
case main, selection, map
}

struct DiaryFormView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var layout: DiaryFormLayout = .main
    @State private var date: Date = Date()
    @State private var startTime: Date = Date()
    @State private var interval: Int = 30
    
    @State private var modalActivity: Bool = false
    @State private var modalMainMenu: Bool = false
    @State private var modalSelectionMenu: Bool = false
    @State private var modalPanelType = false
    
    @State private var itemWrappers: [DiaryItemWrapper] = []
    
    private var realm = try! Realm()
    
    @State private var slDoctors = [ObjectId]()
    @State private var slPharmacies = [ObjectId]()
    @State private var slClients = [ObjectId]()
    @State private var slPatients = [ObjectId]()
    @State private var modalPanelDoctor = false
    @State private var modalPanelPharmacy = false
    @State private var modalPanelClient = false
    @State private var modalPanelPatient = false
    
    @State private var diaries: [Diary] = []
    @State private var predefinedTime = ""
    
    var body: some View {
        VStack {
            HeaderToggleView(title: "envDiary") {
                viewRouter.currentPage = "MASTER"
            }
            ZStack(alignment: .bottom) {
                VStack {
                    VStack {
                        HStack {
                            Button(action: {
                                
                            }) {
                                Image("ic-smart")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding(8)
                            }
                            .frame(width: 44, height: 44, alignment: .center)
                            HStack {
                                Button(action: {
                                    var dateComponent = DateComponents()
                                    dateComponent.day = -1
                                    date = Calendar.current.date(byAdding: dateComponent, to: date) ?? Date()
                                }) {
                                    Image("ic-double-arrow-left")
                                        .resizable()
                                        .foregroundColor(.cIcon)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .padding(8)
                                }
                                .frame(width: 44, height: 44, alignment: .center)
                                Spacer()
                                DatePicker(selection: $date, displayedComponents: .date) {}
                                    .labelsHidden()
                                    .id(date)
                                    .onChange(of: date) { d in
                                        refresh()
                                    }
                                Spacer()
                                Button(action: {
                                    var dateComponent = DateComponents()
                                    dateComponent.day = 1
                                    date = Calendar.current.date(byAdding: dateComponent, to: date) ?? Date()
                                }) {
                                    Image("ic-double-arrow-right")
                                        .resizable()
                                        .foregroundColor(.cIcon)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .padding(8)
                                }
                                .frame(width: 44, height: 44, alignment: .center)
                            }
                            .padding(.horizontal, 10)
                            Button(action: {
                                layout = layout == .selection ? .main : .selection
                            }) {
                                Image("ic-selection")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding(8)
                            }
                            .frame(width: 44, height: 44, alignment: .center)
                        }
                        HStack {
                            Text("Start at \(Utils.dateFormat(date: startTime, format: "HH:mm"))")
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("Time interval: \(interval)")
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            ForEach($itemWrappers) { $iw in
                                DiaryFormWrapperItemView(realm: realm, iw: $iw, dateDiaries: $diaries, interval: $interval, onRefreshRequested: refresh) { diw in
                                    predefinedTime = Utils.hourFormat(date: diw.time)
                                    modalPanelType = true
                                }
                            }
                        }
                        HStack(alignment: .bottom) {
                            VStack {
                                if layout == .selection {
                                    FAB(image: "ic-done-all") {
                                        
                                    }
                                }
                            }
                            Spacer()
                            VStack {
                                FAB(image: "ic-more") {
                                    if layout == .selection {
                                        modalSelectionMenu = true
                                    } else {
                                        modalMainMenu = true
                                    }
                                }
                            }
                        }
                        .padding(.bottom, Globals.UI_FAB_VERTICAL)
                        .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
                    }
                    if layout != .selection {
                        HStack {
                            Button(action: {
                                layout = .map
                            }) {
                                Image("ic-map")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding(8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                            EmptyView()
                                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                            Button(action: {
                                modalActivity = true
                            }) {
                                Image("ic-activity")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .padding(8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                        }
                    }
                }
                if layout != .selection {
                    VStack {
                        FAB(image: "ic-plus", size: 60, margin: 32) {
                            predefinedTime = ""
                            modalPanelType = true
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .partialSheet(isPresented: $modalActivity) {
            DiaryActivityFormView {
                modalActivity = false
                refresh()
            }
        }
        .partialSheet(isPresented: $modalMainMenu) {
            VStack(spacing: 20) {
                VStack {
                    Button {
                        
                    } label: {
                        Text("envIntervalToSchedule")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envHourStart")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envSaveAsGroup")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
                VStack {
                    Button {
                        
                    } label: {
                        Text("envMoveAll")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envDeleteAll")
                            .foregroundColor(.cDanger)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
            }
            .padding()
        }
        .partialSheet(isPresented: $modalSelectionMenu) {
            VStack(spacing: 20) {
                VStack {
                    Button {
                        
                    } label: {
                        Text("envContactType")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envContactPoint")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
                VStack {
                    Button {
                        
                    } label: {
                        Text("envMove")
                            .foregroundColor(.cTextHigh)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                    Divider()
                    Button {
                        
                    } label: {
                        Text("envDelete")
                            .foregroundColor(.cDanger)
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                    }
                    .frame(height: 44)
                }
                .background(Color.cBackground1dp)
                .cornerRadius(5)
            }
            .padding()
        }
        .partialSheet(isPresented: $modalPanelType) {
            PanelTypeSelectView(types: ["M", "F", "C", "P", "G"]) { type in
                slDoctors = diaries.filter { $0.panelType == "M" }.map { $0.panelObjectId }
                slPharmacies = diaries.filter { $0.panelType == "F" }.map { $0.panelObjectId }
                slClients = diaries.filter { $0.panelType == "C" }.map { $0.panelObjectId }
                slPatients = diaries.filter { $0.panelType == "P" }.map { $0.panelObjectId }
                switch type {
                    case "F":
                        modalPanelPharmacy = true
                    case "C":
                        modalPanelClient = true
                    case "P":
                        modalPanelPatient = true
                    default:
                        modalPanelDoctor = true
                }
                modalPanelType = false
            }
        }
        .sheet(isPresented: $modalPanelDoctor) {
            DoctorSelectView(selected: $slDoctors) {
                modalPanelDoctor = false
                append(panelType: "M")
            }
        }
        .sheet(isPresented: $modalPanelPharmacy) {
            PharmacySelectView(selected: $slPharmacies) {
                modalPanelPharmacy = false
                append(panelType: "F")
            }
        }
        .sheet(isPresented: $modalPanelClient) {
            ClientSelectView(selected: $slClients) {
                modalPanelClient = false
                append(panelType: "C")
            }
        }
        .sheet(isPresented: $modalPanelPatient) {
            PatientSelectView(selected: $slPatients) {
                modalPanelPatient = false
                append(panelType: "P")
            }
        }
        .onAppear {
            UITableView.appearance().contentInset.top = -35
            initForm()
        }
    }
    
    func initForm() {
        let preferences = UserPreferenceDao(realm: realm).by(module: "DIARY")
        let hourStart = preferences.first { up in
            up.type == "HOUR_START"
        }?.value ?? "08:00"
        let hourEnd = preferences.first { up in
            up.type == "HOUR_END"
        }?.value ?? "22:00"
        interval = Utils.castInt(value: preferences.first { up in
            up.type == "INTERVAL"
        }?.value ?? "30")
        
        startTime = Utils.strToDate(value: hourStart, format: "HH:mm")
        var currentTime = startTime
        let limitTime = Utils.strToDate(value: hourEnd, format: "HH:mm")
        
        while currentTime < limitTime {
            itemWrappers.append(DiaryItemWrapper(time: currentTime))
            currentTime = currentTime.addingTimeInterval(TimeInterval(Double(interval) * 60.0))
        }
        
        refresh()
    }
    
    func append(panelType: String) {
        switch panelType {
            case "F":
                slPharmacies.forEach { oId in
                    validateAppend(diaries: diaries, type: panelType, oId: oId)
                }
            case "C":
                slClients.forEach { oId in
                    validateAppend(diaries: diaries, type: panelType, oId: oId)
                }
            case "P":
                slPatients.forEach { oId in
                    validateAppend(diaries: diaries, type: panelType, oId: oId)
                }
            default:
                slDoctors.forEach { oId in
                    validateAppend(diaries: diaries, type: panelType, oId: oId)
                }
        }
        
        refresh()
    }
    
    func validateAppend(diaries: [Diary], type: String, oId: ObjectId) {
        if let panel = PanelUtils.panel(type: type, objectId: oId) {
            if !diaries.contains(where: { d in
                return d.panelType == type && (d.panelObjectId == oId || d.panelId == panel.id)
            }) {
                appendToEmpty(diary: basicDiary(type: type, oId: oId, id: panel.id))
            }
        }
    }
    
    func basicDiary(type: String, oId: ObjectId, id: Int) -> Diary {
        let diary = Diary()
        diary.date = Utils.dateFormat(date: date)
        diary.panelType = type
        diary.panelObjectId = oId
        diary.panelId = id
        diary.type = "P"
        diary.contactType = "P"
        diary.transactionType = "CREATE"
        return diary
    }
    
    func appendToEmpty(diary: Diary) {
        if predefinedTime.isEmpty {
            if let iw = itemWrappers.first (where: { diw in
                !iwHasDiaries(iw: diw)
            }) {
                diary.hourStart = Utils.hourFormat(date: iw.time)
                diaries.append(diary)
            } else {
                diary.hourStart = Utils.hourFormat(date: itemWrappers.last?.time ?? startTime)
            }
        } else {
            diary.hourStart = predefinedTime
        }
        DiaryDao(realm: realm).store(diary: diary)
    }
    
    func refresh() {
        diaries.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            diaries.append(contentsOf: DiaryDao(realm: realm).by(date: date))
        }
    }
    
    func iwHasDiaries(iw: DiaryItemWrapper) -> Bool {
        let timeEnd = iw.time.addingTimeInterval(TimeInterval(Double(interval) * 60.0))
        return diaries.contains { d in
            TimeUtils.hourTo(time: d.hourStart) >= TimeUtils.hourTo(time: iw.time) && TimeUtils.hourTo(time: d.hourStart) < TimeUtils.hourTo(time: timeEnd)
        }
    }
    
}

struct DiaryFormWrapperItemView: View {
    var realm: Realm
    @Binding var iw: DiaryItemWrapper
    @Binding var dateDiaries: [Diary]
    @Binding var interval: Int
    let onRefreshRequested: () -> Void
    let onItemTapped: (_ diw: DiaryItemWrapper) -> Void
    
    @State private var diaries: [Diary] = []
    
    var body: some View {
        VStack {
            HStack {
                Text(Utils.hourFormat(date: iw.time))
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 13))
                VStack {
                    Divider()
                }
                .frame(maxWidth: .infinity)
            }
            if diaries.isEmpty {
                Button {
                    onItemTapped(iw)
                } label: {
                    VStack {
                        
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                }
            }
            ForEach($diaries, id: \.objectId) { $diary in
                VStack {
                    switch diary.type {
                        case "A":
                            DiaryActivityItemView(diary: diary)
                        default:
                            DiaryPanelItemView(realm: realm, diary: diary)
                    }
                }
                .onDrag {
                    let provider = NSItemProvider(object: diary.objectId.stringValue as NSString)
                    return provider
                }
            }
        }
        .onDrop(of: [UTType.text], delegate: DiaryDropDelegate(iw: iw, onDropPerformed: onRefreshRequested))
        .onChange(of: dateDiaries) { n in
            let timeEnd = iw.time.addingTimeInterval(TimeInterval(Double(interval) * 60.0))
            diaries.removeAll()
            diaries.append(contentsOf: dateDiaries.filter({ d in
                TimeUtils.hourTo(time: d.hourStart) >= TimeUtils.hourTo(time: iw.time) && TimeUtils.hourTo(time: d.hourStart) < TimeUtils.hourTo(time: timeEnd)
            }))
        }
    }
    
}

struct DiaryActivityFormView: View {
    let onSaveDone: () -> Void
    
    @State private var model: DiaryActivityModel = DiaryActivityModel()
    @State private var hourFrom: Date = Date()
    
    let realm = try! Realm()
    
    var body: some View {
        VStack {
            CustomSection {
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        DatePicker("envDate", selection: $model.date, displayedComponents: [.date])
                            .id(model.date)
                        Image("ic-calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 26)
                            .foregroundColor(.cIcon)
                    }
                    HStack {
                        VStack{
                            Text(NSLocalizedString("envFrom", comment: "From"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            DatePicker("", selection: $hourFrom, displayedComponents: [.hourAndMinute])
                                .fixedSize()
                                .onChange(of: hourFrom) { newValue in
                                    model.hourFrom = newValue
                                }
                        }
                        .frame(maxWidth: .infinity)
                        VStack{
                            Text(NSLocalizedString("envTo", comment: "To"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 13))
                            DatePicker("", selection: $model.hourTo, in: hourFrom..., displayedComponents: [.hourAndMinute])
                                .fixedSize()
                        }
                        .frame(maxWidth: .infinity)
                        Image("ic-clock")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 26)
                            .foregroundColor(.cIcon)
                    }
                    VStack {
                        Text("envDTVComment")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor((model.comment.isEmpty) ? .cDanger : .cTextMedium)
                            .font(.system(size: 14))
                        VStack{
                            TextEditor(text: $model.comment)
                                .frame(height: 80)
                        }
                    }
                }
            }
            Button(action: {
                validate()
            }) {
                Text("envSave")
                    .foregroundColor(.cTextHigh)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
        }
        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
    }
    
    func validate() {
        if model.comment.isEmpty {
            return
        }
        save()
    }
    
    func save() {
        let diary = Diary()
        diary.date = Utils.dateFormat(date: model.date)
        diary.type = "A"
        diary.transactionType = "CREATE"
        diary.hourStart = Utils.hourFormat(date: model.hourFrom)
        diary.hourEnd = Utils.hourFormat(date: model.hourTo)
        diary.content = model.comment
        DiaryDao(realm: realm).store(diary: diary)
        onSaveDone()
    }
    
}

struct DiaryDropDelegate: DropDelegate {
    let iw: DiaryItemWrapper
    let onDropPerformed: () -> Void
    
    func dropEntered(info: DropInfo) {
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: ["public.text"]).first {
            item.loadItem(forTypeIdentifier: "public.text", options: nil) { text, err in
                if let data = text as? Data {
                    let inputStr = String(decoding: data, as: UTF8.self)
                    let realm = try! Realm()
                    if let diary = DiaryDao(realm: realm).by(objectId: inputStr) {
                        try! realm.write {
                            if diary.transactionType.isEmpty {
                                diary.transactionType = "UPDATE"
                            }
                            if diary.type == "P" {
                                diary.hourStart = Utils.hourFormat(date: iw.time)
                            } else {
                                
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDropPerformed()
                            }
                        }
                    }
                }
            }
        }
        return true
    }
}

struct DiaryActivityItemView: View {
    let diary: Diary
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image("ic-activity")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cPanelActivity)
                        .frame(width: 34, height: 34, alignment: .center)
                        .padding(4)
                }
                .frame(height: 40)
                VStack {
                    Text(diary.content ?? "--")
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextHigh)
                        .lineLimit(1)
                    Text("\(diary.hourStart) - \(diary.hourEnd ?? "--")")
                        .font(.system(size: 14))
                        .foregroundColor(.cTextMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .contentShape(Rectangle())
    }
    
}

struct DiaryPanelItemView: View {
    let realm: Realm
    let diary: Diary
    
    @State var panel: Panel? = nil
    
    @State var headerColor = Color.cPrimary
    @State var headerIcon = "ic-home"
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(headerIcon)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(headerColor)
                        .frame(width: 34, height: 34, alignment: .center)
                        .padding(4)
                }
                .frame(height: 40)
                VStack {
                    Text(panel?.name?.capitalized ?? " -- ")
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextHigh)
                        .lineLimit(1)
                    Text(diary.hourStart)
                        .font(.system(size: 14))
                        .foregroundColor(.cTextMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    let mainLocation = panel?.mainLocation()
                    Text("\(mainLocation?.address ?? ""), \(CityDao(realm: realm).by(id: mainLocation?.cityId)?.name ?? " -- ")")
                        .font(.system(size: 14))
                        .foregroundColor(.cTextMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .trailing, spacing: 2) {
                    VStack {
                        Text(panel?.mainCategory(realm: realm, defaultValue: "--") ?? "--")
                            .padding(.horizontal, 5)
                            .font(.system(size: 14))
                            .foregroundColor(.cTextMedium)
                            .frame(height: 20)
                    }
                    .frame(minWidth: 30)
                    .background(Color.cBackground1dp)
                    if let user = panel?.findUser(userId: JWTUtils.sub()) {
                        Text("\(user.visitsCycle)/\(user.visitsFee)")
                            .font(.system(size: 14))
                            .frame(width: 30, height: 20, alignment: .center)
                            .background(PanelUtils.visitsBackground(user: user))
                            .foregroundColor(.white)
                    } else {
                        Text("--/--")
                            .font(.system(size: 14))
                            .frame(width: 30, height: 20, alignment: .center)
                            .background(Color.cBackground3dp)
                            .foregroundColor(.white)
                    }
                }
                .frame(minWidth: 30)
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            load()
        }
    }
    
    func load() {
        if diary.panelId <= 0 {
            panel = PanelUtils.panel(type: diary.panelType, objectId: diary.panelObjectId)
        } else {
            panel = PanelUtils.panel(type: diary.panelType, id: diary.panelId)
        }
        if let p = panel {
            self.headerColor = PanelUtils.colorByPanelType(panel: p)
            self.headerIcon = PanelUtils.iconByPanelType(panel: p)
        }
    }
    
}
