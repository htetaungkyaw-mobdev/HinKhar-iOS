import SwiftUI

struct ContactUsDialog: View {
    @Binding var isPresented: Bool
    @Binding var contacts: [Contact]?

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

                    Text("setting.contactUs")
                        .font(.custom("Futura-Medium", size: 18.0))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                    
                    LazyVStack(spacing: 0) {
                        if !(contacts?.isEmpty ?? true) {
                            
                            Text("Hot-Line Numbers")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(Color("PrimaryColor"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(contacts!) { contact in
                                        ContactRow(contact: contact)
                                            .padding(.horizontal, 24)
                                            .onTapGesture {
                                                
                                            }
                                    }
                                }
                            }
                        }
                                                            else {
                                                                Text("No contacts available")
                                                                    .font(.custom("Futura-Medium", size: 16.0))
                                                                    .foregroundStyle(.secondary)
                                                                    .padding(.horizontal, 24)
                                                                    .padding(.top, 8)
                                                            }
                    }
                    .padding(.top, 10)
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
    ContactUsDialog(isPresented: $presented, contacts: .constant(nil))
}
