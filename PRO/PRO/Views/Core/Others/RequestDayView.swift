//
//  RequestDayView.swift
//  PRO
//
//  Created by VMO on 4/08/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift
import AlertToast
import SheeKit

class FreeDayRequestModel: ObservableObject, Identifiable {
    @Published var reasonId: Int = 0
    @Published var observations: String = ""
}

class FreeDayRequestDetailModel: ObservableObject, Identifiable {
    var date: Date = Date()
    @Published var dayFull: Bool = true
    @Published var dayOnlyAM: Bool = false
    @Published var dayOnlyPM: Bool = false
    @Published var dayCustom: Bool = false
    @Published var percentage: Float = 100
}

struct RequestDayView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var selected = [String]()
    @State private var freeDayRequestModel = FreeDayRequestModel()
    @State private var details = [FreeDayRequestDetailModel]()
    @State private var modalOpen = false
    @State private var modalReasonOpen = false
    @State private var showToast = false
    @State private var savedToast = false
    @State private var errorToast = ""
    
    @State private var reasonContent = NSLocalizedString("envChoose", comment: "Choose...")
    
    var realm = try! Realm()
    
    var body: some View {
        ZStack(alignment: .bottom)  {
            VStack {
                HeaderToggleView(title: "modRequestDay")
                VStack {
                    CustomCard {
                        Button(action: {
                            modalReasonOpen = true
                        }, label: {
                            HStack{
                                VStack{
                                    Text(NSLocalizedString("envDayRequestReason", comment: ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(freeDayRequestModel.reasonId <= 0 ? Color.cDanger : .cTextMedium)
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
                            .sheet(isPresented: $modalReasonOpen, content: {
                                DialogSourcePickerView(selected: $selected, key: "FREE-DAY-REASON", multiple: false, title: NSLocalizedString("envDayRequestReason", comment: "Reason for authorized day")) { selected in
                                    modalReasonOpen = false
                                    if !selected.isEmpty {
                                        freeDayRequestModel.reasonId = Utils.castInt(value: selected[0])
                                        let reason = FreeDayReasonDao(realm: realm).by(id: freeDayRequestModel.reasonId)
                                        reasonContent = reason?.content ?? NSLocalizedString("envChoose", comment: "")
                                    }
                                }
                            })
                            .padding(.vertical, 10)
                        })
                        Text("envObservations")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.cTextMedium)
                        TextField("envObservations", text: $freeDayRequestModel.observations)
                            .cornerRadius(CGFloat(4))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
                ScrollView {
                    ForEach($details.sorted(by: { $d1, $d2 in
                        d1.date < d2.date
                    })) { $detail in
                        VStack {
                            CustomCard {
                                HStack {
                                    Text(Utils.dateFormat(date: detail.date, format: "dd MMMM yyy"))
                                        .foregroundColor(.cTextHigh)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                    Button(action: {
                                        delete(detail: detail)
                                    }) {
                                        Image("ic-delete")
                                            .resizable()
                                            .foregroundColor(.cDanger)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 22, height: 22, alignment: .center)
                                            .padding(8)
                                    }
                                    .frame(width: 44, height: 44, alignment: .center)
                                }
                                RequestDayPercentageView(detail: detail)
                            }
                        }
                        .padding(.horizontal, Globals.UI_SC_PADDING_HORIZONTAL)
                    }
                    ScrollViewFABBottom()
                }
            }
            HStack {
                FAB(image: "ic-plus") {
                    modalOpen = true
                }
                Spacer()
                if !savedToast {
                    FAB(image: "ic-cloud") {
                        validate()
                    }
                }
            }
            .padding(.bottom, Globals.UI_FAB_VERTICAL)
            .padding(.horizontal, Globals.UI_FAB_HORIZONTAL)
        }
        .shee(isPresented: $modalOpen, presentationStyle: .formSheet(properties: .init(detents: [.medium()]))) {
            DialogDatePicker(onSelectionDone: onSelectionDone)
        }
        .toast(isPresenting: $showToast) {
            AlertToast(type: .error(.cError), title: NSLocalizedString(errorToast, comment: ""))
        }
        .toast(isPresenting: $savedToast) {
            AlertToast(type: .complete(.cDone), title: NSLocalizedString("envSuccessfullySaved", comment: ""))
        }
    }
    
    func validate() {
        if freeDayRequestModel.reasonId <= 0 {
            showToast = true
            errorToast = "errFormEmpty"
            return
        }
        if details.isEmpty {
            showToast = true
            errorToast = "errFreeDayRequestEmpty"
            return
        }
        save()
    }
    
    func save() {
        let freeDayRequest = FreeDayRequest()
        freeDayRequest.reasonId = freeDayRequestModel.reasonId
        freeDayRequest.observations = freeDayRequestModel.observations
        freeDayRequest.requestedAt = Utils.currentDateTime()
        details.forEach { d in
            let detail = FreeDayRequestDetail()
            detail.date = Utils.dateFormat(date: d.date)
            detail.dayFull = d.dayFull
            detail.dayOnlyAM = d.dayOnlyAM
            detail.dayOnlyPM = d.dayOnlyPM
            detail.dayCustom = d.dayCustom
            detail.percentage = d.percentage
            freeDayRequest.details.append(detail)
        }
        freeDayRequest.transactionType = "CREATE"
        FreeDayRequestDao(realm: realm).store(freeDayRequest: freeDayRequest)
        goTo(page: "MASTER")
    }
    
    func goTo(page: String) {
        savedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Globals.ENV_SAVE_DELAY) {
            viewRouter.currentPage = page
        }
    }
    
    func delete(detail: FreeDayRequestDetailModel) {
        details = details.filter { $0.date != detail.date }
    }
    
    func onSelectionDone(_ selected: Date) {
        print(selected)
        modalOpen = false
        if details.filter({ d in
            Utils.dateFormat(date: d.date) == Utils.dateFormat(date: selected)
        }).count <= 0 {
            let detail = FreeDayRequestDetailModel()
            detail.date = selected
            details.append(detail)
        }
    }
}

struct RequestDayPercentageView: View {
    @ObservedObject var detail: FreeDayRequestDetailModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    detail.dayFull = true
                    detail.dayOnlyAM = false
                    detail.dayOnlyPM = false
                    detail.dayCustom = false
                    detail.percentage = 100
                }) {
                    Text("envAllDay")
                        .frame(minWidth: 50, minHeight: 34.0)
                        .padding(.horizontal, 5)
                        .foregroundColor(detail.dayFull ? .cTextHigh : .cTextMedium)
                        .cornerRadius(5.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .foregroundColor(detail.dayFull ? .cSelected : .cUnselected)
                        )
                }
                Spacer()
                HStack {
                    Button(action: {
                        detail.dayFull = false
                        detail.dayOnlyAM = true
                        detail.dayOnlyPM = false
                        detail.dayCustom = false
                        detail.percentage = 50
                    }) {
                        Text("envTimeAM")
                            .frame(minWidth: 50, minHeight: 34.0)
                            .padding(.horizontal, 5)
                            .foregroundColor(detail.dayOnlyAM ? .cTextHigh : .cTextMedium)
                            .cornerRadius(5.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5.0)
                                    .foregroundColor(detail.dayOnlyAM ? .cSelected : .cUnselected)
                            )
                    }
                    Button(action: {
                        detail.dayFull = false
                        detail.dayOnlyAM = false
                        detail.dayOnlyPM = true
                        detail.dayCustom = false
                        detail.percentage = 50
                    }) {
                        Text("envTimePM")
                            .frame(minWidth: 50, minHeight: 34.0)
                            .padding(.horizontal, 5)
                            .foregroundColor(detail.dayOnlyPM ? .cTextHigh : .cTextMedium)
                            .cornerRadius(5.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5.0)
                                    .foregroundColor(detail.dayOnlyPM ? .cSelected : .cUnselected)
                            )
                    }
                }
                Spacer()
                Button(action: {
                    detail.dayFull = false
                    detail.dayOnlyAM = false
                    detail.dayOnlyPM = false
                    detail.dayCustom = true
                }) {
                    Text("%")
                        .frame(minWidth: 50, minHeight: 34.0)
                        .padding(.horizontal, 5)
                        .foregroundColor(detail.dayCustom ? .cTextHigh : .cTextMedium)
                        .cornerRadius(5.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .foregroundColor(detail.dayCustom ? .cSelected : .cUnselected)
                        )
                }
            }
            if detail.dayCustom {
                HStack {
                    Slider(
                        value: $detail.percentage,
                        in: 0...100
                    )
                    Text("\(Int(detail.percentage)) %")
                        .foregroundColor(.cTextMedium)
                        .frame(width: 50, alignment: .center)
                }
                .padding(.top, 10)
            }
        }
    }
    
}
