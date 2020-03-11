==title==
Test post again

==tags==
wigs, donuts

==description==
Live reloading these things is fucking sweet!

==body==
Dude, in Chapter 9, we mentioned that one limitation of vectors is that they can store elements of only one type. We created a workaround in Listing 8-10 where we defined a SpreadsheetCell enum that had variants to hold integers, floats, and text. This meant we could store different types of data in each cell and still have a vector that represented a row of cells. This is a perfectly good solution when our interchangeable items are a fixed set of types that we know when our code is compiled.

### Code Examples
```
val x = 3.5
```

Code body:
```
val x = 3 + 2
val result = timesThree(x)

fn timesThree(num int) int:
  num * 3

log(result)
```

However, sometimes we want our library user to be able to extend the set of types that are valid in a particular situation. To show how we might achieve this, we’ll create an example graphical user interface (GUI) tool that iterates through a list of items, calling a draw method on each one to draw it to the screen—a common technique for GUI tools. We’ll create a library crate called gui that contains the structure of a GUI library. This crate might include some types for people to use, such as Button or TextField. In addition, gui users will want to create their own types that can be drawn: for instance, one programmer might add an Image and another might add a SelectBox.

However, sometimes we want our library user to be able to extend the set of types that are valid in a particular situation. To show how we might achieve this, we’ll create an example graphical user interface (GUI) tool that iterates through a list of items, calling a draw method on each one to draw it to the screen—a common technique for GUI tools. We’ll create a library crate called gui that contains the structure of a GUI library. This crate might include some types for people to use, such as Button or TextField. In addition, gui users will want to create their own types that can be drawn: for instance, one programmer might add an Image and another might add a SelectBox.

### Another heading separating some bit of text
However, sometimes we want our library user to be able to extend the set of types that are valid in a particular situation. To show how we might achieve this, we’ll create an example graphical user interface (GUI) tool that iterates through a list of items, calling a draw method on each one to draw it to the screen—a common technique for GUI tools. We’ll create a library crate called gui that contains the structure of a GUI library. This crate might include some types for people to use, such as Button or TextField. In addition, gui users will want to create their own types that can be drawn: for instance, one programmer might add an Image and another might add a SelectBox.

However, sometimes we want our library user to be able to extend the set of types that are valid in a particular situation. To show how we might achieve this, we’ll create an example graphical user interface (GUI) tool that iterates through a list of items, calling a draw method on each one to draw it to the screen—a common technique for GUI tools. We’ll create a library crate called gui that contains the structure of a GUI library. This crate might include some types for people to use, such as Button or TextField. In addition, gui users will want to create their own types that can be drawn: for instance, one programmer might add an Image and another might add a SelectBox.
