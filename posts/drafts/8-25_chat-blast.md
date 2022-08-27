==title==
Chat Blast! A TCP chat server in Rust.

==tags==
rust, networking, async, tokio

==description==
Where we write a CLI chat server over TCP sockets using Rust and Tokio.

==image==
monte-carlo.png

==body==
Hello there! I've been playing with Rust for years now, but I've never gotten
around to using it asynchronously. I thought I should change this and write something
simple yet useful enough for learning. A TCP chat server! First, let's define the
problem. Code link

### What is a TCP chat server?

As a user, I want to connect to a remote chat room in my terminal (it's the 80s) and type
messages that everybody else in the room, also remotely connected, can read. This
means we need a client to send messages and a server to handle them. The first part
is super easy. We'll just use [Netcat](https://en.wikipedia.org/wiki/Netcat){:target="x"}
as our client for now. It's probably already on your machine. This will let us
focus on writing the server. We would probably want to write our own client if
we wanted to get fancy with a Chat Blast UI. Let's avoid that for now.

For development, the server will be running on 127.0.0.1 on an arbitrary unused
port, 4888. To connect with netcat we use `nc localhost 4888`, which does absolutely
nothing right now since there is no server. How bout we fix that!

### Rusty server

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
inputs and starting the program. When business logic lives elsewhere, it's reuseable
and easier to test. Speaking of reuseablility, you'll notice that I've hardcoded
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
CPU computation, multithreading would be a better approach.

`#[tokio::main]` is an attribute-like procedural macro. It's a convenient way to
set up the Tokio runtime. It converts the `main` function into this:

```rust
fn main() {
    let mut rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        // your main code
    })
}
```

Async functions return lazy `Future` types that do nothing until `.await` is called
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
        println!("Connection accepted: {}", addr);
```

In the server start function, the given socket address is bound using the Tokio
`TcpListener`. We then enter an infinite loop and accept any incoming socket
connection. This blocks execution while it waits for a connection to come in.
Now the server is on and waiting for clients to join.
