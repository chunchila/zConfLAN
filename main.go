package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/grandcat/zeroconf"
)

// Our fake service.
// This could be a HTTP/TCP service or whatever you want.
func startService() {
	http.HandleFunc("/", func(rw http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(rw, "Hello world!")
	})

	log.Println("starting http service...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}

func main() {
	// Start out http service
	go startService()

	// Extra information about our service
	meta := []string{
		"version=0.1.0",
		"hello=world",
	}

	host, _ := os.Hostname()
	service, err := zeroconf.Register(
		host,              // service instance name
		"_omxremote._tcp", // service type and protocl
		"local.",          // service domain
		8080,              // service port
		meta,              // service metadata
		nil,               // register on all network interfaces
	)

	if err != nil {
		log.Fatal(err)
	}

	defer service.Shutdown()

	// Sleep forever
	select {}
}

// Resolve this is the resolver
func Resolve() {
	resolver, err := zeroconf.NewResolver(nil)
	if err != nil {
		log.Fatal(err)
	}

	// Channel to receive discovered service entries
	entries := make(chan *zeroconf.ServiceEntry)

	go func(results <-chan *zeroconf.ServiceEntry) {
		for entry := range results {
			log.Println("Found service:", entry.ServiceInstanceName(), entry.Text)
			serviceCall(entry.AddrIPv4[0].String(), entry.Port)
		}
	}(entries)

	ctx := context.Background()

	err = resolver.Browse(ctx, "_omxremote._tcp", "local.", entries)
	if err != nil {
		log.Fatalln("Failed to browse:", err.Error())
	}

	<-ctx.Done()

}

func serviceCall(ip string, port int) {
	url := fmt.Sprintf("http://%v:%v", ip, port)

	log.Println("Making call to", url)
	resp, err := http.Get(url)
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	data, _ := ioutil.ReadAll(resp.Body)
	log.Printf("Got response: %s\n", data)
}
