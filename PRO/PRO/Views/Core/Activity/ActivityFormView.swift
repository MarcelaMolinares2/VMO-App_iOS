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

struct ActivityFormView: View {
    
    @State var viewForms = false
    @State private var activity: Activity = Activity()
    @ObservedObject var dashboardRouter = DashboardRouter()
    @State var searchText = ""
    @EnvironmentObject var viewRouter: ViewRouter
    @State private var showToast = false
    
    var body: some View {
        ZStack{
            VStack{
                HeaderToggleView(couldSearch: false, title: "modDifferentToVisit", icon: Image("ic-activity"), color: Color.cPanelActivity)
                if !viewForms {
                    ActivityBasicFormView(activity: $activity)
                } else {
                    AssistantsActivityFormView(activity: $activity)
                }
                GeometryReader { geometry in
                    HStack{
                        Image("ic-signature-paper")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / 2, alignment: .center)
                            .foregroundColor(viewForms ? .cAccent : .cPrimary)
                            .onTapGesture {
                                viewForms = false
                            }
                        Image("ic-client")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / 2, alignment: .center)
                            .foregroundColor(viewForms ? .cPrimary : .cAccent)
                            .onTapGesture {
                                viewForms = true
                            }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46, maxHeight: 46)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        save()
                    }
                }
            }
            .padding(.bottom, 56)
        }
        .toast(isPresenting: $showToast) {
            AlertToast(type: .regular, title: NSLocalizedString("envRequireItems", comment: ""))
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        
        if !viewRouter.data.objectId.isEmpty {
            if let activityItem = try? ActivityDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) {
                activity = activityItem
            }
        }
        
    }
    
    func save(){
        print(activity)
        
        if activity.requestFreeDay == 0{
            if activity.description_ == nil {
                self.showToast.toggle()
            } else{
                ActivityDao(realm: try! Realm()).store(activity: activity)
                self.goTo(page: "MASTER")
            }
        } else {
            if activity.description_ == nil || activity.dayReason == nil {
                self.showToast.toggle()
            } else {
                ActivityDao(realm: try! Realm()).store(activity: activity)
                self.goTo(page: "MASTER")
            }
        }
    }
    
    func goTo(page: String) {
        viewRouter.currentPage = page
    }
}

struct ActivityBasicFormView: View {
    
    @Binding var activity: Activity
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var isSheetCycle = false
    @State private var idsCycle = [String]()
    @State private var cycle = ""
    
    var visitType = "NORMAL"
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_OTHER_FORM_ADDITIONAL").complement ?? "")
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "activity", op: "")
    @State private var showDayAuth = false
    @State private var dateStart : Date = Date()
    @State private var dateEnd : Date = Date()
    @State private var percentageValue = Double(100)
    @State private var commentActivity = ""
    @State private var reasonActivity = ""
    
    var body: some View {
        VStack {
            Form {
                Button(action: {
                    isSheetCycle = true
                }, label: {
                    HStack{
                        VStack{
                            Text(NSLocalizedString("Cycle", comment: ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            Text((cycle == "") ? NSLocalizedString("envChoose", comment: "") : cycle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 16))
                        }
                        Spacer()
                        Image("ic-arrow-expand-more")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(10)
                })
                
                VStack{
                    VStack{
                        HStack{
                            VStack{
                                Text(NSLocalizedString("envFrom", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                DatePicker("", selection: $dateStart, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .clipped()
                                    .accentColor(.cTextHigh)
                                    .background(Color.white)
                                    .onChange(of: dateStart, perform: { value in
                                        activity.dateStart = Utils.dateFormat(date: value)
                                        activity.hourStart = Utils.dateFormat(date: value, format: "HH:mm:ss")
                                        if dateStart >= dateEnd {
                                            dateEnd = dateStart
                                            activity.dateEnd = Utils.dateFormat(date: value)
                                            activity.hourEnd = Utils.dateFormat(date: value, format: "HH:mm:ss")
                                        }
                                    })
                            }
                                .padding(10)
                            Spacer()
                            Image("ic-day-request")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                                .foregroundColor(.cTextMedium)
                                .padding(10)
                        }
                        .background(Color.white)
                        .frame(alignment: Alignment.center)
                        .clipped()
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        HStack{
                            VStack{
                                Text(NSLocalizedString("envTo", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                DatePicker("", selection: $dateEnd, in: dateStart..., displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .clipped()
                                    .accentColor(.cTextHigh)
                                    .background(Color.white)
                                    .onChange(of: dateEnd, perform: { value in
                                        activity.dateEnd = Utils.dateFormat(date: value)
                                        activity.hourEnd = Utils.dateFormat(date: value, format: "HH:mm:ss")
                                    })
                            }
                                .padding(10)
                            Spacer()
                            Image("ic-day-request")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                                .foregroundColor(.cTextMedium)
                                .padding(10)
                        }
                        .background(Color.white)
                        .frame(alignment: Alignment.center)
                        .clipped()
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                    }
                    Text(NSLocalizedString("envComment", comment: ""))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor((commentActivity == "") ? .cDanger : .cTextMedium)
                        .font(.system(size: 14))
                    VStack{
                        TextEditor(text: $commentActivity)
                        .frame(height: 80)
                        .onChange(of: commentActivity, perform: { value in
                            activity.description_ = value
                        })
                    }
                    .background(Color.white)
                    .frame(alignment: Alignment.center)
                    .clipped()
                    .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                }
                .padding(10)
                Section {
                    VStack{
                        HStack{
                            Toggle(isOn: $showDayAuth){
                                Text(NSLocalizedString("activityRequestDay", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .onChange(of: showDayAuth, perform: { value in
                                if value {
                                    activity.dayPercentage = 100
                                    activity.requestFreeDay = 1
                                } else {
                                    activity.dayPercentage = nil
                                    activity.requestFreeDay = 0
                                }
                            })
                            .toggleStyle(SwitchToggleStyle(tint: .cBlueDark))
                        }
                        if showDayAuth {
                            Text(String(format: NSLocalizedString("activityPercentageDay", comment: ""), String(percentageValue)))
                            //Text(NSLocalizedString("activityPercentageDay", comment: ""), String(percentageValue))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            Slider(value: $percentageValue, in: 0.0...100, step: 10)
                            .onChange(of: percentageValue, perform: { value in
                                activity.dayPercentage = Float(value)
                            })
                            Button(action: {
                                reasonActivity = (reasonActivity == "") ? "hola": ""
                                activity.dayReason = reasonActivity
                            }, label: {
                                HStack{
                                    VStack{
                                        Text(NSLocalizedString("activityReasonDay", comment: ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor((reasonActivity == "") ? .cDanger : .cTextMedium)
                                            .font(.system(size: 14))
                                        Text((reasonActivity != "") ? reasonActivity: NSLocalizedString("envChoose", comment: ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.cTextMedium)
                                            .font(.system(size: 16))
                                    }
                                    Spacer()
                                    Image("ic-arrow-expand-more")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35)
                                        .foregroundColor(.cTextMedium)
                                }
                                .padding(10)
                                .background(Color.white)
                                .frame(alignment: Alignment.center)
                                .clipped()
                                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                            })
                        }
                    }
                    .padding(10)
                }
                ForEach(form.tabs, id: \.id) { tab in
                    DynamicFormView(form: $form, tab: $form.tabs[0], options: options)
                }
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }.sheet(isPresented: $isSheetCycle, content: {
            CustomDialogPicker(onSelectionDone: onSelectionCycleDone, selected: $idsCycle, key: "CYCLE", multiple: false, isSheet: true)
        })
        .onAppear{
            load()
        }
    }
    
    func load(){
        
        print(activity)
        options.objectId = activity.objectId
        options.item = activity.id
        options.op = ""
        options.type = visitType.lowercased()
        options.panelType = viewRouter.data.type
        form.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
        if let date_MDY: String = activity.dateStart {
            if let date_HMS: String = activity.hourStart {
                self.dateStart = Utils.strToDate(value : date_MDY + " " + date_HMS)
            }
        } else {
            activity.dateStart = Utils.dateFormat(date: Date())
            activity.hourStart = Utils.dateFormat(date: Date(), format: "HH:mm:ss")
        }
        if let date_MDY: String = activity.dateEnd {
            if let date_HMS: String = activity.hourEnd {
                self.dateEnd = Utils.strToDate(value : date_MDY + " " + date_HMS)
            }
        } else {
            activity.dateEnd = Utils.dateFormat(date: Date())
            activity.hourEnd = Utils.dateFormat(date: Date(), format: "HH:mm:ss")
        }
        showDayAuth = (activity.requestFreeDay == 1) ? true: false
        //activity.requestFreeDay = (showDayAuth) ? 1 : 0
        self.percentageValue = (activity.dayPercentage != nil) ? Double(activity.dayPercentage ?? 100): Double(100)
        
        /*
        if let itemCycle = CycleDao(realm: try! Realm()).by(id: "1"){
            cycle = itemCycle.displayName
            activity.cycle = itemCycle;
        }
         */
        reasonActivity = activity.dayReason ?? ""
        commentActivity = activity.description_ ?? ""
    }
    
    func onSelectionCycleDone(_ selected: [String]) {
        isSheetCycle = false
        if let itemCycle = CycleDao(realm: try! Realm()).by(id: idsCycle[0]){
            cycle = itemCycle.displayName
            print(itemCycle.id)
        }
    }
}

struct AssistantsActivityFormView: View{
    
    @Binding var activity: Activity
    
    @ObservedObject private var selectPanelModalToggle = ModalToggle()
    @State private var cardShow = false
    @State private var type = ""
    @State private var items = [Panel & SyncEntity]()
    
    @State private var slDefault = [String]()
    @State private var slDoctors = [String]()
    @State private var slPharmacies = [String]()
    @State private var slClients = [String]()
    @State private var slPatients = [String]()
    
    var body: some View {
        let selected = [
            "M": BindingWrapper(binding: $slDoctors),
            "F": BindingWrapper(binding: $slPharmacies),
            "C": BindingWrapper(binding: $slClients),
            "P": BindingWrapper(binding: $slPatients)
        ]
        ZStack{
            VStack{
                List {
                    ForEach(items, id: \.objectId) { item in
                        HStack(alignment: .center, spacing: 10){
                            switch item.type {
                                case "M":
                                    Image("ic-medic")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 27)
                                        .foregroundColor(Color.cPanelMedic)
                                case "F":
                                    Image("ic-pharmacy")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 27)
                                        .foregroundColor(Color.cPanelPharmacy)
                                case "C":
                                    Image("ic-client")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 27)
                                        .foregroundColor(Color.cPanelClient)
                                case "P":
                                    Image("ic-patient")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 27)
                                        .foregroundColor(Color.cPanelPatient)
                                default:
                                    Text("default")
                            }
                            PanelItem(panel: item)
                        }
                    }
                    .onDelete { (offsets: IndexSet) in
                        var its: Int = 0
                        var type: String = ""
                        offsets.forEach{ it in
                            type = items[it].type
                            its = items[it].id
                        }
                        selected[type]?.binding.removeAll(where: { $0 == String(its) })
                        self.items.remove(atOffsets: offsets)
                        activity.medics = slDoctors.joined(separator: ",")
                        activity.pharmacies = slPharmacies.joined(separator: ",")
                        activity.clients = slClients.joined(separator: ",")
                        activity.patients = slPatients.joined(separator: ",")
                    }
                }
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        print("plus raton")
                        cardShow.toggle()
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            if selectPanelModalToggle.status {
                GeometryReader {geo in
                    PanelDialogPicker(modalToggle: selectPanelModalToggle, selected: selected[self.type]?.$binding ?? $slDefault, type: self.type, multiple: true)
                }
                .background(Color.black.opacity(0.45))
                .onDisappear {
                    selected[self.type]?.binding.forEach{ it in
                        addPanelItems(type: self.type, it: it)
                    }
                }
            }
        }
        .partialSheet(isPresented: self.$cardShow) {
            PanelTypeMenu(onPanelSelected: onPanelSelected, panelTypes: ["M", "F", "C", "P"], isPresented: self.$cardShow)
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        print(activity)
        activity.medics?.split(separator: ",").forEach{ it in
            addPanelItems(type: "M", it: String(it))
            slDoctors.append(String(it))
        }
        activity.pharmacies?.split(separator: ",").forEach{ it in
            addPanelItems(type: "F", it: String(it))
            slPharmacies.append(String(it))
        }
        activity.clients?.split(separator: ",").forEach{ it in
            addPanelItems(type: "C", it: String(it))
            slClients.append(String(it))
        }
        activity.patients?.split(separator: ",").forEach{ it in
            addPanelItems(type: "P", it: String(it))
            slPatients.append(String(it))
        }
        
    }
    
    func addPanelItems(type: String, it: String){
        switch type {
        case "M":
            activity.medics = slDoctors.joined(separator: ",")
            if let doctor = DoctorDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it, type: type) {
                    items.append(doctor)
                }
            }
        case "F":
            activity.pharmacies = slPharmacies.joined(separator: ",")
            if let pharmacy = PharmacyDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it, type: type) {
                    items.append(pharmacy)
                }
            }
        case "C":
            activity.clients = slClients.joined(separator: ",")
            if let client = ClientDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it, type: type) {
                    items.append(client)
                }
            }
        case "P":
            activity.patients = slPatients.joined(separator: ",")
            if let patient = PatientDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it, type: type) {
                    items.append(patient)
                }
            }
        default:
            break
        }
    }
    
    func validate(items: [Panel & SyncEntity], it: String, type: String) -> Bool {
        var exists: Bool = false
        items.forEach{ i in
            if String(i.id) == it && i.type == type{
                exists = true
            }
        }
        return exists
    }
    
    func onPanelSelected(_ type: String) {
        self.cardShow.toggle()
        self.type = type
        selectPanelModalToggle.status.toggle()
    }
}
