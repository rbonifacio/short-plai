\section{First Class Functions}

There is a similarity between a \texttt{Let} expression
and a function definition applied immediately to a value.
For instance, note that:

\begin{verbatim}
Let x = 5 in x + 3
\end{verbatim}

\noindent is essentially the same as $f(x) = x + 3; f(5)$. Actually,
that is not quite right: in the math equation, we give the function
a name ($f$), whereas there is no identifier named $f$ anywhere
in the \texttt{Let} expression above. We can, however, rewrite
the mathematical formulation as $f = \lambda x . x + 3; f(5)$,
which can then be rewritten as $(\lambda x . x + 3)(5)$ to get
rid of the unnecessary name $f$. Notice, however, that our
language \texttt{F1LAE} does not permit anonymous functions
(a concept that currently is also present in
imperative languages like Java, Scala, and Python, for instance)
of the style we have used above. Because such functions
are useful in their own right, we will now extend our study of
functions.

\subsection{A Taxonomy of Functions}

The translation of \texttt{Let} into mathematical
notation exploits two features of functions: the
ability to create anonymous functions, and the ability
to define functions anywhere in the program (in this case,
in the function position of a Lambda application). Not
every programming language offers one or both of these
capabilities. There is, therefore, a taxonomy that
governs these different features, which we can use
when discussing what kind of functions a language
provides. The taxonomy is as what follows.

\begin{description}
\item [first-order] Functions are not values in the language. They
can only be defined in a designated portion of the program, where
they must be given names for use in the remainder of the program. The
functions in \texttt{F1LAE} are of this nature, which explains the
\texttt{1} in the name of the language.

\item [higher-order] Functions can return other functions as values.

\item [first-class] Functions are values with all the rights of
other values. In particular, they can be supplied as the value
arguments to functions, returned by functions as answers, and
stored in data structures.

\end{description}

\subsection{Enriching \texttt{F1LAE} with First-Class Functions}

To add \emph{first-class functions} to \texttt{F1LAE}, we must
proceed as usual, by first defining its concrete and
abstract syntaxe trees. First, let us examine some concrete programs:

\begin{verbatim}
 (\x -> x + 4) 5
\end{verbatim}

\noindent This program (consisting of a sole expression) defines a function
that adds $4$ to its argument and immediately applies this function
to $5$, resulting in the value $9$. This one

\begin{verbatim}
 Let double = (\x -> x + x)
  in (double 10) + (double 5)
\end{verbatim}

\noindent evaluates to $30$. The program defines a function,
binds it to \texttt{double}, then uses that name twice in
slightly different contexts (i.e., it instantiates the formal
parameter with different actual parameters). From these
examples, it should be clear that we must introduce two
new kinds of expressions: anonymous functions and
anonymous function applications. Here is the revised
\bnf corresponding to these examples.

\begin{grammar}
 <Name> ::= <Id>

 <Arg> :: = <Id>

 <FunDec> ::= `def' <Name> <Arg> `=' <FLAE>

 <FLAE> ::= <Num>
     \alt Add <FLAE> <FLAE>
     \alt Sub <FLAE> <FLAE>
     \alt Let <Id> <FLAE> <FLAE>
     \alt Ref <Id>
     \alt App <Name> <FLAE>
     \alt $\lambda$ <Arg> `.' <FLAE>
     \alt AppLambda <FLAE> <FLAE>
\end{grammar}

In this language, it is possible to declare
both named functions (using the function declarations)
and anonymous functions (using the lambda
abstractions), which might appear anywhere we
are expecting a \texttt{FLAE} expression (in particular,
in the first component of a lambda application). Therefore, instead
of just the name of a function, programmers can write an arbitrary
expression that must be evaluated to obtain the function
to apply. The corresponding abstract syntax is:

\begin{code}
module F2LAE where

type Id = String
type Arg = String

data FunDec = FunDec Id Arg Exp

data Exp = Num Integer
          | Add Exp Exp
          | Sub Exp Exp
          | Let Id Exp Exp
          | Ref Id
          | App Id Exp
          | Lambda Id Exp
          | AppLambda Exp Exp
\end{code}

To define our interpreter, we must think a little about
what kinds of values it consumes and produces. Naturally,
the interpreter consumes values of \texttt{FLAE} expressions
(and a list of function declarations). What does it
produce? Clearly, a program that meets \texttt{FLAE}
must yield numbers. As we have seen above,
some programs that use functions and applications
also evaluate to numbers. How about a program
that consists solely of a function? That is,
what is the value of the program \texttt{$(\lambda x . x)$}? It
clearly does not represent a number. It might be
a function that, when applied to a numeric argument,
produces a number, but it is not itself a number. We
instead realized from this that \emph{anonymous functions are also
values} that may be the result of a computation.

We could design an elaborate representation for function values, but for
now, we will remain modest. We will let the function evaluate to its
abstract syntax representation (i.e., a \texttt{Lambda} structure). For consistency,
we will also let numbers evaluate to a  \texttt{Num} structure. Thus, the
result of evaluating \texttt{$(\lambda x . x)$} would be the value \texttt{Lambda ``x'' (Ref ``x'')}.

Now we are ready to write the interpreter. We must pick a type for
the value that \emph{interp} returns. Since we have decided
to represent function and number answers using the abstract
syntax, it makes sense to use \texttt{FLAE} expressions, with
the caveat that only two kinds of expressions can appear in
the output: numbers and functions. Our first interpreter will
use explicit substitution, to offer a direct comparison with
the interpreters discussed before.

\begin{code}
interp :: Exp -> [FunDec] -> Exp
interp = undefined
\end{code}
