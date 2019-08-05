package pack

import (
	"fmt"
	"testing"
)

func TestCanAddNumbers(t *testing.T) {

	var table = []struct {
		in  []int
		out int
	}{
		{[]int{1, 2}, 3},
		{[]int{2, 3}, 5},
	}

	for _, entry := range table {

		mRet, _ := Add(entry.in...)
		t.Logf("this is sparta %v ", mRet)
		if mRet != entry.out {
			t.Fatal("the output is not ", entry.out)
		}
	}




}

// MathTest this is mathtest
func TestCanMultiply(t *testing.T) {
	//t.Parallel()
	vals := []int{1, 2, 4, 35, 46}

	mRet, _ := Multiply(vals...)
	t.Logf("this is multiply %v", mRet)
	if mRet != 154560 {

		t.Fail()
	}

}

func TestPrint(t *testing.T) {

	//t.Parallel()
	fmt.Println("This is sparta")

	// Output:
	// sadasdasd
	// fdfdslfjdslkfj
}
