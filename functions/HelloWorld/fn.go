package hello

import (
	"fmt"
	"net/http"

	"path/to/my/project/lib"
)

func HelloWorld(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", lib.User)
}
