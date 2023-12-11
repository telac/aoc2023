use std::fs::read_to_string;
use itertools::Itertools;

fn get_input(file_path: &str) -> String {
    let contents = read_to_string(file_path)
        .expect("Should have been able to read the file");
    return contents;
}

fn get_expand_indexes(puzzle_input: Vec<String>) -> (Vec<usize>, Vec<usize>) {
    let mut rows_to_expand = Vec::new();
    for (idx, row) in puzzle_input.iter().enumerate() {
        if !row.contains("#") {
            rows_to_expand.push(idx);
        }
    }
    let mut cols_to_expand = Vec::new();
    for (i, _) in puzzle_input[0].chars().enumerate() {
        let is_empty = puzzle_input
        .iter()
        .fold(
            true, |acc, v| acc && v.chars().nth(i).unwrap() == '.'
        );
        if is_empty {
            cols_to_expand.push(i);
        }
    }
    return (cols_to_expand, rows_to_expand);
}

fn get_pairs(map: &Vec<String>) -> Vec<(usize, usize)> {
    let mut res =  Vec::new();
    for (idx_y, row) in map.iter().enumerate() {
        for (idx_x, c) in row.chars().enumerate() {
            if c == '#' {
                res.push((idx_x, idx_y));
            }
        }
    }
    return res;
}

fn print_string_vec(vec: &Vec<String>) {
    for row in vec {
        println!("{:?}", row);
    }
}

fn get_shortest_lengths(pairs: &Vec<(usize, usize)>, cols_e: &Vec<usize>, rows_e: &Vec<usize>, expansion_coefficient: u64) -> u64 {
    let shortest_lens = pairs
        .iter()
        .tuple_combinations()
        .map(| (a, b) | {
                let x_multiplier = cols_e
                    .iter()
                    .filter(
                    | x | {
                        let max = usize::max(a.0, b.0);
                        let min = usize::min(a.0,b.0);
                        return **x >= min && **x <= max;
                    }).count() as u64;
                let y_multiplier = rows_e
                    .iter()
                    .filter(
                    | x | {
                        let max = usize::max(a.1, b.1);
                        let min = usize::min(a.1,a.1);
                        return **x >= min && **x <= max;
                    }).count() as u64;
            let x_add = x_multiplier * expansion_coefficient;
            let y_add = y_multiplier * expansion_coefficient;
            let diff = 
             x_add + usize::abs_diff(a.0, b.0) as u64 
             + y_add + usize::abs_diff(a.1, b.1 as usize) as u64;
            return diff;
        })
        .collect::<Vec<u64>>();
    return shortest_lens.iter().sum();
}

fn main() {
    let mut result = Vec::new();

    for line in get_input("input.txt").lines() {
        result.push(line.to_string());
    }
    print_string_vec(&result);
    let pairs = get_pairs(&result);
    let (x,y) = get_expand_indexes(result.clone());
    let part1 = get_shortest_lengths(&pairs, &x, &y, 1u64);
    let part2 = get_shortest_lengths(&pairs, &x, &y, 999999u64);
    println!("part1: {part1}");
    println!("part2: {part2}");
}