import SwiftUI

struct DeleteAccountDialog: View {
    @Binding var isPresented: Bool
    var onCancel: () -> Void
    var onConfirmDelete: () -> Void

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }

                VStack(spacing: 16) {
                    Text("setting.delete")
                        .font(.custom("Futura-Medium", size: 18.0))
                        .foregroundStyle(.primary)

                    Text("delete.title1")
                        .font(.custom("Futura-Medium", size: 16.0))
                        .foregroundStyle(Color("PrimaryColor"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("delete.title2")
                        .font(.custom("Futura-Medium", size: 16.0))
                        .foregroundStyle(Color("PrimaryColor"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        
                        Text("delete.detail1")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .foregroundStyle(Color("PrimaryColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: .infinity)
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        
                        Text("delete.detail2")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .foregroundStyle(Color("PrimaryColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: .infinity)
                    
                    HStack(spacing: 12) {
                        Button {
                            isPresented = false
                            onCancel()
                        } label: {
                            Text("alert.cancel")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(.white)
                                .frame(maxWidth: 120)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color("PrimaryColor"), lineWidth: 1)
                        )
                        
                        Button {
                            onConfirmDelete()
                            isPresented = false
                        } label: {
                            Text("delete.button")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(.white)
                                .frame(maxWidth: 120)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("PrimaryColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color("SecondaryColor"), lineWidth: 1)
                        )
                    }
                    .padding(10)

//                    HStack(spacing: 12) {
//                        Button(role: .cancel) {
//                            isPresented = false
//                            onCancel()
//                        } label: {
//                            Text("Cancel")
//                                .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(.bordered)
//
//                        Button(role: .destructive) {
//                            onConfirmDelete()
//                            isPresented = false
//                        } label: {
//                            Text("Delete")
//                                .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .tint(.red)
//                    }
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
    return DeleteAccountDialog(isPresented: $presented, onCancel: {}, onConfirmDelete: {})
}
