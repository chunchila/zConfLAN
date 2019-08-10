package main

import (
	"fmt"
	"time"
)

type Roman struct {
	name string
	age  int
}

func main() {
	forever := make(chan bool)

	fmt.Printf("this is sparta %#v", Roman{name: "roman ", age: 12})

	go func() {
		for {
			t := <-time.After(time.Second * 2)
			fmt.Printf("this is sparta %#v\n", t)
		}
	}()
	<-forever

}
