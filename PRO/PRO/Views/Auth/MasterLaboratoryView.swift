//
//  MasterLaboratoryLoginView.swift
//  PRO
//
//  Created by VMO on 9/03/22.
//  Copyright © 2022 VMO. All rights reserved.
//

import SwiftUI

struct MasterLaboratoryView: View {
    
    @State var laboratories: [MasterLaboratory] = []
    @State var laboratory: MasterLaboratory? = nil
    
    var body: some View {
        VStack {
            if laboratory == nil {
                Text("envLaboratories")
                List(laboratories, id: \.id) { l in
                    Button(action: {
                        laboratory = l
                    }) {
                        Text(l.name)
                    }
                }
            } else {
                MasterLaboratoryUserView(laboratory: laboratory!) {
                    laboratory = nil
                }
            }
        }
        .onAppear {
            loadLabs()
        }
    }
    
    private func loadLabs() {
        MasterServer().getRequest(path: "master/bridge/laboratories") { success, code, data in
            if success {
                if let rs = data as? [String] {
                    for item in rs {
                        let object = Utils.jsonDictionary(string: item)
                        laboratories.append(try! MasterLaboratory(from: object))
                    }
                }
            }
        }
    }
}
