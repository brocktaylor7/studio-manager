import SwiftUI
import CoreData

struct ManageManufacturersView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Manufacturer.name, ascending: true)])
    private var manufacturers: FetchedResults<Manufacturer>

    @State private var newManufacturerName = ""
    @State private var showingAddAlert = false

    var body: some View {
        List {
            ForEach(manufacturers) { manufacturer in
                Text(manufacturer.name ?? "")
            }
            .onDelete(perform: deleteManufacturers)
        }
        .navigationTitle("Manufacturers")
        .toolbar {
            ToolbarItem {
                Button(action: { showingAddAlert.toggle() }) {
                    Label("Add Manufacturer", systemImage: "plus")
                }
            }
        }
        .alert("New Manufacturer", isPresented: $showingAddAlert) {
            TextField("Name", text: $newManufacturerName)
            Button("Save", action: addManufacturer)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the name for the new manufacturer.")
        }
    }

    private func addManufacturer() {
        withAnimation {
            let newManufacturer = Manufacturer(context: viewContext)
            newManufacturer.name = newManufacturerName

            do {
                try viewContext.save()
                newManufacturerName = "" // Reset for next use
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteManufacturers(offsets: IndexSet) {
        withAnimation {
            offsets.map { manufacturers[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ManageManufacturersView_Previews: PreviewProvider {
    static var previews: some View {
        ManageManufacturersView()
    }
}
