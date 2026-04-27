//
//  ContactRow.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//
import SwiftUI

struct ContactRow: View {
    let contact: Contact
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .center, spacing: 8) {
                Text(contact.phone)
                    .font(.custom("Futura-Medium", size: 15.0))
                    .frame(maxWidth: 120,alignment: .leading)
            }
            .padding(.leading, 8)
            
            Button {
                // Sanitize phone number to digits and plus sign
                let allowed = CharacterSet(charactersIn: "+0123456789").inverted
                let raw = contact.phone
                let cleaned = raw.components(separatedBy: allowed).joined()
                guard !cleaned.isEmpty, let url = URL(string: "tel://\(cleaned)") else { return }
                openURL(url)
            } label: {
                Image(systemName: "phone.fill")
                    .foregroundStyle(Color("PrimaryColor"))
                    .frame(maxWidth: 60)
                    .padding(.vertical, 2)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color("SecondaryColor"), lineWidth: 1)
            )
            
            Spacer()
        }
        .padding(.bottom, 4)
    }
}

#Preview {
    ContactRow(contact: Contact(id: "", phone: "09123456789"))
//    ContactRow(contact: ApiContact(phone: "09123456789"))
}
