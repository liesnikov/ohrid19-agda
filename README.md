Correct by Construction Programming in Agda
===========================================

Abstract
--------

In a dependently typed programming language you can get much stronger
static guarantees about the correctness of your program than in most
other languages. At the same time, dependent types enable new forms of
interactive programming, by letting the types guide the construction
of the program. Dependently typed languages have existed for many
years, but only recently have they become usable for practical
programming.

In this course, you will learn how to write correct-by-construction
programs in the dependently typed programming language
Agda. Concretely, we will together implement a verified typechecker
and interpreter for a small C-like imperative language. Along the way,
we will explore several modern features of the Agda language that make
this task more pleasant, such as dependent pattern matching, monads
and do-notation, coinduction and copattern matching, instance
arguments, sized types, and the Haskell FFI.

Links
-----

* Slides [Lecture 1](slides/slides1.html) [Lecture
  2](slides/slides2.html) [Lecture 3](slides/slides3.html) [Lecture
  4](slides/slides4.html)

* Code listing [V1](src/V1/html/V1.runwhile.html)
  [V2](src/V2/html/V2.runwhile.html)
  [V3](src/V3/html/V3.runwhile.html)

<!--
* This README as a Webpage on
  [github.io](https://jespercockx.github.io/ohrid19-agda/)
-->



Prerequisites
-------------

For the exercises in this course, you need to install [Agda
2.6.0.1](https://agda.readthedocs.io/en/v2.6.0.1/getting-started/installation.html).,
the [Agda standard library
v1.1](https://github.com/agda/agda-stdlib/blob/master/notes/installation-guide.md),
and the [BNFC tool](https://github.com/BNFC/bnfc).

If you are brave, there is a [bash
script](https://github.com/jespercockx/ohrid19-agda/blob/master/setup.sh)
that installs all of these on a fresh installation of Ubuntu 18.04 or
later. Alternatively, below are step-by-step instructions.

### Installing Agda on Ubuntu

First, make sure you have git, cabal, and emacs installed. You also
need the `zlib` c library. On Ubuntu and related systems, the
following command should work:

```bash
sudo apt-get install git cabal-install emacs zlib1g-dev
```

Make sure that binaries installed by `cabal` are available on your
path by adding the following line to `~/.profile`:

```bash
export PATH="$PATH:$HOME/.cabal/bin"
```

Now install Agda and its prerequisites:

```bash
cabal update
cabal install alex happy
cabal get Agda && cd Agda-2.6.0.1 && cabal install
agda-mode setup
```

### Installing Agda on Mac

Follow the instructions in the [user
manual](https://agda.readthedocs.io/en/v2.6.0.1/getting-started/installation.html#os-x). Alternatively,
you can install the Haskell Platform and follow the instructions
above.

### Installing Agda on Windows

Follow the [instructions by Péter
Diviánszky](https://people.inf.elte.hu/divip/AgdaTutorial/Installation.html). Alternatively,
install a virtual machine with Ubuntu and follow the instructions
above.

### Installing the standard library

To install the Agda standard library:

```bash
git clone https://github.com/agda/agda-stdlib.git
cd agda-stdlib && git checkout v1.1 && cabal install
mkdir $HOME/.agda
echo $PWD/standard-library.agda-lib >> $HOME/.agda/libraries
echo standard-library >> $HOME/.agda/defaults
```

### Installing BNFC

```bash
cabal install BNFC
```


### Installing using Docker

You'll need `docker` and `docker-compose`. Installation instructions:

* https://docs.docker.com/get-docker/
* https://docs.docker.com/compose/install/

Or you can install Docker Desktop: https://www.docker.com/products/docker-desktop/

For editor, you'll need VSCode: https://code.visualstudio.com/
with an extension: [Remote -- Containers Extension](vscode:extension/ms-vscode-remote.remote-containers) (alternatively, use [this link](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers&WT.mc_id=devcloud-11496-buhollan))

*FIXME* : you have to change agda-path in the agda-mode extension to "/home/vscode/.cabal/bin/agda".


Exercises
---------

During the exercise sessions, your first goal should be to install
Agda (see above for instructions) and make yourself familiar with the
Emacs mode to navigate around in the code. Some useful commands:


- **C-c C-l**: typecheck and highlight the current file
- **C-c C-d**: deduce the type of an expression
- **C-c C-n**: evaluate an expression to normal form
- **C-c C-,**: get information about the hole under the cursor
- **C-c C-space**: give a solution
- **C-c C-r**: *refine* the hole
  * Introduce a lambda or constructor
  * Apply given function to some new holes
- **C-c C-c**: case split on a variable

See the [Agda documentation](https://agda.readthedocs.io/en/v2.6.0.1/)
for further information. The important parts of the code are the following:

- [While.cf](src/V1/While.cf) contains the BNF grammar of the language.
- [AST.agda](src/V1/html/V1.AST.html) contains the raw (untyped)
  syntax representation.
- [Parser.agda](src/V1/html/V1.Parser.html) contains bindings to the
  Haskell parser generated by BNFC.
- [WellTypedSyntax.agda](src/V1/html/V1.WellTypedSyntax.html) contains
  the intrinsically well-typed syntax representation.
- [TypeChecker.agda](src/V1/html/V1.TypeChecker.html) contains the
  typechecker, converting from raw to well-typed syntax.
- [Interpreter.agda](src/V1/html/V1.Interpreter.html) contains an
  interpreter for well-typed syntax.
- [runwhile.agda](src/V1/html/V1.runwhile.html) contains the main
  program.

Once you are familiar with (a part of) the codebase, you can try to
extend the language in a way of your choice. Some suggestions:

- (V1) Add more operations on booleans, e.g. negation `~`, disjunction
  `||`, ...
- (V1) Add more operations on integer, e.g. minus `-`, multiplication `*`,
  division `/`, ...
- (V1) Add an equality test `==` that works both on booleans and
  integers.
- (V2) Add additional assignment operators to the language, e.g. `x += e;`,
  `x++;`, ...
- (V2) Add uninitialized variables to the language (`int x;` instead of
  `int x = 5;`), and make sure the typechecker produces an error
  message when a variable is used before it is initialized.
- (V3) Add more control operators to the language, e.g. `if`-statements,
  `do/while` loops, `for` loops, `switch` statements, ...
- (any) Add more types to the language, e.g. `char` or `float`, and
  add appropriate syntactic constructions for literals, e.g. `'a'` or
  `1.2`.
- (any) Add the ability to define and call additional functions apart from
  the `main` function.

Further reading
---------------

- [Agda documentation](https://agda.readthedocs.io/en/v2.6.0.1/)
- [An introduction to dependent types in Agda](http://www2.tcs.ifi.lmu.de/~abel/DepTypes.pdf) by Andreas Abel
- [Agda tutorial](https://people.inf.elte.hu/divip/AgdaTutorial/Index.html) by Péter Diviánszky
- [Dependently typed programming in Agda (video lectures)](https://www.youtube.com/playlist?list=PL44F162A8B8CB7C87) by Conor McBride
- [Programming language foundations in Agda (online book)](https://plfa.github.io/)
- [Type-driven development in Idris (book)](https://www.manning.com/books/type-driven-development-with-idris)
- [Certified programming with dependent types (book)](http://adam.chlipala.net/cpdt/)
