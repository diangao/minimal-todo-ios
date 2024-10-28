//
//  ContentView.swift
//  todo_ios
//
//  Created by Diyan Gao on 10/27/24.
//

import SwiftUI
import CoreMotion

struct TodoItem: Identifiable {
    var id = UUID()
    var title: String
    var isCompleted = false
}

struct ContentView: View {
    @State private var todoItems: [TodoItem] = []
    @State private var isAddingNew = false
    @State private var newItemText = ""
    private let motionManager = CMMotionManager()
    
    var body: some View {
        NavigationView {
            List {
                if isAddingNew {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.gray)
                        TextField("I want to ...", text: $newItemText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                addItem()
                            }
                    }
                    .listRowSeparator(.hidden)
                }
                
                ForEach(todoItems.indices, id: \.self) { index in
                    Text(todoItems[index].title)
                        .strikethrough(todoItems[index].isCompleted)
                        .foregroundColor(todoItems[index].isCompleted ? .gray : .primary)
                        .swipeActions(edge: .leading) {
                            Button {
                                withAnimation {
                                    todoItems[index].isCompleted.toggle()
                                }
                            } label: {
                                Label("Complete", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                }
            }
            .navigationTitle("MinimalList")
            .refreshable {
                withAnimation {
                    isAddingNew = true
                }
            }
            .onAppear(perform: startMotionDetection)
            .onDisappear(perform: stopMotionDetection)
        }
    }
    
    private func addItem() {
        if !newItemText.isEmpty {
            withAnimation {
                todoItems.append(TodoItem(title: newItemText))
                newItemText = ""
                isAddingNew = false
            }
        }
    }
    
    private func startMotionDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let data = data else { return }
            
            let threshold = 2.0
            if abs(data.acceleration.x) > threshold ||
               abs(data.acceleration.y) > threshold ||
               abs(data.acceleration.z) > threshold {
                clearCompletedItems()
            }
        }
    }
    
    private func stopMotionDetection() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func clearCompletedItems() {
        withAnimation {
            todoItems.removeAll { $0.isCompleted }
        }
    }
}

#Preview {
    ContentView()
}
