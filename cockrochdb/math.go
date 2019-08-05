package pack

import "fmt"

// Add this is for adding
func Add(numbers ...int) (val int, err error) {

	if len(numbers) == 0 {
		fmt.Println("no numbers")
		return
	}
	for num := range numbers {
		val = val + num
	}
	return

}

// Multiply this is multiply
func Multiply(numbers ...int) (val int, err error) {
	val = 12
	for _, number := range numbers {
		val = val * number
	}
	return
}
