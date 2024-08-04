//
//  TaskView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 16/07/2024.
//

import SwiftUI
import SwiftData

struct TaskView: View {
    @Binding var currentDate: Date
    /// SwiftData Dynamic Query
    @Query private var tasks: [PomoTask]
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        // Predicate
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: currentDate.wrappedValue)
        let endOfDate = calendar.date(byAdding: .day, value: 1, to: startOfDate)!
        let predicate = #Predicate<PomoTask>{
            return $0.creationDate >= startOfDate && $0.creationDate < endOfDate
        }
        /// Sorting
        let sortDescriptor = [
            SortDescriptor(\PomoTask.creationDate, order: .forward)
        ]
        self._tasks = Query(filter: predicate, sort: sortDescriptor, animation: .snappy)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 35){
            ForEach(tasks) { task in
                TaskRowView(task: task)
                    .background(alignment: .leading) {
                        if tasks.last?.id != task.id {
                            Rectangle()
                                .frame(width: 1)
                                .offset(x:8)
                                .padding(.bottom, -35)
                        }
                    }
            }
        }
        .padding([.vertical, .leading], 15)
        .padding(.top,15)
        .overlay(alignment: .center) {
            if tasks.isEmpty {
                Text("No Task's Found")
                    .font(.title2)
                    .foregroundStyle(.gray)
                    .frame(width:200)
            }
        }
    }
}

#Preview {
    do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: PomoTask.self, configurations: config)
            
            // Créer quelques tâches de test
            let testTask1 = PomoTask(taskTitle: "Test Task 1", creationDate: Date(), tint: "TaskColor1")
            let testTask2 = PomoTask(taskTitle: "Test Task 2", creationDate: Date().addingTimeInterval(3600), tint: "TaskColor2")
            container.mainContext.insert(testTask1)
            container.mainContext.insert(testTask2)
            
            return TaskView(currentDate: .constant(Date()))
                .modelContainer(container)
        } catch {
            return Text("Failed to create preview: \(error.localizedDescription)")
        }
}


#Preview(body: {
   TasksView()
})
