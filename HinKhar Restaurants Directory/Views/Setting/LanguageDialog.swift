import SwiftUI

struct LanguageDialog: View {
    @Binding var isPresented: Bool
    @Binding var selectedLanguage: String
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Image("Close")
                            .onTapGesture { isPresented = false }
                    }

                    Text("Change Language/ဘာသာစကား")
                        .font(.custom("Futura-Medium", size: 18.0))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                    // English option
                    Button {
                        selectedLanguage = "en"
                        selectedLanguageCode = "en"
                        isPresented = false
                    } label: {
                        HStack {
                            Text("English")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(selectedLanguage == "en" ? Color("PrimaryColor") : .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                            if selectedLanguage == "en" {
                                Image("Selected")
                                    .foregroundStyle(Color("PrimaryColor"))
                                    .padding(10)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selectedLanguage == "en" ? Color("PrimaryColor") : .black, lineWidth: 1)
                    )
                    .padding(.bottom, 20)

                    // Myanmar option
                    Button {
                        selectedLanguage = "my"
                        selectedLanguageCode = "my"
                        isPresented = false
                    } label: {
                        HStack {
                            Text("မြန်မာ")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(selectedLanguage == "my" ? Color("PrimaryColor") : .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                            if selectedLanguage == "my" {
                                Image("Selected")
                                    .foregroundStyle(Color("PrimaryColor"))
                                    .padding(10)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selectedLanguage == "my" ? Color("PrimaryColor") : .black, lineWidth: 1)
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .frame(maxWidth: 340)
                .shadow(radius: 20)
            }
            .transition(.opacity)
            .animation(.easeInOut, value: isPresented)
        }
    }
}

#Preview {
    @State var presented = true
    @State var language = "my"
    return LanguageDialog(isPresented: $presented, selectedLanguage: $language)
}
