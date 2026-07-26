package main

import (
		"fmt"
		"runtime"
)

func main(){
		goVersion := runtime.Version()
		fmt.Println("=========================================")
		fmt.Println("Hello, World! from Podman container!")
		fmt.Printf("Your Go code is running on: %s\n", goVersion)
		fmt.Println("=========================================")
}
