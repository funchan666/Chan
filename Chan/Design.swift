import SwiftUI

enum Palette {
    static let paper = Color(red: 0.97, green: 0.96, blue: 0.93)
    static let ink = Color(red: 0.13, green: 0.18, blue: 0.25)
    static let muted = Color(red: 0.41, green: 0.44, blue: 0.46)
    static let blue = Color(red: 0.19, green: 0.30, blue: 0.62)
    static let line = Color(red: 0.85, green: 0.85, blue: 0.82)
    static let white = Color(red: 1.0, green: 0.995, blue: 0.98)
}

struct Page<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ScrollView {
            content
                .frame(maxWidth: 620, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
        }
        .background(Palette.paper.ignoresSafeArea())
        .foregroundStyle(Palette.ink)
        .scrollDismissesKeyboard(.interactively)
    }
}

struct PageHeading: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow).font(.system(size: 11, weight: .semibold, design: .monospaced)).tracking(1.3).foregroundStyle(Palette.blue)
            Text(title).font(.system(size: 32, weight: .semibold)).fixedSize(horizontal: false, vertical: true)
            Text(subtitle).font(.subheadline).foregroundStyle(Palette.muted).fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ActionButton: View {
    let title: String
    var prominent = false
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
                .foregroundStyle(prominent ? Color.white : Palette.ink)
                .background(prominent ? Palette.blue : Palette.white, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(prominent ? Palette.blue : Palette.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct ToolNavigation: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") { dismiss() }
                        .foregroundStyle(Palette.blue)
                }
            }
            .toolbarBackground(Palette.paper, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
