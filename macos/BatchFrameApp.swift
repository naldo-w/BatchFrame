import Cocoa
import WebKit
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    private var window: NSWindow!
    private var webView: WKWebView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentController = WKUserContentController()
        contentController.add(self, name: "batchFrameSave")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.setValue(false, forKey: "drawsBackground")

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 900),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "BatchFrame"
        window.contentView = webView
        window.center()
        window.makeKeyAndOrderFront(nil)

        loadApp()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func loadApp() {
        guard let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html") else {
            presentError("index.html was not found in the app bundle.")
            return
        }
        webView.loadFileURL(htmlURL, allowingReadAccessTo: Bundle.main.resourceURL ?? htmlURL.deletingLastPathComponent())
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "batchFrameSave",
              let body = message.body as? [String: Any],
              let filename = body["filename"] as? String,
              let base64 = body["base64"] as? String,
              let data = Data(base64Encoded: base64) else {
            NSSound.beep()
            return
        }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        panel.canCreateDirectories = true
        panel.title = "Save \(filename)"

        if filename.lowercased().hasSuffix(".zip") {
            panel.allowedContentTypes = [UTType.zip]
        } else if filename.lowercased().hasSuffix(".png") {
            panel.allowedContentTypes = [UTType.png]
        }

        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                self.presentError("Could not save \(filename): \(error.localizedDescription)")
            }
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            NSWorkspace.shared.open(url)
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url,
           (url.scheme == "http" || url.scheme == "https") {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    private func presentError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "BatchFrame"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
