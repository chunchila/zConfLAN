package pack

import (
	"bytes"
	"testing"
	"text/template"
)

func BenchmarkTemplate(b *testing.B) {
	temp, _ := template.New("").Parse("This is sparta")
	var buff bytes.Buffer
	for i := 0; i < b.N; i++ {

		temp.Execute(&buff, nil)
		buff.Reset()
	}
}
