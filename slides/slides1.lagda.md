
---
title: "Correct-by-construction programming in Agda"
subtitle: "Part 1: Getting started with Agda"
author: "Jesper Cockx, Bohdan Liesnikov"
date: "31 May 2022"

transition: "linear"
center: "false"
width: "1280"
height: "720"
margin: "0.2"
---

# Correct-by-construction programming

## Two approaches to verification with dependent types:

- **Extrinsic approach**
- **Intrinsic approach**

## Extrinsic verification

first write the program and then prove correctness:

<!--
```agda
postulate
  ⋯ : ∀ {ℓ} {A : Set ℓ} → A

module Intro where
  open import Data.Bool.Base using (Bool; true; false)
  open import Data.Char.Base using (Char)
  open import Data.Integer.Base using (ℤ)
  open import Data.List.Base using (List; []; _∷_)
  open import Data.Maybe.Base using (Maybe; nothing; just)
  open import Data.Nat.Base using (ℕ; zero; suc; _+_; _*_; _<_)
  open import Data.Product using (_×_; _,_)
  open import Agda.Builtin.Equality using (_≡_; refl)
```
-->

```agda
  module Extrinsic where
    sort : List ℕ → List ℕ
    sort = ⋯

    IsSorted : List ℕ → Set
    IsSorted = ⋯

    sort-is-sorted : ∀ xs → IsSorted (sort xs)
    sort-is-sorted = ⋯
```

## Intrinsic verification

first define the *type* of programs that satisfy the correctness property and then write the program that inhabits this type

```agda
  module Intrinsic where
    SortedList : Set
    SortedList = ⋯

    sort : List ℕ → SortedList
    sort = ⋯
```

Also called **correct-by-construction** programming. We will be using this approach.

## Running example

Implementation of a correct-by-construction **typechecker** + **interpreter** for a C-like language (WHILE)

```c
int main () {
  int n   = 100;
  int sum = 0;
  int k   = 0;
  while (n > k) {
    k   = k   + 1;
    sum = sum + k;
  }
  printInt(sum);
}
```

## Overview of this course

* **Part 1**: Getting started with Agda
* **Part 2**: Indexed datatypes and dependent pattern matching
* **Part 3**: Writing Agda programs that run
  - instance arguments
  - do notation
  - Haskell FFI

# Introduction to Agda

## Installation

We will need:

* Docker Desktop: [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
* VSCode: [code.visualstudio.com](https://code.visualstudio.com/)
* Clone this repo:  
  `git clone https://github.com/liesnikov/liesnikov/pl-group-retreat-workshop-2022`

## Working with files

* Open this folder in VSCode.
* You should see a popup "Folder contains a Dev Container configuration file".  
  Press "Reopen in Container" button.
* If you pulled the image before it should take a couple of seconds.  
  Otherwise wait a little while for the download of the docker image.

## VSCode mode for Agda

Basic commands:

- **C-c C-l**: typecheck and highlight the current file
- **C-c C-d**: deduce the type of an expression
- **C-c C-n**: evaluate an expression to normal form

Programs may contain **holes** (? or {! !}).

- **C-c C-,**: get information about the hole under the cursor
- **C-c C-space**: give a solution
- **C-c C-r**: *refine* the hole
  * Introduce a lambda or constructor
  * Apply given function to some new holes
- **C-c C-c**: case split on a variable

## Unicode input

Agda's mode interprets many latex-like commands as unicode symbols:

- `\lambda` = `λ`
- `\forall` = `∀`
- `\r` = `→`, `\l` = `←`
- `\Gamma` = `Γ`, `\Sigma` = `Σ`, ...
- `\equiv` = `≡`
- `\::` = `∷`
- `\bN` = `ℕ`, `\bZ` = `ℤ`, ...

To get information about specific character, use `C-x C-=`

# Demo time!

## Data types

<!--
```
module datatypes where
```
-->

```
  data Bool : Set where
    true  : Bool
    false : Bool

  data ℕ : Set where
    zero : ℕ
    suc  : (n : ℕ) → ℕ
```

<!--
```
open import Data.Nat using (ℕ; zero; suc)
open import Data.Bool using (Bool; true; false)
```
-->

## Function definitions

```
_+_ : ℕ → ℕ → ℕ
zero  + y = y
suc x + y = suc (x + y)
```

**Note:** underscores indicate argument positions for mixfix functions

## Pattern-matching lambda

A *pattern lambda* introduces an anonymous function:
```
f : Bool → Bool
f = λ { true  → false
      ; false → true
      }
```
Alternative syntax:
```
f′ : Bool → Bool
f′ = λ where
  true  → false
  false → true
```

## Testing functions using the identity type

The identity type `x ≡ y` is inhabited by `refl` iff `x` and `y` are
(definitionally) equal.

We can use this to write *checked* tests for our Agda functions!

```
open import Relation.Binary.PropositionalEquality using (_≡_; refl)

testPlus : 1 + 1 ≡ 2
testPlus = refl
```

## Parametrized datatypes

```
data List (A : Set) : Set where
  []  : List A
  _∷_ : A → List A → List A

data Maybe (A : Set) : Set where
  nothing : Maybe A
  just    : A → Maybe A
```

## Parametrized functions

```
if_then_else_ : {A : Set} → Bool → A → A → A
if false then x else y = y
if true  then x else y = x
```

**Note:** `{A : Set}` indicates an *implicit argument*

# Syntax of WHILE language

## Abstract syntax tree of WHILE

```
open import Data.Char using (Char)
open import Data.Integer using (ℤ)

data Id : Set where
  mkId : List Char → Id

data Exp : Set where
  eId       : (x : Id)      → Exp
  eInt      : (i : ℤ)       → Exp
  eBool     : (b : Bool)    → Exp
  ePlus     : (e e' : Exp)  → Exp
  eGt       : (e e' : Exp)  → Exp
  eAnd      : (e e' : Exp)  → Exp
```

## Untyped interpreter

```
data Val : Set where
  intV  : ℤ    → Val
  boolV : Bool → Val

eval : Exp → Maybe Val
eval = ⋯
```

See [`V1/UntypedInterpreter.agda`]( ../src/V1/html/V1.UntypedInterpreter.html)

## Practical part:

* Download the code with `git clone https://github.com/liesnikov/pl-group-retreat-workshop-2022`
* Load the code in VSCode
* Choose a language construct (e.g. negation `~` or minus `-`).  
  Add it to [`V1/AST.agda`](../src/V1/html/V1.AST.html) and [`V1/UntypedInterpreter.agda`](../src/V1/html/V1.UntypedInterpreter.html)
