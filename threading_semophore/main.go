package main

import "fmt"

func main() {
	c := make(chan int, 100)
	c <- 123

	for v := range c {
		c <- 123
		fmt.Println("this is sparta", v)
	}

	select {
	case val := <-c:
		fmt.Println("this is channel return", val)

	}
}
