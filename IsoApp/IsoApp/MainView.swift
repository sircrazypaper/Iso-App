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
    //Define miscellaneus variables
    @State var selectedTab = 0
    
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
    @State var textToDisplayInPainTrackingInputField = "Enter pain level, 1-10"
    @State var todaysPainLevel: Double = 1.0
    @State var painLevelInt: Int?
    @State var formerPainLevels: [Int] = []
    @State var currentDate = Date()
    
    //Define variables for the Timer page
    @State var timerDuration: Int = 45
    @State var timerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var tabSwitchingAllowed = true
    
    //Define variables for the Settings page
    @State var isoDurationInput: Double = 45
    
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
                .navigationTitle("Iso App")
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
                                .onChange(of: todaysPainLevel) { oldValue, newValue in
                                    // Convert the slider's value (Double) to an integer
                                    painLevelInt = Int(newValue)
                                }
                            
                            Text("\(painLevelInt ?? 1)")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
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
                .tag(2)
            
            //Set up the Settings page
            NavigationView {
                VStack{
                    Form{
                        VStack(alignment: .leading) {
                            Text("Isometric Exercise Duration")
                                .font(.headline)
                            
                            Slider(value: $isoDurationInput, in: 30...60, step: 1)
                                .onChange(of: isoDurationInput) { oldValue, newValue in
                                    // Convert the slider's value (Double) to an integer
                                    timerDuration = Int(newValue)
                                }
                            Text("\(timerDuration)s")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                        }
                    }
                }
                .navigationTitle("Settings")
            }
            .tabItem{
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(3)
            
            }
        .onChange(of: selectedTab) {oldTab, newTab in
            if tabSwitchingAllowed == false{
                selectedTab = 2
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
        formerPainLevels.insert(painLevelInt ?? 1, at: 0)
        data.append(painDataPoint(dateForPlot: dateFormatter.string(from: currentDate), painForPlot: painLevelInt ?? 1))
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
