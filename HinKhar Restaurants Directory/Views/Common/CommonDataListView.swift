import SwiftUI

struct CommonDataListView: View {
    // Accept from caller
    let title: String
    let tag: String
    let id: Int

    init(
        title: String = "",
        tag: String = "",
        id: Int = 0
    ){
        self.title = title
        self.tag = tag
        self.id = id
    }
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    @State private var searchValue: String = ""
    @State private var navigateToUpdateProfile: Bool = false

    @StateObject private var vm = GeneralDataViewModel()

    // Derived display list based on tag
    private var displayItems: [GeneralData] {
        switch tag {
        case "region":
            let regions = vm.regions ?? []
            return regions.map { r in
                GeneralData(id: r.id, name: r.name, nameMM: r.name_mm)
            }
        case "district":
            let districts = vm.districts ?? []
            return districts.map { d in
                GeneralData(id: d.id, name: d.name, nameMM: d.name_mm)
            }
        case "township":
            let townships = vm.townships ?? []
            return townships.map { t in
                GeneralData(id: t.id, name: t.name, nameMM: t.name_mm)
            }
        case "gender":
            return [
                GeneralData(id: 1, name: "Male", nameMM: "ကျား"),
                GeneralData(id: 2, name: "Female", nameMM: "မ")
            ]
        default:
            return []
        }
    }

    // Filtered by search
    private var filteredItems: [GeneralData] {
        guard !searchValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return displayItems
        }
        let query = searchValue.lowercased()
        return displayItems.filter { item in
            item.name.lowercased().contains(query) || item.nameMM.lowercased().contains(query)
        }
    }

    @State private var selectedId: Int = 0
    @State private var selectedName: String = ""
    @State private var selectedNameMM: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBar(title: title) {
                    navigateToUpdateProfile = true
                }

                SearchField(text: $searchValue)
                    .font(.custom("Futura-Medium", size: 16.0))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)

                // Unified Data List
                if !filteredItems.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredItems) { generalData in
                                CommonDataRow(generalData: generalData, currentLanguage: selectedLanguageCode)
                                    .padding(.horizontal, 24)
                                    .onTapGesture { handleSelection(generalData) }
                            }
                        }
                    }
                } else {
                    Text(emptyStateText)
                    .font(.custom("FuturaCyrillicMedium", size: 16.0))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding(.top, 0)
            .navigationDestination(isPresented: $navigateToUpdateProfile) {
                UpdateProfileView(
                    selectedId: selectedId,
                    selectedName: selectedName,
                    selectedNameMM: selectedNameMM,
                    tagFromCommonData: tag
                )
                .navigationBarBackButtonHidden(true)
            }
        }
        .task {
            await loadData()
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }

    // MARK: - Helpers

    private var emptyStateText: String {
        switch tag {
        case "region": return "No region available"
        case "district": return "No district available"
        case "township": return "No township available"
        case "gender": return "No option available"
        default: return "No data available"
        }
    }

    private func handleSelection(_ item: GeneralData) {
        selectedId = item.id
        selectedName = item.name
        selectedNameMM = item.nameMM
        navigateToUpdateProfile = true
    }

    private func loadData() async {
        switch tag {
        case "region":
            await vm.getRegions()
        case "district":
            await vm.getDistrictsByRegionId(regionId: id)
        case "township":
            await vm.getTownshipsByDistrictId(districtId: id)
        case "gender":
            break
        default:
            break
        }
    }
}

// MARK: - Subviews

private struct TitleBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(LocalizedStringKey(title))
                .font(.custom("Futura-Medium", size: 18.0))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)

            HStack {
                Image("BackArrow")
                    .renderingMode(.template)
                    .foregroundStyle(Color("PrimaryColor"))
                    .padding(.leading, 24)
                    .onTapGesture { onBack() }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

private struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("search")
                        .foregroundStyle(.black.opacity(0.6))
                }
                TextField("", text: $text)
                    .padding(.vertical, 12)
                    .keyboardType(.default)
                    .textContentType(.name)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.black)
            }
            .padding(.horizontal, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("PrimaryColor"), lineWidth: 1)
            )
        }
    }
}

#Preview {
    CommonDataListView(title: "Title", tag: "")
}
