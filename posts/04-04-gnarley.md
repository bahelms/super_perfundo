==title==
Awesome post

==tags==
monkeys, donuts

==description==
In order to increase fluency in a programming language, one has to read a lot of it. 
But how can you read a lot of it if you don't know what it means?

==body==
One increasingly popular approach to ensuring safe concurrency is message passing, where threads or actors communicate by sending each other messages containing data. Here’s the idea in a slogan from the Go language documentation: “Do not communicate by sharing memory; instead, share memory by communicating.”

One major tool Rust has for accomplishing message-sending concurrency is the channel, a programming concept that Rust’s standard library provides an implementation of. You can imagine a channel in programming as being like a channel of water, such as a stream or a river. If you put something like a rubber duck or boat into a stream, it will travel downstream to the end of the waterway.

A channel in programming has two halves: a transmitter and a receiver. The transmitter half is the upstream location where you put rubber ducks into the river, and the receiver half is where the rubber duck ends up downstream. One part of your code calls methods on the transmitter with the data you want to send, and another part checks the receiving end for arriving messages. A channel is said to be closed if either the transmitter or receiver half is dropped.
