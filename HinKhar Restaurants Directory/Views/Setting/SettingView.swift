//
//  SettingView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 30/12/2025.
//
import SwiftUI
import StoreKit

// Reusable row for settings list
private struct SettingRow: View {
    let title: String
    var trailingText: String? = nil
    var titleColor: Color = .primary
    var trailingColor: Color = Color("PrimaryColor")
    var showChevron: Bool = true
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(LocalizedStringKey(title))
                    .foregroundStyle(titleColor)
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                if let trailingText {
                    Text(LocalizedStringKey(trailingText))
                        .font(.custom("Futura-Medium", size: 14.0))
                        .foregroundStyle(trailingColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    Spacer(minLength: 0)
                }

                if showChevron {
                    Image("RightArrow")
                        .renderingMode(.template)
                        .foregroundStyle(titleColor == .red ? .red : Color("SecondaryColor"))
                        .padding(.trailing, 20)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { action() }
            .padding(.bottom, 4)

            Divider()
                .padding(10)
        }
    }
}

struct SettingView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @Environment(\.requestReview) private var requestReview
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToHome: Bool = false
    @State private var navigateToChangePhoneOrEmail: Bool = false
    @State private var navigateToCommonWebView: Bool = false
    @State private var navigateToLogin: Bool = false
    @State private var showDeleteDialog: Bool = false
    @State private var showSuggestionDialog: Bool = false
    //    @State private var suggestionText: String = ""
    
    @State private var showLanguageDialog: Bool = false
    @State private var selectedLanguage: String = "English" // or "Myanmar"
    
    @State private var showContactUsDialog: Bool = false
    
    @State private var userPhone = KeychainManager.shared.get("userPhone") ?? ""
    @State private var userEmail = KeychainManager.shared.get("userEmail") ?? ""
    
    @State private var type = ""
    @State private var value = ""
    
    @State private var selectedWebTitle: String = ""
    @State private var selectedWebType: String = ""
    @State private var selectedWebValue: String = ""
    
    @StateObject var vm = SettingViewModel()
    
    private var displaySetting: [Setting] {
        // If API data exists, map it to display model; otherwise return empty list
        guard !vm.settings.isEmpty else { return [] }
        
        return vm.settings.map { s in
            
            return Setting(
                id: s.id,
                type: s.type,
                title: s.title,
                value: s.value
            )
        }
    }
    
    @State private var displayContacts: [Contact]? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ZStack {
                        // Centered title
                        Text("setting.title")
                            .font(.custom("Futura-Medium", size: 18.0))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Leading back button overlaid
                        HStack {
                            Image("BackArrow")
                                .renderingMode(.template) // optional if you set Template Image
                                .foregroundStyle(Color("PrimaryColor"))
                                .onTapGesture {
                                    dismiss()
                                }
                                .padding(.leading, 24)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                
                //Change Phone Number
                SettingRow(
                    title: userPhone.isEmpty ? "setting.setPhone" : "setting.changePhone",
                    trailingText: userPhone.isEmpty ? "set" : userPhone
                ) {
                    type = "phone"
                    value = userPhone.isEmpty ? "" : userPhone
                    navigateToChangePhoneOrEmail = true
                }
                .padding(.top, 20)
                
                //Change Email Address
                SettingRow(
                    title: userEmail.isEmpty ? "setting.setEmail" : "setting.changeEmail",
                    trailingText: userEmail.isEmpty ? "set" : userEmail
                ) {
                    type = "email"
                    value = userEmail
                    navigateToChangePhoneOrEmail = true
                }
                
                //Change Password
                SettingRow(
                    title: "setting.changePassword",
                    trailingText: "*********"
                ) {
                    // Hook up when ready
                }
                
                //Suggestion to Our App
                SettingRow(title: "setting.suggestion") {
                    showSuggestionDialog = true
                }
                
                //Change Language
                SettingRow(title: "Change Language/ဘာသာစကား") {
                    showLanguageDialog = true
                }
                
                //Privacy Policy
                SettingRow(title: "setting.privacy.policy") {
                    if let aboutSetting = displaySetting.first(where: { $0.type == "privacy" }) {
                        selectedWebTitle = "setting.privacy.policy"
                        selectedWebType = aboutSetting.type
                        selectedWebValue = aboutSetting.value
                    } else {
                        selectedWebTitle = "setting.privacy.policy"
                        selectedWebType = "privacy"
                        selectedWebValue = ""
                    }
                    navigateToCommonWebView = true
                }
                
                //Terms of Service
                SettingRow(title: "setting.terms.of.service") {
                    if let aboutSetting = displaySetting.first(where: { $0.type == "term_service" }) {
                        selectedWebTitle = "setting.terms.of.service"
                        selectedWebType = aboutSetting.type
                        selectedWebValue = aboutSetting.value
                    } else {
                        selectedWebTitle = "setting.terms.of.service"
                        selectedWebType = "term_service"
                        selectedWebValue = ""
                    }
                    navigateToCommonWebView = true
                }
                
                //Contact Us
                SettingRow(title: "setting.contactUs") {
                    if let aboutSetting = displaySetting.first(where: { $0.type == "contact_info" }) {
                        
                        let rawHTML = aboutSetting.value.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Step 1: Extract <p>...</p> content
                        let pattern = "<p>(.*?)</p>"
                        var extractedText = ""

                        if let regex = try? NSRegularExpression(pattern: pattern) {
                            let results = regex.matches(in: rawHTML, range: NSRange(rawHTML.startIndex..., in: rawHTML))
                            
                            // If multiple <p> tags, join them with comma
                            let texts = results.compactMap { match -> String? in
                                if let range = Range(match.range(at: 1), in: rawHTML) {
                                    return String(rawHTML[range])
                                }
                                return nil
                            }
                            
                            extractedText = texts.joined(separator: ",")
                        }

                        // Step 2: Apply your existing logic
                        let cleanText = extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !cleanText.isEmpty, cleanText.contains(",") {
                            let parts = cleanText
                                .split(separator: ",")
                                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

                            self.displayContacts = parts.map {
                                Contact(id: UUID().uuidString, phone: $0)
                            }
                        }
                    }
                    showContactUsDialog = true
                }
                
                //About App
                SettingRow(title: "setting.about") {
                    if let aboutSetting = displaySetting.first(where: { $0.type == "about" }) {
                        selectedWebTitle = "setting.about"
                        selectedWebType = aboutSetting.type
                        selectedWebValue = aboutSetting.value
                    } else {
                        selectedWebTitle = "setting.about"
                        selectedWebType = "about"
                        selectedWebValue = ""
                    }
                    navigateToCommonWebView = true
                }
                
                //Rate Our App
                SettingRow(title: "setting.rate") {
                    requestReview()
                    let appID = "APP_ID"
                    if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                }
                
                //Delete Account
                SettingRow(
                    title: "setting.delete",
                    trailingText: nil,
                    titleColor: .red,
                    trailingColor: .red
                ) {
                    showDeleteDialog = true
                }
                
                // Logout button
                Button {
                    KeychainManager.shared.save("no", forKey: "isLoggedIn")
                    auth.isAuthenticated = false
                    navigateToLogin = true
                } label: {
                    Text("setting.logout")
                        .font(.custom("Futura-Medium", size: 18.0))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 160)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color("PrimaryColor"), lineWidth: 2)
                )
                .padding(.top, 12)
                
                Spacer()
                
                Text(String(format: String(localized: "app.version"), "1.0.0"))
                    .font(.custom("Futura-Medium", size: 12.0))
                    .foregroundStyle(.black)
            }
            .overlay(
                SuggestionDialog(
                    isPresented: $showSuggestionDialog,
                    text: $vm.suggestionText,
                    isSubmitting: vm.isLoadingForSubmitSuggestion
                ) {
                    Task { await vm.submitSuggestion() }
                }
            )
            .overlay(
                LanguageDialog(
                    isPresented: $showLanguageDialog,
                    selectedLanguage: $selectedLanguageCode
                )
            )
            .overlay(
                ContactUsDialog(
                    isPresented: $showContactUsDialog,
                    contacts: $displayContacts
                )
            )
            .overlay(
                DeleteAccountDialog(
                    isPresented: $showDeleteDialog,
                    onCancel: { showDeleteDialog = false },
                    onConfirmDelete: {
                        showDeleteDialog = false
                    }
                )
            )
            .navigationDestination(isPresented: $navigateToChangePhoneOrEmail) {
                ChangePhoneOrEmailView(type: type, value: value)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToCommonWebView) {
                CommonWebView(title: selectedWebTitle, type: selectedWebType, value: selectedWebValue)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .onChange(of: vm.apiSuccessForSubmitSuggestion) { oldValue, newValue in
                if newValue {
                    showSuggestionDialog = false
                    // Optionally clear the text after successful submission
                    vm.suggestionText = ""
                }
            }
            .task {
                await vm.getAllSettings()
            }
            
            if vm.isLoadingForSubmitSuggestion {
                ProgressView("Submitting...")
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
            
            //            if vm.apiSuccessForSubmitSuggestion {
            //                VStack {
            //                    Spacer()
            //                    ToastView(message: "Successfully Submitted.")
            //                        .padding(.horizontal, 16)
            //                        .padding(.vertical, 10)
            //                        .background(Color.green.opacity(0.9))
            //                        .cornerRadius(12)
            //                        .onTapGesture { vm.showError = false }
            //                }
            //                .animation(.easeInOut, value: "Submit Success")
            //            }
        }
        .toast(
            isPresented: $vm.apiSuccessForSubmitSuggestion,
            message: "Successfully Submitted."
        )
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

#Preview {
    SettingView()
        .environmentObject(AuthViewModel())
}

