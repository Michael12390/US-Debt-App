//
//  getDebt.swift
//  Debt
//
//  Created by Michael Horowitz on 4/1/21.
//

import Foundation
import SwiftUI

class Debt: ObservableObject {
    
    @Published var debt = ""
    
    func getDebt(date: Date) {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        var debtDictionary = [Double:Double]()
        let archivedData = UserDefaults.standard.data(forKey: "debtDictionary") ?? Data()
        do {
            if let unarchivedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? [Double:Double] {
                debtDictionary = unarchivedData
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if debtDictionary[dateFormatter.date(from: dateFormatter.string(from: date))!.timeIntervalSince1970] != nil {
                    debt = numberFormatter.string(from: debtDictionary[dateFormatter.date(from: dateFormatter.string(from: date))!.timeIntervalSince1970]! as NSNumber) ?? ""
                    return
                }
            }
        } catch {}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startingDate = Date(timeIntervalSince1970: debtDictionary.keys.sorted().last ?? Calendar.current.date(from: DateComponents(year: 1993, month: 1, day: 4))!.timeIntervalSince1970)
        let endingDate = Date()
        let baseURL = "https://www.treasurydirect.gov/NP_WS/debt/search?"
        let stringURL = baseURL + "startdate=\(dateFormatter.string(from: startingDate))&enddate=\(dateFormatter.string(from: endingDate))"
        let url = URL(string: stringURL)!
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            guard let data = data else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:[Any]] else { return }
            guard let entries = json["entries"] else { return }
            for entry in entries {
                if let item = entry as? [String:Any] {
                    dateFormatter.dateFormat = "MMMM d, yyyy zzz"
                    if let date = dateFormatter.date(from: item["effectiveDate"] as! String) {
                        debtDictionary[date.timeIntervalSince1970] = item["totalDebt"] as? Double
                    }
                }
            }
            var currentDate = Date(timeIntervalSince1970: debtDictionary.keys.sorted()[0])
            for time in debtDictionary.keys.sorted() {
                let date = Date(timeIntervalSince1970: time)
                var dayDifference = Calendar.current.dateComponents([.day], from: currentDate, to: date).day ?? 0
                while dayDifference > 1 {
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                    debtDictionary[currentDate.timeIntervalSince1970] = debtDictionary[time]
                    dayDifference-=1
                }
            }
            let seconds = currentDate.timeIntervalSince1970
            var dayDifference = Calendar.current.dateComponents([.day], from: currentDate, to: endingDate).day ?? 0
            while dayDifference > 0 {
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                debtDictionary[currentDate.timeIntervalSince1970] = debtDictionary[seconds]
                dayDifference-=1
            }
            DispatchQueue.main.async {
                self.debt = numberFormatter.string(from: debtDictionary[currentDate.timeIntervalSince1970]! as NSNumber) ?? ""
            }
            do {
                let archivedDictionary = try NSKeyedArchiver.archivedData(withRootObject: debtDictionary, requiringSecureCoding: true)
                UserDefaults.standard.set(archivedDictionary, forKey: "debtDictionary")
            } catch {
                return
            }
        }
        
        task.resume()
        
    }
}
