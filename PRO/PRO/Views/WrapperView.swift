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
            case PanelUtils.formByPanelType(type: "M"):
                DoctorFormView()
            case "DTV-FORM":
                ActivityFormView()
            case "DTV-SUMMARY":
                ActivitySummaryView()
            case "MATERIAL-DELIVERY":
                MaterialDeliveryView()
            case "MATERIAL-REQUEST":
                MaterialRequestView()
            case "MOVEMENT-FORM":
                MovementFormView()
            case "PANEL-CARD":
                PanelCardView(panel: viewRouter.panel(), defaultTab: viewRouter.option(key: "tab", default: "CARD"))
            case "PATIENT-LIST":
                PatientListView()
            case PanelUtils.formByPanelType(type: "F"):
                PharmacyFormView()
            case PanelUtils.formByPanelType(type: "P"):
                PatientFormView()
            case "POTENTIAL-LIST":
                PotentialListView()
            case PanelUtils.formByPanelType(type: "T"):
                PotentialFormView()
            case "REQUEST-DAY":
                RequestDayView()
            case "REQUEST-MATERIAL":
                MaterialRequestView()
            case "ROUTE-VIEW":
                RouteView()
            /*
            case "ROUTE-FORM":
                RouteFormView()
            */
            case "SUPPORT":
                SupportView()
            default:
                Text("")
        }
    }
}

struct WrapperView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView()
    }
}
