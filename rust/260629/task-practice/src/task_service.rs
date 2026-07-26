use std::vec;

#[derive(Debug)]
pub struct Task {
    pub title: String,
    pub priority: u8,
    pub done: bool,
}

fn is_unfinished(task: &Task) -> bool {
    !task.done
}

fn priority_key(task: &Task) -> u8 {
    task.priority
}

pub fn unfinished_task_titles_by_priority(tasks: &[Task]) -> Vec<String> {
    let mut unfinished_tasks: Vec<&Task> = tasks
        .iter()
        .filter(|task| is_unfinished(task))
        .collect();

   // sortはVecの破壊的変更処理(なので最初に引数をmutなVec<&Task>に代入している)
    unfinished_tasks.sort_unstable_by_key(|task| priority_key(task));

    unfinished_tasks
        .iter()
        .map(|task| task.title.clone())
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn is_unfinished_returns_true_when_task_is_not_done() {
        // 1. done: false の Task を1件用意してください。
        let task = Task{
            title: String::from("メールに返信する"),
            priority: 1,
            done: false,
        };
        // 2. is_unfinished を呼び出してください。
        let got = is_unfinished(&task);
        // 3. 結果が true であることを検証してください。
        //let want = true;
        assert!(got)
    }

    #[test]
    fn is_unfinished_returns_false_when_task_is_done() {
        // 1. done: true の Task を1件用意してください。
        let task = Task {
            title: String::from("請求書を確認する"),
            priority: 2,
            done: true,
        };
        // 2. is_unfinished を呼び出してください。
        let got = is_unfinished(&task);
        // 3. 結果が false であることを検証してください。
        //let want = false;
        assert!(!got)
    }

    #[test]
    fn priority_key_returns_task_priority() {
        // 1. priority: 2 の Task を1件用意してください。
        let task = Task {
            title: String::from("請求書を確認する"),
            priority: 2,
            done: true,
        };
        // 2. priority_key を呼び出してください。
        let got = priority_key(&task);
        // 3. 結果が 2 であることを検証してください。
        let want: u8 = 2;
        assert_eq!(got, want)
    }
}
