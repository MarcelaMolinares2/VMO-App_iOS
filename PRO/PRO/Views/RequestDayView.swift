//
//  RequestDayView.swift
//  PRO
//
//  Created by VMO on 30/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

struct RequestDayView: View {
    
    @State private var cycles: [Cycle] = [Cycle]()
    @State private var reasons: [FreeDayReason] = [FreeDayReason]()
    @State private var selectedReason = -1
    @State private var dateStart = Date()
    @State private var dateEnd = Date()
    @State private var noDays = "1"
    @State var percentageValue = Double(4)
    @State private var comment = ""
    @State private var isValidationOn = false
    
    @State private var selectedCycle = [String]()
    
    @ObservedObject var selectCycleModalToggle = ModalToggle()
    
    init() {
        //UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modRequestDays", icon: Image("ic-day-request"), color: Color.cPanelRequestDay)
                ZStack(alignment: .bottomTrailing) {
                    Form {
                        Button(action: {
                            selectCycleModalToggle.status.toggle()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("envCycle")
                                        .font(!selectedCycle.isEmpty ? .system(size: 14.0) : .none)
                                        .foregroundColor(!selectedCycle.isEmpty ? .cTextMedium : (isValidationOn ? .cDanger : .cTextHigh))
                                    if !selectedCycle.isEmpty {
                                        Text(cycles.filter { $0.id == Utils.castInt(value: selectedCycle[0]) }[0].displayName)
                                            .foregroundColor(.cTextHigh)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                Image("ic-arrow-right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .foregroundColor(.cAccent)
                            }
                        }
                        DatePicker("envDateStart", selection: $dateStart, displayedComponents: .date)
                            .foregroundColor(.cTextHigh)
                        DatePicker("envDateEnd", selection: $dateEnd, displayedComponents: .date)
                            .foregroundColor(.cTextHigh)
                        VStack {
                            Text("envNoRequestedDays")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(isValidationOn && noDays.isEmpty ? .cDanger : .cTextHigh)
                            TextField("envNoDays", text: $noDays)
                                .frame(minHeight: 38.0)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .autocapitalization(.none)
                        }
                        VStack {
                            Text(NSLocalizedString("envRequestedDayPercentage", comment: "") + " (\(Int(percentageValue * 25))%)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(isValidationOn && percentageValue <= 0 ? .cDanger : .cTextHigh)
                            Slider(value: $percentageValue, in: 0.0...4, step: 1)
                        }
                        Picker(selection: $selectedReason, label: Text("envDayRequestReason")) {
                            ForEach(0 ..< reasons.count) {
                                Text(self.reasons[$0].content ?? "").tag(self.reasons[$0].id)
                            }
                        }
                        .foregroundColor(isValidationOn && selectedReason == -1 ? .cDanger : .cTextHigh)
                        VStack {
                            Text("envComment")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TextEditor(text: $comment)
                                .border(Color.cAccent, width: 1)
                                .cornerRadius(4)
                        }
                    }
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        if validate() {
                            save()
                        }
                    }
                }
            }
            if selectCycleModalToggle.status {
                GeometryReader {geo in
                    CustomDialogPicker(onSelectionDone: onSelectionDone, selected: $selectedCycle, key: "CYCLE")
                }
                .background(Color.black.opacity(0.45))
            }
        }
        .onAppear {
            load()
        }
    }
    
    func load() {
        let realm = try! Realm()
        cycles = Array(realm.objects(Cycle.self).sorted(byKeyPath: "cycle"))
        reasons = Array(realm.objects(FreeDayReason.self).sorted(byKeyPath: "content"))
        print(reasons)
    }
    
    func validate() -> Bool {
        isValidationOn = true
        if selectedCycle.isEmpty || selectedReason < 0 || percentageValue <= 0 || noDays.isEmpty {
            return false
        }
        return true
    }
    
    func save() {
        let dayRequest = RequestDay()
        dayRequest.cycleId = Utils.castInt(value: selectedCycle[0])
        dayRequest.reason = reasons[selectedReason].content
        dayRequest.dateStart = dateStart
        dayRequest.dateEnd = dateEnd
    }
    
    func onSelectionDone(_ selected: [String]) {
        selectCycleModalToggle.status.toggle()
    }
}

struct RequestDayView_Previews: PreviewProvider {
    static var previews: some View {
        RequestDayView()
    }
}
