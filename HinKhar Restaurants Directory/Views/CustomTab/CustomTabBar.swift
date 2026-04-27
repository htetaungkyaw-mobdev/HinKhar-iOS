import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    
    @EnvironmentObject var auth: AuthViewModel // 1. Access Auth State here
    
    @State private var showLogin: Bool = false // 2. Add local state for login trigger
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    // Add a closure to tell the parent to show login
    //    var onProfileTap: () -> Void
    
    var body: some View {
        HStack {
            // Wrap allCases in Array to make ForEach initializer unambiguous
            ForEach(Array(TabItem.allCases), id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: {
                        withAnimation(.spring()) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color(.white)
            //                .clipShape(RoundedRectangle(cornerRadius: 20))
            //                .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
        )
        //        .padding(.horizontal)
    }
}

private struct TabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .frame(width: 24, height: 24)
                    .foregroundStyle(isSelected ? Color.white : Color("PrimaryColor"))
                
                //                Text("tab.\(tab.rawValue.lowercased())")
                Text(LocalizedStringKey(tab.titleKey))
                    .font(.custom("Futura-Medium", size: 13.0))
                    .foregroundStyle(isSelected ? Color.white : Color("PrimaryColor"))
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        Color("PrimaryColor")
                    } else {
                        Color.white
                    }
                }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
        }
        //        .buttonStyle(.plain)
        
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.red : Color.yellow.opacity(1), lineWidth: 1)
        )
    }
}

#Preview {
    CustomTabView()
}
