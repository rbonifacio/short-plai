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

Having named and def ind $f$, what do we do with it? The 
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

data F1LAE = Num Integer
           | Add F1LAE F1LAE
           | Sub F1LAE F1LAE 
           | Let Id F1LAE F1LAE
           | Ref Id
           | App Id F1LAE
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
data FunDec = FunDec Id Id F1LAE 
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
and the set of known function declarations. Must of 
the rules of \texttt{LAE} remain the same, 
so we can focus on the new rule. 

\begin{code}
interp :: F1LAE -> [FunDec] -> Int 
interp = undefined 
\end{code} 