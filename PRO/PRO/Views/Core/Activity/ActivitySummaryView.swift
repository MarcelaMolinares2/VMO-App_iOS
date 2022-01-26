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

struct ActivitySummaryView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var activity: Activity = Activity()
    
    @State var viewForms = false
    @State var waitLoad = false
    
    @State private var totalHeight = CGFloat(100)

    
    var body: some View {
        ZStack{
            VStack {
                HeaderToggleView(couldSearch: false, title: "modSummaryActivity", icon: Image("ic-activity"), color: Color.cPanelActivity)
                
                if waitLoad {
                    if !viewForms {
                        ActivityMapSummaryView(activity: activity)
                    } else {
                        ActivityListSummaryView(activity: activity)
                    }
                }
                
                GeometryReader { geometry in
                    HStack{
                        VStack {
                            Image("ic-signature-paper")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(5)
                                .frame(width: geometry.size.height / 1.7, alignment: .center)
                                .foregroundColor(viewForms ? .cAccent : .cPrimary)
                                .onTapGesture {
                                    viewForms = false
                                }
                        }
                        .frame(width: geometry.size.width / 2)
                        VStack {
                            Image("ic-client")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(5)
                                .frame(width: geometry.size.height / 1.7, alignment: .center)
                                .foregroundColor(viewForms ? .cPrimary : .cAccent)
                                .onTapGesture {
                                    viewForms = true
                                }
                        }
                        .frame(width: geometry.size.width / 2)
                    }
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.bottom)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 46)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-edit", foregroundColor: .cPrimary) {
                        FormEntity(objectId: activity.objectId.stringValue).go(path: "DTV-FORM", router: viewRouter)
                        print("Edit")
                    }
                }
            }
            .padding([.bottom], 56)
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        if !viewRouter.data.objectId.isEmpty {
            if let activityItem = try? ActivityDao(realm: try! Realm()).by(objectId: ObjectId(string: viewRouter.data.objectId)) {
                activity = Activity(value: activityItem)
            }
        }
        print(activity)
        waitLoad = true
    }
}

struct ActivityMapSummaryView: View {
    
    @State var activity: Activity
    
    @State private var bottomSheetPosition: BottomSheetPosition = .middle
    
    @State private var dateStart : Date = Date()
    @State private var dateEnd : Date = Date()
    
    @State private var commentActivity = ""
    
    var body: some View {
        
        VStack{
            GoogleMapsView()
                .edgesIgnoringSafeArea(.all)
                //.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .bottomSheet(
                    bottomSheetPosition: self.$bottomSheetPosition,
                    options: [.noBottomPosition, .background(AnyView(Color.white))],
                    content: {
                        VStack {
                            Text(NSLocalizedString("envComment", comment: ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextMedium)
                                .font(.system(size: 14))

                            Text(commentActivity)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cPrimaryLight)
                                .font(.system(size: 16))
                                .padding(1)
                            HStack{
                                VStack{
                                    Text(NSLocalizedString("envFrom", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextMedium)
                                        .font(.system(size: 14))
                                    DatePicker("", selection: $dateStart, in: dateStart..., displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .labelsHidden()
                                        .clipped()
                                        .accentColor(.cTextHigh)
                                        //.background(Color.white)
                                        .disabled(true)
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
                                    DatePicker("", selection: $dateEnd, in: dateEnd..., displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .labelsHidden()
                                        .clipped()
                                        .accentColor(.cTextHigh)
                                        //.background(Color.white)
                                        .disabled(true)
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
                        .padding(10)
                        /*
                        ScrollView {
                            VStack {
                                Text(NSLocalizedString("envComment", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextMedium)
                                    .font(.system(size: 14))

                                Text(commentActivity)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cPrimaryLight)
                                    .font(.system(size: 16))
                                    .padding(1)
                                HStack{
                                    VStack{
                                        Text(NSLocalizedString("envFrom", comment: ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.cTextMedium)
                                            .font(.system(size: 14))
                                        DatePicker("", selection: $dateStart, in: dateStart..., displayedComponents: [.date, .hourAndMinute])
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .labelsHidden()
                                            .clipped()
                                            .accentColor(.cTextHigh)
                                            //.background(Color.white)
                                            .disabled(true)
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
                                        DatePicker("", selection: $dateEnd, in: dateEnd..., displayedComponents: [.date, .hourAndMinute])
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .labelsHidden()
                                            .clipped()
                                            .accentColor(.cTextHigh)
                                            //.background(Color.white)
                                            .disabled(true)
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
                            .padding(10)
                        }
                        */
                    }
                )
            /*
            Text(NSLocalizedString("envComment", comment: ""))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.cTextMedium)
                .font(.system(size: 14))

            Text(commentActivity)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.cPrimaryLight)
                .font(.system(size: 16))
                .padding(1)
            
            VStack {
                HStack{
                    VStack{
                        Text(NSLocalizedString("envFrom", comment: ""))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextMedium)
                            .font(.system(size: 14))
                        DatePicker("", selection: $dateStart, in: dateStart..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .clipped()
                            .accentColor(.cTextHigh)
                            .background(Color.white)
                            .disabled(true)
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
                        DatePicker("", selection: $dateEnd, in: dateEnd..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .clipped()
                            .accentColor(.cTextHigh)
                            .background(Color.white)
                            .disabled(true)
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
            */
        }
        .onAppear{
            load()
        }
    }
    
    func load() {
        if let date_MDY: String = activity.dateStart {
            if let date_HMS: String = activity.hourStart {
                dateStart = Utils.strToDate(value : date_MDY + " " + date_HMS)
            }
        }
        if let date_MDY: String = activity.dateEnd {
            if let date_HMS: String = activity.hourEnd {
                dateEnd = Utils.strToDate(value : date_MDY + " " + date_HMS)
            }
        }
        
        commentActivity = activity.description_ ?? ""
    }
    
    public enum BottomSheetPosition: CGFloat, CaseIterable {
        case middle = 0.4, bottom = 0.094, hidden = 0
    }
}

struct ActivityListSummaryView: View {
    
    @State var activity: Activity
    
    @State private var items = [Panel & SyncEntity]()
    
    
    @State private var slDefault = [String]()
    @State private var slDoctors = [String]()
    @State private var slPharmacies = [String]()
    @State private var slClients = [String]()
    @State private var slPatients = [String]()
    
    var body: some View {
        VStack{
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
            Spacer()
        }
        .padding(10)
        .onAppear {
            load()
        }
    }
    
    func load() {
        print(activity)
        activity.medics?.split(separator: ",").forEach{ it in
            addPanelItems(type: "M", it: String(it))
        }
        activity.pharmacies?.split(separator: ",").forEach{ it in
            addPanelItems(type: "F", it: String(it))
        }
        activity.clients?.split(separator: ",").forEach{ it in
            addPanelItems(type: "C", it: String(it))
        }
        activity.patients?.split(separator: ",").forEach{ it in
            addPanelItems(type: "P", it: String(it))
        }
        print(items)
    }
    
    func addPanelItems(type: String, it: String){
        switch type {
        case "M":
            if let doctor = DoctorDao(realm: try! Realm()).by(id: it){
                items.append(doctor)
            }
        case "F":
            if let pharmacy = PharmacyDao(realm: try! Realm()).by(id: it){
                items.append(pharmacy)
            }
        case "C":
            if let client = ClientDao(realm: try! Realm()).by(id: it){
                items.append(client)
            }
        case "P":
            if let patient = PatientDao(realm: try! Realm()).by(id: it){
                items.append(patient)
            }
        default:
            break
        }
    }
    
}

struct ActivitySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitySummaryView()
    }
}
