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
        case "CLIENT-FORM":
            ClientFormView()
        case "MATERIAL-DELIVERY":
            MaterialDeliveryView()
        case "MATERIAL-REQUEST":
            MaterialRequestView()
        case "MEDIC-FORM":
            MedicFormView(viewRouter: viewRouter)
        case "MOVEMENT-FORM":
            MovementFormView(viewRouter: viewRouter)
        case "PANEL-CARD":
            PanelCardView(panel: viewRouter.panel(), defaultTab: viewRouter.option(key: "tab", default: "CARD"))
        case "REQUEST-DAY":
            RequestDayView()
        case "REQUEST-MATERIAL":
            MaterialRequestView()
        case "ROUTE-VIEW":
            RouteView()
        case "ROUTE-FORM":
            RouteFormView()
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
