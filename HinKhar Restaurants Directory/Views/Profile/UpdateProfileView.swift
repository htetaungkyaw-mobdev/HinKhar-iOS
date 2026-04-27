//
//  UpdateProfileView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 24/02/2026.
//
import SwiftUI

struct UpdateProfileView: View {
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @State private var navigateToProfile: Bool = false
    @State private var navigateToCommonDataList: Bool = false
    
    @State private var title: String = ""
    @State private var tag: String = ""
    @State private var idToPass: Int = 0
    
    @State private var enterName = false
    
    @State private var selectGender = false
    
    @State private var dob: String = ""
    @State private var selectDob = false
    @State private var showDatePicker = false
    @State private var tempDate: Date = Date()
    
    private var dobFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f
    }
    
    @State private var selectRegion = false
    
    @State private var selectDistrict = false
    
    @State private var selectTownship = false
    
    @State private var enterAddress = false
    
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
    @StateObject var vm = ProfileViewModel()
    @State private var isLoading: Bool = true
    
    let selectedId: Int
    let selectedName: String
    let selectedNameMM: String
    let tagFromCommonData: String
    
    init(
        selectedId: Int = 0,
        selectedName: String = "",
        selectedNameMM: String = "",
        tagFromCommonData: String = "",
        )
    {
        self.selectedId = selectedId
        self.selectedName = selectedName
        self.selectedNameMM = selectedNameMM
        self.tagFromCommonData = tagFromCommonData
        
        switch tagFromCommonData {
        case "gender":
            KeychainManager.shared.save(selectedName, forKey: "userGender")
        case "region":
            KeychainManager.shared.save(String(selectedId), forKey: "userRegionId")
            KeychainManager.shared.save(selectedName, forKey: "userRegionName")
            KeychainManager.shared.save(selectedNameMM, forKey: "userRegionNameMM")
        case "district":
            KeychainManager.shared.save(String(selectedId), forKey: "userDistrictId")
            KeychainManager.shared.save(selectedName, forKey: "userDistrictName")
            KeychainManager.shared.save(selectedNameMM, forKey: "userDistrictNameMM")
        case "township":
            KeychainManager.shared.save(String(selectedId), forKey: "userTownshipId")
            KeychainManager.shared.save(selectedName, forKey: "userTownshipName")
            KeychainManager.shared.save(selectedNameMM, forKey: "userTownshipNameMM")
        default:
            break
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !isLoading {
                    // Title
                    HStack {
                        ZStack {
                            // Centered title
                            Text("profile.button.update")
                                .font(.custom("Futura-Medium", size: 18.0))
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Leading back button overlaid
                            HStack {
                                Image("BackArrow")
                                    .renderingMode(.template) // optional if you set Template Image
                                    .foregroundStyle(Color("PrimaryColor"))
                                    .onTapGesture {
                                        navigateToProfile = true
                                    }
                                    .padding(.leading, 24)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                    
                    VStack(spacing: 12) {
                        // Name
                        VStack(spacing: 4) {
                            Text("update.profile.name")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                ZStack(alignment: .leading) {
                                    if vm.name.isEmpty {
                                        Text("register.placeholder.name")
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(.black.opacity(0.6))
                                    }
                                    //                                TextField("", text: vm.user?.name)
                                    TextField("", text: $vm.name)
                                        .font(.custom("Futura-Medium", size: 16.0))
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
                        
                        // Gender
                        VStack(spacing: 4) {
                            Text("update.profile.gender")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                ZStack(alignment: .leading) {
                                    if vm.gender.isEmpty {
                                        Text("update.placeholder.select")
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(.black.opacity(0.6))
                                            .padding(.vertical, 12)
                                    }
                                    HStack {
                                        Text(vm.gender)
                                            .padding(.vertical, 12)
                                            .autocorrectionDisabled()
                                            .foregroundStyle(.black)
                                        //                                        .disabled(true)
                                        Spacer()
                                        Image("DropDown")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("PrimaryColor"), lineWidth: 1)
                                )
                            }
                            .onTapGesture {
                                title = "gender.title"
                                tag = "gender"
                                idToPass = 0
                                navigateToCommonDataList = true
                            }
                        }
                        
                        // Dob
                        VStack(spacing: 4) {
                            Text("update.profile.dob")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                ZStack(alignment: .leading) {
                                    if vm.dob.isEmpty {
                                        Text("update.placeholder.select")
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(.black.opacity(0.6))
                                            .padding(.vertical, 12)
                                    }
                                    HStack {
                                        Text(vm.dob)
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .padding(.vertical, 12)
                                            .autocorrectionDisabled()
                                            .foregroundStyle(.black)
                                        //                                        .disabled(true)
                                        Spacer()
                                        Image("Calendar")
                                    }
                                }
                                .onTapGesture {
                                    // Initialize tempDate from current dob if available
                                    if let current = dobFormatter.date(from: vm.dob) {
                                        tempDate = current
                                    } else {
                                        tempDate = Date()
                                    }
                                    showDatePicker = true
                                }
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("PrimaryColor"), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Region
                        VStack(spacing: 4) {
                            Text("update.profile.region")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                ZStack(alignment: .leading) {
                                    if vm.regionName.isEmpty {
                                        Text("update.placeholder.select")
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(.black.opacity(0.6))
                                            .padding(.vertical, 12)
                                    }
                                    HStack {
                                        Text(vm.regionName)
                                            .padding(.vertical, 12)
                                            .autocorrectionDisabled()
                                            .foregroundStyle(.black)
                                        //                                        .disabled(true)
                                        Spacer()
                                        Image("DropDown")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("PrimaryColor"), lineWidth: 1)
                                )
                            }
                        }
                        .onTapGesture {
                            title = "region.title"
                            tag = "region"
                            idToPass = 0
                            navigateToCommonDataList = true
                        }
                        
                        // District
                        VStack(spacing: 4) {
                            Text("update.profile.district")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                ZStack(alignment: .leading) {
                                    if vm.districtName.isEmpty {
                                        Text("update.placeholder.select")
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(.black.opacity(0.6))
                                            .padding(.vertical, 12)
                                    }
                                    HStack {
                                        Text(vm.districtName)
                                            .padding(.vertical, 12)
                                            .autocorrectionDisabled()
                                            .foregroundStyle(.black)
                                        //                                        .disabled(true)
                                        Spacer()
                                        Image("DropDown")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("PrimaryColor"), lineWidth: 1)
                                )
                            }
                        }
                        .onTapGesture {
                            if vm.regionId == 0 {
                                alertMessage = "alert.regionRequired"
                                showAlert = true
                            }
                            else {
                                title = "district.title"
                                tag = "district"
                                idToPass = vm.regionId
                                navigateToCommonDataList = true
                            }
                        }
                        
                        // Township
                        VStack(spacing: 4) {
                            Text("update.profile.township")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                ZStack(alignment: .leading) {
                                    if vm.townshipName.isEmpty {
                                        Text("update.placeholder.select")
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(.black.opacity(0.6))
                                            .padding(.vertical, 12)
                                    }
                                    HStack {
                                        Text(vm.townshipName)
                                            .padding(.vertical, 12)
                                            .autocorrectionDisabled()
                                            .foregroundStyle(.black)
                                        //                                        .disabled(true)
                                        Spacer()
                                        Image("DropDown")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("PrimaryColor"), lineWidth: 1)
                                )
                            }
                            .onTapGesture {
                                if vm.districtId == 0 {
                                    alertMessage = "alert.districtRequired"
                                    showAlert = true
                                }
                                else {
                                    title = "township.title"
                                    tag = "township"
                                    idToPass = vm.districtId
                                    print("vm.districtId = \(vm.districtId)")
                                    navigateToCommonDataList = true
                                }
                            }
                        }
                        
                        // Address
                        VStack(spacing: 4) {
                            Text("update.profile.address")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                ZStack(alignment: .leading) {
                                    if vm.address.isEmpty {
                                        Text("")
                                            .foregroundStyle(.black.opacity(0.6))
                                    }
                                    HStack {
                                        TextField("", text: $vm.address)
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .padding(.vertical, 32)
                                            .autocorrectionDisabled()
                                            .foregroundStyle(.black)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("PrimaryColor"), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Update button
                        Button {
                            Task { await vm.updateUser(
                                name: vm.name
                                ,
                                gender: vm.gender.lowercased(),
                                dob: vm.dob,
                                townshipId: vm.townshipId,
                                address: vm.address
                            )
                            }
                        } label: {
                            Text("update.profile.button")
                                .font(.custom("Futura-Medium", size: 18.0))
                                .foregroundStyle(Color("PrimaryColor"))
                                .frame(maxWidth: 160)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("SecondaryColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.top, 12)
                    }
                    .padding(20)
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                else {
                    VStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color("PrimaryColor"))
                            .padding(.top, 40)
                    }
                }
                
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker("alert.selectDate", selection: $tempDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                    HStack {
                        Button("alert.cancel") {
                            showDatePicker = false
                        }
                        .padding()
                        Spacer()
                        Button("alert.done") {
                            vm.dob = dobFormatter.string(from: tempDate)
                            showDatePicker = false
                            KeychainManager.shared.save(vm.dob, forKey: "userDob")
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
                .presentationDetents([.height(300)])
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(LocalizedStringKey(alertMessage)))
            }
            .navigationDestination(isPresented: $vm.updateSuccess) {
                CustomTabView(selectedTab: .profile)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                CustomTabView(selectedTab: .profile)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToCommonDataList) {
                CommonDataListView(
                    title: title,
                    tag: tag,
                    id: idToPass
                )
                .navigationBarBackButtonHidden(true)
            }
            .task {
                if tagFromCommonData.isEmpty {
                    isLoading = true
                    await vm.getUser()
                    isLoading = false
                } else {
                    // Apply selection coming back from CommonDataListView
                    
                    vm.name = KeychainManager.shared.get("userName")!
                    vm.gender = KeychainManager.shared.get("userGender")!
                    vm.dob = KeychainManager.shared.get("userDob")!
                    vm.regionId = Int(KeychainManager.shared.get("userRegionId")!) ?? 0
                    vm.regionName = KeychainManager.shared.get("userRegionName")!
                    vm.regionNameMM = KeychainManager.shared.get("userRegionNameMM")!
                    vm.districtId = Int(KeychainManager.shared.get("userDistrictId")!) ?? 0
                    vm.districtName = KeychainManager.shared.get("userDistrictName")!
                    vm.districtNameMM = KeychainManager.shared.get("userDistrictNameMM")!
                    vm.townshipId = Int(KeychainManager.shared.get("userTownshipId")!) ?? 0
                    vm.townshipName = KeychainManager.shared.get("userTownshipName")!
                    vm.townshipNameMM = KeychainManager.shared.get("userTownshipNameMM")!
                    vm.address = KeychainManager.shared.get("userAddress")!
                    
                    switch tagFromCommonData {
                    case "gender":
                        vm.gender = selectedName
                    case "region":
                        vm.regionId = selectedId
                        vm.regionName = selectedName
                        // Clear dependent selections if needed
                        vm.districtId = 0; vm.districtName = ""
                        vm.townshipId = 0; vm.townshipName = ""
                    case "district":
                        vm.districtId = selectedId
                        vm.districtName = selectedName
                        vm.townshipId = 0; vm.townshipName = ""
                    case "township":
                        vm.townshipId = selectedId
                        vm.townshipName = selectedName
                    default:
                        break
                    }
                    isLoading = false
                }
            }
            
            if vm.isLoadingForUpdate {
                ProgressView("Updating...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            if vm.showError {
                VStack {
                    Spacer()
                    ToastView(message: vm.errorMessage)
                        .onTapGesture { vm.showError = false }
                }
                .animation(.easeInOut, value: vm.showError)
            }
            
            if vm.updateSuccess {
                VStack {
                    Spacer()
                    ToastView(message: "Successfully Updated.")
                        .onTapGesture { vm.showError = false }
                }
                .animation(.easeInOut, value: "Login Success")
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

#Preview {
    UpdateProfileView(
        selectedId: 0,
        selectedName: "",
        selectedNameMM: "",
        tagFromCommonData: "")
}
