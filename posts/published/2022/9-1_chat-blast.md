==title==
Chat Blast! A TCP chat server in Rust

==tags==
rust, networking, async, tokio

==description==
Where we write a CLI chat server over TCP sockets using Rust and Tokio.

==image==
chat-blast.jpg

==body==
Hello there! I've been playing with Rust for years now, but I've never gotten
around to using it asynchronously. I thought I should change this and write something
simple yet useful enough for learning. A TCP chat server! First, let's define the
problem.

_All the code for this can be found [here](https://github.com/bahelms/chat_blast){:target="x"}._

### What is a TCP chat server?

As a user, I want to connect to a remote chat room in my terminal (it's the 80s) and send
messages that anyone else who's connected can read. This
means we need a client to send those messages and a server to handle them. The first part
is super easy; we'll use [Netcat](https://en.wikipedia.org/wiki/Netcat){:target="x"}.
It's probably already on your machine. This will let us
focus on writing the server. We might want to write our own client if
we want to get fancy with a Chat Blast UI. Let's avoid that for now.

For development, the server will be running on 127.0.0.1 on an arbitrary unused
port, 4888. To connect with netcat we use `nc localhost 4888`, which does absolutely
nothing right now since there is no server. How bout we fix that!

### A rusty server

```rust
// main.rs
mod server;

#[tokio::main]
async fn main() {
    let address = "127.0.0.1".to_string();
    let port = "4888".to_string();
    server::start(address, port).await;
}
```
It's a good idea to keep the main file pretty clean. It's responsible for handling
inputs and starting the program. When business logic lives elsewhere, it's reusable
and easier to test. Speaking of reusablility, you'll notice that I've hardcoded
the socket's address. If you deploy this to production, you'll probably want to change
that. The address is passed to a function that will start the server. That
function lives in another file named `server.rs`. `mod server` tells the
compiler to include that file during compilation; by default it won't, since it
doesn't like to compile code that's not used.

Now's when you ask, "WTH is tokio::main?". Good question! I had to figure that
out myself. [Tokio](https://tokio.rs){:target="x"} is an async runtime for Rust.
The async/await feature comes with
Rust, but Tokio makes it easier to use by treating async functions like tasks that
it schedules for you. All you need to do is wait for them to finish. Tasks are good
to use when you're waiting for a lot of IO operations. If you're doing lots of
CPU computation, multithreading might be a better approach.

`#[tokio::main]` is an attribute-like procedural macro. It's simply a convenient way to
set up the Tokio runtime by converting `main` into this:

```rust
fn main() {
    let mut rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        // your main code
    })
}
```

Async functions return lazy `Future` types that do nothing until `await` is called
on them. You can only await a future while inside an async function, which is why
main is labelled as async. We've started the server, and now we're waiting for it
to do something.

```rust
// server.rs
use tokio::net::{TcpListener, TcpStream};

pub async fn start(address: String, port: String) {
    let location = format!("{}:{}", address, port);
    let listener = TcpListener::bind(&location)
        .await
        .expect("Failed to bind to addr");

    loop {
        let (stream, addr) = listener.accept().await.unwrap();
        tokio::spawn(async move {
            handle_stream(stream, addr).await;
        });
    }
```
In the `start` function, the given socket address is bound using the Tokio
`TcpListener`. We then enter an infinite loop and listen for and accept incoming socket
connections, which blocks execution during this waiting period.
The server is officially on and waiting for clients to join.

    $ nc localhost 4888

Look at that! Our first customer. When Netcat makes the TCP connection, our listener
will return a tuple that holds the socket stream and its address. Since we want
to handle a lot of connections at once (lot's of people are going to be chatting, I can't wait!),
we'll create an async task for each one by giving an async block to `tokio::spawn`.
Defining the block with `move` means the stream and addr ownerships will be 
passed into the block and will no longer be usable in this scope, which is fine.
Then we await the `handle_stream` function.

```rust
async fn handle_stream(stream: TcpStream, addr: std::net::SocketAddr) {
    let mut reader = BufReader::new(stream);
    let mut buffer = String::new();
    loop {
        tokio::select! {
            read_result = reader.read_line(&mut buffer) => {
                // chat message received!
            }
        }
    }
}
```
When a user types in a message and hits enter, those bytes are sent into the socket.
If you've never worked with sockets before, they're treated just like files!
`BufReader#read_line` will read bytes from the stream until a newline is found
and then put them in the buffer, a string in this case.
This is a blocking operation; if nothing is in the socket, the reader says,
"__EVERYBODY SHHHHH!__ _I'm listening..._".

And this is why we spawned a task.
Let's say we're on a single thread and we have many tasks doing important things.
If one of them stops to take a break, we don't want to prevent the others from working, too.
When a task blocks, on IO for example, Tokio will raise an eyebrow and put that task back in the box
and switch execution over to the next available task. Eventually, when the first
one is no longer blocked, it will continue where it left off. Tokio also does this
using multithreading, passing tasks across threads, but that is an implementation detail.

#### tokio::select!
The `tokio::select!` macro is the shining jewel that made this whole chat server
possible. It's similar to the `match` statement where branches are
matched to patterns. The branches in this `select!`, however, are futures that are
awaited on. The first one that returns and matches its pattern is the branch that gets evaluated.
If the return value does not match the pattern, the `select!` drops it and waits for another future.
Due to the infinite loop, after a line is read and that branch evaluated,
the process begins again and waits for more data to enter the stream.
We only have one branch currently, but this will be important when we add more functionality
later. First thing's first though: we got a message from the stream! What do we
do with it?

### Handle a message
We have two things to work with, the result of the reading and the message itself.
If the read was successful, we need to broadcast the message to all the other streams
that are open.
```rust
match read_result {
    Ok(_bytes_read) => {
        publisher
            .send(Event(addr, message))
            .expect("Error publishing message.");
    }
    Err(e) => {
        println!("Error reading stream: {}", e);
    }
}
```
Wait a minute! Where'd that `publisher` come from? Has this post been proofread?
Look here, I was witholding information until it was needed. Let's go back and
add the code to get a publisher.

```rust
// server.rs
use tokio::sync::broadcast;

pub async fn start(address: String, port: String) {
    let (tx, _) = broadcast::channel(32);
    loop {
        // ...
        let publisher = tx.clone();
        let consumer = tx.subscribe();
        tokio::spawn(async move {
            handle_stream(stream, publisher, consumer, addr).await;
        });
    }
}
```
In the `start` function, we create a Tokio broadcast channel.
You set the maximum number of values to be stored in the channel, 
and you get a tuple containing a transmitter and receiver. If you know Go, 
you'll be familiar with the concept. 
Calling `send` on the transmitter puts a value in the channel, and
using `recv` on the receiver gets the value out. This broadcast allows for a multiple-producer,
multiple consumer communication method. We can `clone` and `subscribe` the transmitter
to get new transmitters and receivers, respectively, and move them into the
spawned tasks on each iteration.

### Consumption
The message has been sent to the channel, and all the other tasks need to pick it
up and write it to their streams. But how are they supposed to do that while they are
blocked waiting for a read? Back to `tokio::select!`!

```rust
loop {
    tokio::select! {
        read_result = reader.read_line(&mut buffer) => {
            // chat message received, publish it!
        }

        event = consumer.recv() => {
            let Event(id, msg) = event.expect("Parsing event failed");
            if id != addr {
                let formatted_msg = format!("[{}]: {}", id, msg);
                let _ = reader.write(formatted_msg.as_bytes()).await.expect("Broadcast write failed");
            }
        }
    }
}
```
Now we can see the power. The select awaits on `read_line` and `recv` (they are both async).
Whichever one finishes first will have their branch executed (those variable patterns match anything).
When a message arrives on the channel, it will be written to the stream through the `reader`
(yeah I was confused to).
Then the loop will start over and wait for another read or write. Beautiful!

One more thing to note is how to avoid broadcasting a message to the same socket
that it was read from. We can do this by including a unique task identifier with the
message and avoid writing to that stream if it's from the same task. That's what the
`addr` variable is used for (it comes from `accept` remember).

```rust
#[derive(Debug, Clone)] // automatic trait implementation
struct Event(SocketAddr, Message); // tuple struct

// publish
publisher.send(Event(addr, message))

// consume
let Event(id, msg) = event.expect("Parsing event failed");
if id != addr {
    // write to stream
}
```

### Final Summation
Remember that concurrency is not parallelism. You can achieve high concurrency on a single core
in one thread. Vanilla async Rust acts simiarly to coroutines in Python, goroutines
in Go, and processes in Elixir (although they all differ in implementation). They
are green threads, which means application code manages the execution contexts rather
than the OS. This generally happens in one actual OS thread, but the scheduler may also
use multiple OS threads as an implementation detail. Green threads are great for 
heavy IO use as opposed to CPU crunching.

My initial attempt at this server stayed in the standard lib by using
`std::thread` to manage threads directly and `std::sync::mpsc` to communicate between them.
I ran into pain when trying to figure out how to make a thread read data from the
socket AND from the channel without blocking either. MPSC
(multi-producer, single consumer) was also not
the paradigm I was going for, but it seemed to be the only channel structure offered by stdlib. 
After reading through the [Tokio tutorial](https://tokio.rs/tokio/tutorial){:target="x"}, 
I discovered it was built to handle everything I needed.
Sometimes it's fun to know how stuff runs under the covers, and sometimes you just
want to get shit done. Tokio excels at that part.
It makes concurrency a lot more ergonomic, and I highly recommend it.
