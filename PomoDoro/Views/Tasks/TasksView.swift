//
//  TasksView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 14/07/2024.
//

import SwiftUI

struct TasksView: View {
    /// Environnement
    @Environment(\.colorScheme) private var colorScheme
    /// Task Manager Properties
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var createNewTask: Bool = false
    /// Animation Namespace
    @Namespace private var animation
    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HeaderView()
            ScrollView(.vertical){
                VStack {
                    TaskView(currentDate: $currentDate)
                }
                .hSpacing(.center)
                .vSpacing(.center)
            }
            .scrollIndicators(.hidden)
        })
        .vSpacing(.top)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                createNewTask.toggle()
            }) {
                Image(systemName: "plus")
                    .fontWeight(.bold)
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                    .frame(width: 55, height: 55)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color.white : Color.black)
                            .shadow(
                                color: colorScheme == .dark ? .white.opacity(0.45) : .black.opacity(0.45),
                                radius: 5, x: 10, y: 7
                            )
                    )
            }
            .padding(15)
        })
        .onAppear(perform: {
            if weekSlider.isEmpty {
                let currentWeek = Date().fetchWeek()
                
                if let firstDate = currentWeek.first?.date {
                    weekSlider.append(firstDate.createPreviousWeek())
                }
                weekSlider.append(currentWeek)
                
                if let lastDate = currentWeek.last?.date {
                    weekSlider.append(lastDate.createNextWeek())
                }
            }
        })
        .sheet(isPresented: $createNewTask, content: {
            NewTaskView()
                .presentationDetents([.height(400)])
//                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
        })
    }
    
    /// Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6, content: {
            HStack(spacing: 5 , content: {
                Text(currentDate.format("MMMM"))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(currentDate.format("YYYY"))
                    .foregroundStyle(.gray)
            })
            .font(.title.bold())
            
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)
            
            /// Week Slider
            TabView(selection: $currentWeekIndex){
                ForEach(weekSlider.indices, id: \.self){ index in
                    let week = weekSlider[index]
                    WeekView(week)
                        .padding(.horizontal, 15)
                        .tag(index)
                }
            }
            .padding(.horizontal, -15)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        })
        .hSpacing(.leading)
//        .overlay(alignment: .topTrailing, content: {
//            Button {
//                
//            } label: {
//                Image(.memoji)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 45, height: 45)
//                    .clipShape(.circle)
//            }
//            
//        })
        .padding(15)
        .hSpacing(.leading)
        .background(colorScheme == .dark ? .black : .white)
        .onChange(of: currentWeekIndex, initial: false) { oldValue, newValue in
            /// Creating when it reaches first/last Page
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
        }
    }
    
    /// Week View
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                VStack(spacing:10) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .textScale(.secondary)
                        .foregroundStyle(isSameDate(day.date, currentDate)
                            ? (colorScheme == .dark ? .black : .white)
                            : (colorScheme == .dark ? .gray.opacity(0.9) : .gray))
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, currentDate){
                                Circle()
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }
                            /// Indicator to Show, Wich is Today's Date
                            if day.date.isToday {
                                Circle()
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y:12)
                            }
                        })
                        .background(.white.shadow(.drop(radius: 1)), in: .circle)
                    
                }
                .hSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
                    /// Updating Current Date
                    withAnimation(.snappy){
                        currentDate = day.date
                    }
                }
            }
        }
        .background{
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self, perform: { value in
                        /// When the Offset reaches 15 and if the createWeek is toggled then simply generating next set of week
                        if value.rounded() == 15 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    })
            }
        }
    }
    
    func paginateWeek() {
        /// SafeCheck
        if weekSlider.indices.contains(currentWeekIndex){
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                /// Insertiung New Week at 0th Index and Removing last array Item
                weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastdate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                /// Appending New Week at Last Index and Removing First Array Item
                weekSlider.append(lastdate.createNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
    }
    
    
    
}

#Preview {
    TasksView()
}
