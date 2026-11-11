import SwiftUI

enum Tool: String, CaseIterable, Hashable {
    case focus, convert, notes

    var number: String {
        switch self { case .focus: return "01"; case .convert: return "02"; case .notes: return "03" }
    }
    var title: String {
        switch self { case .focus: return "Focus Timer"; case .convert: return "Unit Converter"; case .notes: return "Quick Note" }
    }
    var description: String {
        switch self { case .focus: return "Make time for what matters"; case .convert: return "Length, weight and temperature"; case .notes: return "Keep thoughts close at hand" }
    }
}

struct HomeView: View {
    @StateObject private var timer = FocusTimer()
    var body: some View {
        NavigationStack {
            Page {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("CHAN").font(.system(size: 15, weight: .bold, design: .rounded)).tracking(2)
                        Spacer()
                        Text("EVERYDAY TOOLS").font(.system(size: 10, weight: .medium, design: .monospaced)).tracking(1).foregroundStyle(Palette.muted)
                    }
                    .padding(.bottom, 28)
                    Text("A little simpler,\nevery day.")
                        .font(.system(size: 36, weight: .semibold))
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Thoughtful tools for everyday life.")
                        .font(.subheadline).foregroundStyle(Palette.muted).padding(.top, 12)
                    Image("EverydayArtwork")
                        .resizable().scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 190)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .accessibilityHidden(true)
                        .padding(.top, 24)
                    HStack {
                        Text("Your tools").font(.system(size: 19, weight: .semibold))
                        Spacer()
                        Text("3 ITEMS").font(.system(size: 10, weight: .medium, design: .monospaced)).tracking(1).foregroundStyle(Palette.muted)
                    }.padding(.top, 32).padding(.bottom, 14)
                    ForEach(Tool.allCases, id: \.self) { tool in
                        NavigationLink(value: tool) {
                            HStack(alignment: .center, spacing: 18) {
                                Text(tool.number).font(.system(size: 12, weight: .medium, design: .monospaced)).foregroundStyle(Palette.blue)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(tool.title).font(.system(size: 17, weight: .semibold)).foregroundStyle(Palette.ink)
                                    Text(tool.description).font(.subheadline).foregroundStyle(Palette.muted)
                                }
                                Spacer(minLength: 10)
                                Text("Open").font(.subheadline.weight(.medium)).foregroundStyle(Palette.blue)
                            }
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Divider().overlay(Palette.line)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Information")
                            .font(.system(size: 19, weight: .semibold))
                            .padding(.top, 32)
                            .padding(.bottom, 8)
                        ForEach(LegalDocument.allCases, id: \.self) { document in
                            NavigationLink(value: document) {
                                HStack {
                                    Text(document.title).font(.subheadline.weight(.medium)).foregroundStyle(Palette.ink)
                                    Spacer(minLength: 12)
                                    Text("Open").font(.subheadline.weight(.medium)).foregroundStyle(Palette.blue)
                                }
                                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Divider().overlay(Palette.line)
                        }
                    }
                    Text("Make space for your own pace.")
                        .font(.footnote).foregroundStyle(Palette.muted).padding(.top, 24).padding(.bottom, 8)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: LegalDocument.self) { document in
                LegalView(document: document)
            }
            .navigationDestination(for: Tool.self) { tool in
                switch tool {
                case .focus: FocusView(timer: timer)
                case .convert: ConvertView()
                case .notes: NotesView()
                }
            }
        }
        .tint(Palette.blue)
    }
}
