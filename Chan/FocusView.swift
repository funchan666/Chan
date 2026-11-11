import SwiftUI
import Combine
import UserNotifications

@MainActor
final class FocusTimer: ObservableObject {
    @Published private(set) var remaining: TimeInterval = 25 * 60
    @Published private(set) var isRunning = false
    @Published private(set) var isFinished = false
    @Published private(set) var selectedMinutes = 25
    @Published private(set) var notificationMessage = "Allow notifications for a reminder when your timer ends."

    private let defaults = UserDefaults.standard
    private let center = UNUserNotificationCenter.current()
    private var deadline: Date?
    private var notificationID: String?
    private var generation = UUID()
    private var schedulingID: String?
    private let stateKey = "chan.focus.state"

    init() {
        if let state = defaults.dictionary(forKey: stateKey) {
            selectedMinutes = state["minutes"] as? Int ?? 25
            remaining = state["remaining"] as? Double ?? TimeInterval(selectedMinutes * 60)
            isRunning = state["running"] as? Bool ?? false
            isFinished = state["finished"] as? Bool ?? false
            deadline = state["deadline"] as? Date
            notificationID = state["notificationID"] as? String
            if isRunning && deadline == nil { isRunning = false }
            update()
        }
        refreshNotificationStatus()
    }

    func select(_ minutes: Int) {
        cancelReminder()
        selectedMinutes = minutes
        remaining = TimeInterval(minutes * 60)
        deadline = nil
        isRunning = false
        isFinished = false
        save()
        refreshNotificationStatus()
    }

    func start() {
        guard remaining > 0, !isRunning else { return }
        cancelReminder()
        let end = Date().addingTimeInterval(remaining)
        deadline = end
        isRunning = true
        isFinished = false
        let id = "chan.focus." + UUID().uuidString
        notificationID = id
        let requestGeneration = generation
        save()
        notificationMessage = "Setting up your reminder…"
        Task { await scheduleReminder(id: id, end: end, generation: requestGeneration) }
    }

    func pause() {
        update()
        guard isRunning else { return }
        cancelReminder()
        deadline = nil
        isRunning = false
        save()
        refreshNotificationStatus()
    }

    func reset() { select(selectedMinutes) }

    func update() {
        guard let deadline, isRunning else { return }
        remaining = max(0, deadline.timeIntervalSinceNow)
        if remaining <= 0 {
            self.deadline = nil
            isRunning = false
            isFinished = true
            notificationMessage = "Your focus session is complete."
            notificationID = nil
            generation = UUID()
            save()
        }
    }

    func refreshNotificationStatus() {
        Task {
            let settings = await center.notificationSettings()
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                guard isRunning, let id = notificationID, let end = deadline else {
                    notificationMessage = "Timer reminders are allowed."
                    return
                }
                let currentGeneration = generation
                let pending = await center.pendingNotificationRequests()
                guard generation == currentGeneration, isRunning, notificationID == id else { return }
                if let reminder = pending.first(where: { $0.identifier == id }),
                   reminder.content.title == "Focus session complete" {
                    notificationMessage = "You'll be notified when the timer ends."
                } else if schedulingID != id {
                    // Replace an older-language reminder without resetting the running timer.
                    await scheduleReminder(id: id, end: end, generation: currentGeneration)
                }
            case .denied:
                notificationMessage = "Notifications are off. You can enable them in Settings."
            default:
                notificationMessage = "Allow notifications for a reminder when your timer ends."
            }
        }
    }

    private func scheduleReminder(id: String, end: Date, generation requestGeneration: UUID) async {
        guard schedulingID != id else { return }
        schedulingID = id
        defer { if schedulingID == id { schedulingID = nil } }
        do {
            let allowed = try await center.requestAuthorization(options: [.alert, .sound])
            guard generation == requestGeneration, isRunning, notificationID == id else { return }
            guard allowed else {
                notificationMessage = "Notifications are off. You can enable them in Settings."
                return
            }
            let interval = end.timeIntervalSinceNow
            guard interval > 0 else { update(); return }
            let content = UNMutableNotificationContent()
            content.title = "Focus session complete"
            content.body = "Nice work. Take a moment to rest."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, interval), repeats: false)
            try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
            guard generation == requestGeneration, isRunning, notificationID == id else {
                center.removePendingNotificationRequests(withIdentifiers: [id])
                return
            }
            notificationMessage = "You'll be notified when the timer ends."
        } catch {
            NSLog("Chan: unable to schedule focus reminder: %@", String(describing: error))
            guard generation == requestGeneration else { return }
            notificationMessage = "Couldn't set a reminder. Your timer will keep running."
        }
    }

    private func cancelReminder() {
        generation = UUID()
        if let notificationID { center.removePendingNotificationRequests(withIdentifiers: [notificationID]) }
        notificationID = nil
    }

    private func save() {
        var state: [String: Any] = ["minutes": selectedMinutes, "remaining": remaining,
                                    "running": isRunning, "finished": isFinished]
        if let deadline { state["deadline"] = deadline }
        if let notificationID { state["notificationID"] = notificationID }
        defaults.set(state, forKey: stateKey)
    }

    var display: String {
        let seconds = Int(ceil(remaining))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

struct FocusView: View {
    @ObservedObject var timer: FocusTimer
    @Environment(\.scenePhase) private var scenePhase
    private let ticker = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    var body: some View {
        Page {
            VStack(alignment: .leading, spacing: 28) {
                PageHeading(eyebrow: "01 / FOCUS", title: "Focus Timer", subtitle: "Choose a little time for one thing.")
                VStack(alignment: .leading, spacing: 16) {
                    Text(timer.isFinished ? "Time's up. Take a break." : (timer.isRunning ? "Focus in progress" : "Ready when you are"))
                        .font(.subheadline.weight(.medium)).foregroundStyle(Palette.blue)
                    Text(timer.display)
                        .font(.system(size: 64, weight: .light, design: .rounded))
                        .monospacedDigit().minimumScaleFactor(0.6).lineLimit(1)
                        .accessibilityLabel("Time remaining \(timer.display)")
                    Text("Your timer continues when you leave or reopen the app.")
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(Palette.white, in: RoundedRectangle(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose a duration").font(.subheadline.weight(.semibold))
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach([5, 15, 25, 45], id: \.self) { minutes in
                            Button { timer.select(minutes) } label: {
                                Text("\(minutes) min").font(.subheadline.weight(.medium))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                                    .foregroundStyle(timer.selectedMinutes == minutes ? Color.white : Palette.ink)
                                    .background(timer.selectedMinutes == minutes ? Palette.blue : Palette.white, in: RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(timer.selectedMinutes == minutes ? .isSelected : [])
                        }
                    }
                }
                HStack(spacing: 10) {
                    ActionButton(title: timer.isRunning ? "Pause" : (timer.isFinished ? "Start again" : "Start"), prominent: true) {
                        if timer.isRunning { timer.pause() }
                        else if timer.isFinished { timer.reset(); timer.start() }
                        else { timer.start() }
                    }
                    ActionButton(title: "Reset") { timer.reset() }
                }
                Text(timer.notificationMessage)
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
        .modifier(ToolNavigation())
        .onReceive(ticker) { _ in timer.update() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { timer.update(); timer.refreshNotificationStatus() } }
        .onAppear { timer.update(); timer.refreshNotificationStatus() }
    }
}
