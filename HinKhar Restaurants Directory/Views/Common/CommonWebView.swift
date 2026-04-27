//
//  CommonWebView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 04/12/2025.
//
import SwiftUI
import WebKit

struct CommonWebView: View {
    
    // Accept from caller
    let title: String
    let type: String
    let value: String
    
//    let html: String
    let baseURL: URL?
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @State private var navigateToSetting: Bool = false
//    @State private var title: String = "Testing"

    init(
        title: String = "About App",
        type: String = "about",
        value: String = "<html><body><h3 style=\"font-family: -apple-system;\">Hello, WebView</h3><p>This is sample HTML content.</p></body></html>",
         baseURL: URL? = nil) {
             self.title = title
             self.type = type
        self.value = value
        self.baseURL = baseURL
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ZStack {
                        // Centered title
                        Text(LocalizedStringKey(title))
                            .font(.custom("Futura-Medium", size: 18.0))
                            .frame(maxWidth: .infinity, alignment: .center)

                        // Leading back button overlaid
                        HStack {
                            Image("BackArrow")
                                .renderingMode(.template) // optional if you set Template Image
                                .foregroundStyle(Color("PrimaryColor"))
                                .onTapGesture {
                                    navigateToSetting = true
                                }
                                .padding(.leading, 24)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                
                HTMLWebView(html: value, baseURL: baseURL)
                    .padding(20)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
            .navigationDestination(isPresented: $navigateToSetting) {
                SettingView()
                    .navigationBarBackButtonHidden(true)
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

private struct HTMLWebView: UIViewRepresentable {
    let html: String
    let baseURL: URL?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: baseURL)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            print("WebView navigation failed: \(error.localizedDescription)")
            #endif
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            print("WebView provisional navigation failed: \(error.localizedDescription)")
            #endif
        }
    }
}

#Preview {
//    CommonWebView(
//        html: """
//        <html>
//          <head>
//            <meta name=\"viewport\" content=\"initial-scale=1, maximum-scale=1\" />
//            <style>body { font-family: -apple-system; padding: 16px; } h1 { color: #007AFF; }</style>
//          </head>
//          <body>
//            <h1>HinKhar Restaurants Directory</h1>
//            <p>This HTML is rendered inside WKWebView.</p>
//          </body>
//        </html>
//        """
//    )
    
    CommonWebView(title: "About App", type: "about", value: "sample text")
}
