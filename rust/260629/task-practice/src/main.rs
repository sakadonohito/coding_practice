use task_practice::{unfinished_task_titles_by_priority, Task};

fn main() {
    let tasks = vec![
        Task {
            title: String::from("請求書を確認する"),
            priority: 2,
            done: true,
        },
        Task {
            title: String::from("メールに返信する"),
            priority: 1,
            done: false,
        },
        Task {
            title: String::from("日報を書く"),
            priority: 3,
            done: false,
        },
        Task {
            title: String::from("買い物リストを作る"),
            priority: 2,
            done: false,
        },
    ];

    let titles = unfinished_task_titles_by_priority(&tasks);
    println!("{:?}", titles);
}
