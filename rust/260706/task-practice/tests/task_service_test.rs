use task_practice::{incomplete_tasks, Task};

#[test]
fn 未完了タスクだけを返す() {
    // 1. completed が true のタスクと false のタスクを混ぜて用意してください。
    let tasks = vec![
        Task { title: "メール確認".to_string(), completed: true },
        Task { title: "日報を書く".to_string(), completed: false },
    ];
    // 2. incomplete_tasks を呼び出してください。
    let got = incomplete_tasks(&tasks);
    // 3. 戻り値に completed が false のタスクだけ含まれることを確認してください。
    let want = vec![
        Task { title: "日報を書く".to_string(), completed: false },
    ];
    assert_eq!(got, want)
}

#[test]
fn 空のタスク一覧なら空の_vec_を返す() {
    // 1. 空の Vec<Task> を用意してください。
    let tasks: Vec<Task> = vec![];
    // 2. incomplete_tasks を呼び出してください。
    let got = incomplete_tasks(&tasks);
    // 3. 戻り値が空であることを確認してください。
    assert!(got.is_empty())
}
