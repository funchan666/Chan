import SwiftUI
import UIKit
import WebKit

enum LegalDocument: Hashable, CaseIterable {
    case terms, privacy

    var title: String {
        switch self {
        case .terms: return "Terms of Service"
        case .privacy: return "Privacy Policy"
        }
    }

    var url: URL {
        switch self {
        case .terms:
            return URL(string: "https://docs.google.com/document/d/1zX25rHqgp7HBr2MNiMfAGYAFaI5rit5LUy9GP8al57g/preview")!
        case .privacy:
            return URL(string: "https://docs.google.com/document/d/1YHHigLL4WkjvHfDG6ZS5phbxHO5BJ7sO5Ed6f881OKQ/preview")!
        }
    }
}

@MainActor
final class LegalWebState: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var isLoading = true
    @Published var hasError = false
    private weak var webView: WKWebView?
    private var documentURL: URL?

    func attach(_ webView: WKWebView, url: URL) {
        self.webView = webView
        documentURL = url
        webView.navigationDelegate = self
        DispatchQueue.main.async { [weak self] in self?.load() }
    }

    func load() {
        guard let webView, let documentURL else { return }
        hasError = false
        isLoading = true
        webView.load(URLRequest(url: documentURL))
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        hasError = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showFailure(error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showFailure(error)
    }

    func webView(_ webView: WKWebView, decidePolicyFor response: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if response.isForMainFrame, let http = response.response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            isLoading = false
            hasError = true
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        isLoading = false
        hasError = true
    }

    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = action.request.url, let scheme = url.scheme?.lowercased() else {
            decisionHandler(.cancel)
            return
        }
        if scheme == "mailto", action.navigationType == .linkActivated {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else if scheme == "https" {
            if action.targetFrame == nil {
                webView.load(action.request)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.cancel)
        }
    }

    private func showFailure(_ error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        isLoading = false
        hasError = true
    }
}

struct LegalWebPage: UIViewRepresentable {
    let url: URL
    @ObservedObject var state: LegalWebState

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Palette.paper)
        webView.scrollView.backgroundColor = UIColor(Palette.paper)
        state.attach(webView, url: url)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

struct LegalView: View {
    let document: LegalDocument
    @StateObject private var state = LegalWebState()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(document.title)
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            ZStack {
                LegalWebPage(url: document.url, state: state)
                    .opacity(state.hasError ? 0 : 1)
                    .accessibilityHidden(state.hasError)
                if state.hasError {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Couldn't open this page")
                            .font(.headline)
                        Text("Check your internet connection and try again.")
                            .font(.subheadline)
                            .foregroundStyle(Palette.muted)
                        ActionButton(title: "Try again", prominent: true) { state.load() }
                    }
                    .frame(maxWidth: 360, alignment: .leading)
                    .padding(24)
                } else if state.isLoading {
                    ProgressView("Loading…")
                        .tint(Palette.blue)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Palette.paper.ignoresSafeArea())
        .modifier(ToolNavigation())
    }
}
