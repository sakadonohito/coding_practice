use std::collections::HashMap;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AttendanceStatus {
    NotRecorded,
    Present,
    Absent,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Participant {
    id: String,
    name: String,
    status: AttendanceStatus,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AttendanceError {
    BlankParticipantId,
    BlankParticipantName { participant_id: String },
    DuplicateParticipantId(String),
    UnknownParticipantId(String),
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct AttendanceSummary {
    pub total: usize,
    pub not_recorded: usize,
    pub present: usize,
    pub absent: usize,
}

#[derive(Debug, Default)]
pub struct AttendanceBook {
    participants: HashMap<String, Participant>,
}

impl Participant {
    pub fn new(
        id: impl Into<String>,
        name: impl Into<String>,
    ) -> Result<Self, AttendanceError> {
        let id = id.into();
        let name = name.into();
        if id.trim().is_empty() {
            return Err(AttendanceError::BlankParticipantId);
        }
        if name.trim().is_empty() {
            return Err(AttendanceError::BlankParticipantName { participant_id: id});
        }
        Ok(
            Self {
                id: id,
                name: name,
                status: AttendanceStatus::NotRecorded
            }
        )
    }

    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn status(&self) -> AttendanceStatus {
        self.status
    }
}

impl AttendanceBook {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn register(
        &mut self,
        participant: Participant,
    ) -> Result<(), AttendanceError> {
        if self.participants.contains_key(participant.id()) {
            return Err(AttendanceError::DuplicateParticipantId(participant.id().to_string()));
        }
        let participant_id = participant.id().to_string();
        self.participants.insert(participant_id, participant);
        Ok(())
    }

    pub fn find(&self, participant_id: &str) -> Option<&Participant> {
        self.participants.get(participant_id)
    }

    pub fn record(
        &mut self,
        participant_id: &str,
        status: AttendanceStatus,
    ) -> Result<(), AttendanceError> {
        match self.participants.get_mut(participant_id) {
            Some(participant) => {
                participant.status = status;
                Ok(())
            }
            None => Err(AttendanceError::UnknownParticipantId(participant_id.to_string()))
        }
    }

    pub fn summary(&self) -> AttendanceSummary {
        let mut summary = AttendanceSummary::default();
        summary.total = self.participants.len();
        for participant in self.participants.values() {
            match participant.status() {
                AttendanceStatus::NotRecorded => summary.not_recorded += 1,
                AttendanceStatus::Present => summary.present += 1,
                AttendanceStatus::Absent => summary.absent += 1,
            }
        }
        summary
    }
}
