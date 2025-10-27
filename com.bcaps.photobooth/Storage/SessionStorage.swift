import Foundation

class SessionStorage {
    static let shared = SessionStorage()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func saveSessions(_ sessions: [PhotoSession]) throws {
        let data = try encoder.encode(sessions)
        let fileURL = getSessionsFileURL()
        try data.write(to: fileURL)
    }

    func loadSessions() -> [PhotoSession] {
        let fileURL = getSessionsFileURL()

        guard let data = try? Data(contentsOf: fileURL),
              let sessions = try? decoder.decode([PhotoSession].self, from: data) else {
            return []
        }

        return sessions
    }

    func saveSession(_ session: PhotoSession) throws {
        var sessions = loadSessions()

        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }

        try saveSessions(sessions)
    }

    func deleteSession(id: UUID) throws {
        var sessions = loadSessions()
        sessions.removeAll { $0.id == id }
        try saveSessions(sessions)
    }

    private func getSessionsFileURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsURL = urls.first else {
            fatalError("Could not find documents directory")
        }
        return documentsURL.appendingPathComponent("sessions.json")
    }
}