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

struct PanelItemPharmacy: View {
    let realm: Realm
    let userId: Int
    var pharmacy: Pharmacy
    let onItemTapped: () -> Void
    
    var body: some View {
        PanelItem(realm: realm, userId: userId, panel: pharmacy, subtitle: PharmacyChainDao(realm: realm).by(id: pharmacy.pharmacyChainId)?.name ?? "", complement: "", onItemTapped: onItemTapped)
            .onTapGesture {
                onItemTapped()
            }
    }
    
}

struct PanelItemClient: View {
    let realm: Realm
    let userId: Int
    var client: Client
    let onItemTapped: () -> Void
    
    var body: some View {
        PanelItem(realm: realm, userId: userId, panel: client, subtitle: "", complement: "", onItemTapped: onItemTapped)
            .onTapGesture {
                onItemTapped()
            }
    }
    
}

struct PanelItemPatient: View {
    let realm: Realm
    let userId: Int
    var patient: Patient
    let onItemTapped: () -> Void
    
    var body: some View {
        PanelItem(realm: realm, userId: userId, panel: patient, subtitle: "", complement: "", onItemTapped: onItemTapped)
            .onTapGesture {
                onItemTapped()
            }
    }
    
}

struct PanelItemPotential: View {
    let realm: Realm
    let userId: Int
    var potential: PotentialProfessional
    let onItemTapped: () -> Void
    
    var body: some View {
        PanelItem(realm: realm, userId: userId, panel: potential, subtitle: "", complement: "", onItemTapped: onItemTapped)
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

struct CustomCard<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack {
            VStack(content: content)
                .padding()
                .background(Color.cBackground1dp)
                .cornerRadius(5)
        }
        .padding(.top, 5)
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

struct ChipView: View {
    
    var chip: ChipItem
    
    var body: some View {
        HStack {
            if !chip.image.isEmpty {
                Image.init(systemName: chip.image).font(.title3)
                    .onTapGesture {
                        
                    }
            }
            Text(chip.label)
                .font(.system(size: 13))
                .lineLimit(1)
        }.padding(.all, 5)
            .foregroundColor(.cTextHigh)
            .background(Color.cUnselected)
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.cSelected, lineWidth: 1)
            )
    }
    
}

struct ChipsContainerView: View {
    
    @Binding var chips: [ChipItem]
    
    @State private var containerHeight = CGFloat(0)
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(chips, id: \.id) { chip in
                    ChipView(chip: chip)
                    .padding(.all, 5)
                    .alignmentGuide(.leading) { dimension in
                        if (abs(width - dimension.width) > geo.size.width) {
                            width = 0
                            height -= dimension.height
                        }
                        
                        let result = width
                        if chip.id == chips.last!.id {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { dimension in
                        let result = height
                        if chip.id == chips.last!.id {
                            height = 0
                            DispatchQueue.main.async {
                                containerHeight = result * -1
                            }
                        }
                        return result
                    }
                }
            }
        }
        .frame(height: containerHeight + 20)
    }
}

struct ScrollViewFABBottom: View {
    
    var height: CGFloat = 70
    
    var body: some View {
        VStack {
            
        }
        .frame(height: height)
    }
    
}

struct CustomHeaderButtonIconView: View {
    var label: String
    var icon: String = "ic-plus-circle"
    let onItemTapped: () -> Void
    
    var body: some View {
        Button(action: {
            onItemTapped()
        }) {
            ZStack(alignment: .center) {
                HStack {
                    Spacer()
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40, alignment: .center)
                        .foregroundColor(.cIcon)
                }
                VStack {
                    Text(label)
                        .foregroundColor(.cTextHigh)
                }
            }
        }
        .padding(.horizontal, Globals.UI_FORM_PADDING_HORIZONTAL)
    }
    
}
