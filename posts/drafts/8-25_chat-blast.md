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

Now's where you ask, "WTH is tokio::main?". Good question! I had to figure that
out myself.

