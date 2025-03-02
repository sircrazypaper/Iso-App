//
//  ContentView.swift
//  IsoApp
//
//  Created by Jonathan Karniala Lehmann on 02/03/2025.
//

import SwiftUI

struct ContentView: View {
    //Define variables for the Pain Tracking page
    @State var textToDisplayInPainTrackingInputField = "Enter pain level, 1-10"
    @State var todaysPainLevel: String = ""
    @State var painLevelInt: Int?
    @State var formerPainLevels: [Int] = []
    
    //Define variables for the Timer page
    @State var timerDuration = 5
    @State var timerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //Define variables for the Settings page
    @State var isoDurationInput: String = ""
    
    var body: some View {
        TabView{
            
            //Set up the Home page
            NavigationView {
                VStack{
                    Text("Graph goes here")
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
                    Form{
                        VStack(alignment: .leading) {
                            Text("Today's Pain Level")
                                .font(.headline)
                            TextField(textToDisplayInPainTrackingInputField, text: $todaysPainLevel)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: submitPainLevel){
                                Text("Submit")
                            }
                        }
                    }
                    
                    Text("\(formerPainLevels)")
                    
                }
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
                print(formerPainLevels)
            } else {
                todaysPainLevel = ""
                textToDisplayInPainTrackingInputField = "Please enter a valid number, 1-10"
                
            }
    }
    
    }

#Preview {
    ContentView()
}
