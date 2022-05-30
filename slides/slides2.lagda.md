
---
title: "Correct-by-construction programming in Agda"
subtitle: "Part 2: indexed datatypes and dependent pattern matching"
author: "Jesper Cockx, Bohdan Liesnikov"
date: "31 May 2022"

transition: "linear"
center: "false"
width: "1280"
height: "720"
margin: "0.2"
---

# Intrinsically well-typed syntax


## Well-typed syntax representation

<!--
```
open import Data.Bool using (Bool; true; false)
open import Data.Nat using (ℕ; zero; suc)
open import Data.Integer using (ℤ)

postulate
  ⋯ : ∀ {ℓ} {A : Set ℓ} → A

data Vec (A : Set) : ℕ → Set where
  []  : Vec A 0
  _∷_ : ∀ {n} → A → Vec A n → Vec A (suc n)

data List (A : Set) : Set where
  []  : List A
  _∷_ : A → List A → List A

data Fin : ℕ → Set where
  zero : ∀ {n} → Fin (suc n)
  suc  : ∀ {n} → Fin n → Fin (suc n)

lookup : ∀ {A} {n} → Vec A n → Fin n → A
lookup xs i = ⋯
```
-->

Our correct-by-construction typechecker produces **intrinsically well-typed syntax**:

<!--
```
module V1 where
```
-->

```
  data Type : Set where
    int bool : Type

  data Exp : Type → Set
    -- ...
```

A term `e : Exp t` is a *well-typed* WHILE expression.

## Well-typed syntax

```agda
  data Op : (dom codom : Type) → Set where
    plus  : Op int  int
    gt    : Op int  bool
    and   : Op bool bool

  data Exp where
    eInt  : (i : ℤ)            → Exp int
    eBool : (b : Bool)         → Exp bool
    eOp   : ∀{t t'} (op : Op t t')
          → (e e' : Exp t)     → Exp t'
```

See
[V1/WellTypedSyntax.agda](../src/V1/html/V1.WellTypedSyntax.html).

## Evaluating well-typed syntax

We can interpret `C` types as Agda types:
```
  Val : Type → Set
  Val int  = ℤ
  Val bool = Bool
```

We can now define `eval` for well-typed expressions:

```

  eval : ∀ {t} → Exp t → Val t
  eval = ⋯
```
that **always** returns a value (bye bye `Maybe`!)

See definition of `eval` in
[V1/Interpreter.agda](../src/V1/html/V1.Interpreter.html).

# Dealing with variables

## Extending well-typed syntax with variables

A **context** is a list containing the types of variables in scope
```
data Type : Set where int bool : Type

Cxt = List Type
```

A **variable** is an index into the context
```
data Var : (Γ : Cxt) (t : Type) → Set where
  here  : ∀ {Γ t}    → Var (t ∷ Γ) t
  there : ∀ {Γ t t'} → Var Γ t → Var (t' ∷ Γ) t
```
(compare this to the definition of `Fin`)

## Well-typed syntax with variables

The type `Exp` is now parametrized by a context `Γ`:

```agda
data Exp (Γ : Cxt) : Type → Set where
  -- ...
  eVar  : ∀{t} (x : Var Γ t) → Exp Γ t
```
See [V2/WellTypedSyntax.agda](../src/V2/html/V2.WellTypedSyntax.html).

## The `All` type

`All P xs` contains an element of `P x` for each `x` in the list `xs`:

```
data All {A : Set} (P : A → Set) : List A → Set where
  []  : All P []
  _∷_ : ∀ {x xs} → P x → All P xs → All P (x ∷ xs)
```

## Evaluation environments

During evaluation we need a value for `All` variables
```
Val : Type → Set
Val int  = ℤ
Val bool = Bool

Env : Cxt → Set
Env Γ = All Val Γ
```

We can now extend `eval` to expressions with variables:

```
eval : ∀ {Γ} {t} → Env Γ → Exp Γ t → Val t
eval = ⋯
```

See definition of `eval` in [V2/Interpreter.agda](../src/V2/html/V2.Interpreter.html).

## Exercises

Extend the well-typed syntax ([V2/WellTypedSyntax.agda](../src/V2/html/V2.WellTypedSyntax.html)) and interpreter ([V2/Interpreter.agda](../src/V2/html/V2.Interpreter.html)) with either negation `~` or minus `-`.
