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
         | Bool Bool
         | Add Exp Exp
         | Sub Exp Exp
         | Div Exp Exp
         | And Exp Exp | Or Exp Exp | Not Exp
         | Let Id Exp Exp
         | Ref Id
         | App Name Exp
         | Lambda (FormalArg, Type) Exp
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
           | BoolValue Bool
           | Closure (FormalArg, Type) Exp DefrdSub
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

\end{code}
