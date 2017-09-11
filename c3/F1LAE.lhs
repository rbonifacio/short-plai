\section{An Introduction to Functions}

In the previous chapter, we have
added identifiers and and the ability
to name expressions to the language.
Much of the time, though, simply
being able to name an expression isn't
enough: the expression's value
is going to depend on the context of
its use. That means the expression needs
to be parameterized and, thus, it
must be a \emph{function}.

Dissecting a \texttt{Let} expression is
a useful exercise in helping us design
functions. Consider the program

\begin{verbatim}
Let x = 5 in x + 3
\end{verbatim}

In this program, the expression \texttt{x + 3} is parameterized
over the value of \texttt{x}. In that sense, it is just like
a function definition: in mathematical notation we might
write:

\begin{eqnarray*}
f(x) & = & x + 3
\end{eqnarray*}

Having named and defined $f$, what do we do with it? The
\texttt{LAE} program introduces \texttt{x} and than immediately
binds it to \texttt{5}. The way we bind a function's argument
to a value is to apply it. Thus, it is as if we wrote:

\begin{eqnarray*}
f(x) & = & x + 3;\ f(5)
\end{eqnarray*}

In general, functions are useful entities to have in programming
languages, and it would be instructive to model them.

\subsection{Enriching the Languages with Functions}

To add functions to \texttt{LAE}, we must define their abstract syntax.
In particular, we must both describe a \emph{function definition} (declaration) and
provide a means for its \emph{application} or \emph{invocation}. To do the
latter, we must add a new kind of expression, resulting in the language
\texttt{F1LAE}. We will presume, as a simplification, that functions consume
only one argument. This expression language has the following \bnf.

\begin{verbatim}
 <F1LAE> ::= Int Num
         | Add <F1LAE> <F1LAE>
         | Sub <F1LAE> <F1LAE>
         | Let <Id> <F1LAE> <F1LAE>
         | Ref <Id>
         | App <Id> <F1LAE>
\end{verbatim}

The expression representing the argument supplied to the
function is known as the actual parameter. To capture this
new language, we again have to declare a Haskell
data type.

\begin{code}
module F1LAE where

import Test.HUnit

type Id = String
type Value = Integer

data Exp = Num Integer
           | Add Exp Exp
           | Sub Exp Exp
           | Let Id Exp Exp
           | Ref Id
           | App Id Exp
 deriving(Read, Show, Eq)
\end{code}

Now, let's study function declaration. A function declaration has three
components: the name of the function, the names of its arguments
(known as the formal parameters), and the function's body.
(The function's parameters might have types, which we will
discuss later in this book). For now, we will presume
that functions consume only one argument. A simple
data definition captures this.

\begin{code}
data FunDec = FunDec Id Id Exp
 deriving(Read, Show, Eq)
\end{code}

Using this definition, one might declare a standard function
for doubling its argument as:

\begin{code}
double :: FunDec
double = FunDec "double" "x" (Add (Ref "x") (Ref "x"))
\end{code}

Now we are ready to write the calculator, which we will
call \emph{interp}---short for interpreter-rather than
\emph{calc} to reflect the fact that our language
has grown beyond arithmetic. The interpreter must
consume two arguments: the expression to evaluate
and the set of known function declarations. Most of
the rules of \texttt{LAE} remain the same,
so we can focus on the new rule.

\begin{code}
interp :: Exp -> [FunDec] -> Int
interp = undefined
\end{code}

The rule for an application first looks up
the named function. If this access succeeds,
then interpretation proceeds in the body
of the function after first substituting
its formal parameter with the (interpreted)
value of the actual parameter. We can
see the result using GHCi.

\subsection{The scope of substitution}

Suppose we ask our interpreter to evaluate
the expression

\begin{code}
app1 :: F1LAE
app1 = App "f" (Num 10)
\end{code}

In the presence of the solitary function definition

\begin{code}
f :: FunDec
f = FunDec "f" "n" (App "n" (Ref "n"))
\end{code}

What should happen? Should the interpreter try to substitute
the $n$ in the function position of the application
with the number $10$, then complain that no such function
can be found (or even that function lookup fundamentally
fails because the names of the functions must be identifiers,
not numbers)? Or should the interpreter decide that function
names and function arguments live in two different ``spaces'',
and let the context determine in which space to lookup a name? Languages
like Scheme take the former approach: the name of a function
can be bound to a value in a local scope, thereby rendering
the function inaccessible through that name. This later
strategy is known as employing namespaces and languages
like Common Lisp adopt it.

\subsection{The Scope of Function Definitions}

Suppose our \emph{definition list} contains multiple function
declarations. How do these interact with one another?
For instance, suppose we evaluate the following
input \texttt{eval app1 [g, h]}, where

\begin{code}
app1 :: F1LAE
app1 = App "g" (Num 5)

g :: FunDec
g = FunDec "g" "n" (App "h" (Add (Ref "n") (Num 5)))

h :: FuncDec
h = FunDec "h" "m" (Sub (Ref "m") (Num 1))
\end{code}

What does the mentioned evaluation do? The main expression
applies $g$ to $5$. The definition of $g$, in turn, invokes
function $h$. Should $g$ be able to invoke $h$? Should the
invocation fail because $h$ is defined after $g$ in the list
of definitions? What if there are multiple bindings
for a given function's name? We will expect this evaluation
to reduce to $9$. That is, we employ the more natural interpretation
that each function can ``see'' every function's definition,
and the natural assumption that each name is bound at most
once so we don't need to disambiguate between definitions.
It is, however, possible to define more sophisticated
scopes.

\begin{Exercise}
If a function can invoke every defined function, that
means it can also invoke itself. This is currently of
limited value because our \texttt{F1LAE} language lacks
a harmonious way of terminating recursion. Implement a
simple conditional construct (\texttt{if0}) which succeeds
if the term in the first position evaluates to zero,
and write interesting recursive functions in this language.
\end{Exercise}
