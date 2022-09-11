//
//  WrapperView.swift
//  PRO
//
//  Created by VMO on 30/11/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import SwiftUI

struct WrapperView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    var body: some View {
        switch viewRouter.currentPage {
            case PanelUtils.formByPanelType(type: "C"):
                ClientFormView()
            case PanelUtils.formByPanelType(type: "F"):
                PharmacyFormView()
            case PanelUtils.formByPanelType(type: "M"):
                DoctorFormView()
            case PanelUtils.formByPanelType(type: "P"):
                PatientFormView()
            case PanelUtils.formByPanelType(type: "T"):
                PotentialFormView()
            case "ACTIVITIES-VIEW":
                ActivityListWrapperView()
            case "CLIENT-VIEW":
                ClientListWrapperView()
            case "DOCTOR-VIEW":
                DoctorListWrapperView()
            case "PHARMACY-VIEW":
                PharmacyListWrapperView()
            case "PATIENTS-VIEW":
                PatientListWrapperView()
            case "POTENTIAL-VIEW":
                PotentialListWrapperView()
            case "DTV-FORM":
                ActivityFormView()
            case "DTV-SUMMARY":
                ActivitySummaryView()
            case "DIARY-VIEW":
                DiaryFormView()
            case "MATERIAL-DELIVERY-VIEW":
                MaterialDeliveryView()
            case "MOVEMENT-FORM":
                MovementFormView()
            case "MOVEMENTS-VIEW":
                MovementsView()
            case "PANEL-CARD":
                PanelSummaryView(panel: viewRouter.panel(), defaultTab: viewRouter.option(key: "tab", default: "CARD"))
            case "REQUEST-MATERIAL-VIEW":
                MaterialRequestView()
            case "GROUPS-VIEW":
                RouteView()
            case "RECORD-EXPENSES-VIEW":
                RecordExpenseView()
            case "REQUEST-DAYS-VIEW":
                RequestDayView()
            case "REPORTS-VIEW":
                ReportsMenuView()
            case "SUPPORT-VIEW":
                SupportMainView()
            case "PANEL-GLOBAL-SEARCH-VIEW":
                PanelGlobalSearchView()
            default:
                Text(viewRouter.currentPage)
        }
    }
}

struct WrapperView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView()
    }
}
