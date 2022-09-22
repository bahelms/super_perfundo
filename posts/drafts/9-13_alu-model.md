==title==
Model an ALU circuit in Rust

==tags==
rust, hardware, computer-science

==description==
Arithmetic logic units are the brain of central processing units, which are the
brains of computers. Let's see how they work by coding one using Rust.

==image==
replace.png

==body==
Do you love [metal!?](https://www.youtube.com/watch?v=MDBykpSXsSE){:target="x"}
No, not that kind of metal. I'm talking about those periodic table elements that
make up a computer. I thought so! Why else would you be here with a blog title like that?
Well, I do, too. Lately, I've been reading the fantastic book,
[Dive Into Systems](https://diveintosystems.org/){:target="x"}. It's been the most
enlightening yet succinct and specific experience I've had learning about the foundations of
how computers work. It starts out going over the basics of C which in my opinion
is the best first language to learn because it easily allows you to create a mental model of
how your code is manipulating the hardware without also having to think about other
things like safety (oh, the overhead). But the sweet spot of the book is where it describes
how the computation itself works, starting with logic gates and going all the way up to multithreaded
operating systems. Whew. I highly recommend reading it if you're not already familiar
with this stuff<a class="note-anchor" name="1'">[<sup>1</sup>](#1)</a>.

The walk from logic gate to arithmetic logic unit (ALU) is fascinating, and it
inspired me to want to implement it myself in software land. So I did. In Rust!

### Logic Gates
Logic gates are simple circuits that are used as the foundation of building
more complicated circuits. Those circuits are then combined to build even more
complicated circuits which eventually make up an entire processor.
Logic gates themselves are composed of transistors, which are itty bitty switches that control
the flow of electricity. They are etched directly onto some semiconductor like silicon which
makes up the chip. Beneath the transistors? It's turtles all the way down.
Logic gates are about as fundamental is it gets for our task of circuit modeling,
so we'll stop there. We'll use them to implement the basic boolean logic concepts
of AND, OR, and NOT. Everything else can be built from these.
First let's start off with the truth tables:
```
x | y | AND | OR       x | NOT
----------------       -------
0   0    0    0        0    1
1   0    0    1        1    0
0   1    0    1
1   1    1    1
```
These ones and zeros represent the presence or absence of an electrical charge
(which is controlled by transistors). The AND and OR gates take two one-bit inputs
and output one bit that's the result of the logic. Sounds like function time!
We can easily implement this in code. First let's enforce the truth tables as tests.
```rust
#[test]
fn and_gate_truth_table() {
    assert!(!and_gate(false, false));
    assert!(!and_gate(true, false));
    assert!(!and_gate(false, true));
    assert!(and_gate(true, true));
}

#[test]
fn or_gate_truth_table() {
    assert!(!or_gate(false, false));
    assert!(or_gate(true, false));
    assert!(or_gate(false, true));
    assert!(or_gate(true, true));
}
```
TDD is fun! Now the logic gates:
```rust
pub type Bit = bool;

pub fn and_gate(x: Bit, y: Bit) -> Bit {
    x & y
}

pub fn or_gate(x: Bit, y: Bit) -> Bit {
    x | y
}
```
Since we are only ever dealing with two values here, the `bool` type nicely represents
a bit. It's just an alias for `u8` which is the smallest type in Rust and
allocates one byte of memory (way more than we need, but alas).
It can also be used with bitwise operators, which is what we've done. Now
for NOT.
```rust
#[test]
fn not_gate_truth_table() {
    assert!(not_gate(false));
    assert!(!not_gate(true));
}

pub fn not_gate(a: Bit) -> Bit {
    !a
}
```
Voila! It's pretty neat how everything else you know about computers is built on
top of these three gates. But now what? How do we go about arranging them
[like matches](https://www.youtube.com/watch?v=Qfw60qXtOH0){:target="x"}
in order to build an ALU? Let's jump up the abstraction tree to figure out what
we actually want the ALU to do.

### What are we doing here?
ALUs are the heart and soul of CPUs. It's where all the magic happens. Everything
else is just storage and control circuits to get what's in storage into the ALU.
And then what? Since we are building our own, what should we make it do?
Since it stands for arithmetic and logic, let's implement
two simple operations for our simple ALU: equality and addition. Also, for simplicity's
sake, let's make it an [8-bit](https://en.wikipedia.org/wiki/Nintendo_Entertainment_System){:target="x"} ALU.

### Equality
- one bit equals
- m-bit equals
- add another op - one bit add
- m-bit add
- one bit two-way mux
- m-bit two-way mux

### Final Summation
do it


#### Notes
* <a name="1">[1](#1')</a>: [The Elements of Computing Systems](https://www.nand2tetris.org/book){:target="x"} is another similar book, but instead of just describing it, you actually build the stuff with code.
