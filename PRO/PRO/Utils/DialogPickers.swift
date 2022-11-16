//
//  DialogPickers.swift
//  PRO
//
//  Created by VMO on 24/08/21.
//  Copyright © 2021 VMO. All rights reserved.
//

import SwiftUI
import RealmSwift

class ListGenericViewModel: ObservableObject {

    @Published var items: [GenericSelectableItem] = [GenericSelectableItem]()
    
    func put(list: [GenericSelectableItem]) {
        items = list
    }
    
    func toggle() {
        let tmp = items
        items = tmp
    }
    
    func clear() {
        items.indices.forEach { ix in
            items[ix].selected = false
        }
    }

}

class ListPanelViewModel: ObservableObject {

    @Published var items: [GenericSelectablePanelItem] = [GenericSelectablePanelItem]()
    
    func put(list: [GenericSelectablePanelItem]) {
        items = list
    }
    
    func toggle() {
        let tmp = items
        items = tmp
    }

}

struct DialogTimeRangePicker: View {
    @Binding var hourStart: Date
    @Binding var hourEnd: Date
    var minHour = Utils.strToDate(value: "00:00", format: "HH:mm")
    var maxHour = Utils.strToDate(value: "23:59", format: "HH:mm")
    let onSelectionDone: (_ selected: [Date]) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    onSelectionDone([hourStart, hourEnd])
                }) {
                    Text("envDone")
                        .foregroundColor(.cHighlighted)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            HStack {
                VStack {
                    Text("envFrom")
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    DatePicker("", selection: $hourStart, in: minHour...maxHour, displayedComponents: [.hourAndMinute])
                        .fixedSize()
                }
                VStack {
                    Text("envTo")
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    DatePicker("", selection: $hourEnd, in: hourStart...maxHour, displayedComponents: [.hourAndMinute])
                        .fixedSize()
                }
            }
        }
    }
    
}

struct DialogDatePicker: View {
    let onSelectionDone: (_ selected: Date) -> Void
    
    @State private var date = Date()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    onSelectionDone(date)
                }) {
                    Text("envDone")
                        .foregroundColor(.cHighlighted)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            ScrollView {
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
            }
        }
    }
    
}

struct DialogDateRangePicker: View {
    @Binding var selected: [String]
    let onSelectionDone: (_ selected: [String]) -> Void
    
    @State private var dateStart = Date()
    @State private var dateEnd = Date()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("envFrom")
                        .foregroundColor(.cTextMedium)
                    DatePicker("envFrom", selection: $dateStart, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }
                .padding(.top, 5)
                VStack {
                    Text("envTo")
                        .foregroundColor(.cTextMedium)
                    DatePicker("envTo", selection: $dateEnd, in: dateStart..., displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }
            }
            VStack {
                Button(action: {
                    self.done()
                }) {
                    Image("ic-done")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .foregroundColor(.cIcon)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
            }
            .frame(height: 40)
            .padding([.leading, .trailing], 10)
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        if !selected.isEmpty {
            if !selected[0].isEmpty {
                dateStart = Utils.strToDate(value: selected[0])
            }
        }
        if selected.count > 1 {
            if !selected[1].isEmpty {
                dateEnd = Utils.strToDate(value: selected[1])
            }
        }
    }
    
    func done() {
        selected = [Utils.dateFormat(date: dateStart), Utils.dateFormat(date: dateEnd)]
        onSelectionDone(selected)
    }
    
}

struct PanelDialogPicker: View {
    
    @ObservedObject var modalToggle: ModalToggle
    @Binding var selected: [String]
    var type: String = ""
    var multiple: Bool = false
    var skip: Bool = false
    
    @ObservedObject var viewModel = ListPanelViewModel()
    @State var searchText = ""
    let headerHeight = CGFloat(40)
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                HStack {
                    Button(action: {
                        self.modalToggle.status.toggle()
                    }) {
                        Image("ic-left-arrow")
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                    }
                    SearchBar(text: $searchText, placeholder: Text("Buscar")) {
                        
                    }
                }
                .frame(height: headerHeight)
                .padding([.leading, .trailing], 10)
                .background(Color.white)
                .zIndex(1)
                List {
                    Color
                        .clear
                        .frame(height: 30)
                    ForEach(viewModel.items.filter {
                        searchText.isEmpty ? true : ($0.panel.name ?? "").lowercased().contains(searchText.lowercased())
                    }, id: \.panel.id) { item in
                        ZStack {
                            if item.selected {
                                Color
                                    .cSelected
                                    .ignoresSafeArea()
                                    .cornerRadius(15)
                            }
                            /*PanelItem(panel: item.panel).onTapGesture {
                                self.onItemSelected(item: item)
                            }*/
                        }
                    }
                }
            }
            if multiple {
                VStack {
                    Button(action: {
                        self.done()
                    }) {
                        Image("ic-done")
                            .resizable()
                            .foregroundColor(.cTextHigh)
                            .scaledToFit()
                            .padding(5)
                    }
                }
                .frame(height: headerHeight)
                .padding([.leading, .trailing], 10)
                .background(Color.white)
                .zIndex(1)
            }
        }
        .background(Color.white)
        .padding(20)
        .clipped()
        .cornerRadius(20)
        .onAppear {
            self.load()
        }
    }
    
    func load() {
        var list = [Panel & SyncEntity]()
        switch type {
        case "M":
            list = DoctorDao(realm: try! Realm()).all()
        case "F":
            list = PharmacyDao(realm: try! Realm()).all()
        case "C":
            list = ClientDao(realm: try! Realm()).all()
        case "P":
            list = PatientDao(realm: try! Realm()).all()
        default:
            break
        }
        var cleanedList = [GenericSelectablePanelItem]()
        if skip {
            
        } else {
            cleanedList = list.map { GenericSelectablePanelItem(panel: $0) }
            for item in cleanedList {
                item.selected = selected.contains("\(item.panel.id)")
            }
        }
        viewModel.put(list: cleanedList)
    }
    
    func onItemSelected(item: GenericSelectablePanelItem) {
        item.selected = !item.selected
        viewModel.toggle()
        if !multiple {
            done()
        }
    }
    
    func done() {
        selected = viewModel.items.filter { item in item.selected }.map { "\($0.panel.id)" }
        modalToggle.status.toggle()
    }
    
}

struct GenericDialogItem: View {
    @Binding var item: GenericSelectableItem
    var alignment: Alignment
    var capitalized: Bool = true
    let onItemTapped: () -> Void
    
    var body: some View {
        Button(action: {
            self.onItemTapped()
        }) {
            ZStack {
                if item.selected {
                    Color
                        .cSelected
                        .ignoresSafeArea()
                        .cornerRadius(15)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: .infinity)
                }
                VStack(alignment: .leading) {
                    Text("\(capitalized ? item.label.capitalized : item.label)")
                        .foregroundColor(.cTextHigh)
                        .multilineTextAlignment(.leading)
                    if !item.complement.isEmpty {
                        Text("\(item.complement)")
                            .foregroundColor(.cTextMedium)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 5)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40)
        }
    }
    
}

struct GenericDialogItemOld: View {
    var item: GenericSelectableItem
    var alignment: Alignment
    var capitalized: Bool = true
    let onItemTapped: () -> Void
    
    var body: some View {
        Button(action: {
            self.onItemTapped()
        }) {
            ZStack {
                if item.selected {
                    Color
                        .cSelected
                        .ignoresSafeArea()
                        .cornerRadius(15)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: .infinity)
                }
                VStack(alignment: .leading) {
                    Text("\(capitalized ? item.label.capitalized : item.label)")
                        .foregroundColor(.cTextHigh)
                        .multilineTextAlignment(.leading)
                    if !item.complement.isEmpty {
                        Text("\(item.complement)")
                            .foregroundColor(.cTextMedium)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 5)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40)
        }
    }
    
}

struct DialogSortPickerView: View {
    var data: [String]
    
    @StateObject var viewModel = ListGenericViewModel()
    let onSelectionDone: (_ selected: SortModel) -> Void
    
    var body: some View {
        VStack {
            Text("envSortBy")
                .foregroundColor(.cTextMedium)
            ScrollView {
                VStack {
                    ForEach($viewModel.items) { $item in
                        GenericDialogItem(item: $item, alignment: .center) {
                            self.onItemSelected(item: item)
                        }
                    }
                }
            }
            HStack {
                Button(action: {
                    done(asc: false)
                }) {
                    Text("envDescending")
                        .foregroundColor(.cTextHigh)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                Button(action: {
                    done(asc: true)
                }) {
                    Text("envAscending")
                        .foregroundColor(.cTextHigh)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        viewModel.items = data.map { GenericSelectableItem(value: $0, label: TextUtils.serializeEnv(s: $0)) }
    }
    
    func onItemSelected(item: GenericSelectableItem) {
        for i in viewModel.items {
            i.selected = false
        }
        item.selected = !item.selected
        viewModel.toggle()
    }
    
    func done(asc: Bool) {
        let selected = viewModel.items.first { item in item.selected }
        onSelectionDone(SortModel(key: selected?.value ?? "", ascending: asc))
    }
    
}

struct DialogPlainPickerView: View {
    @Binding var selected: [String]
    var data: String = ""
    var multiple: Bool = false
    var title: String = ""
    let onSelectionDone: (_ selected: [String]) -> Void
    
    @StateObject var viewModel = ListGenericViewModel()
    @StateObject var headerRouter = TabRouter()
    @State var searchText = ""
    let headerHeight = CGFloat(40)
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: Text("\(NSLocalizedString("envSearch", comment: "Search")) \(title.lowercased())")) {
                
            }
            ScrollView {
                ForEach(viewModel.items.filter {
                    searchText.isEmpty ? true : $0.label.lowercased().contains(searchText.lowercased())
                }, id: \.id) { item in
                    GenericDialogItemOld(item: item, alignment: .leading) {
                        self.onItemSelected(item: item)
                    }
                }
            }
            if multiple {
                VStack {
                    Button(action: {
                        self.done()
                    }) {
                        Image("ic-done")
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                            .foregroundColor(.cIcon)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: headerHeight, maxHeight: headerHeight, alignment: .center)
                }
                .frame(height: headerHeight)
                .padding([.leading, .trailing], 10)
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        let list = Utils.genericList(data: data)
        list.indices.forEach { ix in
            if selected.contains(list[ix].value) {
                list[ix].selected = true
            }
        }
        viewModel.put(list: list)
    }
    
    func onItemSelected(item: GenericSelectableItem) {
        if !multiple {
            viewModel.clear()
        }
        item.selected = !item.selected
        viewModel.toggle()
        if !multiple {
            done()
        }
    }
    
    func done() {
        selected = viewModel.items.filter { item in item.selected }.map { $0.value }
        onSelectionDone(selected)
    }
    
}

struct DialogSourcePickerView: View {
    @Binding var selected: [String]
    var key: String = ""
    var multiple: Bool = false
    var title: String = ""
    var extraData: [String: Any] = [:]
    let onSelectionDone: (_ selected: [String]) -> Void
    
    @StateObject var viewModel = ListGenericViewModel()
    @StateObject var headerRouter = TabRouter()
    @State var searchText = ""
    @State private var capitalized = true
    let headerHeight = CGFloat(40)
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: Text("\(NSLocalizedString("envSearch", comment: "Search")) \(title.lowercased())")) {
                
            }
            ScrollView {
                ForEach(viewModel.items.filter {
                    searchText.isEmpty ? true : $0.label.lowercased().contains(searchText.lowercased())
                }, id: \.id) { item in
                    GenericDialogItemOld(item: item, alignment: .leading, capitalized: capitalized) {
                        self.onItemSelected(item: item)
                    }
                }
            }
            if multiple {
                VStack {
                    Button(action: {
                        self.done()
                    }) {
                        Image("ic-done")
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                            .foregroundColor(.cIcon)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: headerHeight, maxHeight: headerHeight, alignment: .center)
                }
                .frame(height: headerHeight)
                .padding([.leading, .trailing], 10)
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        var list: [GenericSelectableItem] = []
        switch key.uppercased() {
            case "BRICK":
                list = GenericSelectableDao(realm: try! Realm()).bricks()
            case "CATEGORY":
                capitalized = false
                list = GenericSelectableDao(realm: try! Realm()).categories(categoryType: Utils.castInt(value: extraData["categoryType"]))
            case "CITY":
                list = GenericSelectableDao(realm: try! Realm()).cities()
            case "COLLEGE":
                list = GenericSelectableDao(realm: try! Realm()).colleges()
            case "COMPANION":
                list = GenericSelectableDao(realm: try! Realm()).usersInverseHierarchy()
            case "COUNTRY":
                list = GenericSelectableDao(realm: try! Realm()).countries()
            case "CYCLE":
                list = GenericSelectableDao(realm: try! Realm()).cycles()
            case "EXPENSE-CONCEPT":
                list = GenericSelectableDao(realm: try! Realm()).expenseConcepts()
            case "FREE-DAY-REASON":
                list = GenericSelectableDao(realm: try! Realm()).freeDayReasons()
            case "LINE":
                list = GenericSelectableDao(realm: try! Realm()).lines()
            case "MATERIAL":
                list = GenericSelectableDao(realm: try! Realm()).materials()
            case "MATERIAL-PLAIN":
                list = GenericSelectableDao(realm: try! Realm()).materialsPlain()
            case "MOVEMENT-FAIL-REASON":
                list = GenericSelectableDao(realm: try! Realm()).movementFailReasons(panelType: Utils.castString(value: extraData["panelType"]))
            case "PANEL-DELETE-REASON":
                list = GenericSelectableDao(realm: try! Realm()).panelDeleteReasons(panelType: Utils.castString(value: extraData["panelType"]))
            case "PHARMACY-CHAIN":
                list = GenericSelectableDao(realm: try! Realm()).pharmacyChains()
            case "PHARMACY-TYPE":
                list = GenericSelectableDao(realm: try! Realm()).pharmacyTypes()
            case "PREDEFINED-COMMENT":
                list = GenericSelectableDao(realm: try! Realm()).predefinedComments(table: Utils.castString(value: extraData["table"]), field: Utils.castString(value: extraData["field"]))
            case "PRICES-LIST":
                list = GenericSelectableDao(realm: try! Realm()).pricesLists()
            case "PRODUCT-PROMOTED":
                list = GenericSelectableDao(realm: try! Realm()).productsPromoted(pharmacyChainId: Utils.castInt(value: extraData["pharmacyChain"]))
            case "PRODUCT", "PRODUCT-TRANSFERENCE", "PRODUCT-STOCK":
                list = GenericSelectableDao(realm: try! Realm()).products()
            case "PRODUCT-BY-BRAND":
                list = GenericSelectableDao(realm: try! Realm()).productBrands()
            case "PRODUCT-SHOPPING":
                list = GenericSelectableDao(realm: try! Realm()).productsWithCompetitors()
            case "SPECIALTY":
                list = GenericSelectableDao(realm: try! Realm()).specialties()
            case "SECOND-SPECIALTY":
                list = GenericSelectableDao(realm: try! Realm()).specialties(tp: "S")
            case "STYLE":
                list = GenericSelectableDao(realm: try! Realm()).styles()
            case "USER-HIERARCHY":
                list = GenericSelectableDao(realm: try! Realm()).usersHierarchy()
            case "ZONE":
                list = GenericSelectableDao(realm: try! Realm()).zones()
            default:
                break
        }
        list.indices.forEach { ix in
            if selected.contains(list[ix].value) {
                list[ix].selected = true
            }
        }
        viewModel.put(list: list)
    }
    
    func onItemSelected(item: GenericSelectableItem) {
        if !multiple {
            viewModel.clear()
        }
        item.selected = !item.selected
        viewModel.toggle()
        if !multiple {
            done()
        }
    }
    
    func done() {
        selected = viewModel.items.filter { item in item.selected }.map { $0.value }
        onSelectionDone(selected)
    }
}

struct DialogMonthPickerView: View {
    let onSelectionDone: (_ selected: Int) -> Void
    
    @State var months = TimeUtils.months()
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("envMonth")
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 14))
                Spacer()
                Button(action: {
                    onSelectionDone(0)
                }) {
                    Text("envClear")
                        .foregroundColor(.cHighlighted)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            LazyVGrid(columns: layout, spacing: 20) {
                ForEach(months) { month in
                    Button(action: {
                        onSelectionDone(month.value)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5.0)
                                .foregroundColor(.cBackground1dp)
                            Text(month.label)
                                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                                .font(.system(size: 14))
                                .foregroundColor(.cTextHigh)
                                .cornerRadius(5.0)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
}

struct DialogMonthDayPickerView: View {
    @Binding var month: Int
    let onSelectionDone: (_ selected: Int) -> Void
    
    @State var days = [GenericPickerItem]()
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("envDay")
                    .foregroundColor(.cTextHigh)
                    .font(.system(size: 14))
                Spacer()
                Button(action: {
                    onSelectionDone(0)
                }) {
                    Text("envClear")
                        .foregroundColor(.cHighlighted)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            LazyVGrid(columns: layout, spacing: 20) {
                ForEach(days) { day in
                    Button(action: {
                        onSelectionDone(day.value)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5.0)
                                .foregroundColor(.cBackground1dp)
                            Text(day.label)
                                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                                .font(.system(size: 14))
                                .foregroundColor(.cTextHigh)
                                .cornerRadius(5.0)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .onAppear {
            load()
        }
    }
    
    func load() {
        days = TimeUtils.monthDays(m: month)
    }
    
}

struct Drawing {
    var points: [CGPoint] = [CGPoint]()
}

struct CanvasShape: Shape {
    @Binding var drawings: [Drawing]
    @Binding var currentDrawing: Drawing
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        drawings.forEach { drawing in
            let points = drawing.points
            if !points.isEmpty {
                path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            }
            for point in points {
                path.addLine(to: CGPoint(x: point.x, y: point.y))
            }
        }
        let points = currentDrawing.points
        if !points.isEmpty {
            path.move(to: CGPoint(x: points[0].x, y: points[0].y))
        }
        for point in points {
            path.addLine(to: CGPoint(x: point.x, y: point.y))
        }
        return path
    }
    
}

struct CanvasDrawerDialog: View {
    @Binding var uiImage: UIImage?
    var title: String = ""
    let onSelectionDone: (_ done: Bool) -> Void
    
    @State private var currentDrawing: Drawing = Drawing()
    @State private var drawings: [Drawing] = [Drawing]()
    @State private var color: Color = Color.black
    @State private var lineWidth: CGFloat = 3.0
    @State private var rect: CGRect = .zero
    
    var canvas: some View {
        CanvasShape(drawings: $drawings, currentDrawing: $currentDrawing)
        .stroke(self.color, lineWidth: self.lineWidth)
            .background(Color.init(white: 1))
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    drawings = []
                }) {
                    Image("ic-clean")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 32, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
                Spacer()
                Text(title)
                    .foregroundColor(.cPrimary)
                Spacer()
                Button(action: {
                    self.uiImage = canvas.asImage(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (50)))
                    onSelectionDone(true)
                }) {
                    Image("ic-file-done")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 32, alignment: .center)
                        .foregroundColor(.cPrimary)
                }
            }
            .padding([.leading, .trailing], 20)
            .padding([.top], 10)
            GeometryReader { geometry in
                canvas
                .gesture(
                    DragGesture(minimumDistance: 0.1)
                        .onChanged({ (value) in
                            let currentPoint = value.location
                            if currentPoint.y >= 0
                                && currentPoint.y < geometry.size.height {
                                self.currentDrawing.points.append(currentPoint)
                            }
                        })
                        .onEnded({ (value) in
                            self.drawings.append(self.currentDrawing)
                            self.currentDrawing = Drawing()
                        })
                )
            }
            .frame(maxHeight: .infinity)
            .background(RectGetter(rect: $rect))
            HStack {
                Button(action: {
                    onSelectionDone(false)
                }) {
                    Text("envCancel")
                }
            }
        }
    }
    
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

struct RectGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        
        return Rectangle().fill(Color.clear)
    }
}

struct DialogDurationPickerView: View {
    @StateObject var modelDuration: MovementDurationModel
    let onSelectionDone: () -> Void
    
    var body: some View {
        VStack {
            Text("envDuration")
                .foregroundColor(.cTextMedium)
                .padding(.vertical, 4)
            Spacer()
            HStack {
                VStack {
                    Button {
                        if modelDuration.hour < 23 {
                            modelDuration.hour += 1
                        }
                    } label: {
                        Image("ic-plus")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cIcon)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .center)
                    Text("\(Utils.zero(n: modelDuration.hour))")
                        .foregroundColor(.cTextHigh)
                        .font(.system(size: 26))
                    Text("envHours")
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 13))
                    Button {
                        if modelDuration.hour > 0 {
                            modelDuration.hour -= 1
                        }
                    } label: {
                        Image("ic-remove")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cIcon)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .center)
                }
                Text(":")
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 22))
                VStack {
                    Button {
                        if modelDuration.minute < 23 {
                            modelDuration.minute += 1
                        }
                    } label: {
                        Image("ic-plus")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cIcon)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .center)
                    Text("\(Utils.zero(n: modelDuration.minute))")
                        .foregroundColor(.cTextHigh)
                        .font(.system(size: 26))
                    Text("envMinutes")
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 13))
                    Button {
                        if modelDuration.minute > 0 {
                            modelDuration.minute -= 1
                        }
                    } label: {
                        Image("ic-remove")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cIcon)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .center)
                }
                Text(":")
                    .foregroundColor(.cTextMedium)
                    .font(.system(size: 22))
                VStack {
                    Button {
                        if modelDuration.second < 23 {
                            modelDuration.second += 1
                        }
                    } label: {
                        Image("ic-plus")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cIcon)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .center)
                    Text("\(Utils.zero(n: modelDuration.second))")
                        .foregroundColor(.cTextHigh)
                        .font(.system(size: 26))
                    Text("envSeconds")
                        .foregroundColor(.cTextMedium)
                        .font(.system(size: 13))
                    Button {
                        if modelDuration.second > 0 {
                            modelDuration.second -= 1
                        }
                    } label: {
                        Image("ic-remove")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.cIcon)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .center)
                }
            }
            Spacer()
            VStack {
                Button(action: {
                    self.onSelectionDone()
                }) {
                    Image("ic-done")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .foregroundColor(.cIcon)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
            }
            .frame(height: 40)
            .padding([.leading, .trailing], 10)
        }
    }
    
}
