//
//  ProfileView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 07/12/2025.
//
import SwiftUI

struct ProfileView: View {
    init(isTabBarHidden: Binding<Bool>) {
        self._isTabBarHidden = isTabBarHidden
    }
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @Binding var isTabBarHidden: Bool
    
    @State private var navigateToSearch: Bool = false
    @State private var navigateToSetting: Bool = false
    @State private var navigateToUpdateProfile: Bool = false
    @State private var navigateToFavorite: Bool = false
    
    // Replace these with your actual user data source
    @State private var profileImageName: String? = nil
    @State private var displayName: String = "Your Name"
    @State private var memberSinceDate: String = "18, October 2025"
    @State private var durationText: String = ""
    
    @State private var showInfo = false
    
    @StateObject var vm = ProfileViewModel()
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {
                // Search and Setting
                
                if !isLoading {
                    HStack(spacing: 8) {
                        Image("Search")
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(Color("SecondaryColor"))
                            .onTapGesture {
                                navigateToSearch = true
                                isTabBarHidden = true
                            }
                        Image("Setting")
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(Color("PrimaryColor"))
                            .onTapGesture {
                                navigateToSetting = true
                                isTabBarHidden = true
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 24)
                    
                    
                    // Profile Image
                    HStack {
                        VStack(spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                Group {
                                    if let imageName = profileImageName, !imageName.isEmpty {
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(Color("PrimaryColor"))
                                            Text(String((vm.user?.name ?? displayName).trimmingCharacters(in: .whitespacesAndNewlines).first ?? "?"))
                                                .textCase(.uppercase)
                                                .font(.custom("Futura-Bold", size: 48.0))
                                                .foregroundStyle(.white)
                                        }
                                        .frame(width: 160, height: 160)
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color("SecondaryColor"), lineWidth: 3)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)

                                // Camera overlay button
                                Button(action: {
                                    // handle camera tap (e.g., present image picker)
                                }) {
                                    ZStack {
                                        
                                        // Use asset named "Camera" if available, else SF Symbol
                                        Image("CameraProfile")
                                            .symbolRenderingMode(.monochrome)
                                        .foregroundStyle(Color("SecondaryColor"))
                                        .frame(width: 22, height: 22)
                                    }
                                }
                                .offset(x: -26, y: -4)
                            }

                            Text("profile.welcome")
                                .font(.custom("Futura-Medium", size: 20.0))
                                .foregroundStyle(.black)
                            
                            Text(vm.user?.name ?? displayName)
                                .font(.custom("Futura-Bold", size: 20.0))
                                .foregroundStyle(.black)
                            
                            HStack(spacing: 6) {
                                Text("Member since")
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .foregroundStyle(Color("PrimaryColor"))
                                
                                
                                Text(formatDateString(vm.user?.created_at ?? memberSinceDate) ?? memberSinceDate)
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .foregroundStyle(Color("PrimaryColor"))
                            }
                            
                            Text("Congratulations! You’ve been a valued member for \(durationText)")
                                .font(.custom("FuturaCyrillicMedium", size: 14.0))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .onAppear {
                                    durationText = calculateTimePeriod(from: vm.user?.created_at ?? "") ?? ""
                                }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            VStack(alignment: .center, spacing: 8) {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "phone.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                            .foregroundStyle(Color("PrimaryColor"))
                                        
                                        Text(LocalizedStringKey(vm.user?.phone ?? "not.set"))
                                            .font(.custom("Futura-Medium", size: 17.0))
                                            .foregroundStyle(.black)
                                            .frame(maxWidth : 200, alignment: .leading)
                                    }
                                    
                                    HStack(spacing: 16) {
                                        Image("Email")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                            .foregroundStyle(Color("PrimaryColor"))
                                        
                                        Text(LocalizedStringKey(vm.user?.email ?? "not.set"))
                                            .font(.custom("Futura-Medium", size: 17.0))
                                            .foregroundStyle(.black)
                                            .frame(maxWidth : 200, alignment: .leading)
                                    }
                                }
                                
                                if !showInfo {
                                    HStack {
                                        Image("DownArrow")
                                            .frame(width: 32, height: 16)
                                            .foregroundStyle(Color("SecondaryColor"))
                                            .onTapGesture {
                                                withAnimation {
                                                    showInfo = true
                                                }
                                            }
                                    }
                                    .padding(.top, 10)
                                }
                                
                                // Show/Hide Info
                                if showInfo {
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 14) {
                                            Image("Gender")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(Color("PrimaryColor"))
                                            
                                            Text(LocalizedStringKey(vm.user?.gender?.capitalizingFirstLetter() ?? "not.set"))
                                                .font(.custom("Futura-Medium", size: 17.0))
                                                .foregroundStyle(.black)
                                                .frame(maxWidth : 200, alignment: .leading)
                                        }
                                        .frame(alignment: .leading)
                                        
                                        HStack(spacing: 16) {
                                            Image("DateOfBirth")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(Color("PrimaryColor"))
                                            
                                            Text(LocalizedStringKey(vm.user?.date_of_birth ?? "not.set"))
                                                .font(.custom("Futura-Medium", size: 17.0))
                                                .foregroundStyle(.black)
                                                .frame(maxWidth : 200, alignment: .leading)
                                        }
                                        
                                        HStack(spacing: 16) {
                                            Image("Location")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(Color("PrimaryColor"))
                                            
                                            Text(LocalizedStringKey(vm.user?.township?.name ?? "not.set"))
                                                .font(.custom("Futura-Medium", size: 17.0))
                                                .foregroundStyle(.black)
                                                .frame(maxWidth : 200, alignment: .leading)
                                        }
                                        
                                        HStack(spacing: 16) {
                                            Image("Location")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(Color("PrimaryColor"))
                                            
                                            Text(LocalizedStringKey(vm.user?.district?.name ?? "not.set"))
                                                .font(.custom("Futura-Medium", size: 17.0))
                                                .foregroundStyle(.black)
                                                .frame(maxWidth : 200, alignment: .leading)
                                        }
                                        
                                        HStack(spacing: 16) {
                                            Image("Location")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(Color("PrimaryColor"))
                                            
                                            Text(LocalizedStringKey(vm.user?.region?.name ?? "not.set"))
                                                .font(.custom("Futura-Medium", size: 17.0))
                                                .foregroundStyle(.black)
                                                .frame(maxWidth : 200, alignment: .leading)
                                        }
                                        
                                        HStack(spacing: 16) {
                                            Image("Home")
                                                .renderingMode(.template)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundStyle(Color("PrimaryColor"))
                                            
                                            Text(LocalizedStringKey(vm.user?.address ?? "not.set"))
                                                .font(.custom("Futura-Medium", size: 17.0))
                                                .foregroundStyle(.black)
                                                .frame(maxWidth : 200, alignment: .leading)
                                        }
                                    }
                                    
                                    HStack {
                                        Image("UpArrow")
                                            .frame(width: 32, height: 16)
                                            .foregroundStyle(Color("SecondaryColor"))
                                            .onTapGesture {
                                                withAnimation {
                                                    showInfo = false
                                                }
                                            }
                                    }
                                    .padding(.top, 10)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            VStack(alignment: .center) {
                                Button {
                                    navigateToUpdateProfile = true
                                    isTabBarHidden = true
                                } label: {
                                    Text("profile.button.update")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: 250)
                                    Image("RegisterRightArrow")
                                        .renderingMode(.template)
                                        .foregroundStyle(.white)
                                        .frame(height: 40)
                                        .padding(.trailing, 24)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color("PrimaryColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(.white, lineWidth: 2)
                                )
                                .padding(20)
                                
                                Button {
                                    navigateToFavorite = true
                                    isTabBarHidden = true
                                } label: {
                                    Text("profile.button.favorite")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: 250)
                                    Image("RegisterRightArrow")
                                        .renderingMode(.template)
                                        .foregroundStyle(.white)
                                        .frame(height: 40)
                                        .padding(.trailing, 24)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color("PrimaryColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(.white, lineWidth: 2)
                                )
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom, 100)
                    }
                }
                else {
                    CommonLoading()
                }
                
                
            }
            .navigationDestination(isPresented: $navigateToSearch) {
                SearchView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToSetting) {
                SettingView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToUpdateProfile) {
                UpdateProfileView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToFavorite) {
                FavoritesView()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear { isTabBarHidden = false }
            .task {
                isLoading = true
                await vm.getUser()
                await MainActor.run {
                    isLoading = false
                }
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
        
    }
    
    private func formatDateString(_ isoDateString: String) -> String? {
        // Input formatter (ISO 8601 with timezone)
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        // Try without fractional seconds first
        var date = inputFormatter.date(from: isoDateString)
        
        // If it fails (no fractional seconds), try basic format
        if date == nil {
            inputFormatter.formatOptions = [.withInternetDateTime]
            date = inputFormatter.date(from: isoDateString)
        }
        
        guard let validDate = date else { return nil }
        
        // Output formatter
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd, MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return outputFormatter.string(from: validDate)
    }
    
    private func calculateTimePeriod(from isoDateString: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let targetDate = formatter.date(from: isoDateString) else {
            return nil
        }
        
        let now = Date()
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: targetDate,
            to: now
        )
        
//        return """
//        \(components.year ?? 0) year \
//        \(components.month ?? 0) month \
//        \(components.day ?? 0) day
//        """
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        // If everything is 0 → just now
        if years == 0 && months == 0 && days == 0 {
            return "just now"
        }
        
        var parts: [String] = []
        
        if years > 0 {
            parts.append("\(years) year" + (years > 1 ? "s" : ""))
        }
        
        if months > 0 {
            parts.append("\(months) month" + (months > 1 ? "s" : ""))
        }
        
        if days > 0 {
            parts.append("\(days) day" + (days > 1 ? "s" : ""))
        }
        
        return parts.joined(separator: ", ")
    }
}

#Preview {
    ProfileView(isTabBarHidden: .constant(false))
}

