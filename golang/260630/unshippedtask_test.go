package main

import (
	"slices"
	"testing"
)

func TestUnfinishedTaskTitlesByPriority(t *testing.T) {
	tests := []struct {
		name  string
		tasks []Task
		want  []string
		wantNotNil bool
	}{
		{
			name: "未完了タスクのタイトルだけを優先度順に返す",
			tasks: []Task{
				{Title: "請求書を確認する", Priority: 2, Done: true},
				{Title: "メールに返信する", Priority: 1, Done: false},
				{Title: "日報を書く", Priority: 3, Done: false},
				{Title: "買い物リストを作る", Priority: 2, Done: false},
			},
			want: []string{"メールに返信する", "買い物リストを作る", "日報を書く"},
			wantNotNil: true,
		},
		{
			name: "すべて完了済みの場合は空のスライスを返す",
			tasks: []Task{
				{Title: "請求書を確認する", Priority: 2, Done: true},
				{Title: "メールに返信する", Priority: 1, Done: true},
				{Title: "日報を書く", Priority: 3, Done: true},
				{Title: "買い物リストを作る", Priority: 2, Done: true},
			},
			want: []string{},
			wantNotNil: true,
		},
		{
			name:  "タスクが空の場合は空のスライスを返す",
			tasks: []Task{},
			want:  []string{},
			wantNotNil: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := unfinishedTaskTitlesByPriority(tt.tasks)

			if tt.wantNotNil && got == nil {
				t.Fatal("unfinishedTaskTitlesByPriority() returned nil, want empty non-nil slice")
			}

			if !slices.Equal(got, tt.want) {
				t.Errorf("UnfinishedTaskTitlesByPriority() = %v, want %v", got, tt.want)
			}
		})
	}

	//t.Run("未完了タスクのタイトルだけを優先度順に返す", func(t *testing.T) {
	//	// 1. 完了済みタスクと未完了タスクが混ざった []Task を用意してください。
	//	// 2. 未完了タスクには Priority: 1, 2, 3 が混ざるようにしてください。
	//	tasks := []Task{
	//		{Title: "請求書を確認する", Priority: 2, Done: true},
	//		{Title: "メールに返信する", Priority: 1, Done: false},
	//		{Title: "日報を書く", Priority: 3, Done: false},
	//		{Title: "買い物リストを作る", Priority: 2, Done: false},
	//	}
	//	// 3. unfinishedTaskTitlesByPriority を呼び出してください。
	//	//titles := unfinishedTaskTitlesByPriority(tasks)
	//	// 4. 未完了タスクの Title だけが Priority の小さい順で返ることを検証してください。
	//})

	//t.Run("すべて完了済みの場合は空のスライスを返す", func(t *testing.T) {
	//	// TODO:
	//	// 1. すべて Done: true の []Task を用意してください。
	//	// 2. unfinishedTaskTitlesByPriority を呼び出してください。
	//	// 3. 結果が空の []string になることを検証してください。
	//})

	//t.Run("タスクが空の場合は空のスライスを返す", func(t *testing.T) {
	//	// TODO:
	//	// 1. 空の []Task を用意してください。
	//	// 2. unfinishedTaskTitlesByPriority を呼び出してください。
	//	// 3. 結果が空の []string になることを検証してください。
	//})
}
