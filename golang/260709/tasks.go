package main

import (
	"fmt"
)

type Task struct {
	Title string
	Done bool
}

func GetIncompleteTasks(tasks []Task) []Task {
	incompleteTasks := []Task{}

	for _, task := range tasks {
		if !task.Done {
			incompleteTasks = append(incompleteTasks, task)
		}
	}

	return incompleteTasks
}

func main() {
	tasks := []Task{
		{Title: "買い物に行く", Done: false},
		{Title: "メールを返信する", Done: true},
		{Title: "本を読む", Done: false},
	}

	result := GetIncompleteTasks(tasks)

	fmt.Println(result)
}
