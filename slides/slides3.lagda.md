
---
title: "Correct-by-construction programming in Agda"
subtitle: "Part 3: Side effects, type classes, and monads"
author: "Jesper Cockx, Bohdan Liesnikov"
date: "31 May 2022"

transition: "linear"
center: "false"
width: "1280"
height: "720"
margin: "0.2"
---


# Type classes

## Type classes in Agda

A type class offers one or more functions for a **generic** type.
A type class is implemented by using a **record type** + **instance arguments**.
For example, `Print A`:

  * `print : A → String`

## Record type

Record type is a **dictionary** holding implementation of each function for a specific type

<!--
```agda
module _ where
open import Data.Bool.Base
open import Data.String.Base
```
-->
```agda
record Print {ℓ} (A : Set ℓ) : Set ℓ where
  field
    print : A → String
open Print {{...}}  -- print : {{r : Print A}} → A → String
```

## Instance arguments
Instance arguments *automatically* pick the 'right' dictionary for the given type

```agda
instance
  PrintBool : Print Bool
  print {{PrintBool}} true  = "true"
  print {{PrintBool}} false = "false"

  PrintString : Print String
  print {{PrintString}} x = x
```

## Using type classes in Agda

When using a function of type `{{x : A}} → B`, Agda will automatically
resolve the argument if there is a **unique** instance of the
right type in scope.

```agda
testPrint : String
testPrint = (print true) ++ (print "a string")
```

# Monads

## Side effects in a pure language

Agda is a **pure** language: functions have no side effects

But a typechecker has many side effects:

- raise error messages
- read or write files
- maintain a state for declared variables

How does one use Monads in Agda?

See [Library/Error.agda](../src/html/Library.Error.html)

## `do` notation

The syntax for `do`-notation is just about what you're used to.

<!--
```
open import Data.Vec using (Vec)
open import Library hiding (All; IMonad; return; _>>=_)
module _ where
  open import Library hiding (All; IMonad)
```
-->

```
  _ : Maybe ℤ
  _ = do
    x ← just (-[1+ 3 ])
    y ← just (+ 5)
    return (x + y)
```

## Pattern matching with `do`

There can be a *pattern* to the left of a `←`, alternative cases can be handled in a local `where`

```
  pred : ℕ → Maybe ℕ
  pred n = do
    suc m ← just n
      where zero → nothing
    return m
```

## Dependent pattern matching with `do`

```
  postulate
    test : (m n : ℕ) → Maybe (m ≡ n)

  cast : (m n : ℕ) → Vec ℤ m → Maybe (Vec ℤ n)
  cast m n xs = do
    refl ← test m n
    return xs
```
Pattern matching allows typechecker to learn new facts!

## Type-checking expressions

See [V3/TypeChecker.agda](../src/html/V3/V3.TypeChecker.html).

Exercise: extend the typechecker with rules for the new syntactic constructions you added before


# Indexed monads

## Typechecking variable declarations

For type-checking variables, we need the following side-effects:

* For checking *expressions*: find variable with given name (⇒ read-only access)
* For checking *declarations*: add new variable with given name (⇒ read-write access)

How to ensure **statically** that each variable in scope has a name?

## Reminder: The `All` type

For `P : A → Set` and `xs : List A`, `All P xs` associates an element of `P x` to each `x ∈ xs`:
```
data All {A : Set} (P : A → Set) : List A → Set where
  []  : All P []
  _∷_ : ∀ {x xs} → P x → All P xs → All P (x ∷ xs)
```

- Value for each variable: `Env Γ = All Val Γ`
- Name for each variable: `TCCxt Γ = All (\_ → Name) Γ`

## Adding new variables to the typechecking context

We need to *modify* both `Γ : Cxt` and `ρ : TCCxt Γ`!

Possible solutions:

- decouple names from the context?
- use state of type `Σ Cxt TCCxt`?
- **index** the monad by the context Γ!

## Indexed monads

An **indexed monad** = a monad with two extra parameters for the (static) *input* and *output* states

```
record IMonad {I : Set} (M : I → I → Set → Set) : Set₁ where
  field
    return : ∀ {A i} → A → M i i A
    _>>=_  : ∀ {A B i j k}
           → M i j A → (A → M j k B) → M i k B
```

Examples:

- `TCDecl` monad (see [V2/TypeChecker.agda](../src/html/V2/V2.TypeChecker.html)).
- `Exec` monad (see [V3/Interpreter.agda](../src/html/V3/V3.TypeChecker.html)).

# Haskell FFI

## Why use an FFI?

We now have a correct-by-construction typechecker + interpreter.

However, some things are still missing:

- Parser
- Pretty printer

**Goal.** Use Haskell library for generating these *automatically*

<!--
```agda
module _ where

module FFI where
```
-->



## Haskell FFI: basics

Import a Haskell module:

```agda
  {-# FOREIGN GHC import HaskellModule.hs #-}
```

Bind Haskell function to Agda name:

<!--
```
  postulate AgdaType : Set
```
-->

```agda
  postulate agdaName : AgdaType
  {-# COMPILE GHC agdaName = haskellCode #-}
```

Bind Haskell datatype to Agda datatype:

```
  data D : Set where c₁ c₂ : D
  {-# COMPILE GHC D = data hsData (hsCon₁ | hsCon₂) #-}
```
## Haskell FFI example:

```haskell
  -- In file `While/V1/Abs.hs`:
  data Type = TBool | TInt
```
```agda
  -- In file `AST.agda`:
  {-# FOREIGN GHC import While.Abs #-}
  data Type : Set where
    bool int : Type

  {-# COMPILE GHC Type = data Type
    ( TBool
    | TInt
    ) #-}
```

## BNFC: the Backus-Naur Form Compiler

BNFC is a Haskell library for generating Haskell code from a grammar:

- Datatypes for abstract syntax
- Parser
- Pretty-printer

See [While.cf](../src/V1/While.cf) for the grammar of WHILE.

## Exercises

Extend the typechecker and the BNFC grammar with the new syntactic
constructions you added.

Don't forget to update the Haskell bindings in
[AST.agda](../src/V1/html/V1.AST.html)!

Running the test suite:

* `make parser`: compile the parser and run it on [/test/gcd.c](../test/gcd.c).
* `make test`: compile the whole typechecker and run it on the examples in `/test`
