use task_practice::{incomplete_tasks, Task};

fn main() {
    let tasks = vec![
        Task { title: "メール確認".to_string(), completed: true },
        Task { title: "日報を書く".to_string(), completed: false },
    ];

    let remaining_tasks = incomplete_tasks(&tasks);
    println!("{:?}",remaining_tasks);
}
