import SwiftUI

enum ConversionKind: String, CaseIterable {
    case length = "Length", weight = "Weight", temperature = "Temperature"
    var units: [String] {
        switch self {
        case .length: return ["Meters", "Kilometers", "Feet", "Miles"]
        case .weight: return ["Kilograms", "Grams", "Pounds", "Ounces"]
        case .temperature: return ["Celsius", "Fahrenheit"]
        }
    }
    func convert(_ value: Double, from: String, to: String) -> Double {
        if self == .temperature {
            let celsius = from == "Celsius" ? value : (value - 32) * 5 / 9
            return to == "Celsius" ? celsius : celsius * 9 / 5 + 32
        }
        let factors: [String: Double] = self == .length
            ? ["Meters": 1, "Kilometers": 1000, "Feet": 0.3048, "Miles": 1609.344]
            : ["Kilograms": 1, "Grams": 0.001, "Pounds": 0.45359237, "Ounces": 0.028349523125]
        return value * (factors[from] ?? 1) / (factors[to] ?? 1)
    }
}

struct ConvertView: View {
    @State private var kind: ConversionKind = .length
    @State private var from = "Meters"
    @State private var to = "Feet"
    @State private var input = "1"
    @State private var choosingSource: Bool?
    @FocusState private var editing: Bool

    private var number: Double? {
        let separator = Locale.current.decimalSeparator ?? "."
        let normalized = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: separator, with: ".")
        guard let value = Double(normalized), value.isFinite else { return nil }
        return value
    }
    private var result: String {
        guard let number else { return "—" }
        let value = kind.convert(number, from: from, to: to)
        guard value.isFinite else { return "—" }
        return value.formatted(.number.precision(.significantDigits(1...8)))
    }
    var body: some View {
        Page {
            VStack(alignment: .leading, spacing: 28) {
                PageHeading(eyebrow: "02 / CONVERT", title: "Unit Converter", subtitle: "Enter a value to see the result.")
                VStack(alignment: .leading, spacing: 12) {
                    Text("Conversion type").font(.subheadline.weight(.semibold))
                    HStack(spacing: 8) {
                        ForEach(ConversionKind.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                kind = option
                                from = option.units[0]
                                to = option.units[1]
                                choosingSource = nil
                            }
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .foregroundStyle(kind == option ? Color.white : Palette.ink)
                            .background(kind == option ? Palette.blue : Palette.white, in: RoundedRectangle(cornerRadius: 10))
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(kind == option ? .isSelected : [])
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 20) {
                    Text("Enter a value").font(.subheadline.weight(.semibold))
                    TextField("Enter a value", text: $input)
                        .keyboardType(.numbersAndPunctuation)
                        .focused($editing)
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .accessibilityLabel("Enter a value")
                    Divider()
                    HStack {
                        unitButton("From", unit: from, source: true)
                        Spacer(minLength: 8)
                        Button("Swap") {
                            let previous = from; from = to; to = previous
                            choosingSource = nil
                        }
                        .font(.subheadline.weight(.medium)).foregroundStyle(Palette.blue)
                        .frame(minWidth: 44, minHeight: 44)
                        Spacer(minLength: 8)
                        unitButton("To", unit: to, source: false)
                    }
                    if let choosingSource {
                        Text(choosingSource ? "Choose a starting unit" : "Choose a destination unit")
                            .font(.footnote.weight(.medium)).foregroundStyle(Palette.muted)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(kind.units, id: \.self) { unit in
                                let selected = choosingSource ? from == unit : to == unit
                                Button {
                                    if choosingSource { from = unit } else { to = unit }
                                    self.choosingSource = nil
                                } label: {
                                    Text(unit).font(.subheadline.weight(.medium))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .foregroundStyle(selected ? Color.white : Palette.ink)
                                        .background(selected ? Palette.blue : Palette.paper, in: RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(selected ? .isSelected : [])
                            }
                        }
                    }
                }
                .padding(24).background(Palette.white, in: RoundedRectangle(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Result · \(to)").font(.subheadline).foregroundStyle(Palette.muted)
                    Text(result).font(.system(size: 38, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.6).lineLimit(1).textSelection(.enabled)
                    if result == "—" { Text("Enter a valid number within range.").font(.footnote).foregroundStyle(Palette.muted) }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .modifier(ToolNavigation())
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { editing = false } } }
    }
    private func unitButton(_ label: String, unit: String, source: Bool) -> some View {
        Button {
            editing = false
            choosingSource = choosingSource == source ? nil : source
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                Text(label).font(.caption).foregroundStyle(Palette.muted)
                Text(unit).font(.subheadline.weight(.semibold)).foregroundStyle(Palette.blue)
                Text("Choose unit").font(.caption).foregroundStyle(Palette.muted)
            }
            .frame(minWidth: 80, minHeight: 58, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label), \(unit), Choose unit")
    }
}
