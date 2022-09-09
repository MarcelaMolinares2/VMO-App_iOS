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
import GoogleMaps

class DiaryModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var hourFrom: Date = Date()
    @Published var hourTo: Date = Date()
    @Published var comment: String = ""
    @Published var contactType: String = ""
    @Published var isContactPoint: Bool = false
}

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
    
    @State private var modalMenuEdit = false
    
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
    @State private var diarySelected: Diary = Diary()
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
                                        layout = .main
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
                        if layout == .map {
                            DiaryListMapView(items: $diaries)
                        } else {
                            ScrollView {
                                ForEach($itemWrappers) { $iw in
                                    DiaryFormWrapperItemView(realm: realm, iw: $iw, dateDiaries: $diaries, interval: $interval, onRefreshRequested: refresh, onDiaryTapped: { diary in
                                        diarySelected = diary
                                        modalMenuEdit = true
                                    }) { diw in
                                        predefinedTime = Utils.hourFormat(date: diw.time)
                                        modalPanelType = true
                                    }
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
                                if layout == .map {
                                    layout = .main
                                    refresh()
                                } else {
                                    layout = .map
                                }
                            }) {
                                Image(layout == .map ? "ic-list" : "ic-map")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26, alignment: .center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                            VStack {
                                
                            }
                            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                            Button(action: {
                                modalActivity = true
                            }) {
                                Image("ic-activity")
                                    .resizable()
                                    .foregroundColor(.cIcon)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26, alignment: .center)
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
        .partialSheet(isPresented: $modalMenuEdit) {
            DiaryMenuEdit(realm: realm, diary: diarySelected) {
                modalMenuEdit = false
                refresh()
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
            diaries.append(contentsOf: DiaryDao(realm: realm).by(date: date).map { Diary(value: $0) })
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
    let onDiaryTapped: (_ diw: Diary) -> Void
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
                                .onTapGesture {
                                    onDiaryTapped(diary)
                                }
                        default:
                            DiaryPanelItemView(realm: realm, diary: diary)
                                .onTapGesture {
                                    onDiaryTapped(diary)
                                }
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
                                let difference = Utils.strToDate(value: diary.hourStart, format: "HH:mm").distance(to: Utils.strToDate(value: diary.hourEnd ?? "", format: "HH:mm"))
                                diary.hourStart = Utils.hourFormat(date: iw.time)
                                diary.hourEnd = Utils.hourFormat(date: iw.time.addingTimeInterval(TimeInterval(difference)))
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
            HStack(alignment: .top) {
                DiaryItemLeadingView(diary: diary, headerColor: .cPanelActivity, headerIcon: "ic-activity")
                VStack {
                    Text(diary.content ?? "--")
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextHigh)
                        .lineLimit(3)
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
    
    @State private var headerColor = Color.cPrimary
    @State private var headerIcon = "ic-home"
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                DiaryItemLeadingView(diary: diary, panel: panel, headerColor: headerColor, headerIcon: headerIcon)
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
        panel = PanelUtils.panel(type: diary.panelType, objectId: diary.panelObjectId, id: diary.panelId)
        if let p = panel {
            self.headerColor = PanelUtils.colorByPanelType(panel: p)
            self.headerIcon = PanelUtils.iconByPanelType(panel: p)
        }
    }
    
}

struct DiaryItemLeadingView: View {
    let diary: Diary
    var panel: Panel? = nil
    var headerColor: Color
    var headerIcon: String
    
    var body: some View {
        VStack(spacing: 2) {
            Image(headerIcon)
                .resizable()
                .scaledToFit()
                .foregroundColor(headerColor)
                .frame(width: 26, height: 26, alignment: .center)
                .padding(4)
            HStack(spacing: 0) {
                Image(diary.contactType == "V" ? "ic-phone-call" : "ic-person")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.cIcon)
                    .frame(width: 12, height: 12, alignment: .center)
                    .padding(2)
                Image("ic-pin")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor( diary.isContactPoint == 1 ? .cDanger : .cIcon)
                    .frame(width: 12, height: 12, alignment: .center)
                    .padding(2)
                Image("ic-circle-check")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.cIconLight)
                    .frame(width: 12, height: 12, alignment: .center)
                    .padding(2)
            }
            .frame(width: 50)
        }
        .frame(width: 50)
        .onAppear {
            load()
        }
    }
    
    func load() {
    }
    
}

struct DiaryListMapView: View {
    @Binding var items: [Diary]
    
    @State private var markers = [GMSMarker]()
    @State private var goToMyLocation = false
    @State private var fitToBounds = false
    
    @State private var menuIsPresented = false
    @State private var panelTapped: Panel = GenericPanel()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CustomMarkerMapView(markers: $markers, goToMyLocation: $goToMyLocation, fitToBounds: $fitToBounds) { marker in
                if let p = marker.userData as? Panel {
                    panelTapped = p
                    menuIsPresented = true
                }
            }
            .onAppear {
                markers.removeAll()
                items.forEach { diary in
                    if let panel = PanelUtils.panel(type: diary.panelType, objectId: diary.panelObjectId, id: diary.panelId) {
                        if let location = panel.mainLocation() {
                            if let lat = location.latitude, let lng = location.longitude {
                                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng)))
                                marker.userData = panel
                                markers.append(marker)
                            }
                        }
                    }
                }
                fitToBounds = true
            }
            VStack(spacing: 10) {
                FAB(image: "ic-my-location") {
                    goToMyLocation = true
                }
                FAB(image: "ic-bounds") {
                    fitToBounds = true
                }
            }
            .padding(.top, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .sheet(isPresented: $menuIsPresented) {
            
        }
    }
    
}

struct DiaryMenuEdit: View {
    let realm: Realm
    let diary: Diary
    let onActionDone: () -> Void
    
    @State private var date: Date = Date()
    @State private var hourFrom: Date = Date()
    @State private var hourTo: Date = Date()
    @State private var comment: String = ""
    @State private var contactType: String = ""
    @State private var isContactPoint: Bool = false
    
    var body: some View {
        let panel = PanelUtils.panel(type: diary.panelType, objectId: diary.panelObjectId, id: diary.panelId)
        VStack {
            if diary.type == "P" {
                if let p = panel {
                    let headerColor = PanelUtils.colorByPanelType(panel: p)
                    let headerIcon = PanelUtils.iconByPanelType(panel: p)
                    HStack {
                        Text(p.name ?? "")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .padding(.horizontal, 5)
                            .foregroundColor(.cTextHigh)
                        Image(headerIcon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(headerColor)
                            .frame(width: 34, height: 34, alignment: .center)
                            .padding(4)
                    }
                    PanelItemMapView(item: p)
                        .frame(maxHeight: 200)
                }
            }
            CustomSection {
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        DatePicker("envDate", selection: $date, displayedComponents: [.date])
                            .id(date)
                        Image("ic-calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 26)
                            .foregroundColor(.cIcon)
                    }
                    if diary.type == "P" {
                        HStack(spacing: 15) {
                            DatePicker("envHour", selection: $hourFrom, displayedComponents: [.hourAndMinute])
                                .id(hourFrom)
                            Image("ic-clock")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 26)
                                .foregroundColor(.cIcon)
                        }
                    }
                    if diary.type == "A" {
                        HStack {
                            VStack{
                                Text(NSLocalizedString("envFrom", comment: "From"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 13))
                                DatePicker("", selection: $hourFrom, displayedComponents: [.hourAndMinute])
                                    .fixedSize()
                            }
                            .frame(maxWidth: .infinity)
                            VStack{
                                Text(NSLocalizedString("envTo", comment: "To"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 13))
                                DatePicker("", selection: $hourTo, in: hourFrom..., displayedComponents: [.hourAndMinute])
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
                                .foregroundColor((comment.isEmpty) ? .cDanger : .cTextMedium)
                                .font(.system(size: 14))
                            VStack{
                                TextEditor(text: $comment)
                                    .frame(height: 80)
                            }
                        }
                    }
                }
            }
            HStack {
                Button(action: {
                    validate()
                }) {
                    Image("ic-done-all")
                        .resizable()
                        .foregroundColor(.cIcon)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26, alignment: .center)
                }
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                Button(action: {
                    contactType = contactType == "V" ? "P" : "V"
                }) {
                    Image(contactType == "V" ? "ic-phone-call" : "ic-person")
                        .resizable()
                        .foregroundColor(.cIcon)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26, alignment: .center)
                }
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                Button(action: {
                    isContactPoint.toggle()
                }) {
                    Image("ic-pin")
                        .resizable()
                        .foregroundColor(isContactPoint ? .cWarning : .cIcon)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26, alignment: .center)
                }
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                Button(action: {
                    delete()
                }) {
                    Image("ic-delete")
                        .resizable()
                        .foregroundColor(.cDanger)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26, alignment: .center)
                }
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        date = Utils.strToDate(value: diary.date)
        hourFrom = Utils.strToDate(value: diary.hourStart, format: "HH:mm")
        hourTo = Utils.strToDate(value: diary.hourEnd ?? "", format: "HH:mm")
        contactType = diary.contactType ?? "P"
        isContactPoint = diary.isContactPoint == 1
        comment = diary.content ?? ""
    }
    
    func validate() {
        if diary.type == "A" {
            if comment.isEmpty {
                return
            }
        }
        save()
    }
    
    func save() {
        diary.date = Utils.dateFormat(date: date)
        diary.hourStart = Utils.hourFormat(date: hourFrom)
        diary.hourEnd = Utils.hourFormat(date: hourTo)
        diary.contactType = contactType
        diary.isContactPoint = isContactPoint ? 1 : 0
        diary.content = comment
        DiaryDao(realm: realm).store(diary: diary)
        onActionDone()
    }
    
    func delete() {
        if let d = DiaryDao(realm: realm).by(objectId: diary.objectId.stringValue) {
            try! realm.write {
                realm.delete(d)
                DispatchQueue.main.async {
                    onActionDone()
                }
            }
        }
    }
    
}
