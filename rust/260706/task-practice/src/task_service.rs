//use std::vec;

#[derive(Debug, Clone, PartialEq)]
pub struct Task {
    pub title: String,
    pub completed: bool,
}

pub fn incomplete_tasks(tasks: &[Task]) -> Vec<Task> {
    tasks
        .iter()
        .filter(|task| !task.completed)
        .cloned()
        .collect()
}
