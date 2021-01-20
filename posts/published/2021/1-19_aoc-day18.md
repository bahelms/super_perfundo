==title==
Advent of Code 2020 - Day 18

==tags==
rust, advent-of-code, PLT, parsing

==description==
Evaluate addition and multiplication expressions with arbitrary precedence.

==image==
og-image_aoc-day18.png

==body==
One aspect of computer science that fascinates me is [programming language theory](https://en.wikipedia.org/wiki/Programming_language_theory){:target="x"}.
It's so cool that text in a file can make a computer do something.
I've studied a good deal about parsers, interpreters, and compilers, so when I read
the problem for day 18 on 2020's [Advent of Code](https://adventofcode.com/2020/day/18){:target="x"},
I got excited. Spoiler: this post has a lot of [Rust](https://www.rust-lang.org/){:target="x"} code!

### The Problem - Part 1
The challenge is to evaluate expressions consisting of addition, multiplication,
and parentheses. The twist being the precedences for 
adding and multiplying are the same: `5 + (6 + (3 * 1)) + 9 * 2 = 46`.
I immediately thought, "Oh, should I write a [Pratt parser](https://matklad.github.io/2020/04/13/simple-but-powerful-pratt-parsing.html){:target="x"}?". Due to the simple
left to right precedence, I decided on a straightforward recursive algorithm to find the 
products and sums while taking into account groupings by parentheses. First working iteration:

```rust
fn calculate(chars: &[char]) -> u64 { // the full list of characters
    let mut lhs: u64 = 0; // left hand side
    let mut pointer = 0;

    while pointer < chars.len() {
        let mut seeker = pointer + 1;
        let ch = chars[pointer];
        match ch.to_digit(10) {
            Some(num) => {
                // if the char is a number, set it to lhs
                lhs = num as u64;
                pointer += 1;
            }
            None => {
                // find left hand side
                if ch == '(' {
                    seeker = consume_groups(chars, seeker); // find closing ')'
                    lhs = calculate(&chars[pointer + 1..seeker - 1]);
                    pointer = seeker;
                    continue;
                }

                // find right hand side
                let next_char = chars[seeker];
                let rhs = match next_char.to_digit(10) {
                    Some(num) => num as u64,
                    None => match next_char {
                        '(' => {
                            seeker = consume_groups(chars, seeker);
                            calculate(&chars[pointer + 2..seeker])
                        }
                        _ => panic!("no rhs next char match"),
                    },
                };

                // char must be an operator
                // calculate with same precedence and set it as lhs
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

As I was implementing that solution, something occurred to me based on my experience
solving the previous seventeen AOC problems. "I bet Part 2 is going to be about
changing the precedences somehow." That would invalidate my entire algorithm since 
it only goes left to right, executing operators as it finds them. 
At that point, I would need a genuine Pratt parser that would cover both parts of the problem 
and let me change precedence with ease. Well, I won the bet. 

### Part 2
The second half of the problem asks for the same process, but this time addition
has a higher precedence than multiplication. A [Pratt parser](https://en.wikipedia.org/wiki/Operator-precedence_parser#Pratt_parsing){:target="x"} makes setting precedences
on infix and prefix operators trivial, although the parser itself can be hard to grok.
First, we need a lexer and some tokens to play with.

``` rust
enum Token {
    Int(char),
    Op(char),
    Eof,
}

struct Lexer {
    tokens: Vec<Token>,
}

impl Lexer {
    fn new(input: &str) -> Lexer {
        // turn chars into tokens
        let mut tokens: Vec<Token> = input
            .chars()
            .filter(|&ch| ch != ' ')
            .map(|ch| match ch {
                '0'..='9' => Token::Int(ch),
                _ => Token::Op(ch),
            })
            .collect();
        tokens.reverse(); // using the end of the vector is easier
        Lexer { tokens }
    }

    fn next(&mut self) -> Token {
        self.tokens.pop().unwrap_or(Token::Eof)
    }
    fn peek(&mut self) -> Token {
        self.tokens.last().copied().unwrap_or(Token::Eof)
    }
}
```

The following is a Pratt parser that works for both parts of the problem:

```rust
// new function creating a Lexer and evaluating with 0 precedence
fn calculate(input: &str) -> u64 {
    let mut lexer = Lexer::new(input);
    evaluate(&mut lexer, 0)
}

fn evaluate(lexer: &mut Lexer, precedence: u8) -> u64 {
    // find lhs
    let mut lhs = match lexer.next() {
        Token::Int(ch) => ch.to_digit(10).unwrap() as u64,
        Token::Op('(') => {
            let lhs = evaluate(lexer, 0);
            lexer.next();
            lhs
        }
        t => panic!("you broke it: {:?}", t),
    };

    loop {
        // find operator
        let op = match lexer.peek() {
            Token::Eof => break,
            Token::Op(op) => op,
            t => panic!("fix your token already: {:?}", t),
        };

        // the magic
        if let Some((lbp, rbp)) = infix_binding_power(op) {
            if lbp < precedence {
                break;
            }
            lexer.next();
            let rhs = evaluate(lexer, rbp); // find rhs
            match op { // calculate for reals
                '+' => lhs += rhs,
                '*' => lhs *= rhs,
                _ => panic!("what are you trying to do here? {}", op),
            }
            continue;
        }
        break;
    }
    lhs
}
```

#### The magic of infix binding power
You can think of precedence in the order of operations (PEMDAS) as the power
to bind two operands. With `1 + 6 + 4`, the operators have the same precedence but
different binding power. The right operand is bound more tightly than the left.

```
1  +  6  +  4
  1 2   1 2   - binding powers
```

This says that the first addition operator will be the first to execute because 
`6` is bound tighter to the first operator than to the second (2 > 1). This binding is 
implemented in code with the `lbp < precedence` condition. In the above example, 
the precedence starts at zero, the LHS becomes `1`, and RHS is evaluated with precedence 2.
Since the left binding power of the following operator (1) is lower than the
current precedence, RHS evaluation stops and `6` is returned.

Then add multiplication to the expression, which has a higher precedence and thus binding power:

```
1  +  2  *  3  +  4
  1 2   3 4   1 2
```

The `3` operand is drawn to the `*` more than any other operand to their operator. Then 
it's multiplied by `2`, the next highest. And now it's reduced to the state of the previous
expression. Once we map the operators to their binding powers, we have a precedence
adhering parser/interpreter! This allows us to arbitrarily change precedence in 
one spot to find the answers for both parts of the problem.

```rust
fn infix_binding_power(op: char) -> Option<(u8, u8)> {
    match op {
        // Use this to satisfy Part 1
        '+' | '*' => Some((1, 2)), // same precedence

        // Use this to satisfy Part 2
        '*' => Some((1, 2)),
        '+' => Some((3, 4)), // higher precedence due to stronger binding power

        _ => None,
    }
}
```

### Final Summation
The Pratt parser is an ingenious algorithm. In a few lines of code, any operator 
expression with precedence can be handled and new operators added with ease. That's
pretty powerful.
