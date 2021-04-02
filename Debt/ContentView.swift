//
//  ContentView.swift
//  Debt
//
//  Created by Michael Horowitz on 4/1/21.
//

import SwiftUI

struct ContentView: View {
    @State private var date = Date()
    @ObservedObject private var debt = Debt()
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                Text("Total Debt")
                    .font(Font.custom("lato-bold", size: 1000))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .foregroundColor(.blue)
                    .padding([.leading, .trailing], 60)
                    .padding([.top, .bottom], 30)
                    .scaledToFit()
                Text(debt.debt)
                    .font(Font.custom("lato", size: 1000))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .foregroundColor(.blue)
                    .padding([.leading, .trailing], 20)
                    .onAppear(perform: {
                        debt.getDebt(date: date)
                    })
                Spacer()
                DatePicker(selection: $date, in: Calendar.current.date(from: DateComponents(year: 1993, month: 1, day: 4))!...Date(), displayedComponents: .date) {
                    Text("Date Picker")
                }
                    .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
                    .onChange(of: date, perform: { date in
                        debt.getDebt(date: date)
                    })
                .padding()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
