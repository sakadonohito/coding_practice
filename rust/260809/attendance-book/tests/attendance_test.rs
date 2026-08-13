use attendance_book::{
    AttendanceBook,
    AttendanceError,
    AttendanceStatus,
    AttendanceSummary,
    Participant,
};

#[test]
fn creates_participant_with_not_recorded_status() {
    let participant = Participant::new("EMP-001", "山田 太郎")
        .expect("valid participant should be created");

    assert_eq!(participant.id(), "EMP-001");
    assert_eq!(participant.name(), "山田 太郎");
    assert_eq!(participant.status(), AttendanceStatus::NotRecorded);
}

#[test]
fn rejects_blank_participant_fields() {
    struct TestCase {
        name: &'static str,
        id: &'static str,
        participant_name: &'static str,
        expected: AttendanceError,
    }

    let tests = [
        TestCase {
            name: "blank ID",
            id: "   ",
            participant_name: "山田 太郎",
            expected: AttendanceError::BlankParticipantId,
        },
        TestCase {
            name: "blank name",
            id: "EMP-001",
            participant_name: "  ",
            expected: AttendanceError::BlankParticipantName {
                participant_id: "EMP-001".to_string(),
            },
        },
    ];

    for test in tests {
        let actual = Participant::new(test.id, test.participant_name);
        assert_eq!(actual, Err(test.expected), "{}", test.name);
    }
}

#[test]
fn registers_and_finds_participant() {
    let mut book = AttendanceBook::new();
    let participant = Participant::new("EMP-001", "山田 太郎")
        .expect("valid participant should be created");

    book.register(participant)
        .expect("first registration should succeed");

    let found = book.find("EMP-001")
        .expect("registered participant should be found");

    assert_eq!(found.id(), "EMP-001");
    assert_eq!(found.name(), "山田 太郎");
    assert_eq!(found.status(), AttendanceStatus::NotRecorded);
    assert!(book.find("EMP-999").is_none());
}

#[test]
fn rejects_duplicate_id_without_replacing_original() {
    let mut book = AttendanceBook::new();
    let original = Participant::new("EMP-001", "山田 太郎").unwrap();
    let duplicate = Participant::new("EMP-001", "別の参加者").unwrap();

    book.register(original).unwrap();

    let actual = book.register(duplicate);
    assert_eq!(
        actual,
        Err(AttendanceError::DuplicateParticipantId(
            "EMP-001".to_string(),
        )),
    );

    let found = book.find("EMP-001").unwrap();
    assert_eq!(found.name(), "山田 太郎");
}

#[test]
fn records_and_overwrites_attendance_status() {
    let mut book = AttendanceBook::new();
    let participant = Participant::new("EMP-001", "山田 太郎").unwrap();
    book.register(participant).unwrap();

    book.record("EMP-001", AttendanceStatus::Present)
        .expect("registered participant can be updated");
    assert_eq!(
        book.find("EMP-001").unwrap().status(),
        AttendanceStatus::Present,
    );

    book.record("EMP-001", AttendanceStatus::Absent)
        .expect("status can be overwritten");
    assert_eq!(
        book.find("EMP-001").unwrap().status(),
        AttendanceStatus::Absent,
    );
}

#[test]
fn returns_error_for_unknown_participant() {
    let mut book = AttendanceBook::new();

    let actual = book.record("EMP-999", AttendanceStatus::Present);

    assert_eq!(
        actual,
        Err(AttendanceError::UnknownParticipantId(
            "EMP-999".to_string(),
        )),
    );
}

#[test]
fn summarizes_each_attendance_status() {
    let mut book = AttendanceBook::new();

    for (id, name) in [
        ("EMP-001", "山田 太郎"),
        ("EMP-002", "鈴木 花子"),
        ("EMP-003", "佐藤 次郎"),
        ("EMP-004", "高橋 美咲"),
    ] {
        book.register(Participant::new(id, name).unwrap())
            .unwrap();
    }

    book.record("EMP-001", AttendanceStatus::Present).unwrap();
    book.record("EMP-002", AttendanceStatus::Present).unwrap();
    book.record("EMP-003", AttendanceStatus::Absent).unwrap();

    assert_eq!(
        book.summary(),
        AttendanceSummary {
            total: 4,
            not_recorded: 1,
            present: 2,
            absent: 1,
        },
    );
}
