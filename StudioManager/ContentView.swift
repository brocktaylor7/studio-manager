//
//  ContentView.swift
//  StudioManager
//
//  Created by Brock Taylor on 9/8/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GearItem.name, ascending: true)],
        animation: .default)
    private var gearItems: FetchedResults<GearItem>

    @State private var showingAddSheet = false
    @State private var showingSettingsSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(gearItems) { gearItem in
                    Text(gearItem.name ?? "New Gear")
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Gear List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettingsSheet.toggle()
                    }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        showingAddSheet.toggle()
                    }) {
                        Label("Add Gear", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddGearItemView()
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
            }
            
            Text("Select an item")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { gearItems[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
