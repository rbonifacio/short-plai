\section{Substitution} 


Even in a simple arithmetic language, we 
sometimes encounter repeated expressions. 
For instance, the Newtonian formula for the 
gravitational force between two objects has a
squared term in the denominator. We would 
like to avoid redundant expressions: they are 
annoying to repeat, we might make a mistake 
while repeating them, and evaluating them 
wastes computational cycles. 

The normal way to avoid redundancy is to introduce 
an identifier.\footnote{As the authors of Concrete Mathematics 
say: ``Name and conquer''.} As its name suggests, 
an identifier names, or identifies, ({\bf the value of}) 
an expression.  We can then use its name in place of 
the larger computation. Identifiers may sound exotic, 
but you are use to them in every programming language 
you have used so far: they are called \emph{variables}. 
We choose not to call them that because the term
``variable'' is semantically 
charged: it implies that the value associated with the identifier 
can change (\emph{vary}). Since our language initially 
won't offer any way of changing the associated value, 
we use the more conservative term ``identifier''. 
For now, they are therefore just names for computed constants. 

Let's first write a few sample programs that use identifiers, 
inventing notation as we go along: 

\begin{verbatim}
 Let x = 5 + 5 in x + x
\end{verbatim}

We want this to evaluate to 20. Here is more elaborate example: 

\begin{verbatim}
 Let x = 5 + 5 
  in Let y = x - 3 
   in y + y 

= Let x = 10 in Let y = x - 3 in y + y    [+ operation]
= Let y = 10 - 3 in y + y                 [substitution] 
= Let y = 7 in y + y                      [- operation] 
= 7 + 7                                   [substitution] 
= 14                                      [+ operation] 
\end{verbatim}

En passant, notice that the act of reducing an expression to 
a value requires more than just substitution; 
indeed, it is an interleaving of substitution and calculation 
steps. Furthermore, when we have completed 
substitution we implicitly ``descend''into the inner expression to 
continue calculating. Now, let's define the language more 
formally. To honor the addition of identifiers, we will give 
our language a new name: \lae, short for 
``'Let with arithmetic expressions''. Its \textsc{BNF} is: 

\begin{verbatim}
 <LAE> ::= Int Num 
         | Add <LAE> <LAE>
         | Sub <LAE> <LAE> 
         | Let <Id> <LAE> <LAE>
         | Ref <Id>
\end{verbatim}

Notice that we have had to add two rules to the \textsc{BNF}: 
one for associating values with identifiers and 
another for actually using the identifiers. The nonterminal 
\texttt{<Id>} stands for some suitable syntax for identifiers 
(usually a sequence of alphanumeric characters). 

To write programs that process \lae terms, we need a data 
definition to represent those terms. Most 
of \lae carries over unchanged from \ae, but we must pick 
some concrete representation for identifiers. 
Fortunately, Haskell has a primitive type called String, which 
server this role admirably. Nevertheless, it 
is also interesting to introduce a new name 
to the String type, to make clear the purpose of 
identifying expressions. We choose the name \texttt{Id} 
as synonymous to the \texttt{String} data type. Therefore, 
the data definition in Haskell is

\begin{code}
module LAE where 

import Test.HUnit 

type Id = String 
type Value = Integer

data LAE = Num Integer
    | Add LAE LAE
    | Sub LAE LAE 
    | Let Id LAE LAE
    | Ref Id
 deriving(Read, Show, Eq)
\end{code} 

The \texttt{Let} data constructor expects 
three arguments: the name of the identifier, 
the named expression associated to the identifier, 
and the \texttt{Let} expression body. The \texttt{Ref} 
data constructor expects only one argument: the name 
of the identifier. 

\subsection{Defining Substitution}

Without ceremony, we use the concept of 
\emph{substitution} to explain how the 
\texttt{Let} construct works. We are able to do 
this because substitution is not unique to 
\texttt{Let}: we have studied it for years 
in algebra courses, because that is what 
happens when we pass arguments to 
functions. For instance, let 
$f(x,y) = x^3 + y^3$. Then 

\begin{eqnarray*}
f(12,1) & = & 12^3 + 1^3 = 1728 + 1 = 1729 \\ 
f(10,9) & = & 10^3 + 9^3 = 1000 + 729 = 1729   
\end{eqnarray*} 

Nevertheless, it is a good idea to pin down 
this operation precisely. 

Let's make sure we understand what we are trying 
to define. We want a crisp description of the 
process of substitution, namely what happens when 
we replace an identifier (such as $x$ or \texttt{x}) with 
a value (such as 12 or \texttt{5}) in an expression 
(such as $x^3 + y^3$ or \texttt{x + x}). 

Recall from the sequence of reductions above that 
substitution is a part of, but not the 
same as, calculating an answer for an expression 
that has identifiers. Looking back at the 
sequence of steps in the 
evaluation example above, some of them invoke substitution 
while the rest are calculation as defined for \ae. 
For now, we are first going to pin down substitution. 
Once we have done that, we will revisit the related 
question of calculation. But it will take us a few tries 
to get substitution right! 

\begin{mydef}[Substitution]{def:substitution}
Given an expression like \texttt{Let $x$ = $exp_1$ in $exp_2$},
the components of the \texttt{Let} expression are the 
identifier \texttt{$x$}, the named expression \texttt{$exp_1$}, 
and expression body \texttt{$exp_2$}. To substitute 
the identifier \texttt{$x$} in the expression body \texttt{$exp_1$} 
with the named expression \texttt{$exp_2$}, replace all identifiers 
in the expression body that have the name \texttt{$x$} with the 
named expression (in this case \texttt{$exp_1$}). 
\end{mydef}

Beginning with the program

\texttt{Let x = 5 in x + x}

\noindent 
we will use substitution to replace the identifier 
\texttt{x} with the named expression it is bound 
to (\texttt{5}). The above definition of substitution 
certainly does the trick: after substitution, we 
get 

\texttt{Let x = 5 in 5 + 5} 

\noindent

as we would want. Likewise, it correctly substitutes 
when there are no instances of the identifier. For instance, 

\texttt{Let x = 5 in 10 + 4} 

\noindent the definition of substitution leads 
to \texttt{Let x = 5 in 10 + 4}, since there are 
no instances of x in the expression body. Now consider 

\texttt{Let x = 5 in x + Let x = 3 in 10}

\noindent 

The rules reduce this to \texttt{Let x = 5 in 5 + Let 5 = 3 in 10}. 
Huh? Our substitution rule converted a perfectly reasonable program 
(whose value is 15) into one that 
isn't even syntactically legal, i.e., it would be rejected by a parser 
because the program contains a \texttt{5} where the 
the \bnf tells us to expect an identifier. We definitely don't 
want substitution to have such an effect! It's 
obvious that the substitution algorithm is too naive. To state 
the problem with the algorithm precisely, though, we 
need to introduce a little terminology. 


\begin{mydef}[Binding Instance]{def:bindingInstance}
A binding instance of an identifier is the 
occurrence of the identifier that gives it its 
value. In \lae, the \texttt{Id} position of a 
\texttt{Let} expression is the only binding instance. 
\end{mydef}

\begin{mydef}[Scope]{def:scope}
The scope of a binding instance is the region 
of a program text in which instances of 
the identifier {\bf refer to the value} bound 
by the binding instance. 
\end{mydef}

\begin{mydef}[Bound Instance]{def:boundInstance}
An identifier is bound if it is contained within the 
scope of a binding instance of its name. 
\end{mydef}

\begin{mydef}[Free Instance]{def:freeInstance}
An identifier not contained in the scope of any 
binding instance of its name is said to be 
free. 
\end{mydef}

With this terminology in hand, we can now state 
the problem with the first definition of 
substitution more precisely: it failed to distinguish 
between bound instances (which should be substituted) 
and binding instances (which should not). This leads 
to a refined notion of substitution. 

\begin{mydef}[Substitution, take 2]{def:substitution2}
Given an expression like $Let\ x =\ exp_1\ in\ exp_2$,
the components of the \texttt{Let} expression are the 
identifier \texttt{$x$}, the named expression \texttt{$exp_1$}, 
and expression body \texttt{$exp_2$}. To substitute 
the identifier \texttt{$x$} in the expression body \texttt{$exp_1$} 
with the named expression \texttt{$exp_2$}, replace all identifiers 
in the expression body which are not binding instances and 
that have the name \texttt{$x$} with the 
named expression (in this case \texttt{$exp_1$}). 
\end{mydef}

A quick check reveals that this does not affect the 
outcome of the examples that the previous definition 
substituted correctly. In addition, this definition of 
substitution reduces 
\texttt{Let x = 5 in x + Let x = 3 in 10} to 
\texttt{Let x = 5 in 5 + Let x = 3 in 10}. 

Let's consider a closely related expression 
\texttt{Let x = 5 in x + Let x = 3 in x}. Think 
a little bit. What should the value of this 
expression? Hopefully, we can agree that the 
value of this program is 8 )the left \texttt{x} in the 
addition evaluates to \texttt{5}, the right 
\texttt{x} is given the value \texttt{3}, by the inner 
\texttt{Let}, so the sum is \texttt{8}). The refined substitution 
algorithm, however, converts this expression into 
\texttt{Let x = 5 in 5 + Let x = 3 in 5}, which, 
when evaluated, yields \texttt{10}. 

What went wrong here? Our substitution algorithm 
respected binding instances, but not their 
scope. In the sample expression, the \texttt{Let} introduces 
a new scope for the inner \texttt{x}. The scope of the 
outer \texttt{x} is \emph{shadowed} or \emph{masked} 
by the inner binding. Because substitution doesn't 
recognize this possibility, it incorrectly substitutes 
the inner \texttt{x}. 

\begin{mydef}[Substitution, take 2]{def:substitution2}
Given an expression like $Let\ x =\ exp_1\ in\ exp_2$,
the components of the \texttt{Let} expression are the 
identifier \texttt{$x$}, the named expression \texttt{$exp_1$}, 
and expression body \texttt{$exp_2$}. To substitute 
the identifier \texttt{$x$} in the expression body \texttt{$exp_2$} 
with the named expression \texttt{$exp_1$}, replace all identifiers 
in the expression body which are not binding instances and 
that have the name \texttt{$x$} with the 
named expression (in this case \texttt{$exp_1$}), unless 
the identifier is in a scope different from that 
introduced by \texttt{x}. 
\end{mydef}

While this rule avoids the faulty substitution we have 
discussed earlier, it has the following effect: 
after substitution, the expression \texttt{Let x = 5 in x + Let y = 3 in x} 
becomes \texttt{Let x = 5 in 5 + Let y = 3 in x}. The inner expression 
should result in an error, because \texttt{x} has no value. 
Once again, substitution has changed a correct program into 
an incorrect one! 

Let's understand what went wrong. Why didn't we substitute 
the inner \texttt{x}? Substitution halts at 
the \texttt{Let} because, by definition, every 
\texttt{Let} introduces a new scope, which we said 
should delimit substitution. But this 
\texttt{Let} contains an instance of \texttt{x}, which we 
very much want substituted! So which is it---substitute 
within nested scopes or not? Actually, the two examples 
above should reveal that our latest definition 
for substitution, which might have seemed sensible at first 
blush, is too draconian: it rules out substitution 
within \emph{any} nested scopes. 


\begin{mydef}[Substitution, take 2]{def:substitution2}
Given an expression like $Let\ x =\ exp_1\ in\ exp_2$,
the components of the \texttt{Let} expression are the 
identifier \texttt{$x$}, the named expression \texttt{$exp_1$}, 
and expression body \texttt{$exp_2$}. To substitute 
the identifier \texttt{$x$} in the expression body \texttt{$exp_2$} 
with the named expression \texttt{$exp_1$}, replace all identifiers 
in the expression body which are not binding instances and 
that have the name \texttt{$x$} with the 
named expression (in this case \texttt{$exp_1$}), except within 
\emph{nested scopes of} \texttt{x}. 
\end{mydef}
 
Finally, we have a version of substitution that works. A different, 
more succinct way of phrasing this definition is


\begin{mydef}[Substitution, take 5]{def:substitution2}
Given an expression like $Let\ x =\ exp_1\ in\ exp_2$,
the components of the \texttt{Let} expression are the 
identifier \texttt{$x$}, the named expression \texttt{$exp_1$}, 
and expression body \texttt{$exp_2$}. To substitute 
the identifier \texttt{$x$} in the expression body \texttt{$exp_2$} 
with the named expression \texttt{$exp_1$}, replace all 
free instances of \texttt{x} in the expression body with 
the named expression (in this case, $exp_1$).
\end{mydef}

Recall that we are still defining substitution, not 
evaluation. Substitution is just an algorithm 
defined over expressions, independent of any use in an 
evaluator. It is the calculator's job to invoke substitution 
as many times as necessary to reduce a program down to an 
answer. That is, substitution simply converts 
\texttt{Let x = 5 in x + Let y = 3 in x} into 
\texttt{Let x = 5 in 5 + Let y = 3 in 5}. Reducing this to 
an actual value is the task of the rest of the calculator. Phew! 
Just to be sure we understand this, let's express it in the form 
of a function. 

\begin{code}
-- substitutes the first argument (x) by the second argument (v) 
-- in the free occurrences of the let expression body (the third 
-- argument of the function). the resulting expression must not have 
-- any free occurrence of the first argument.  
subst :: Id -> LAE -> LAE -> LAE 
subst _ _ (Num n) = Num n
subst x v (Add lhs rhs) = Add (subst x v lhs) (subst x v rhs)
subst x v (Sub lhs rhs) = Sub (subst x v lhs) (subst x v rhs)
subst x v (Let i e1 e2) = undefined 
subst x v (Ref i) = undefined
\end{code} 
 
The \texttt{subst} function is defined in terms of 
\emph{pattern matching}. In the first case, a substitution 
of any identifier by any named expression within 
a \texttt{Num n} expression body actually returns 
the expression body. When the message body 
is an expression like \texttt{Add e1 e2} or 
\texttt{Sub e1 e2} we return either and \texttt{Add} 
or a \texttt{Sub} expression, respectively, though 
having as sub expressions recursive calls to the 
\texttt{subst} function on their respective 
sub expressions \texttt{e1} and \texttt{e2}. Based on 
the previous definitions, you should implement 
the case for \texttt{subst} on \texttt{Let} expressions. 
This is the most interesting case. Finally, 
substituting a \texttt{Ref i} expression have 
to deal with two new situations. The first, 
we are trying to substitute the identifier \texttt{x} 
by the named expression \texttt{v} within a \texttt{Ref x}. 
In this case, we just return \texttt{v}. In the second, 
we are trying to substitute within a \texttt{Ref i}, where 
\texttt{x != i}, and thus we return \texttt{Ref i}---there 
is no substitution to perform in this case. 

\subsection{Calculating with \texttt{Let}}

We have finally defined substitution, but we still 
have not specified how we will use it to reduce 
expressions to answers. To do this, we must 
modify our calculator. Specifically, we must add 
rules for our two new source language syntactic 
constructs: \texttt{Let} and \texttt{Ref}. 

\begin{itemize}
\item To evaluate \texttt{Let} expressions, we {\bf first calculate} the 
named expression and then substitutes identifier by its value 
in the body of the \texttt{Let} 
expression. 

\item How about identifiers? Well any identifier that is in the scope of 
a \texttt{Let} expression must be replaced with a value when the 
calculator encounters that identifiers binding instance. Consequently, 
the purpose statement of \emph{subst} said there would be no free 
instances of the identifier given as an argument left in the 
result. In other words, \emph{subst} replaces identifiers with 
values before the calculator ever finds them. As a result, any 
\emph{as-yet-unsubstituted} identifier must be free in the whole 
program. The calculator can't assign a value to a free identifier, 
so it halts with an error. 
\end{itemize}

Please, considering the implementation of the \texttt{calc} function 
for \ae, implement a new function (also named \texttt{calc}) for \lae. Consider 
the following test cases. 

\begin{code}
calc :: LAE -> Integer

calc = undefined

-- some HUnit test cases to better understand the calc semantics

exp1, exp2, exp3, exp4 :: String 
exp1 = "Num 5"
exp2 = "Add (Num 5) (Num 5)"
exp3 = "Let x (Add (Num 5) (Num 5)) (Add (Ref x) (Ref x))"
exp4 = "Let x (Num 5) (Let y (Ref x) (Ref y))" 
exp5 = "Let x (Num 5) (Let x (Ref x) (Ref x))"

tc01 = TestCase (assertEqual "tc01" (calc (parse exp1)) 5) 
tc02 = TestCase (assertEqual "tc02" (calc (parse exp2)) 10)
tc03 = TestCase (assertEqual "tc03" (calc (parse exp3)) 20)  
tc04 = TestCase (assertEqual "tc04" (calc (parse exp4)) 5)
tc05 = TestCase (assertEqual "tc05" (calc (parse exp5)) 5)

parse :: String -> LAE
parse = read 
\end{code}