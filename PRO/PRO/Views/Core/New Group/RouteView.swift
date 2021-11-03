//
//  RouteView.swift
//  PRO
//
//  Created by Fernando Garcia on 28/10/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI

struct RouteView: View {
    @ObservedObject private var moduleRouter = ModuleRouter()
    var body: some View {
        switch moduleRouter.currentPage {
        case "LIST":
            RouteListView(moduleRouter: moduleRouter)
        case "FORM":
            RouteFormView(moduleRouter: moduleRouter)
        default:
            Text("")
        }
    }
}

struct RouteListView: View {
    
    @ObservedObject var moduleRouter: ModuleRouter
    
    /*
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    */
    
    var body: some View {
        ZStack {
            VStack{
                HeaderToggleView(couldSearch: true, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        moduleRouter.currentPage = "FORM"
                    }
                }
            }
        }
        .onAppear{
            loadData()
        }
    }
    
    func loadData(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
}

struct RouteFormView: View {
    
    
    @ObservedObject var moduleRouter: ModuleRouter
    @State private var name = ""
    @State private var items = [Panel & SyncEntity]()
    @State private var isValidationOn = false
    @State private var cardShow = false
    @State private var cardDimissal  = false
    
    /*
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    */
    
    /*
    Text("envName")
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(isValidationOn && name.isEmpty ? .cDanger : .cTextHigh)
    */
    
    var body: some View {
        ZStack {
            VStack {
                HeaderToggleView(couldSearch: false, title: "modPeopleRoute", icon: Image("ic-people-route"), color: Color.cPanelRequestDay)
                VStack{
                    TextField(NSLocalizedString("envName", comment: ""), text: $name)
                    Divider()
                     .frame(height: 1)
                     .padding(.horizontal, 5)
                     .background(Color.gray)
                }.padding(10)
                /*
                Button(action: {
                    print("jajaaj")
                    cardShow.toggle()
                    cardDimissal.toggle()
                }) {
                    HStack(alignment: .center){
                        Text("addRouters")
                        Image("ic-plus-circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                    }
                }
                .animation(.default)
                .padding(10)
                .background(Color(red: 100, green: 100, blue: 100))
                .frame(alignment: Alignment.center)
                .cornerRadius(8)
                .clipped()
                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                .foregroundColor(.cPrimaryLight)
                */
                
                ScrollView {
                    LazyVStack {
                        ForEach(items, id: \.id) { element in
                            PanelItem(panel: element)
                        }
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FAB(image: "ic-cloud", foregroundColor: .cPrimary) {
                        if validate() {
                            save()
                        }
                        moduleRouter.currentPage = "LIST"
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    FAB(image: "ic-plus", foregroundColor: .cPrimary) {
                        cardShow.toggle()
                        cardDimissal.toggle()
                        print(UIScreen.main.bounds.width)
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            
            BottomCard(cardShow: $cardShow, cardDimissal: $cardDimissal, height: UIScreen.main.bounds.height / 2.2){
                CardContent()
                    //.padding()
            }
        }
        .onAppear{
            loadData()
        }
    }
    
    func loadData(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    func validate() -> Bool {
        isValidationOn = true
        if items.isEmpty {
            return false
        }
        return true
    }
    
    func save() {
        
    }
    
}

struct Item: Identifiable {
    var id: String
    var label: String
    var isOn: Bool {
        didSet {
            // Added to show that state is being modified
            print("\(label) just toggled")
        }
    }
}

class Service: ObservableObject {
    @Published var items: [Item]

    init() {
        self.items = [
            Item(id: "0", label: "Zero", isOn: false),
            Item(id: "1", label: "One", isOn: true),
            Item(id: "2", label: "Two", isOn: false),
            Item(id: "3", label: "tree", isOn: false),
            Item(id: "0", label: "Zero", isOn: false),
            Item(id: "1", label: "One", isOn: true),
            Item(id: "2", label: "Two", isOn: false),
            Item(id: "3", label: "tree", isOn: false)
        ]
    }
}

struct CardContent: View {
    //let data = (1...4).map {datos.init(name: "fdfd", imagen: "gggg")}
    //@State private var array: [datos] = []
    @ObservedObject var service: Service = Service()
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View{
        VStack{
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(service.items.indices, id: \.self) { index in
                        Text(self.service.items[index].label)
                            .padding(.horizontal)
                    }
                }
                Text("Photo collage")
                    .bold()
                    .font(.system(size: 30))
                    .padding()
                Text("You can create asome grid with yours firends!")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                Image("ic-plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            
            //.frame(maxHeight: 300)
        }
        .frame(width: UIScreen.main.bounds.width)
    }
}

struct BottomCard<Content: View>: View {
    let content:Content
    @Binding var cardShow: Bool
    @Binding var cardDimissal: Bool
    let height: CGFloat
    
    init(cardShow: Binding<Bool>,
         cardDimissal: Binding<Bool>,
         height: CGFloat,
        @ViewBuilder content: () -> Content
    ){
        self.height = height
        _cardShow = cardShow
        _cardDimissal = cardDimissal
        self.content = content()
    }
    
    @State private var topLeft: CGFloat = 20
    @State private var topRight: CGFloat = 20
    
    var body: some View {
        ZStack{
            //Dimis
            
            GeometryReader{ _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.4))
            .opacity(cardShow ? 1 :0)
            .animation(Animation/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/)
            .onTapGesture {
                //Dismiss
                cardShow.toggle()
                cardDimissal.toggle()
            }
            
            //card
            VStack{
                Spacer()
                VStack{
                    content
                    /*
                    Button(action: {
                        cardShow.toggle()
                        cardDimissal.toggle()
                    }, label: {
                        Text("Dismiss")
                            .foregroundColor(Color.white)
                            .background(Color.pink)
                            .frame(width: 200, height: 50)
                            .cornerRadius(8)
                    })
                    */
                    Spacer()
                        .frame(height: 50)
                }
                //.background(Color.white)
                .background(RoundedCorners(color: Color.white, tl: 15, tr: 15, bl: 0, br: 0))
                .clipped()
                .shadow(color: Color.red, radius: 10, x: 0, y: 0)
                .foregroundColor(.cPrimaryLight)

                //.frame(height: height, maxWidth: .infinity)
                .frame(width: UIScreen.main.bounds.width, height: height)
                .offset(y: cardDimissal && cardShow ? 0 : height)
                .animation(Animation.default.delay(0.2))
                //.cornerRadius(topLeft, corners: .topLeft)
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                let w = geometry.size.width
                let h = geometry.size.height

                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
                
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                path.closeSubpath()
            }
            .fill(self.color)
        }
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView()
    }
}
