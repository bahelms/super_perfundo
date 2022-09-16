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
how your code is manipulating the hardware. But the sweet spot of the book is where it describes
how the computer itself works, starting with logic gates and going up to multithreaded
operating systems. Whew. I highly recommend reading it if you're not already familiar
with this stuff<a class="note-anchor" name="1'">[<sup>1</sup>](#1)</a>.

The walk from logic gate to arithmetic logic unit (ALU) is fascinating, and it
inspired me to want to implement it myself in software land. So I did. In Rust!

### Logic Gates

#### Notes
* <a name="1">[1](#1')</a>: [The Elements of Computing Systems](https://www.nand2tetris.org/book){:target="x"} is another similar book, but instead of just describing it, you actually build the stuff with code.
