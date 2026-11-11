import SwiftUI

struct NotesView: View {
    @AppStorage("chan.quickNote") private var note = ""
    @FocusState private var editing: Bool
    var body: some View {
        Page {
            VStack(alignment: .leading, spacing: 28) {
                PageHeading(eyebrow: "03 / NOTES", title: "Quick Note", subtitle: "Keep your thoughts and lists in one place.")
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("My note").font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("Saved on this device").font(.caption).foregroundStyle(Palette.muted)
                    }
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $note)
                            .scrollContentBackground(.hidden)
                            .focused($editing)
                            .frame(minHeight: 240)
                            .accessibilityLabel("My note")
                        if note.isEmpty {
                            Text("Write something down…")
                                .foregroundStyle(Palette.muted).padding(.horizontal, 5).padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                    }
                    Text(note.count == 1 ? "1 character" : "\(note.count) characters").font(.caption).foregroundStyle(Palette.muted)
                }
                .padding(20).background(Palette.white, in: RoundedRectangle(cornerRadius: 18))
                Text("Your note is saved only on this device. Deleting the app also deletes your note.")
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
        .modifier(ToolNavigation())
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { editing = false } } }
    }
}
