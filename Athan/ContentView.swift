//
//  ContentView.swift
//  Athan
//
//  Created by Omarrhazem Khattab  on 03/12/2024.
//

import SwiftUI
import Foundation
import Foundation
import UserNotifications
import MapKit
func getSavedLocation() -> [Double]? {
    if let locationData = UserDefaults.standard.dictionary(forKey: "userLocation") as? [String: Double],
       let latitude = locationData["latitude"],
       let longitude = locationData["longitude"] {
        return [latitude,longitude]
    }
    return nil
}

func saveStringToUserDefaults(key: String, value: String) {
    UserDefaults.standard.set(value, forKey: key)
}

func loadStringFromUserDefaults(key: String) -> String? {
    return UserDefaults.standard.string(forKey: key)
}


// Request permission to send notifications
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
        if granted {
            print("Notification permission granted.")
        } else {
            print("Notification permission denied.")
        }
    }
}


func timeUntilNextPrayer(currentTime: Date, timings: Timings) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    // Convert prayer times to Date objects
    let prayerTimes: [(String, Date)] = [
            ("Fajr", dateFormatter.date(from: timings.fajr)!),
            ("Dhuhr", dateFormatter.date(from: timings.dhuhr)!),
            ("Asr", dateFormatter.date(from: timings.asr)!),
            ("Maghrib", dateFormatter.date(from: timings.maghrib)!),
            ("Isha", dateFormatter.date(from: timings.isha)!)
        ]
        
        // Sort the prayer times by Date
        let sortedPrayerTimes = prayerTimes.sorted { $0.1 < $1.1 }
        
    let ct = dateFormatter.string(from:(currentTime))
    var nextPrayerTime: Date?
    // Loop through each prayer time and find the next one
    for (_, timeString) in sortedPrayerTimes {
     
        if   let cts = dateFormatter.date(from:ct), timeString > cts {
            
            
            
                
            nextPrayerTime = timeString
              
                
           
            break
            
            

            
        }
    }
    // If no upcoming prayer time is found (it means the last prayer is today)
    if nextPrayerTime == nil ,let fajr=dateFormatter.date(from: timings.fajr) {
        nextPrayerTime = fajr.addingTimeInterval(24 * 60 * 60) // Start from Fajr next day
    }
    let cts = dateFormatter.date(from:ct)
    // Calculate the time difference
    if let nextPrayer = nextPrayerTime,let vtt=cts {
        let timeInterval = nextPrayer.timeIntervalSince(vtt)
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    return "N/A"
}


struct PrayerTimesResponse: Codable {
    let code: Int?
    let status: String?
    let data: PrayerTimesData?
}

struct PrayerTimesData: Codable {
    let timings: Timings
    let date: PrayerDate
    let meta: Meta
}

struct Timings: Codable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let sunset: String
    let maghrib: String
    let isha: String
    let imsak: String
    let midnight: String
    let firstthird: String
    let lastthird: String

    enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case sunset = "Sunset"
        case maghrib = "Maghrib"
        case isha = "Isha"
        case imsak = "Imsak"
        case midnight = "Midnight"
        case firstthird = "Firstthird"
        case lastthird = "Lastthird"
    }
}

struct PrayerDate: Codable {
    let readable: String
    let timestamp: String
    let hijri: HijriDate
    let gregorian: GregorianDate
}

struct HijriDate: Codable {
    let date: String
    let format: String
    let day: String
    let weekday: Day
    let month: Month
    let year: String
    let designation: Designation
    let holidays: [String]
}

struct GregorianDate: Codable {
    let date: String
    let format: String
    let day: String
    let weekday: Day
    let month: Month
    let year: String
    let designation: Designation
}

struct Day: Codable {
    let en: String
    let ar: String?
}

struct Month: Codable {
    let number: Int
    let en: String
    let ar: String?
}

struct Designation: Codable {
    let abbreviated: String
    let expanded: String
}

struct Meta: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let method: Method
    let latitudeAdjustmentMethod: String
    let midnightMode: String
    let school: String
    let offset: [String: Int]
}

struct Method: Codable {
    let id: Int
    let name: String
    let params: MethodParams
    let location: Location
}

struct MethodParams: Codable {
    let fajr: Double
    let isha: Double

    enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case isha = "Isha"
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

class ItemViewModel: ObservableObject {
    @Published var items: PrayerTimesResponse =  PrayerTimesResponse(code: nil,status: nil,data: nil)
    @Published var isLoading = false
    @Published var errorMessage: String?
    

    func fetchData(longandlat : [Double]) {
        
        guard let url = URL(string: "https://api.aladhan.com/v1/timings/22-12-2024?latitude=\(longandlat[0])4&longitude=\(longandlat[0])") else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received."
                    return
                }

                do {
                    self?.items = try JSONDecoder().decode(PrayerTimesResponse.self, from: data)
                    
                    
                    if let timings = self?.items.data?.timings{
                        print("amerika")
                        if let sharedDefaults = UserDefaults(suiteName: "group.omarika.atthan") {
                            
                     
                            
                            if let fajr = convertTo12HourFormat(from24Hour: timings.fajr){
                                
                                sharedDefaults.set(fajr, forKey: "fajr")
                                
                                
                            }
                            if let fajr = convertTo12HourFormat(from24Hour: timings.dhuhr){
                                
                                sharedDefaults.set(fajr, forKey: "dhuhr")
                                
                            }
                            if let fajr = convertTo12HourFormat(from24Hour: timings.asr){
                                
                                sharedDefaults.set(fajr, forKey: "asr")
                                
                            }
                            if let fajr = convertTo12HourFormat(from24Hour: timings.maghrib){
                                
                                sharedDefaults.set(fajr, forKey: "maghrib")
                                
                            }
                            if let fajr = convertTo12HourFormat(from24Hour: timings.isha){
                                
                                sharedDefaults.set(fajr, forKey: "isha")
                                
                            }
                            if let fajr = sharedDefaults.string(forKey: "isha"){
                                print(fajr)
                            }
                        
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                   
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    if let times = self?.items.data?.timings {
                        
                        scheduleAthanNotifications(timings:times )
                    }
                } catch {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct ItemListView: View {
    @StateObject private var viewModel = ItemViewModel()
    @State private var currentTime = Date()
    @State private var savedString: String = ""
    @State private var longandlat : [Double]=[]
    var body: some View {
        
        TabView {
            
           
            ZStack{
                Image(savedString) .resizable()
                    .scaledToFit()
                
                VStack{
                    VStack {
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                        } else if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else if let timings = viewModel.items.data?.timings {
                            VStack{
                                VStack(alignment:.leading, spacing: 20) {
                                    Text("Time Until Next Prayer: \(timeUntilNextPrayer(currentTime: currentTime, timings: timings))")
                                        .font(.headline)
                                        .padding()
                                    
                                }.frame(alignment: .top)
                                    .padding()
                                VStack(alignment:.leading, spacing: 20) {
                                    
                                    if let fajr = convertTo12HourFormat(from24Hour: timings.fajr){
                                        
                                        Text("Fajr: \(fajr)")
                                        
                                    }
                                    if let fajr = convertTo12HourFormat(from24Hour: timings.dhuhr){
                                        
                                        Text("Duhr: \(fajr)")
                                        
                                    }
                                    if let fajr = convertTo12HourFormat(from24Hour: timings.asr){
                                        
                                        Text("Asr: \(fajr)")
                                        
                                    }
                                    if let fajr = convertTo12HourFormat(from24Hour: timings.maghrib){
                                        
                                        Text("Maghrib: \(fajr)")
                                        
                                    }
                                    if let fajr = convertTo12HourFormat(from24Hour: timings.isha){
                                        
                                        Text("Isha: \(fajr)")
                                        
                                    }
                                }.padding()
                                    .frame(width: 200)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                    .scaleEffect(1.2)
                            }
                        } else {
                            Text("No data available.")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    .ignoresSafeArea()
                }
                .ignoresSafeArea()
                .onAppear {
                    if let loadedString = loadStringFromUserDefaults(key: "background") {
                                       savedString = loadedString
                                   }
                    if let scheduled = loadStringFromUserDefaults(key: "notif") , scheduled == "true"{
                        
                    }else{
                        saveStringToUserDefaults(key: "notif", value: "true")
                        requestNotificationPermission()
                    }
                    if let loc = getSavedLocation() {
                        longandlat=loc
                        
                        viewModel.fetchData(longandlat: longandlat)
                        
                    }
                    
                    
                    
                    
                    // Update current time every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        currentTime = Date()
                    }
                }
            }
            .tabItem {
                              Label("Prayers", systemImage: "clock.fill")
                          }
            NavigationView {
                VStack{
                    Form{
                        NavigationLink(destination: SecondScreen()){
                            Text("set background image") .frame(maxWidth: .infinity)
                            .padding()                    }
                        
                        NavigationLink(destination:LocationPickerView()){
                            Text("set Location") .frame(maxWidth: .infinity)
                            .padding()                  }
                    }
                }
            }
            .tabItem {
                              Label("Settings", systemImage: "gearshape.fill")
                          }
        }
    }
}
import UserNotifications

func scheduleAthanNotifications(timings: Timings) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    let prayerTimes: [String: String] = [
        "Fajr": timings.fajr,
        "Dhuhr": timings.dhuhr,
        "Asr": timings.asr,
        "Maghrib": timings.maghrib,
        "Isha": timings.isha,
        "test" :"18:50"
    ]
    
    for (prayer, timeString) in prayerTimes {
        if let prayerDate = dateFormatter.date(from: timeString) {
            scheduleNotification(at: prayerDate, prayer: prayer)
            scheduleNotificationReminder(at: prayerDate, prayer: prayer)
        }
    }
}

func scheduleNotification(at date: Date, prayer: String) {
    let content = UNMutableNotificationContent()
    content.title = "It's time for \(prayer)!"
    content.body = "It's time for your prayer. The Athan is playing now."
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "1222(4).WAV")) // Replace with your sound file name
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: date), repeats: true)

    print(trigger)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        }
    }
}

func scheduleNotificationReminder(at date: Date, prayer: String) {
    let content = UNMutableNotificationContent()
    content.title = "It's time for \(prayer)!"
    content.body = "It's time for your prayer. The Athan is playing now."
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "1222(4).WAV")) // Replace with your sound file name
    let reminderdate = date.addingTimeInterval(60 * 15)
    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: reminderdate), repeats: true)

    print(trigger)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        }
    }
}


struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
    }
}
import SwiftUI

struct SecondScreen: View {
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Form { HStack{
                Text("default")
                Spacer()
                Image("athanpic") .resizable() // Make the image resizable
                    .scaledToFit() // Ensure the image scales proportionally
                    .frame(maxWidth: 50, maxHeight: 50) // Limit the size of the image
                
                
            }
            .onTapGesture {
                saveStringToUserDefaults(key: "background", value: "athanpic")
                showToastMessage(message: "Background set to athanpic")
            }
            .frame(maxWidth: .infinity,maxHeight: 50)
          
            .padding()
                HStack{
                    Text("fanos")
                    Spacer()
                    Image("fanos") .resizable() // Make the image resizable
                        .scaledToFit() // Ensure the image scales proportionally
                        .frame(maxWidth: 50, maxHeight: 50) // Limit the size of the image
                    
                    
                }
                .onTapGesture {
                    saveStringToUserDefaults(key: "background", value: "fanos")
                    showToastMessage(message: "Background set to fanos")
                }
                .frame(maxWidth: .infinity,maxHeight: 50)
             
                .padding()
            }
        }
        .navigationTitle("Background Image")
        .overlay(
            VStack {
                Spacer()
                if showToast {
                    Text(toastMessage)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: showToast)
                }
            }
            .padding(),
            alignment: .bottom
        )
    }

    // Show toast message with a 2-second delay
    private func showToastMessage(message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
        
        // Hide the toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showToast = false
            }
        }
    }

    // Simulate saving a string to UserDefaults (replace with your actual function)
    private func saveStringToUserDefaults(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

struct SecondScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecondScreen()
        }
    }
}
import Foundation

func convertTo12HourFormat(from24Hour time: String) -> String? {
    let dateFormatter = DateFormatter()
    
    // Set the input date format (24-hour format)
    dateFormatter.dateFormat = "HH:mm"
    
    // Convert the input string to a Date object
    if let date = dateFormatter.date(from: time) {
        
        // Now set the output format to 12-hour format
        dateFormatter.dateFormat = "hh:mm a"  // "a" is for AM/PM
        
        // Convert the Date object back to a string in 12-hour format
        return dateFormatter.string(from: date)
    }
    
    // Return nil if the input format is invalid
    return nil
}