import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showingImporter = false
    @State private var isScanning = false
    @State private var result: ScanResult?
    @State private var errorMessage: String?

    private let background = Color(red: 0.045, green: 0.045, blue: 0.065)
    private let accent = Color(red: 0.65, green: 0.42, blue: 0.98)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    scannerCard

                    if let result {
                        resultCard(result)
                    }

                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
                    }

                    footer
                }
                .padding(20)
            }
            .background(background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.item],
                allowsMultipleSelection: false,
                onCompletion: handleImport
            )
        }
        .tint(accent)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "cube.transparent")
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(accent)
                Text("LIBTOOL")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .tracking(1.5)
            }
            Text("UNITY PACKAGE INSPECTOR")
                .font(.caption.weight(.bold))
                .tracking(2.2)
                .foregroundStyle(.secondary)
            Text("Inspect an IPA or ZIP for Unity framework markers.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
        .padding(.top, 14)
    }

    private var scannerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Package Scanner", systemImage: "doc.text.magnifyingglass")
                .font(.headline)
            Text("Choose a package from Files. LibTool scans archive entry paths and reports known Unity indicators.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                errorMessage = nil
                showingImporter = true
            } label: {
                HStack {
                    Image(systemName: "folder")
                    Text(isScanning ? "Scanning package…" : "Select IPA / ZIP")
                    Spacer()
                    Image(systemName: "arrow.up.doc")
                }
                .font(.headline)
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(accent, in: RoundedRectangle(cornerRadius: 13))
                .foregroundStyle(.white)
            }
            .disabled(isScanning)
        }
        .padding(18)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.07), lineWidth: 1))
    }

    private func resultCard(_ result: ScanResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: result.detected ? "checkmark.seal.fill" : "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(result.detected ? .green : .orange)
                VStack(alignment: .leading, spacing: 3) {
                    Text(result.detected ? "UNITY DETECTED" : "NO KNOWN MARKERS")
                        .font(.headline)
                    Text(result.fileName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Divider().overlay(.white.opacity(0.1))

            HStack {
                Text("Archive entries")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(result.entryCount)")
                    .monospacedDigit()
            }
            .font(.subheadline)

            if result.matches.isEmpty {
                Text("No known Unity marker appeared in the archive paths. This is not proof that the app is not built with Unity.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(result.matches, id: \.self) { match in
                    Label(match, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.07), lineWidth: 1))
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("SCOPE & LIMITATIONS")
                .font(.caption.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(.secondary)
            Text("Only the file you select is inspected. LibTool does not automatically read other apps’ private containers. Detection is heuristic and may miss renamed or stripped markers.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    private func handleImport(_ outcome: Result<[URL], Error>) {
        switch outcome {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            result = nil
            errorMessage = nil
            isScanning = true

            Task {
                do {
                    let scan = try await UnityScanner.scan(url: url)
                    await MainActor.run {
                        result = scan
                        isScanning = false
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        isScanning = false
                    }
                }
            }
        }
    }
}
