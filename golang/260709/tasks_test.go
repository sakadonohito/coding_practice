package main

import (
	"slices"
	"testing"
)

func TestGetIncompleteTasks(t *testing.T) {
	tests := []struct {
		name string
		tasks []Task
		want []Task
		wantNotNil bool
	}{
		{
			// 1. Done が true のタスクと false のタスクを混ぜた []Task を用意してください。
			// 2. GetIncompleteTasks を呼び出してください。
			// 3. Done が false のタスクだけが返ってくることを確認してください。
			name: "未完了のタスクだけを返す",
			tasks: []Task {
				{Title: "買い物に行く", Done: false},
				{Title: "メールを返信する", Done: true},
				{Title: "本を読む", Done: false},
			},
			want: []Task {
				{Title: "買い物に行く", Done: false},
				{Title: "本を読む", Done: false},
			},
			wantNotNil: true,
		},
		{
			// 1. 空の []Task を用意してください。
			// 2. GetIncompleteTasks を呼び出してください。
			// 3. 戻り値が空スライスであることを確認してください。
			name: "空のタスクリストなら空スライスを返す",
			tasks: []Task {},
			want: []Task {},
			wantNotNil: true,
		},
		{
			// 1. Done が true のタスクだけを持つ []Task を用意してください。
			// 2. GetIncompleteTasks を呼び出してください。
			// 3. 戻り値が空スライスであることを確認してください。
			name: "すべて完了済みなら空スライスを返す",
			tasks: []Task {
				{Title: "メールを返信する", Done: true},
			},
			want: []Task {},
			wantNotNil: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := GetIncompleteTasks(tt.tasks)

			if tt.wantNotNil && got == nil {
				t.Fatal("GetIncompleteTasks() returned nil, want empty non-nil slice")
			}

			if !slices.Equal(got, tt.want) {
				t.Errorf("GetIncompleteTasks() = %v, want %v", got, tt.want)
			}
		})
	}

}
