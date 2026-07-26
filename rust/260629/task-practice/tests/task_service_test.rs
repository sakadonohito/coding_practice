use task_practice::{unfinished_task_titles_by_priority, Task};

#[test]
fn returns_unfinished_task_titles_ordered_by_priority() {
    // 1. 完了済みタスクと未完了タスクが混ざった Vec<Task> を用意してください。
    // 2. 未完了タスクには priority: 1, 2, 3 が混ざるようにしてください。
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
    // 3. unfinished_task_titles_by_priority を呼び出してください。
    let got = unfinished_task_titles_by_priority(&tasks);
    // 4. 未完了タスクのタイトルだけが priority の小さい順で返ることを検証してください。
    let want = vec![
        String::from("メールに返信する"),
        String::from("買い物リストを作る"),
        String::from("日報を書く"),
    ];
    assert_eq!(got,want)
}

#[test]
fn returns_empty_vec_when_all_tasks_are_done() {
    // 1. すべて done: true の Vec<Task> を用意してください。
    let tasks = vec![
        Task {
            title: String::from("請求書を確認する"),
            priority: 2,
            done: true,
        },
    ];
    // 2. unfinished_task_titles_by_priority を呼び出してください。
    let got = unfinished_task_titles_by_priority(&tasks);
    // 3. 結果が空の Vec<String> になることを検証してください。
    //let want: Vec<String> = vec![]; // String型のデータが入るはずだった空リストを定義
    assert!(got.is_empty());
}

#[test]
fn returns_empty_vec_when_tasks_is_empty() {
    // 1. 空の Vec<Task> を用意してください。
    let tasks: Vec<Task> = vec![]; // Task型のデータが入るはずだった空リストを定義
    // 2. unfinished_task_titles_by_priority を呼び出してください。
    let got = unfinished_task_titles_by_priority(&tasks);
    // 3. 結果が空の Vec<String> になることを検証してください。
    //let want: Vec<String> = vec![]; // String型のデータが入るはずだった空リストを定義
    assert!(got.is_empty());
}
