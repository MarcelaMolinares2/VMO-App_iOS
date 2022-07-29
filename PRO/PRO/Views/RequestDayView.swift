//
//  RequestDayView.swift
//  PRO
//
//  Created by VMO on 30/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast

struct RequestDayView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var dateStart = Date()
    @State private var dateEnd = Date()
    
    @State private var noDays = "1"
    
    @State var percentageValue = Double(100)
    @State private var comment = ""
    
    @State private var isSheetCycle = false
    @State private var idsCycle = [String]()
    @State private var cycle = ""
    
    @State private var isSheetReason = false
    @State private var idsReason = [String]()
    @State private var reason = ""
    
    @State private var showToast = false
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(title: "modRequestDays")
                CustomForm {
                    CustomSection {
                        Button(action: {
                            isSheetCycle = true
                        }, label: {
                            HStack{
                                VStack{
                                    Text(NSLocalizedString("envCycle", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 14))
                                    Text((cycle == "") ? NSLocalizedString("envChoose", comment: "") : cycle)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                                Image("ic-arrow-expand-more")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .foregroundColor(.cTextHigh)
                            }
                            .sheet(isPresented: $isSheetCycle, content: {
                                CustomDialogPicker(onSelectionDone: onSelectionCycleDone, selected: $idsCycle, key: "CYCLE", multiple: false, isSheet: true)
                            })
                            .padding(10)
                        })
                    }
                    CustomSection {
                        HStack{
                            VStack{
                                Text(NSLocalizedString("envFrom", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                DatePicker("", selection: $dateStart, in: Date()..., displayedComponents: [.date])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .clipped()
                                    .accentColor(.cTextHigh)
                                    .background(Color.white)
                                    .onChange(of: dateStart, perform: { value in
                                        if dateStart >= dateEnd {
                                            dateEnd = dateStart
                                            noDays = String(Calendar.current.dateComponents([.day], from: dateStart, to: dateEnd).day! + 1)
                                        }
                                    })
                            }
                            .padding(10)
                            Spacer()
                            Image("ic-day-request")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                                .foregroundColor(.cTextHigh)
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
                                    .foregroundColor(.cTextHigh)
                                    .font(.system(size: 14))
                                DatePicker("", selection: $dateEnd, in: Date()..., displayedComponents: [.date])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .clipped()
                                    .accentColor(.cTextHigh)
                                    .background(Color.white)
                                    .onChange(of: dateEnd, perform: { value in
                                        if dateStart >= dateEnd {
                                            dateEnd = dateStart
                                            noDays = String(Calendar.current.dateComponents([.day], from: dateStart, to: dateEnd).day! + 1)
                                        }
                                    })
                            }
                            .padding(10)
                            Spacer()
                            Image("ic-day-request")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                                .foregroundColor(.cTextHigh)
                                .padding(10)
                        }
                        .background(Color.white)
                        .frame(alignment: Alignment.center)
                        .clipped()
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        VStack {
                            Text("envNoRequestedDays")
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(noDays.isEmpty ? .cDanger : .cTextHigh)
                            TextField("envNoDays", text: $noDays)
                                .frame(minHeight: 38.0)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .autocapitalization(.none)
                                .disabled(true)
                        }
                    }
                    CustomSection {
                        VStack {
                            Text(String(format: NSLocalizedString("envRequestedDayPercentage", comment: ""), String(percentageValue)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.cTextHigh)
                                .font(.system(size: 14))
                            Slider(value: $percentageValue, in: 0.0...100, step: 10)
                        }
                        Button(action: {
                            isSheetReason = true
                        }, label: {
                            HStack{
                                VStack{
                                    Text(NSLocalizedString("envDayRequestReason", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor((reason == "") ? .cDanger : .cTextHigh)
                                        .font(.system(size: 14))
                                    Text((reason != "") ? reason: NSLocalizedString("envChoose", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.cTextHigh)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                                Image("ic-arrow-expand-more")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                                    .foregroundColor(.cTextHigh)
                            }
                            .sheet(isPresented: $isSheetReason, content: {
                                CustomDialogPicker(onSelectionDone: onSelectionReasonDone, selected: $idsReason, key: "STYLE", multiple: false, isSheet: true)
                            })
                            .padding(10)
                            .background(Color.white)
                            .frame(alignment: Alignment.center)
                            .clipped()
                            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        })
                        VStack {
                            Text(NSLocalizedString("envComment", comment: ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor((comment == "") ? .cDanger : .cTextHigh)
                                .font(.system(size: 14))
                            VStack{
                                TextEditor(text: $comment)
                                    .frame(height: 80)
                            }
                            .background(Color.white)
                            .frame(alignment: Alignment.center)
                            .clipped()
                            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        }
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud") {
                        if validate() {
                            save()
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $showToast) {
            AlertToast(type: .regular, title: NSLocalizedString("envRequireItems", comment: ""))
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        if let itemCycle = CycleDao(realm: try! Realm()).by(id: "1"){
            cycle = itemCycle.displayName
            idsCycle.append(String(itemCycle.id))
        }
    }
    
    func validate() -> Bool {
        if idsCycle.isEmpty || idsReason.isEmpty || reason.isEmpty || percentageValue <= 0 || noDays.isEmpty || comment.isEmpty{
            self.showToast.toggle()
            return false
        }
        return true
    }
    
    func save() {
        let dayRequest = RequestDay()
        dayRequest.dateStart = dateStart
        dayRequest.dateEnd = dateEnd
        dayRequest.days = Float(noDays) ?? 0
        dayRequest.percentage = Float(percentageValue)
        dayRequest.reason = reason
        dayRequest.comment = comment
        dayRequest.cycleId = Utils.castInt(value: idsCycle[0])
        RequestDayDao(realm: try! Realm()).store(request: dayRequest)
        self.goTo(page: "MASTER")
    }
    
    func goTo(page: String) {
        viewRouter.currentPage = page
    }
    
    func onSelectionCycleDone(_ selected: [String]) {
        isSheetCycle = false
        if let itemCycle = CycleDao(realm: try! Realm()).by(id: idsCycle[0]){
            cycle = itemCycle.displayName
        }
    }
    
    func onSelectionReasonDone(_ selected: [String]) {
        isSheetReason = false
        if let itemReason = FreeDayReasonDao(realm: try! Realm()).by(id: idsReason[0]){
            reason = itemReason.content ?? ""
        }
    }
}

struct RequestDayView_Previews: PreviewProvider {
    static var previews: some View {
        RequestDayView()
    }
}
