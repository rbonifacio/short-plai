\section{Implementing Laziness}

Now that we've seen laziness at work and finished our implementation
using eager, we're ready to study the implementation of laziness. That is,
we will keep the \textit{syntax} of our language unchanged, but alter the
\textit{semantics} of function application to be lazy.

\subsection{Implementing Laziness}

Consider the following expression:

\begin{verbatim}
  let x = 4+5
    in let y = x+x
      in let z = y
        in let x = 4
          in z
\end{verbatim}

Recall that in a lazy language, the argument to a function--- which includes
the named expression of a \texttt{let}--- does not get evaluated until use.
Therefore, we can naively think of the expression above reducing as follows.

\begin{verbatim}
  let x = 4+5
    in let y = x+x
      in let z = y
        in let x = 4
          in z
  = let y = x+x
      in let x = 4
        in let z = y
          in z      [x -> 4+5]
  = let x = 4
      in let z = y
        in z        [x -> 4+5, y -> x+x]
  = let z = y
      in z          [x -> 4, y -> x+x]
  = z               [x -> 4, y -> x+x, z -> y]
  = y               [x -> 4, y -> x+x, z -> y]
  = x+x             [x -> 4, y -> x+x, z -> y]
  = 4+4             [x -> 4, y -> x+x, z -> y]
  = 8
\end{verbatim}

In contrast, suppose we used substituition instead of environments:

\begin{verbatim}
  let x = 4+5
    in let y = x+x
      in let z = y
        in let x = 4
          in z
  = let y = (4+5)+(4+5)
      in let z = y
        in let x = 4
          in z
  = let z = (4+5)+(4+5)
      in let x = 4
        in z
  = let x = 4
      in (4+5)+(4+5)
  =(4+5)+(4+5)
  = 9+9
  = 18
\end{verbatim}

We perform substituition, which means we replace identifiers whenever we
encounter bindings for them, but we don't replace them only with values:
sometimes we replace them with entire \textit{expressions}. Those expressions
have themselves already had all identifiers substituited.

This situation should look very familiar: this is the very same problem we
encountered when switching from substituition to environments. Substituition
\textit{defines} a program's value; because environments merely defer
substituition, they should not change value.

We address this problem before using closures. That is, the text of a function
was closed over (i.e., wrapped in a structure containing) its environment at
the point of definition, which was then used when evaluating the function's
body. The difference here is that we must create closures for \textit{all}
expressions that are not immediately reduced to values, so their environments
can be used when the reduction to a value actually happens.

We shall refer to these new kinds of values as \textit{expression closures}.
Since they can be the ressult of evaluating an expression (as we will soon see),
it makes sense to extend the set of values with this new kind of value. We will
also assume that our language has conditionals (since they help illustrate
some interesting points about laziness). Thus we will define the F6LAE with
the following grammar:

\begin{code}
data Exp = Num Integer
         | Add Exp Exp
         | Sub Exp Exp
         | Let Id Exp Exp
         | Ref Id
         | App Name Exp
         | Lambda FormalArg Exp
         | LambdaApp Exp Exp
         | IF0 Exp Exp Exp
     deriving(Show, Eq)
\end{code}

Observe the eager counterpart of this language would have the same \textit{syntax}.
The difference lies entirely in its interpretation. As before, we will continue
to assume that \texttt{Let} expressions are converted into immediate function
applications by the parser or by a pre-processor.

For this language, we define an extended set of values:

\begin{code}
data Value = NumValue Integer
           | Closure FormalArg Exp DefrdSub
           | ExpV Exp DefrdSub
     deriving(Show, Eq)
\end{code}

That is, a ExpV is just a wrapper that holds an expression and the environment
of this definition.

What needs to change interpreter? Obviously, procedure application must change.
By definition, we should not evaluate the argument expression; furthermore, to
preserve static scope, we should close it over its environmet:\footnote{The
argument expression results in an expression closure, which we then bind to
the function's formal parameter. Since parameters are bound to values, it
becomes natural to regard the expression closure as a kind of value.}

\begin{code}
interp (LambdaApp e1 e2) ds decs = interp body env decs
  where
    Closure farg body ds0 = interp e1 ds decs
    expV = ExpV e2 ds
    env  = (farg,expV):ds0
\end{code}

As a consequence, if we make a function declaration and aply it to an
expression such as

> interp(LambdaApp (Lambda "x" (Ref "x")) (Num 3)) [] []

\nindent will evaluate to some expression closure value, such as

> ExpV (Num 3) []

\nindent This says that the representation of the 3 is closed over the empty
environment.

That may be an acceptable output for a particularly simple program, but what
happens when we evaluate this one?

> interp(Let "x" (Num 3)(Add(Ref "x")(Ref "x"))) [][]

\nindent The interpreter evaluates each x in the body to an expression closure
(because that's what is bound to x in the environment), but the addition
procedure cannot handle these: it (and similarly any other arithmetic
primitive) needs to know exactly which number the expression closure
corresponds to. The interpreter must therefore "force" the expression closure
to reduce to an actual value. Indeed, we must do so in other positions as well:
the functionposition of an application, for instance, needs to know which
procedure to invoke. If we do not force evaluation at these points, then even
a simple expression such as

> Let "double" (Lambda "x" (Add(Ref "x")(Ref "x")))
>  (Add(LambdaApp (Ref "double")(Num 5))(LambdaApp (Ref "double")(Num 10)))

\nindent cannot be evaluated (since at the points of application, $double$ is
bound to an $expression$ closure, not a $procedural$ closure with an
identifiable parameter name and body).

Because we need to force expression closures to values in several places in
the interpreter, it makes sense to write the code to do this only once, so
we write the helper function $strict$:

\begin{code}
strict :: Value -> [FunDec] -> Value
strict n@(NumValue v) _ = n
strict c@(Closure farg body ds) _ = c
strict (ExpV e1 ds) decs = strict (interp e1 ds decs) decs
\end{code}

\nindent Now we can use this for numbers,

\begin{code}
interp (Add e1 e2) ds decs = NumValue (v1 + v2)
  where
    NumValue v1 = strict (interp e1 ds decs) decs
    NumValue v2 = strict (interp e2 ds decs) decs
\end{code}

\nindent and similarly in other arithmetic primitives, and also for $App$:

\begin{code}
interp (LambdaApp e1 e2) ds decs = strict (interp body env decs) decs
  where
    Closure farg body ds0 = interp e1 ds decs
    expV = ExpV e2 ds
    env  = (farg,expV):ds0
\end{code}

The points where the implementation of a lazy language forces an expression to
reduce to a value (if any) are called \textit{strictness} points of the
language; hence the perhaps odd name, \textit{strict}, for the procedure that
annotates these points of the interpreter.

Let's now exercise (so to speak) the interpreter's laziness. Consider the
following simple example:

> interp( Let "f" (Ref "x") (Num 4))[][]

Had the language been strict, it would have evaluated the named expression,
halting with an error ($x$ has not been declared). In contrast, our interpreter
yields the value $4$.

There is actually one more strictness point in our language: the evaluation of
the conditional. It needsto know the precise value that the test expression
evaluates to so it can determine which branch to proceed evaluating. This
highlights a benefit of studying languages through interpreters: assuming we
had good test cases, we would quickly discover this problem. (In practice, we
might bury the strictness requirement in a helper function such as $num-zero?$,
just as the arithmetic primitives' strictness is buried in the procedures such
as $Add$. We therefore need to trace which ecpression evaluations invoke
\textit{strict} primitives to truly understand the language's strictness
positions.)
