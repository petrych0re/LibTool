import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showIPA = false
    @State private var showDylib = false
    @State private var ipaURL: URL?
    @State private var dylibURL: URL?
    @State private var report = "Choose an IPA and a dylib to begin."

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("IPA Toolkit").font(.largeTitle.bold())
                        Text("Inspect first. Patch only when compatibility is understood.")
                            .foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity, alignment: .leading)

                    fileCard("Target IPA", value: ipaURL?.lastPathComponent ?? "Choose an .ipa file", icon: "app.badge") { showIPA = true }
                    fileCard("Dylib", value: dylibURL?.lastPathComponent ?? "Choose a .dylib file", icon: "shippingbox") { showDylib = true }

                    Button {
                        report = "Selected files:\\nIPA: \\(ipaURL?.lastPathComponent ?? "-")\\nDylib: \\(dylibURL?.lastPathComponent ?? "-")\\n\\nNext step: inspect the archive and Mach-O architectures. No files have been modified."
                    } label: {
                        Text("Run Compatibility Check").fontWeight(.semibold)
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.indigo).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                    }.disabled(ipaURL == nil || dylibURL == nil)

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Preflight report", systemImage: "doc.text.magnifyingglass").font(.headline)
                        Text(report).font(.subheadline).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                    }.padding().background(.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("Scaffold only: binary rewriting, load-command changes, entitlement handling, and re-signing are not implemented.")
                        .font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                }.padding()
            }
            .background(Color(red: 0.045, green: 0.05, blue: 0.075))
            .navigationTitle("DylibKit")
            .fileImporter(isPresented: $showIPA, allowedContentTypes: [UTType(filenameExtension: "ipa") ?? .archive], allowsMultipleSelection: false) { result in
                if case .success(let urls) = result { ipaURL = urls.first }
            }
            .fileImporter(isPresented: $showDylib, allowedContentTypes: [UTType(filenameExtension: "dylib") ?? .data], allowsMultipleSelection: false) { result in
                if case .success(let urls) = result { dylibURL = urls.first }
            }
        }
    }

    private func fileCard(_ title: String, value: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.title2).frame(width: 46, height: 46)
                    .background(Color.indigo.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(.primary)
                    Text(value).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                Spacer()
                Image(systemName: "folder").foregroundStyle(.secondary)
            }.padding().background(.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 16))
        }.buttonStyle(.plain)
    }
}
