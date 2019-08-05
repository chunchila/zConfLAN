package main

import (
	"fmt"
	"log"
	"math/rand"
	"time"

	// Import GORM-related packages.
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
)

// Account is our model, which corresponds to the "accounts" database table.
type Account struct {
	ID      int `gorm:"primary_key"`
	Balance int
}

//Roman this is romans
type Roman struct {
	name string
	age  int
}

func main() {
	// Connect to the "bank" database as the "maxroach" user.
	const addr = "postgresql://maxroach@localhost:26257/bank?sslmode=disable"
	db, err := gorm.Open("postgres", addr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Automatically create the "accounts" table based on the Account model.
	db.AutoMigrate(&Account{})

	// Insert two rows into the "accounts" table.
	counter := 0
	go func(counter *int) {

		for {
			*counter = *counter + 1

			rand.Seed(time.Now().Unix())
			r := rand.Intn(1000000000000)

			//fmt.Printf("%#v ", &Account{ID: r, Balance: r + r})
			db.Create(&Account{ID: r * r, Balance: r * r})
			time.Sleep(time.Millisecond * 1000)
		}
	}(&counter)
	// Print out the balances.
	var accounts []Account

	for {
		db.Find(&accounts)
		//fmt.Println("Initial balances:")
		if counter%100 == 0 {
			fmt.Println("this is count ", len(accounts))
		}
		//fmt.Println("counter ", counter, "accounts ", len(accounts))
		for range accounts {
			//fmt.Printf("%d %d\n", account.ID, account.Balance)
		}
		// time.Sleep(time.Millisecond * 200)
	}

}
