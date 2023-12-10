package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strconv"
	"strings"
)

func getLines() []string {
	data, _ := ioutil.ReadFile("input.txt")
	return strings.Split(string(data), "\n")
}

func stringArrayToIntArray(stringArray []string) []int {
	intArray := []int{}
	for _, i := range stringArray {
		if i == "" {
			continue
		}
		j, err := strconv.Atoi(i)
		if err != nil {
			panic(err)
		}
		intArray = append(intArray, j)
	}
	return intArray
}

func getIntersection(a []int, b []int) []int {
	intersection := []int{}
	for _, i := range a {
		for _, j := range b {
			if i == j {
				intersection = append(intersection, i)
			}
		}
	}
	return intersection
}

func processCard(line string) []int {
	card := strings.Split(line, ":")[1]
	winningNumbers := stringArrayToIntArray(strings.Split(strings.Split(card, "|")[0], " "))
	playerNumbers := stringArrayToIntArray(strings.Split(strings.Split(card, "|")[1], " "))
	intersection := getIntersection(winningNumbers, playerNumbers)
	return intersection
}

func cardsToMap(cards []string) map[int]string {
	cardMap := make(map[int]string)
	for _, card := range cards {
		cardNumber, _ := strconv.Atoi(strings.Split(strings.Split(card, ":")[0], " ")[1])
		cardMap[cardNumber] = card
	}
	return cardMap
}

func getPoints(line string) int {
	intersection := processCard(line)
	return len(intersection)
}

func main() {
	lines := getLines()
	points := 0
	matchMap := map[int]int{}
	for i := 0; i < len(lines); i++ {
		matchMap[i] = 1
	}
	for i, line := range lines {
		numMatches := getPoints(line)
		points += int(math.Pow(2.0, float64(numMatches-1)))
		for j := i + 1; j < i+numMatches+1; j++ {
			_, ok := matchMap[i]
			if ok {
				matchMap[j] += matchMap[i]
			}
		}
	}

	fmt.Println("part1", points)
	matchMapsum := 0
	for _, v := range matchMap {
		matchMapsum += v
	}
	fmt.Println("part2", matchMapsum)
}
