import SwiftUI

struct AddGearItemView: View {
    // 1. Access the managed object context
    @Environment(\.managedObjectContext) private var viewContext
    // 2. Environment variable to dismiss the sheet
    @Environment(\.dismiss) private var dismiss

    // Fetch all manufacturers and gear types to populate the pickers
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Manufacturer.name, ascending: true)])
    private var manufacturers: FetchedResults<Manufacturer>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GearType.name, ascending: true)])
    private var gearTypes: FetchedResults<GearType>

    // State to hold the form data
    @State private var name: String = ""
    @State private var selectedManufacturer: Manufacturer?
    @State private var selectedGearTypes = Set<GearType>()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gear Details")) {
                    TextField("Gear Name", text: $name)

                    Picker("Manufacturer", selection: $selectedManufacturer) {
                        Text("Select a Manufacturer").tag(nil as Manufacturer?)
                        ForEach(manufacturers) { manufacturer in
                            Text(manufacturer.name ?? "").tag(manufacturer as Manufacturer?)
                        }
                    }

                    NavigationLink(destination: SelectGearTypesView(selectedGearTypes: $selectedGearTypes)) {
                        HStack {
                            Text("Gear Types")
                            Spacer()
                            Text("\(selectedGearTypes.count) selected")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add New Gear")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        dismiss()
                    }
                    .disabled(name.isEmpty) // Disable save if name is empty
                }
            }
        }
    }

    private func saveItem() {
        withAnimation {
            let newItem = GearItem(context: viewContext)
            newItem.name = name
            newItem.manufacturer = selectedManufacturer
            newItem.gearType = selectedGearTypes as NSSet

            do {
                try viewContext.save()
            } catch {
                ErrorHandler.shared.handle(error, context: "Saving gear item")
            }
        }
    }
}

struct AddGearItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddGearItemView()
    }
}
