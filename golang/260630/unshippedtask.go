package main

import (
	"fmt"
	"sort"
)

type Task struct {
	Title    string
	Priority int
	Done     bool
}

func unfinishedTaskTitlesByPriority(tasks []Task) []string {
	var unfinishedTasks []Task

	for _, task := range tasks {
		if !task.Done {
			unfinishedTasks = append(unfinishedTasks, task)
		}
	}

	sort.Slice(unfinishedTasks, func(i, j int) bool {
		return unfinishedTasks[i].Priority < unfinishedTasks[j].Priority
	})

	// 空スライスで定義(何も追加されない場合は空スライスを返す仕様)
	titles := []string{}

	for _, task := range unfinishedTasks {
		titles = append(titles, task.Title)
	}

	return titles
}

func main() {
	tasks := []Task{
		{Title: "請求書を確認する", Priority: 2, Done: true},
		{Title: "メールに返信する", Priority: 1, Done: false},
		{Title: "日報を書く", Priority: 3, Done: false},
		{Title: "買い物リストを作る", Priority: 2, Done: false},
	}

	titles := unfinishedTaskTitlesByPriority(tasks)

	fmt.Println(titles)
}
