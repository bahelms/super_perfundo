==title==
Ray Tracer Challenge, pt. 4: The Next Dimension

==tags==
rust, graphics, algorithms, ray-tracer-challenge, math

==description==
Let's accept The Ray Tracer Challenge and write a 3D renderer in Rust!
In Part 4, we'll barf.

==image==
lighted_sphere.jpg

==body==
_The full code for this challenge can be found at [this repo](https://github.com/bahelms/ray_tracer){:target="x"}._

* [Part 1: Creating A 2D Image](/articles/ray-tracer-part1)
* [Part 2: Enter The Matrix](/articles/ray-tracer-part2)
* [Part 3: Let There Be Light!](/articles/ray-tracer-part3)
* Part 4: The Next Dimension

Greetings, you beautiful people! I have great news: we've finally reached the stage
where we can create a real life 3D image. Behold!

<div class="flex" style="justify-content:center;">
  <img class="md-image" style="width:40%;" src="<%= img_url.("lighted_sphere.jpg") %>" alt="Lighted Sphere" />
  <img class="md-image" style="width:40%;" src="<%= img_url.("sphere3.jpg") %>" alt="Lighted Sphere" />
  <img class="md-image" style="width:40%;" src="<%= img_url.("sphere4.jpg") %>" alt="Lighted Sphere" />
</div>

Such beautiful balls we've created! What's fascinating is all that's needed to take
the original 2D circle up to the 3rd dimension is light and shade.

# Cast Out the Dark
There are many ways to simulate light algorithmically; the method the book describes is the
[Phong reflection model](https://en.wikipedia.org/wiki/Phong_reflection_model){:target="x"}.
It consists of three layers of colors derived from the base image (our 2d circle).
* Ambient reflection
* Diffuse reflection
* Specular reflection

Alone, they aren't much, but combined, they convince your brain you're looking at a sphere.
<div class="flex" style="justify-content:space-around;flex-wrap:wrap;">
  <div class="flex" style="flex-direction:column;align-items:center;">
    <img class="md-image" style="" src="<%= img_url.("ambient_only.jpg") %>" alt="Lighted Sphere" />
    <span style="">Ambient</span>
  </div>
  <div class="flex" style="flex-direction:column;align-items:center;">
    <img class="md-image" style="" src="<%= img_url.("diffuse_only.jpg") %>" alt="Lighted Sphere" />
    <span>Diffuse</span>
  </div>
  <div class="flex" style="flex-direction:column;align-items:center;">
    <img class="md-image" style="" src="<%= img_url.("specular_only.jpg") %>" alt="Lighted Sphere" />
    <span>Specular</span>
  </div>
  <div class="flex" style="flex-direction:column;align-items:center;">
    <img class="md-image" style="" src="<%= img_url.("all_three.jpg") %>" alt="Lighted Sphere" />
    <span>Combined</span>
  </div>
</div>





It's always blown my mind that layers of color is all it takes to elevate a shape out of the second dimension.
