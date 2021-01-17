==title==
Advent of Code 2020 - Day 18

==tags==
rust, advent-of-code, PLT, parsing

==description==
Evaluate addition and multiplication expressions with arbitrary precedence.

==body==
One aspect of computer science that fascinates me is [programming language theory](https://en.wikipedia.org/wiki/Programming_language_theory){:target="x"}.
It's so cool that text in a file can make a computer do something.
I've studied a lot about parsers, interpreters, and compilers, so when I read
the problem for day 18 on 2020's [Advent of Code](https://adventofcode.com/2020/day/18){:target="x"},
I got excited.

### The Problem - Part 1
The challenge is to evaluate expressions consisting of addition and multiplication
with parentheses. The twist being the precedences for adding and multiplying are the same.
I immediately thought, "Oh, do I need to write a Pratt parser?". Due to the simple
left to right precedence, I decided to a straightforward algorithm to find the 
products and sums while taking into account groupings by parentheses.

```rust
fn calculate(chars: &[char]) -> u64 { // the full list of characters
    let mut lhs: u64 = 0;
    let mut pointer = 0;

    while pointer < chars.len() {
        let mut seeker = pointer + 1;
        let ch = chars[pointer];
        match ch.to_digit(10) {
            Some(num) => {
                lhs = num as u64;
                pointer += 1;
            }
            None => {
                // find lhs
                if ch == '(' {
                    let mut groups = 1;
                    while groups > 0 {
                        match chars[seeker] {
                            '(' => groups += 1,
                            ')' => groups -= 1,
                            _ => {}
                        }
                        seeker += 1;
                    }
                    lhs = calculate(&chars[pointer + 1..seeker - 1]);
                    pointer = seeker;
                    continue;
                }

                // find rhs
                let next_char = chars[seeker];
                let rhs = match next_char.to_digit(10) {
                    Some(num) => num as u64,
                    None => match next_char {
                        '(' => {
                            let mut groups = 1;
                            while groups > 0 {
                                seeker += 1;
                                match chars[seeker] {
                                    '(' => groups += 1,
                                    ')' => groups -= 1,
                                    _ => {}
                                }
                            }
                            calculate(&chars[pointer + 2..seeker])
                        }
                        _ => panic!("no rhs next char match"),
                    },
                };

                match ch {
                    '+' => lhs += rhs,
                    '*' => lhs *= rhs,
                    _ => panic!("operator is wrong"),
                }
                pointer = seeker + 1;
            }
        }
    }
    lhs
}
```
