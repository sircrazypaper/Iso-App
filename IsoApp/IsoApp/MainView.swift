//
//  ContentView.swift
//  IsoApp
//
//  Created by Jonathan Karniala Lehmann on 02/03/2025.
//

import SwiftUI
import Charts

struct painDataPoint: Identifiable{
    var id = UUID().uuidString
    @State var dateForPlot: String
    @State var painForPlot: Int
}

struct ContentView: View {
    //Define variables for the chart
    @State var data = [
        painDataPoint(dateForPlot: "MACRCH 5", painForPlot: 4),
        painDataPoint(dateForPlot: "MACRCH 6", painForPlot: 10),
        painDataPoint(dateForPlot: "MACRCH 7", painForPlot: 6),
        painDataPoint(dateForPlot: "MACRCH 8", painForPlot: 1),
        painDataPoint(dateForPlot: "MACRCH 9", painForPlot: 7),
        painDataPoint(dateForPlot: "MACRCH 10", painForPlot: 5),
        painDataPoint(dateForPlot: "MACRCH 11", painForPlot: 4),]
    enum graphSizes: String, CaseIterable{
        case three = "3"
        case seven = "7"
        case thirty = "30"
        case ninety = "90"
        case year = "365"
        case all = "All"
    }
    @State var graphSize: graphSizes = .three
    
    //Define variables for the Pain Tracking page
    @State var textToDisplayInPainTrackingInputField = "Enter pain level, 1-10"
    @State var todaysPainLevel: String = ""
    @State var painLevelInt: Int?
    @State var formerPainLevels: [Int] = []
    @State var currentDate = Date()
    
    //Define variables for the Timer page
    @State var timerDuration = 45
    @State var timerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //Define variables for the Settings page
    @State var isoDurationInput: String = ""
    
    var body: some View {
        TabView{
            
            //Set up the Home page
            NavigationView {
                VStack{
                    if data.count < 1{
                        Text("Not enough data to display graph")
                    } else {
                        Spacer()
                            .frame(height: 60)
                        Text("Pain history graph")
                            .font(.title)
                            .bold()
                        Chart{
                            ForEach(filteredData) { d in
                                LineMark(x: PlottableValue.value("Day", d.dateForPlot), y: .value("Pain level", d.painForPlot))
                                    .interpolationMethod(.catmullRom)
                            }
                        }
                        
                        Text("Graph size")
                            .foregroundColor(.secondary)
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
                .navigationTitle("Iso App")
            }
            .tabItem{
                Image(systemName: "house")
                Text("Home")
            }
            
            //Set up the Pain Tracking page
            NavigationView {
                VStack{
                 
                        VStack(alignment: .leading) {
                            Text("Today's Pain Level")
                                .font(.title)
                                .bold()
                            TextField(textToDisplayInPainTrackingInputField, text: $todaysPainLevel)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: submitPainLevel){
                                Text("Submit")
                            }
                        }
                        .padding(20)
                    
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
                            
                            ForEach(formerPainLevels, id: \.self) { item in
                                Text("\(currentDate, formatter: dateFormatter): \(item)") // Display each integer in the array on a new line
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }
                    
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                
                .navigationTitle("Pain Tracking")
            }
            .tabItem{
                Image(systemName: "calendar")
                Text("Pain Tracking")
            }
            
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
                                } else{
                                    timerRunning = false
                                    timerDuration = Int(isoDurationInput) ?? 0
                                }
                            }
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    }
                .navigationTitle("Timer")
                }
                .tabItem{
                    Image(systemName: "timer")
                    Text("Timer")
            }
            
            //Set up the Settings page
            NavigationView {
                VStack{
                    Form{
                        VStack(alignment: .leading) {
                            Text("Iso Duration")
                                .font(.headline)
                            TextField("Enter Iso Duration", text: $isoDurationInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: saveSettings){
                                Text("save")
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
            }
            .tabItem{
                Image(systemName: "gear")
                Text("Settings")
            }
            
            }
            
        }
    
    //filter data
    var filteredData: [painDataPoint] {
        let count: Int
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
        return Array(data.suffix(count))
        }
    
    //Functions for settings page
    func saveSettings(){
        timerDuration = Int(isoDurationInput) ?? 0
        timerRunning = false
    }
    
    //Functions for Pain Level page
    func submitPainLevel(){
        if let testnum = Int(todaysPainLevel), testnum >= 1 && testnum <= 10 {
                painLevelInt = testnum
                textToDisplayInPainTrackingInputField = "Enter pain level, 1-10"
                formerPainLevels.append(painLevelInt ?? 0)
            
                //do stuff for graph
                //convert date to string
            
            data.append(painDataPoint(dateForPlot: dateFormatter.string(from: currentDate), painForPlot: painLevelInt ?? 0))
            } else {
                todaysPainLevel = ""
                textToDisplayInPainTrackingInputField = "Please enter a valid number, 1-10"
                
            }
    }
    
    func clearPainHistory(){
        formerPainLevels = []
        data = []
    }
    
    // Custom date formatter to display the date in a readable format
        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }
    
    }

#Preview {
    ContentView()
}
