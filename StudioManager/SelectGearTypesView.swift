import SwiftUI
import CoreData

struct SelectGearTypesView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GearType.name, ascending: true)])
    private var allGearTypes: FetchedResults<GearType>

    @Binding var selectedGearTypes: Set<GearType>

    var body: some View {
        List(allGearTypes, id: \.self) { gearType in
            Button(action: {
                toggleSelection(for: gearType)
            }) {
                HStack {
                    Text(gearType.name ?? "Unknown Type")
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedGearTypes.contains(gearType) {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .navigationTitle("Select Gear Types")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleSelection(for gearType: GearType) {
        if selectedGearTypes.contains(gearType) {
            selectedGearTypes.remove(gearType)
        } else {
            selectedGearTypes.insert(gearType)
        }
    }
}
