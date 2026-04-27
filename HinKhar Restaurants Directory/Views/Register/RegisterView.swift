//
//  RegisterView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 04/12/2025.
//
import SwiftUI
import WebKit

struct RegisterView: View {
    enum Language: String, CaseIterable, Identifiable {
        case mm = "MM"
        case en = "EN"
        var id: String { rawValue }
    }

    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    @State private var selectedLanguage: Language = .en
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var agreedToTerms: Bool = false
    @Environment(\.openURL) private var openURL
    
    @State private var navigateToLogin = false
    @State private var navigateToHome = false
    @State private var showAlert = false
    @State private var navigateToCommonWebView = false
    
    @StateObject var vm = RegisterViewModel()
    @StateObject var setting_vm = SettingViewModel()
    
    @State private var showPolicySheet = false
    @State private var policyHTML: String = ""
    @State private var selectedWebValue: String = ""
    
    private var displaySetting: [Setting] {
        // If API data exists, map it to display model; otherwise return empty list
        guard !setting_vm.settings.isEmpty else { return [] }
        
        return setting_vm.settings.map { s in
            
            return Setting(
                id: s.id,
                type: s.type,
                title: s.title,
                value: s.value
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                Image("BackArrow")
                       .renderingMode(.template) // optional if you set Template Image
                       .foregroundStyle(.white)
                       .onTapGesture {
                           navigateToLogin = true
                       }
                       .frame(maxWidth: .infinity, alignment: .leading)
                       .padding(.leading, 24)
                
                VStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.tint)
                }
                
                VStack(alignment: .center, spacing: 16) {
                    VStack {
                        Text("register.title")
                            .font(.custom("Futura-Medium", size: 20.0))
                            .foregroundStyle(.primary)
                        
                        Text("register.to.be")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .foregroundStyle(.primary)
                    }

                    VStack(spacing: 12) {
                        // Name field
                        HStack {
                            VStack {
                                Image(systemName: "person.fill")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("SecondaryColor"))
                            )
                            
                            ZStack(alignment: .leading) {
                                if phone.isEmpty {
                                    Text("register.placeholder.name")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundStyle(Color("WhiteColor").opacity(0.6))
                                }
                                TextField("", text: $phone)
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .padding(.vertical, 12)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .foregroundStyle(Color("WhiteColor"))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("PrimaryColor"))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("PrimaryColor"))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.top, 30)
                        
                        // Password field
                        HStack {
                            VStack {
                                Image(systemName: "lock.fill")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("SecondaryColor"))
                            )

                            ZStack(alignment: .leading) {
                                if password.isEmpty {
                                    Text("register.placeholder.password")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundStyle(Color("WhiteColor").opacity(0.6))
                                }
                                Group {
                                    if isPasswordVisible {
                                        TextField("", text: $password)
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(Color("WhiteColor"))
                                            .textContentType(.password)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                    } else {
                                        SecureField("", text: $password)
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(Color("WhiteColor"))
                                            .textContentType(.password)
                                    }
                                }
                                .padding(.vertical, 12)
                            }

                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(.white)
                                    .padding(8)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("PrimaryColor"))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Confirm Password field
                        HStack {
                            VStack {
                                Image(systemName: "lock.fill")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("SecondaryColor"))
                            )

                            ZStack(alignment: .leading) {
                                if password.isEmpty {
                                    Text("register.placeholder.confirmPassword")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundStyle(Color("WhiteColor").opacity(0.6))
                                }
                                Group {
                                    if isPasswordVisible {
                                        TextField("", text: $password)
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(Color("WhiteColor"))
                                            .textContentType(.password)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                    } else {
                                        SecureField("", text: $password)
                                            .font(.custom("Futura-Medium", size: 16.0))
                                            .foregroundStyle(Color("WhiteColor"))
                                            .textContentType(.password)
                                    }
                                }
                                .padding(.vertical, 12)
                            }

                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(.white)
                                    .padding(8)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("PrimaryColor"))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        HStack {
                            Button {
                                agreedToTerms.toggle()
                            } label: {
                                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color("SecondaryColor"))
                                    .accessibilityLabel("Agree to terms")
                                    .accessibilityAddTraits(.isButton)
                            }

                            if selectedLanguageCode == "my" {
                                Group {
                                    let attributed: AttributedString = {
                                        var a = AttributedString("ကိုယ်ရေးအချက်အလက်မူဝါဒနှင့် ဝန်ဆောင်မှုစည်းမျဉ်းများကို သဘောတူပါသည်")
                                        if let range = a.range(of: "ကိုယ်ရေးအချက်အလက်မူဝါဒ") {
                                            a[range].underlineStyle = .single
                                            a[range].foregroundColor = .blue
                                            a[range].link = URL(string: "hinkhar://privacy-policy")
                                        }
                                        if let range2 = a.range(of: "ဝန်ဆောင်မှုစည်းမျဉ်းများ") {
                                            a[range2].underlineStyle = .single
                                            a[range2].foregroundColor = .blue
                                            a[range2].link = URL(string: "hinkhar://terms-of-service")
                                        }
                                        return a
                                    }()
                                    Text(attributed)
                                        .font(.custom("Futura-Medium", size: 12.0))
                                }
                            }
                            else {
                                Group {
                                    let attributed: AttributedString = {
                                        var a = AttributedString("Agree to Privacy Policy and Terms of Service")
                                        if let range = a.range(of: "Privacy Policy") {
                                            a[range].underlineStyle = .single
                                            a[range].foregroundColor = .blue
                                            a[range].link = URL(string: "hinkhar://privacy-policy")
                                        }
                                        if let range2 = a.range(of: "Terms of Service") {
                                            a[range2].underlineStyle = .single
                                            a[range2].foregroundColor = .blue
                                            a[range2].link = URL(string: "hinkhar://terms-of-service")
                                        }
                                        return a
                                    }()
                                    Text(attributed)
                                        .font(.custom("Futura-Medium", size: 12.0))
                                }
                            }
                        }
                        .environment(\._openURL, OpenURLAction { url in
                            guard url.scheme == "hinkhar" else { return .discarded }
                            switch url.host {
                            case "privacy-policy":
                                if let aboutSetting = displaySetting.first(where: { $0.type == "privacy" }) {
                                    selectedWebValue = aboutSetting.value
                                } else {
                                    selectedWebValue = "No Privacy Policy"
                                }
                                policyHTML = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"></head><body><h2>Privacy Policy</h2>\(selectedWebValue)</body></html>"
                                showPolicySheet = true
                                return .handled
                            case "terms-of-service":
                                if let aboutSetting = displaySetting.first(where: { $0.type == "term_service" }) {
                                    selectedWebValue = aboutSetting.value
                                } else {
                                    selectedWebValue = "No Terms of Service"
                                }
                                policyHTML = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"></head><body><h2>Privacy Policy</h2>\(selectedWebValue)</body></html>"
                                showPolicySheet = true
                                return .handled
                            default:
                                return .discarded
                            }
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Register button
                        Button {
                            if agreedToTerms {
                                navigateToHome = true
                            } else {
                                showAlert = true
                            }
                        } label: {
                            Text("Register")
                                .font(.custom("Futura-Medium", size: 18.0))
                                .foregroundStyle(.white)
                                .frame(maxWidth: 160)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("PrimaryColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color("SecondaryColor"), lineWidth: 2)
                        )
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        .alert("Please agree to the terms", isPresented: $showAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("You must agree to the Privacy Policy and Terms of Service to continue.")
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 32)
                
                Spacer()
                
            }
            .sheet(isPresented: $showPolicySheet) {
                HTMLWebViewForRegister(html: policyHTML)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 12) {
                    Image("FlagEN")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Toggle("Language", isOn: Binding(
                        get: { selectedLanguageCode == "my" },
                        set: { newValue in selectedLanguageCode = newValue ? "my" : "en" }
                    ))
                    .labelsHidden()
                    .tint(.red)

                    Image("FlagMM")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
            }
            .background(
                ZStack {
                    Image("SplashBackground")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    Color(.systemGroupedBackground)
                        .opacity(0.2)
                        .ignoresSafeArea()
                }
            )
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToHome) {
                CustomTabView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToCommonWebView) {
                CommonWebView()
                    .navigationBarBackButtonHidden(true)
            }
            .task {
                await setting_vm.getAllSettings()
            }
            
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

struct HTMLWebViewForRegister: UIViewRepresentable {
    let html: String
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
    }
}

#Preview {
    RegisterView()
}
