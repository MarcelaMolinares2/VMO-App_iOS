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

struct ActivityFormView: View {
    
    @State var viewForms = false
    
    var body: some View {
        ZStack{
            VStack{
                HeaderToggleView(couldSearch: false, title: "modDifferentToVisit", icon: Image("ic-activity"), color: Color.cPanelActivity)
                if !viewForms{
                    ViewBasicForm()
                } else {
                    ViewAssistantsSelector()
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
                                viewForms.toggle()
                            }
                        Image("ic-client")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(width: geometry.size.width / 2, alignment: .center)
                            .foregroundColor(viewForms ? .cPrimary : .cAccent)
                            .onTapGesture {
                                viewForms.toggle()
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
                        print("nube raton")
                    }
                }
            }
            .padding(.bottom, 56)
        }
    }
}

struct ViewBasicForm: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var tabRouter = TabRouter()
    @ObservedObject var locationService = LocationService()
    
    
    @State private var dynamicData = Utils.jsonDictionary(string: Config.get(key: "P_OTHER_FORM_ADDITIONAL").complement ?? "")
    @State private var form = DynamicForm(tabs: [DynamicFormTab]())
    @State private var options = DynamicFormFieldOptions(table: "movement", op: "")
    @State var mainTabs = [[String: Any]]()
    @State var bb = ""
    @State private var showDayAuth = false
    @State private var dateStart = Date()
    @State private var dateEnd = Date()
    @State var percentageValue = Double(100)
    
    var body: some View {
        VStack {
            VStack{
                Button(action: {
                    print("ffff")
                }, label: {
                    HStack{
                        VStack{
                            Text("Ciclo")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            Text("cccc")
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
                VStack{
                    HStack{
                        VStack{
                            Text("Desde")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            DatePicker("", selection: $dateStart, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .clipped()
                                .accentColor(.cTextHigh)
                                .background(Color.white)
                        }
                        Spacer()
                        Image("ic-day-request")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(10)
                    HStack{
                        VStack{
                            Text("Hasta")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))
                            DatePicker("", selection: $dateEnd, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .clipped()
                                .accentColor(.cTextHigh)
                                .background(Color.white)
                        }
                        Spacer()
                        Image("ic-day-request")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                            .foregroundColor(.cTextMedium)
                    }
                    .padding(10)
                }
                    .background(Color.white)
                    .frame(alignment: Alignment.center)
                    .clipped()
                    .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                TextField("escribir", text: $bb)
                    .cornerRadius(CGFloat(4))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(10)
            VStack{
                HStack{
                    Toggle(isOn: $showDayAuth){
                        Text("Solicitar dias autorizados")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextMedium)
                            .font(.system(size: 18))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .onChange(of: showDayAuth, perform: { value in
                        print(value)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: .cBlueDark))
                }
                if showDayAuth {
                    Text("Porcentaje del dia solicitado (Num)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 14))
                    Slider(value: $percentageValue, in: 0.0...100, step: 10)
                    Button(action: {
                        print("ffff")
                    }, label: {
                        HStack{
                            VStack{
                                Text("Motivo de dia autorizado")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))
                                Text("selecciona")
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
            ForEach(form.tabs, id: \.id) { tab in
                DynamicFormView(form: $form, tab: $form.tabs[0], options: options)
            }
            Spacer()
        }.onAppear{
            initView()
            //CICLO CYCLE
            //MOTIVO DIA AUTORIZADO PENDIENTE
        }
    }
    
    func initView(){
        form.tabs = DynamicUtils.initForm(data: dynamicData).sorted(by: { $0.key > $1.key })
    }
}

struct ViewAssistantsSelector: View{
    
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
                Text("jajaja")
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
    }
    
    func addPanelItems(type: String, it: String){
        switch type {
        case "M":
            if let doctor = DoctorDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it, type: type) {
                    items.append(doctor)
                }
            }
        case "F":
            if let pharmacy = PharmacyDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it, type: type) {
                    items.append(pharmacy)
                }
            }
        case "C":
            if let client = ClientDao(realm: try! Realm()).by(id: it){
                if !validate(items: items, it: it, type: type) {
                    items.append(client)
                }
            }
        case "P":
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
