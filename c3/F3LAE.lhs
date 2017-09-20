\section{Implementing Functions Using Deferred Substitutions} 

Let's examine the process of interpreting the following small 
program. 

\begin{minipage}{.5\textwidth}
\begin{verbatim}
Let x = 3 
 in Let y = 4
  in Let z = 5 
   in x + y + z
\end{verbatim}
\end{minipage}%
\begin{minipage}{.5\textwidth}
\begin{eqnarray*}
& = & Let\ y = 4\ in\ Let\ z = 5\ in\ 3 + y + z\ (subst) \\ 
& = & Let\ z = 5\ in\ 3 + 4 + z\ (subst) \\
& = & 3 + 4 + 5\ (subst) \\
& = & 12\ (arithmetic)  
\end{eqnarray*}
\end{minipage}

\noindent On the right is the sequence of evaluation steps. To reduce 
it to an arithmetic problem, the interpreter had to apply substitution 
three times: once for each \texttt{Let} expression. This is slow! How slow? 
Well, if the program has size $n$ (measured in abstract syntax tree nodes), 
than each substitution \emph{traverses} the rest of the program once, making 
the complexity of this interpreterter at least $O(n^2)$. That seems rather 
wasteful, surely we can do better. 

How will avoid computational redundancy? We should create and use 
a \emph{repository of deferred substitutions}. Concretly, here 
is the idea. Initially, we have no substitutions to perform, so the 
repository is empty. Every time we encounter a substitution (in the form 
of a \texttt{Let}  or \texttt{Application}), we augment the repository 
with one more entry, recording the identifier's name and the 
value (if \emph{eager}) or expression (if \emph{lazy}) it should
eventually be substituted with. We continue to evaluate without 
actually performing the substitution. 

This strategy breaks a key invariant we had established earlier, which 
is that any identifier the interpreter encounters is of necessity 
free---in the case it had been bound, it would have been replaced 
by substitution. Because we are no longer using substitution, 
we will encounter bound identifiers during interpretation. How do 
will handle them? We must consult the repository in order to 
substitute them. Our new language \textsc{F3LAE} is quite 
similar to the previous one 

\begin{code}
module F3LAE where 

type Name = String  
type FormalArg = String 
type Id = String 

data FunDec = FunDec Name FormalArg Exp 

data Exp = Num Integer
         | Add Exp Exp 
         | Sub Exp Exp 
         | Let Id Exp Exp 
         | App Name Exp 
         | Lambda FormalArg Exp
         | LambdaApp Exp Exp
     deriving(Show, Eq)     
\end{code} 

\noindent though we have to declare a new type for representing 
our repository of deferred substitutions. 

\begin{code}
type DefrdSub = [(Id, Value)] 
\end{code} 

Several situations must be considered when implementing 
the \texttt{interp} function for \textsc{F3LAE}. For 
instance, consider the following test case

\begin{verbatim}
Let x = 3 
 in Let f = (\y . y + x) 
   in Let x = 5 
     in f 4
\end{verbatim}

\noindent Depending on the evaluation strategy and 
scope resolution, its evaluation must result either 
in 7 (static scope) or 9 (dynamic scope). In the later 
case, the value of $x$ within the function definition 
depends on the context of application of $f$, not 
on the scope of its definition.

That is, to properly defer substitution, the value of a 
function should be not only its definition, but also 
the substitutions that were due to be performed on 
it. Therefore, we must define a new datatype for the interpreter's 
return value, which attaches the definition-time repository 
to every function value. Our \texttt{Value} datatype 
is either a \emph{numeric value} or a \emph{closure}, 
a kind of function definition that comes together 
with the list of deferred substitutions that appear 
until its definition. We call this constructed 
value a \emph{closure} because it ``closes'' the 
function body of lambda expressions 
over the substitutions that are waiting to 
occur. 

\begin{code}
data Value = NumValue Integer
           | Closure FormalArg Exp DefrdSub  
\end{code} 

When the interpreter encounters a function 
application, it must ensure that the function's 
pending substitutions are not forgotten. It must 
however, ignore the substitutions pending at the 
location of the invocation, for that is 
precisely what led us to dynamic instead of 
static scope. It must instead use the substitutions 
of the invocation location to convert the function 
and argument into values, hope that the 
function expression evaluated to a closure, then 
proceed with evaluating the body of the 
function employing the repository of 
deferred substitutions stored in the closure. 

\begin{Exercise}
Implement the interpreter function for 
F3LAE, considering the following 
specification. 
\end{Exercise} 

\begin{code}
interp :: Exp -> DefrdSub -> [FunDec] -> Value
interp = undefined 
\end{code}
