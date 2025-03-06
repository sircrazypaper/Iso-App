//
//  ContentView.swift
//  IsoApp
//
//  Created by Jonathan Karniala Lehmann on 02/03/2025.
//

import SwiftUI
import Charts
import UserNotifications

struct painDataPoint: Identifiable, Codable{
    var id = UUID()
    var dateForPlot: String
    var painForPlot: Int
}

struct ContentView: View {
    
    //Define miscellaneus variables
    @State var selectedTab = 0
    
    //Define variables for the chart
    @State var data: [painDataPoint] = []
    enum graphSizes: String, CaseIterable{
        case all = "All"
        case three = "3"
        case seven = "7"
        case thirty = "30"
        case ninety = "90"
        case year = "365"
    }
    @State var graphSize: graphSizes = .three
    @State var graphSizeInt: Int?
    
    //Define variables for the Pain Tracking page
    @State var todaysPainLevel: Double = 1.0
    @State var painLevelInt: Int?
    @State var currentDate = Date()
    @State private var buttonDisabled: Bool = false
    
    //Define variables for the Timer page
    @State var timerDuration: Int = 45
    @State var timerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var tabSwitchingAllowed = true
    
    //Define variables for the Settings page
    @State var isoDurationInput: Double = 45
    
    //Define variables for the notifications
    @State var timeForFirstIso = Date()
    @State var timeForSecondIso = Date()
    @State var timeForThirdIso = Date()
    @State var timeForPainTracking = Date()
    
    var body: some View {
        TabView(selection: $selectedTab){
            
            //Set up the Home page
            NavigationView {
                VStack{
                    if data.count < 3 {
                        Text("Not enough data to display graph")
                    } else {
                        Spacer()
                            .frame(height: 60)
                        Text("Pain history graph")
                            .font(.title)
                            .bold()
                        Chart{
                            ForEach(filteredData) { d in
                                PointMark(x: PlottableValue.value("Day", d.dateForPlot), y: .value("Pain level", d.painForPlot))
                                
                                LineMark(x: PlottableValue.value("Day", d.dateForPlot), y: .value("Pain level", d.painForPlot))
                                    .interpolationMethod(.catmullRom)
                            }
                        }
                        
                        Text("Graph data points")
                            .foregroundColor(.secondary)
                        
                        if data.count < 3{
                            Text("Not enough data to display graph")
                        } else if data.count > 2 && data.count <= 6{
                            Picker("Select graph size", selection: $graphSize){
                                ForEach(graphSizes.allCases.prefix(2), id: \.self){ size in
                                    Text(size.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 20)
                            Spacer()
                                .frame(height: 80)
                        } else if data.count > 6 && data.count <= 29{
                            Picker("Select graph size", selection: $graphSize){
                                ForEach(graphSizes.allCases.prefix(3), id: \.self){ size in
                                    Text(size.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 20)
                            Spacer()
                                .frame(height: 80)
                        } else if data.count > 29 && data.count <= 89{
                            Picker("Select graph size", selection: $graphSize){
                                ForEach(graphSizes.allCases.prefix(4), id: \.self){ size in
                                    Text(size.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 20)
                            Spacer()
                                .frame(height: 80)
                        } else if data.count > 89 && data.count <= 364{
                            Picker("Select graph size", selection: $graphSize){
                                ForEach(graphSizes.allCases.prefix(5), id: \.self){ size in
                                    Text(size.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 20)
                            Spacer()
                                .frame(height: 80)
                        } else if data.count > 364{
                            Picker("Select graph size", selection: $graphSize){
                                ForEach(graphSizes.allCases, id: \.self){ size in
                                    Text(size.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 20)
                            Spacer()
                                .frame(height: 80)
                        }
                    }
                }
                .navigationTitle("Graph")
            }
            .tabItem{
                Image(systemName: "chart.xyaxis.line")
                Text("Graph")
            }
            .tag(0)
            
            //Set up the Pain Tracking page
            NavigationView {
                VStack{
                 
                        VStack(alignment: .leading) {
                            Text("Today's Pain Level")
                                .font(.title)
                                .bold()
                            Slider(value: $todaysPainLevel, in: 1...10, step: 1)
                                .onChange(of: todaysPainLevel) { newValue in
                                    painLevelInt = Int(newValue)
                                    UserDefaults.standard.set(todaysPainLevel, forKey: "savedTodaysPainLevel")
                                    UserDefaults.standard.set(painLevelInt, forKey: "savedPainLevelInt")
                                }
                            
                            Text("\(painLevelInt ?? 1)")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Button(action: {
                               if canRunActionToday(){
                                    runAction()
                                }
                            }){
                                Text("Submit")
                                    .foregroundColor(buttonDisabled ? Color.gray : Color.blue)
                            }
                            .disabled(buttonDisabled)
                            
                            
                        }
                        .padding(20)
                        .onAppear{
                            if let savedTodaysPainLevel = UserDefaults.standard.value(forKey: "savedTodaysPainLevel") as? Double{
                                todaysPainLevel = savedTodaysPainLevel
                            }
                            if let savedPainLevelInt = UserDefaults.standard.value(forKey: "savedPainLevelInt") as? Int{
                                painLevelInt = savedPainLevelInt
                            }
                        }
                    
                    VStack {
                        Text("History")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .font(.title)
                            .bold()
                         
                        List {
                            Button(action: clearPainHistory){
                                Text("Clear all history")
                                    .foregroundColor(.red)
                            }
                            
                            ForEach(data.reversed(), id: \.dateForPlot) { item in
                                Text("\(item.dateForPlot): \(item.painForPlot)")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }
                    
                }
                .onAppear {
                    buttonDisabled = !canRunActionToday()
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                
                .navigationTitle("Pain Tracking")
            }
            .tabItem{
                Image(systemName: "calendar")
                Text("Pain Tracking")
            }
            .tag(1)
            
            //Set up the Timer page
            NavigationView {
                VStack{
                    Button(action: {
                        if timerRunning == false{
                            timerRunning = true
                        }
                    }) {
                        Text("\(timerDuration)")
                            .onReceive(timer) { _ in
                                if timerDuration > 0 && timerRunning{
                                    timerDuration -= 1
                                    tabSwitchingAllowed = false
                                } else{
                                    timerRunning = false
                                    tabSwitchingAllowed = true
                                    timerDuration = Int(isoDurationInput)
                                }
                            }
                            .font(.system(size: 100, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    }
                .navigationTitle("Timer")
                .onAppear{
                    if let savedTimerDuration = UserDefaults.standard.value(forKey: "savedTimerDuration") as? Int{
                        timerDuration = savedTimerDuration
                    }
                    
                }
                }
                .tabItem{
                    Image(systemName: "timer")
                    Text("Timer")
            }
                .tag(2)
            
            //Set up the Settings page
            NavigationView {
                VStack{
                    Form{
                        VStack(alignment: .leading) {
                            //Iso Duration settings
                            Text("Isometric Exercise Duration")
                                .font(.title2)
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Slider(value: $isoDurationInput, in: 30...60, step: 1)
                                .onChange(of: isoDurationInput) { newValue in
                                    // Convert the slider's value (Double) to an integer
                                    timerDuration = Int(newValue)
                                    UserDefaults.standard.set(timerDuration, forKey: "savedTimerDuration")
                                    UserDefaults.standard.set(isoDurationInput, forKey: "savedIsoDurationInput")
                                }
                                .padding()
                            Text("\(timerDuration)s")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            //Notification settings
                            Text("Notification settings")
                                .font(.title2)
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("Isometric Exercise Notifications")
                                .font(.headline)
                                .padding()
                            
                            DatePicker("First set:", selection: $timeForFirstIso, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.compact)
                                .onChange(of: timeForFirstIso){ newTime in
                                    scheduleFirstIsoNotification(at: newTime)
                                    UserDefaults.standard.set(timeForFirstIso, forKey: "savedTimeForFirstIso")
                                }
                            
                            DatePicker("Second set:", selection: $timeForSecondIso, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.compact)
                                .onChange(of: timeForSecondIso){ newTime2 in
                                    scheduleSecondIsoNotification(at: newTime2)
                                    UserDefaults.standard.set(timeForSecondIso, forKey: "savedTimeForSecondIso")
                                }
                            
                            DatePicker("Third set:", selection: $timeForThirdIso, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.compact)
                                .onChange(of: timeForThirdIso){ newTime3 in
                                    scheduleThirdIsoNotification(at: newTime3)
                                    UserDefaults.standard.set(timeForThirdIso, forKey: "savedTimeForThirdIso")
                                }
                            
                            Text("Pain tracking notifications")
                                .font(.headline)
                                .padding()
                            
                            DatePicker("Pain tracking:", selection: $timeForPainTracking, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.compact)
                                .onChange(of: timeForPainTracking){ newTime3 in
                                    schedulePainTrackingNotification(at: newTime3)
                                    UserDefaults.standard.set(timeForPainTracking, forKey: "savedTimeForPainTracking")
                                }
                            
                        }
                    }
                    
                }
                .navigationTitle("Settings")
                .onAppear{
                    if let savedIsoDurationInput = UserDefaults.standard.value(forKey: "savedIsoDurationInput") as? Double{
                        isoDurationInput = savedIsoDurationInput
                    }
                    if let savedTimeForFirstIso = UserDefaults.standard.value(forKey: "savedTimeForFirstIso") as? Date{
                        timeForFirstIso = savedTimeForFirstIso
                    }
                    if let savedTimeForSecondIso = UserDefaults.standard.value(forKey: "savedTimeForSecondIso") as? Date{
                        timeForSecondIso = savedTimeForSecondIso
                    }
                    if let savedTimeForThirdIso = UserDefaults.standard.value(forKey: "savedTimeForThirdIso") as? Date{
                        timeForThirdIso = savedTimeForThirdIso
                    }
                    if let savedTimeForPainTracking = UserDefaults.standard.value(forKey: "savedTimeForPainTracking") as? Date{
                        timeForPainTracking = savedTimeForPainTracking
                    }
                }
            }
            .tabItem{
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(3)
            
            }
        .onAppear{
            loadData()
        }
        .onChange(of: selectedTab) { newTab in
            if tabSwitchingAllowed == false{
                selectedTab = 2
            }
        }
            
        }
        
    //Functions for saving the pain history data
    func saveData(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data){
            UserDefaults.standard.set(encoded, forKey: "savedPainData")
        }
    }
    
    func loadData(){
        if let savedData = UserDefaults.standard.data(forKey: "savedPainData"){
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode([painDataPoint].self, from: savedData){
                data = loadedData
            }
        }
    }
    
    //filter data
    var filteredData: [painDataPoint] {
        @State var count: Int
        switch graphSize {
        case .three:
            count = 3
        case .seven:
            count = 7
        case .thirty:
            count = 30
        case .ninety:
            count = 90
        case .year:
            count = 365
        case .all:
            count = data.count
        }
        graphSizeInt = count
        return Array(data.suffix(count))
        }
    
    //Functions for Pain Level page
    func submitPainLevel(){
        data.append(painDataPoint(dateForPlot: dateFormatter.string(from: currentDate), painForPlot: painLevelInt ?? 1))
        saveData()
    }
    
    func clearPainHistory(){
        data = []
    }
    
    func canRunActionToday() -> Bool {
            guard let lastPressedDate = UserDefaults.standard.string(forKey: "lastActionDate") else {
                return true
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let currentDateString = formatter.string(from: Date())

            if lastPressedDate == currentDateString {
                return false
            } else {
                return true
            }
        }
    
    func runAction() {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let currentDateString = formatter.string(from: currentDate)

            UserDefaults.standard.set(currentDateString, forKey: "lastActionDate")

            buttonDisabled = true

            submitPainLevel()
        }
    
    //Date formatter
        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }
    
    //Notification function
    func scheduleFirstIsoNotification(at time: Date){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Isometric Exercise Reminder"
        content.body = "It is time for your first set of isometric exercises!"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        if let triggerDate = calendar.date(from: dateComponents), triggerDate < Date() {
            dateComponents.day! += 1
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "notificationIdentifier", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleSecondIsoNotification(at time2: Date){
        let center2 = UNUserNotificationCenter.current()
        let content2 = UNMutableNotificationContent()
        content2.title = "Isometric Exercise Reminder"
        content2.body = "It is time for your second set of isometric exercises!"
        
        let calendar2 = Calendar.current
        let components2 = calendar2.dateComponents([.hour, .minute], from: time2)
        
        var dateComponents2 = calendar2.dateComponents([.year, .month, .day], from: Date())
        dateComponents2.hour = components2.hour
        dateComponents2.minute = components2.minute
        
        if let triggerDate2 = calendar2.date(from: dateComponents2), triggerDate2 < Date() {
            dateComponents2.day! += 1
        }
        
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponents2, repeats: false)
        let request2 = UNNotificationRequest(identifier: "notificationIdentifier2", content: content2, trigger: trigger2)
        
        center2.add(request2) { error in
            if let error2 = error {
                print("Error scheduling notification: \(error2.localizedDescription)")
            }
        }
    }
    
    func scheduleThirdIsoNotification(at time3: Date){
        let center3 = UNUserNotificationCenter.current()
        let content3 = UNMutableNotificationContent()
        content3.title = "Isometric Exercise Reminder"
        content3.body = "It is time for your third set of isometric exercises!"
        
        let calendar3 = Calendar.current
        let components3 = calendar3.dateComponents([.hour, .minute], from: time3)
        
        var dateComponents3 = calendar3.dateComponents([.year, .month, .day], from: Date())
        dateComponents3.hour = components3.hour
        dateComponents3.minute = components3.minute
        
        if let triggerDate3 = calendar3.date(from: dateComponents3), triggerDate3 < Date() {
            dateComponents3.day! += 1
        }
        
        let trigger3 = UNCalendarNotificationTrigger(dateMatching: dateComponents3, repeats: false)
        let request3 = UNNotificationRequest(identifier: "notificationIdentifier3", content: content3, trigger: trigger3)
        
        center3.add(request3) { error in
            if let error3 = error {
                print("Error scheduling notification: \(error3.localizedDescription)")
            }
        }
    }
    
    func schedulePainTrackingNotification(at time4: Date){
        let center4 = UNUserNotificationCenter.current()
        let content4 = UNMutableNotificationContent()
        content4.title = "Pain Tracking Reminder"
        content4.body = "It is time to track your tendon pain!"
        
        let calendar4 = Calendar.current
        let components4 = calendar4.dateComponents([.hour, .minute], from: time4)
        
        var dateComponents4 = calendar4.dateComponents([.year, .month, .day], from: Date())
        dateComponents4.hour = components4.hour
        dateComponents4.minute = components4.minute
        
        if let triggerDate4 = calendar4.date(from: dateComponents4), triggerDate4 < Date() {
            dateComponents4.day! += 1
        }
        
        let trigger4 = UNCalendarNotificationTrigger(dateMatching: dateComponents4, repeats: false)
        let request4 = UNNotificationRequest(identifier: "notificationIdentifier4", content: content4, trigger: trigger4)
        
        center4.add(request4) { error in
            if let error4 = error {
                print("Error scheduling notification: \(error4.localizedDescription)")
            }
        }
    }
    
    }

#Preview {
    ContentView()
}
