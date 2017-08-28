\section{A simple Arithmetic Expression Language} 

Having established a handle on parsing, 
which addresses syntax, we now begin to 
study semantics. We will study a language 
with only numbers, addition, and subtraction, 
and futher assume both these operations 
are binary. This is indeed a very rudimentary 
exercise, but that's the point. By picking 
something you know well, we can 
focus on the mechanics. Once you have a feel for the 
mechanics, we can use the same methods 
to explore languages you have nevever seen before. 

The interpreter has the following contract and purpose: 

\begin{code}
module AE where 

import Test.HUnit 

-- consumes an AE and computes the corresponding number
calc :: AE -> Integer

-- some HUnit test cases to better understand the calc semantics

exp1, exp2 :: String 
exp1 = "Num 3"
exp2 = "Add (Num 3) (Sub (Num 10) (Num 5))" 

tc1 = TestCase (assertEqual "tc01" (calc (parse  exp1)) 3) 

tc2 = TestCase (assertEqual "tc02" (calc (parse exp2)) 8) 

\end{code}

An arithmetic expression \texttt{AE} might be represented 
using a notation named \emph{Backus-Naur Form} (BNF), after
two early programming languages pioneers. A BNF 
description of rudimentary arithmetic looks like: 

\begin{verbatim}
 <AE> ::= Num <int> 
        | Add <AE> <AE> 
        | Sub <AE> <AE> 
\end{verbatim} 

The \texttt{<AE>} in the \textsc{BNF} is calleed a non-terminal, 
which means we can rewrite it as one of the things on 
the right-hand side. Read \texttt{::=} as ``can be rewritten as''. 
Each line presents one more choice, called a 
\emph{production}. Everything in a production that isn't enclosed 
in the symbos \texttt{< \ldots >} is literal syntax. In Haskell, 
as well as in other programming languages, it is quite easy to 
represent an abstract representation for arithmetic expressions 
based on a \textsc{BNF} specification. Abstract representations 
are independent of our choices to concretely represent arithmetic 
expressions (or other more advanced programming 
language constructs) as strings of characters. For instance, we might 
express an expression 3 + (10 - 5) in many different ways, for instance: 

\begin{verbatim}
+ 3 (- 10 5)
+ (3, -(10, 5))
add(3, sub(10, 5))
\end{verbatim}

All these forms of expressing the same arithmetic expression 
could be \emph{parsed} to generate the same abstract 
syntax tree (a possible alternative is shown in Figure~\ref{ast:ae}). That is, 
after choosing an interesting concrete syntax for a language, 
a parser reads a program written according to the concrete 
syntax and ouputs an instance of an abstract syntax tree (AST). We will 
not give to much attention to concrete syntaxes and parsers in this 
book. Here, we are mostly intereted in the semantics of a programming 
language (in this case, expressed in terms of the \texttt{calc} 
function). We also have to define a \emph{data type} for representing the 
\texttt{AE} AST using Haskell (see Listing~\ref{}). Note 
how similar with the \textsc{BNF} such a data representation 
is (\texttt{Integer} is a primitive data type in Haskell). In this particular 
case, we define a new data type (named \texttt{AE}) with three data constructors: 
\texttt{Num}, \texttt{Add} and \texttt{Sub}. The first constructor expects an 
Integer as argument, while the other two constructors expect two sub-expressions 
of type \texttt{AE}. Let's ignore some details about the \texttt{deriving} directive 
right now, though it explains to the Haskell compiler / interpreter to automatically 
implement support for reading an \texttt{AE} from a string, to show an instance of 
an \texttt{AE} as a string, and to infer the semantics of the \texttt{==} operator 
for the \texttt{AE} data type.

\begin{code}
data AE = Num Integer 
        | Add AE AE
        | Sub AE AE
 deriving(Read, Show, Eq)
\end{code}

The \texttt{calc} function we previously specified must be defined to each 
\texttt{AE} construct (or \emph{term}, in some references). Note that this 
is an indutive definition on the constructs of \texttt{AE}. The first definition 
is the base case, and states that \texttt{calc} for a given \texttt{Num n} 
is \texttt{n}. In the other situations, we have to first evaluate 
both \texttt{lhs} (left-hand side) and \texttt{rhs} (right-hand side) before 
calculating the corresponding addition or subtraction. 


\begin{code}
calc (Num n) = n
calc (Add lhs rhs) = calc lhs + calc rhs
calc (Sub lhs rhs) = calc lhs - calc rhs

parse :: String -> AE
parse s = read s 
\end{code}

Running the test suite helps validate our interpreter (the \texttt{calc} function). 
For instance, if you open the GHCi on the terminal, you can open this module and 
run the test suites, executing in the prompt \texttt{runTestTT tc1} and \texttt{runTestTT tc2}. 
The results must be as follows. 

\begin{mdframed}[style=default]
\noindent \eval{runTestTT tc1} 

\noindent \eval{runTestTT tc2} 
\end{mdframed} 

What we have seen is actually quite remarkable, though its full power may not yet 
be apparent. We have shown that a programming language with just the ability to 
represent structured data can represent one of the most interesting forms of 
data, namely programs themselves. That is, we have just written a program that consumes 
programs (in the \texttt{AE} language); perhaps we can even write programs that 
generate programs. The former is the foundation for an interpreter semantics, while the later 
is the foundation for a compiler. This same idea---but with a much more primitive 
language, namely arithmetic, and a much poorer collection of data, namely 
just numbers---is at the heart of the proof of G\"{o}del's Theorem.  

\input{c2/ae-ast.tex}

