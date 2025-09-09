import SwiftUI
import CoreData

struct ManageGearTypesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GearType.name, ascending: true)])
    private var gearTypes: FetchedResults<GearType>

    @State private var newGearTypeName = ""
    @State private var showingAddAlert = false

    var body: some View {
        List {
            ForEach(gearTypes) { gearType in
                Text(gearType.name ?? "")
            }
            .onDelete(perform: deleteGearTypes)
        }
        .navigationTitle("Gear Types")
        .toolbar {
            ToolbarItem {
                Button(action: { showingAddAlert.toggle() }) {
                    Label("Add Gear Type", systemImage: "plus")
                }
            }
        }
        .alert("New Gear Type", isPresented: $showingAddAlert) {
            TextField("Name", text: $newGearTypeName)
            Button("Save", action: addGearType)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the name for the new gear type.")
        }
    }

    private func addGearType() {
        withAnimation {
            let newGearType = GearType(context: viewContext)
            newGearType.name = newGearTypeName

            do {
                try viewContext.save()
                newGearTypeName = "" // Reset for next use
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteGearTypes(offsets: IndexSet) {
        withAnimation {
            offsets.map { gearTypes[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ManageGearTypesView_Previews: PreviewProvider {
    static var previews: some View {
        ManageGearTypesView()
    }
}
