==title==
Ray Tracer Challenge, pt. 1: Create An Image

==tags==
rust, graphics, algorithms, ray-tracer-challenge

==description==
Let's accept the The Ray Tracer Challenge and write a 3D renderer in Rust!
In Part 1, we'll generate and save an image showing the trajectory of a launched projectile.

==image==
trajectory.png

==body==
Hello there! Are you fascinated with really interesting computer science problems
like compilers, complex machines, or graphics? Well, you've come to the right place.
This is the first in a series of posts detailing my adventures in writing a 3D
rendering program from scratch. A ray tracer, specifically. And my guide on this
journey is the incredible book
[The Ray Tracer Challenge](https://pragprog.com/titles/jbtracer/the-ray-tracer-challenge/){:target="x"}.
This is how all tutorials should be structured. Each chapter builds on the previous,
describing what is necessary to implement in order to have a program that will generate
3D images by the end. The killer feature is that you can code it however you want.
There are no copy pastas or typing exercises involved. You're given explanations
of what must be done and high level tests to prove it works. You are free to use
whatever you can to get the tests to pass and have a running program. So cool.
If you've read any of my previous posts, you'll probably correctly guess that I choose
Rust to complete this challenge. It's a non-trivial piece of work, so once finished,
it would be a great thing to translate into other languages that you want to learn.

<hr>

DEPRECATED

Welcome back! I've been wanting to take the
[Ray Tracer Challenge](https://pragprog.com/titles/jbtracer/the-ray-tracer-challenge/){:target="x"}
for some time now, and I've finally arrived at that spot on my todo list.
This book provides the best way to learn how to build something cool. It describes
what needs to be done (even provides Cucumber tests), and it's on you to figure
out how to implement it. Use whatever languauge and algorithms you want.
Just satisfy the tests and you'll have a working 3D renderer by the end of the book.
All tutorials should be this way!

This will be the first in a series of posts detailing my progress through the challenge.
To get started, I'll walk through how to create an initial image file
using some of the data structures that will be needed later. However, I'm going to
start from the end and work back to the beginning - macro to micro; image to primitives.
Let us begin!

## The Image
Let's launch a projectile on the left side of the image and see how it flies.
All its glory:
<div class="flex" style="justify-content:center;">
  <img class="md-image" style="width:60%;" src="<%= img_url.("trajectory.png") %>" alt="Projectile Trajectory" />
</div>
Beautiful! We have a projectile that is represented by a point in space at a given
time interval. It launches at a certain velocity and gravity and wind play their
part in bringing it to the ground and increasing the travel distance respectively.
Super cool. We'll get into the details in a bit, but for now, let's figure out how
to create the image file.

## File Type and Contents
What type of image file should we use? Unless you've already taken this challenge,
you may have never heard of the type suggested by the book: PPM! The
[Portable Pixmap](https://netpbm.sourceforge.net/){:target="x"}
is one of many ways to encode graphics formats. It consists of a header and pixel data:
```
P3
5 3
255
255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
```
The first three lines are the header:
* `P3` - The PPM spec. P3 means "plain" PPM.
* `5 3` - Image width and height in pixels.
* `255` - Maximum color value - each red/green/blue value can be 0-255.

The rest is the representation of pixels in the image. The height is 3, so there
are 3 lines. Each pixel contains values for 3 colors (red, green, blue) and
the width is 5. Therefore, each line has 3*5 integers that don't exceed the max
value, seperated by spaces. Logically grouping the pixels can help you visualize:
```
(255 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
```
Now we have the text version of our image! Save it to a file.
```rust
let mut file = File::create("images/trajectory.ppm").unwrap();
file.write_all(canvas.to_ppm().as_bytes()).unwrap();
```
There are various apps you can use to render a `.ppm` file. On macOS, Preview.app
has built in support. In Linux, you can use GIMP. Notice on the last line the use
of `canvas.to_ppm()`. The canvas is a struct representing the image and it can
be converted to a PPM string. I wonder what that canvas looks like?

## The Canvas
It's nearly identical to the PPM format. It has a width and height and holds a
flat list of colors representing the pixels.
```rust
pub struct Canvas {
    width: i32,
    height: i32,
    pixels: Vec<Color>,
}
```
When a new canvas is made, it should be blank, and we'll use black to do that (cause dark mode rocks).
We'll look at `Color` later, but for now black is all zeroes and white is all max (255).
```rust
impl Canvas {
    pub fn new(width: i32, height: i32) -> Self {
        let capacity = width * height; // capacity is known!
        let mut pixels = Vec::with_capacity(capacity as usize); // allocate list
        for _ in 0..capacity {
            pixels.push(Color::new(0.0, 0.0, 0.0)); // fill list with black pixels
        }

        Self {
            width,
            height,
            pixels,
        }
    }
}
```

* Color
* write_pixel
* launch (tick loop)
