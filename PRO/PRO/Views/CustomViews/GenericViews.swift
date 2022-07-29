//
//  GenericViews.swift
//  PRO
//
//  Created by VMO on 1/12/20.
//  Copyright © 2020 VMO. All rights reserved.
//

import RealmSwift
import SwiftUI
import Lottie

struct PanelListView: View {
    @State var data: Array<Panel & SyncEntity>
    @Binding var searchText: String

    var body: some View {
        let realm = try! Realm()
        ZStack(alignment: .trailing) {
            Text("Total en panel: \(data.count)")
                .foregroundColor(.cTextMedium)
                .font(.system(size: 12))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            Button(action: {
                
            }) {
                Text("Filtros")
                    .font(.system(size: 13))
                    .foregroundColor(.cTextLink)
                    .padding(.horizontal, 10)
            }
        }
        ScrollView {
            LazyVStack {
                ForEach(data.filter {
                    self.searchText.isEmpty ? true :
                        ($0.name ?? "").lowercased().contains(self.searchText.lowercased()) ||
                    ($0.cityName(realm: realm) ).lowercased().contains(self.searchText.lowercased())
                }, id: \.id) { element in
                    
                }
            }
        }
    }
}

struct PanelItemDoctorOld: View {
    let realm: Realm
    let userId: Int
    var doctor: Doctor
    
    @State var menuIsPresented = false
    
    var body: some View {
        PanelItem(realm: realm, userId: userId, panel: doctor, subtitle: SpecialtyDao(realm: realm).by(id: doctor.specialtyId)?.name ?? "", complement: doctor.institution ?? "") {
            menuIsPresented = true
        }
            .partialSheet(isPresented: $menuIsPresented) {
                PanelMenu(isPresented: self.$menuIsPresented, panel: doctor)
            }
    }
    
}

struct PanelItemDoctor: View {
    let realm: Realm
    let userId: Int
    var doctor: Doctor
    let onItemTapped: () -> Void
    
    var body: some View {
        PanelItem(realm: realm, userId: userId, panel: doctor, subtitle: SpecialtyDao(realm: realm).by(id: doctor.specialtyId)?.name ?? "", complement: doctor.institution ?? "", onItemTapped: onItemTapped)
            .onTapGesture {
                onItemTapped()
            }
    }
    
}

struct PanelItem: View {
    let realm: Realm
    let userId: Int
    var panel: Panel & SyncEntity
    var subtitle = ""
    var complement = ""
    let onItemTapped: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    Text(panel.name?.capitalized ?? " -- ")
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .foregroundColor(.cTextHigh)
                    Text(subtitle.isEmpty ? "--" : subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.cTextMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    let mainLocation = panel.mainLocation()
                    Text("\(mainLocation?.address ?? ""), \(CityDao(realm: realm).by(id: mainLocation?.cityId)?.name ?? " -- ")")
                        .font(.system(size: 14))
                        .foregroundColor(.cTextMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                    if !complement.isEmpty {
                        Text(complement)
                            .font(.system(size: 14))
                            .foregroundColor(.cTextMedium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .trailing, spacing: 2) {
                    VStack {
                        Text(panel.mainCategory(realm: realm, defaultValue: "--"))
                            .padding(.horizontal, 5)
                            .font(.system(size: 14))
                            .foregroundColor(.cTextMedium)
                            .frame(height: 20)
                    }
                    .frame(minWidth: 30)
                    .background(Color.cBackground1dp)
                    if let user = panel.findUser(userId: userId) {
                        Text("\(user.visitsCycle)/\(user.visitsFee)")
                            .font(.system(size: 14))
                            .frame(width: 30, height: 20, alignment: .center)
                            .background(PanelUtils.visitsBackground(user: user))
                            .foregroundColor(.white)
                    } else {
                        Text("--/--")
                            .font(.system(size: 14))
                            .frame(width: 30, height: 20, alignment: .center)
                            .background(Color.cBackground3dp)
                            .foregroundColor(.white)
                    }
                }
                .frame(minWidth: 30)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            onItemTapped()
        }
    }
    
}

struct KeyInfoView: View {
    @State var panel: Panel!
    
    @State var headerColor = Color.cPrimary
    @State var headerIcon = "ic-home"
    
    var body: some View {
        VStack {
            HStack {
                Text(panel.name ?? "")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .foregroundColor(.white)
                Image(headerIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34, alignment: .center)
                    .padding(4)
            }
            .background(headerColor)
            .frame(maxWidth: .infinity)
            ScrollView {
                VStack {
                    
                }
            }
        }
    }
}

protocol CustomContainerView: View {
    associatedtype Content
    init(content: @escaping () -> Content)
}

extension CustomContainerView {
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.init(content: content)
    }
}

struct CustomForm<Content: View>: CustomContainerView {
    var content: () -> Content
    
    var body: some View {
        ScrollView {
            VStack(content: content).padding()
        }
        .background(Color.white.opacity(0))
    }
}

struct CustomSection<Content: View>: View {
    var title: String = ""
    var content: () -> Content
    
    init(_ title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack {
            if !title.isEmpty {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.cTextMedium)
            }
            VStack(content: content)
                .padding()
                .background(Color.cBackground1dp)
                .cornerRadius(5)
        }
        .padding(.top, 10)
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce
    var speed: CGFloat = 2
    
    var animationView = AnimationView()
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {}
}
