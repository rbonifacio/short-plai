\section{Substitution} 


Even in a simple arithmetic language, we 
sometimes euncounter repeated expressions. 
For instance, the Newtoninan formula for the 
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
can change (\emph{vary}). Since our language inicially 
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
our language a new name: \texttt{LAE}, short for 
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
another for acually using the identifiers. The nonterminal 
\texttt{<Id>} stands for some suitable syntax for identifiers 
(usually a sequence of alphanumeric characters). 

