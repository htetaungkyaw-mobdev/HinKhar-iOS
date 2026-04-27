import SwiftUI

struct SuggestionDialog: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    var isSubmitting: Bool = false
    var onSubmit: () -> Void

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

                    Text("setting.suggestion")
                        .font(.custom("Futura-Medium", size: 18.0))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $text)
                            .font(.custom("Futura-Medium", size: 16.0))
                            .frame(minHeight: 120, maxHeight: 160)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color("PrimaryColor"), lineWidth: 1)
                            )
                        if text.isEmpty {
                            Text("suggestion.placeholder")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 10)
                        }
                    }
                    .padding(.vertical, 16)

                    Button {
                        onSubmit()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("suggestion.button.submit")
                                .font(.custom("Futura-Medium", size: 18.0))
                                .foregroundStyle(Color("PrimaryColor"))
                                .frame(maxWidth: 140)
                                .padding(.vertical, 8)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("SecondaryColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color("PrimaryColor"), lineWidth: 1)
                    )
                    .padding(.top, 12)
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
    @State var text = ""
    SuggestionDialog(isPresented: $presented, text: $text, isSubmitting: false) {}
}
