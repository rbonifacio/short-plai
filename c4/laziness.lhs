\section{Programming with Laziness}

Verifying that Haskell uses lazy instead of eager
can be done using a simple interaction:

\begin{verbatim}
Prelude> head []
*** Exception: Prelude.head: empty list
\end{verbatim}

This tells us that attempting to ask for the first
element of the empty list will result in a run-time
exception. Therefore, if Haskell used eager evaluation,
the following expression should also result in an error:

\begin{verbatim}
Prelude> (\x -> 3) (head [])
3
\end{verbatim}

The expression $(\ x-> 3)$ uses Haskell's notation for
defining an anonymous procedure. Which in a language
that adopts the eager strategy of evaluation, such as
Scheme, would result in an error. Instead Haskell
evaluates it to 3. From this, we can posit that Haskell
does not evaluate the argument until it is used, and
therefore follows a lazy evaluation regime.

Why is laziness useful? Clearly, we rarely write a
function that entirely ignores its argument. On the
other hand, functions do frequently use different subsets
of their arguments in different circumstances, based on
some dynamic condition. Most programming languages offer
a form of \textit{short-circuited} evaluation for the
branches of conditional (based on the value of the test
expression, only one of the other branch evaluates) and
for Boolean connectives (if the first branch of a disjunction
yields true the second branch need not evaluate, and dually
for conjunction). Haskell simply asks why this capability
should not be lifted to function arguments also, and
demonstrates what we get when we do.

In particular, since Haskell treats \textit{all} function
applications lazily, this also encompasses the use of
most built-in constructors, such as the list constructor.
As a result, when confronted with a definition such as

\begin{verbatim}
ones = 1 : ones
\end{verbatim}

Haskell does not evaluate the second argument to : until
necessary. When it does evaluate it, there is a definition
avaliable for \texttt{ones:} namely, a 1 followed by ...
The result is therefore an infinite list, but only the act
of examining the list actually constructs any prefix of it.

How do we examine an infinite list? Consider a function such as this:

\begin{verbatim}
front :: Int -> [a] -> [a]
front _ [] = []
front 0 (x:xs) = []
front n (x:xs) = x : front (n-1) xs
\end{verbatim}

When used, \texttt{front} causes as many list constructions
of \texttt{ones} as necessary untill the recursion terminates---

\begin{verbatim}
F4LAE> front 5 ones
[1,1,1,1,1]
F4LAE> front 10 ones
[1,1,1,1,1,1,1,1,1,1]
\end{verbatim}

\noindent ---\textit{but no more}. Because the language does nor force
\texttt{front} to evaluate its arguments until necessary,
Haskell does not construct any more of \texttt{ones} than is
needed for \texttt{front} to determine. That is, it is the act
of pattern-matching that forces \texttt{ones} to grow, since
the pattern-matching must determine the form of the list to
determine which branch of the function to evaluate.

Obtaining the prefix of a list of ones may not seem especially
impressive, but there are many good uses for \texttt{front}.
Suppose, for instance, we have a function that generates the
eigenvalues of a matrix. Natural algorithms for this problem
generate the values in decreasing order of magnitude, and in
most applications, only the first few are meaningful. In a lazy
language, we can pretend we have an entire sequence of eigenvalues,
and use \texttt{front} to obtain just as many as the actual
application needs; this in turn causes only that many to be
computed. Indeed, any application can freely generate an infinite
list of values, safe in the knowledge that a consumer can use
operators such as \texttt{front} to inspect the prefix it cares
about.

The function \texttt{front} is so useful when programming in
Haskell that is actually built into the Prelude, under the name
\texttt{take}. Performing the same computation in an eager
language is considerably more complex, because the computation
that generates values and the one that consumes them must
explicitly coordinate with each other: in particular, the
generator must be programmed to explicitly expect requests
from the consumer. This complicates the construction of the
generator, which may already have complex domain-specific code;
worse, if the generator was not written with such a use in mind,
it is not easy to adapt it to behave accordingly.

Where else are infinite lists useful? Consider the process of
generating a table of data whose rows cycle between a fixed set
of colors. Haskell provides a function \texttt{cycle} that
consumes a list and generates the corresponding cyclic list:

\begin{verbatim}
F4LAE> take 5 (cycle ["blue", "rondo"])
["blue", "rondo", "blue", "rondo", "blue"]
\end{verbatim}

The procedure for displaying the data can consume the cyclic
list and simply extract elements from it as necessary. The
generator of the cyclic list doesn't need to know how many
rows there will be in the table; laziness ensures that the
entire infinite list does not get generated unless necessary.
In other words, programmers often find it convenient to create
cyclic data structure not so much to build a truly infinite
data structure, but rather to produce one that is large enough
for all possible consumers (none of which will ever examine
more than a finite prefix, but each of which may want a different
number of prefix elements).

Consider one more example. At the end of some stages of the
Tour de France, the top finishers receive a "time bonus", which
we can think of as a certain number of bonus points. Let us
suppose that the top three finishers receive 20-, 12-, and 8-second
bonuses, respectively, while the others receive none. Given a list
reflecting the order in which contestants completed a stage, we
would like a list of pairs each name with the number of points
that person received. That is, we would like a function
\texttt{timeBonuses} such that

\begin{verbatim}
F4LAE> timeBonuses ["Lance", "Jan", "Tyler", "Roberto", "Iban"]
[("Lance", 20), ("Jan", 12), ("Tyler", 8), ("Roberto", 0), ("Iban", 0)]
\end{verbatim}

\noindent where ("Lance", 20) is an anonymous tuple of two elements, the first
projection a string and the second a number. Note that the result is
therefore a list of two-tuples (or pairs), where the heterogeneity
of lists force each tuple to be of the same type (a string in the
projection and a number in the second).

We can write \texttt{timeBonuses} by employing the following
strategy. Observe that every position gets a fixed bonus (20, 12
and 8, followed by zero for everyone else), but we don't know how
many finishers there will be. In fact, it isn't even clear that
there will be three finishers if the organizers run a particularly
brutal stage! First lets create a list of all bonuses:

\begin{verbatim}
[20, 12, 8] ++ cycle [0]
\end{verbatim}

\noindent where ++ appends lists. We can check that this list's content
matches our intuition:

\begin{verbatim}
Prelude> take 10 ([20, 12, 8] ++ cycle [0])
[20, 12, 8, 0, 0, 0, 0, 0, 0, 0]
\end{verbatim}

Now we need a helper function that will match up the lists of
finishers with the list of scores. Let's define this function
in parts:

\begin{verbatim}
tB :: [String] -> [Int] -> [(String, Int)]
tB [] _ = []
\end{verbatim}

Clearly, if there are no more finishers, the result must also be
the empty list; we can ignore the second argument. In contrast, if
there is a finisher, we want to assign him the next avaliable time
bonus:

\begin{verbatim}
tB (f:fs) (b:bs) = (f,b) : tB fs bs
\end{verbatim}

The right-hand side of this definition says that we create an
anonymous pair out of the first elements of each list ((f,b)),
and construct a list (:) out og this pair and the natural recursion
(tB fs bs).

At this point our helper function definition is complete. A Haskell
implementation ought to complain that we haven't specified what
should happen if the second argument is empty but the first is not:

\begin{verbatim}
(26,1): Warning: Missing pattern in function bindings:
  tB (_ : _) [] = ...
\end{verbatim}

This massage says that the case where the first list is not empty
(indicated by (_ : _)) and the second one is ([]) hasn't been
covered. Since we know the second list is infinitely long, we
can ignore this warning.

Given this definition of \texttt{tB}, it is now straightforward
to define \texttt{timeBonuses}:

\begin{verbatim}
timeBonuses finishers =
  tB finishers ([20, 12, 8] ++ cycle [0])
\end{verbatim}

This definition matches the test case above. We should be sure
to test it with fewer than three finishers:

\begin{verbatim}
F4LAE> timeBonuses ["Lance", "Jan"]
[("Lance", 20), ("Jan", 12)]
\end{verbatim}

The helper function tB is so helpful, it too (in a slightly
different form) is built into the Haskell Prelude. This more
general function, which termiates the recursion when the second
list is empty, too, is called \texttt{zip}:

\begin{verbatim}
zip [] _ = []
zip _ [] = []
zip (a:as) (b:bs) = (a,b) : zip as bs
\end{verbatim}

Notice that the type of \texttt{zip} is entirely polymorphic:

\begin{verbatim}
Prelude> :type zip
zip :: [a] -> [b] -> [(a, b)]
\end{verbatim}

Its name is suggestive of its behavior: think of the two lists
as the two rows of teeth, and the function as the zipper that
pairs them.

Haskell can equally comfortably accommodate non-cyclic infinite
lists. To demonstrate this, let's first define the function
\texttt{zipOp}. It generates \texttt{zip} by consuming an operator
to apply to the pair of the first elements:

\begin{verbatim}
zipOp :: (a -> b -> c) -> [a] -> [b] -> [c]
zipOp f [] _ = []
zipOp f _ [] = []
zipOp f (a:as) (b:bs) = (f a b) : zipOp f as bs
\end{verbatim}

We can recover the \texttt{zip} operation from \texttt{zipOp} easily:

\begin{verbatim}
myZip = zipOp (\a b -> (a, b))
\end{verbatim}

But we can also pass \texttt{zipOp} other operators, such as (+):
\footnote{We have to enclose + to avoid parsing errors, since + is an
infix operator. Without the parentheses, Haskell would try to add the
value of \texttt{zipOp} to the list passed as the first argument.}

\begin{verbatim}
F4LAE> zipOp (+) [1, 1, 2, 3, 5] [1, 2, 3, 5, 8]
[2,3,5,8,13]
\end{verbatim}

In fact, \texttt{zipOp} is also built into the Haskell Prelude, under
the name \texttt{zipWith}.

In the sample interaction above, we are clearly beginning to build
up the sequence of Fibonacci numbers. But there is an infinite number
of these and, indeed, there is no reason the argument to \texttt{zipOp}
must be finite lists. Let us therefore generate the entire sequence.
The code above is suggestive: clearly the first and second arguments
are the same list (the list of all Fibonacci numbers), but the second
is the first list "shifted" by one, i.e., the tail of that list. We
might therefore try to seed the process with the initial values, then
use that seed to construct the remainder of the list:

\begin{verbatim}
seed = [1, 1]
output = zipOp (+) seed (tail seed)
\end{verbatim}

But this produces only one more Fibonacci number before running out of
input values, i.e., \texttt{output} is bound to [2]. So we have made
progress, but need to find a way to keep \texttt{seed} from exhausting
itself. It appears that we want a way to make \texttt{seed} and
\texttt{output} be the same, so that each new value computed triggers
one more computation! Indeed,

\begin{verbatim}
fibs = 1 : 1 : zipOp (+) fibs (tail fibs)
\end{verbatim}

We can test this in Haskell:

\begin{verbatim}
F4LAE> take 12 fibs
[1,1,2,3,5,8,13,21,34,55,89,144]
\end{verbatim}

Sure enough \texttt{fibs} represents the entire infinite list of
Fibonacci numbers, ready for further use.

\begin{Exercise}
Earlier, we saw the following interaction:

\begin{verbatim}
Prelude> take 10 ([20, 12, 8] ++ cycle[0])
[20, 12, 9, 0, 0, 0, 0, 0, 0, 0]
\end{verbatim}

What happens if you instead write \texttt{take 10 [20, 12, 8]
++ cycle [0]}? Does it result in a type error? If not, do you get the
expected answer? If so, is it for the right reasons? Try this by hand
before entering it into Haskell.
\end{Exercise}

\subsection{An Interpreter}

Finally, we demonstrate an interpreter for \textsc{F3LAE}. For a better
understanding it is important that you have \textsc{F3LAE} type aliases
and structures fresh in you mind, if necessary return to chapter 3 before
continuing.

We have some important type definitions:

\begin{code}
data FunDec = FunDec Name FormalArg Exp
     deriving(Show, Eq)

data Exp = Num Integer
         | Add Exp Exp
         | Sub Exp Exp
         | Let Exp Exp
         | Ref Id Exp
         | App Name Exp
         | Lambda FormalArg Exp
         | LambdaApp Exp Exp
     deriving(Show, Eq)

type DefrdSub = [(Id, Value)]

data Value = NumValue Integer
           | Closure FormalArg Exp DefrdSub
     deriving(Show, Eq)
\end{code}

The core interpreter is defined by cases:

\begin{code}
interp :: Exp -> DefrdSub -> [FunDec] -> Value
interp (Num n) ds decs = NumValue n
interp (Add e1 e2) ds decs = NumValue (v1 + v2)
  where
    NumValue v1 = interp e1 ds decs
    NumValue v2 = interp e2 ds decs
\end{code}

Note that to interpret \textsc{Let} expression we convert
its arguments into its equivalent lambda expression \texttt{ela},
only then will it be interpreted.

\begin{code}
interp (Let v e1 e2) ds decs = interp ela ds decs
  where ela = (LambdaApp (Lambda v e2) e1)
\end{code}

Since \texttt{substituition} is no longer present we use the \texttt{lookup}
function to find the referenced value in the list of deferred substituitons,
working as an environment.

\begin{code}
interp (Ref v) ds decs =
  let res = lookup v fst ds
  in case res of
    (Nothing) -> error $ "variable " ++ v ++ " not found"
    (Just(_, value)) -> value
\end{code}

When interpreting a function declaration, similar to what was done for
\textsc{Ref}. We use \texttt{lookup} to find the wanted function declaration
in our \texttt{decs} environment and evaluate its actual argument, passed in
\texttt{App}, only then we interpret the function body in a new "local"
environmet, \texttt{env}.

\begin{code}
interp (App n a) ds decs =
  let res = lookup n (\(FunDec n _ _) -> n) decs
  in case res of
    (Nothing) -> error $ "funtion " ++ n ++ " not found"
    (Just (FunDec _ farg body)) -> interp body env decs
     where
       pmt = interp a ds decs
       env = [(farg, pmt)]
\end{code}

The interpretation of a lambda abstraction is simply a closure. It cannot
be interpreted into a numeric value until a argument is applyed! Much like
$(\ x->x+1)$.

\begin{code}
interp(Lambda farg body) ds decs = Closure farg body ds
\end{code}

When wew apply an argument to a lambda abstraction it becomes a lambda
application, and can now be interpreted into a numeric value. Completing the
example above $(\ x->x+1)2$, can now be interpreted into $3$!
Following this line of thinking, observe:

\begin{code}
interp (LambdaApp e1 e2) ds decs = interp body env decs
  where
    Closure farg body ds0 = interp e1 ds decs
    pmt = interp e2 ds decs
    env = (farg, pmt):ds0
\end{code}

We interpet the first argument \texttt{e1}, as a \texttt{Closure} because,
for a the expression to be a lambda application its first argument must,
necessarily, be a lambda abstraction! With that, we acquire the function's
body which now enables us to apply the argument to it.

Here we have our helper function, \texttt{lookup}:

\begin{code}
lookup :: Id -> (a -> String) -> [a] -> Maybe a
lookup _ f [] = Nothing
lookup v f (x:xs)
  | v == f x = Just x
  | otherwise = lookup v f xs
\end{code}

This definition of \texttt{lookup} usess Haskell's pattern-matching notation
as an explicit conditional. Finally, testing these yields the expected results:

\begin{verbatim}
F3LAE> interp (Add (Num 3)(Num 5))[][]
NumValue 8
F3LAE> interp (Let "x"(Add(Num 3)(Num 5))(Add(Ref "x")(Ref "x")))[][]
NumValue 16
\end{verbatim}

\begin{Exercise}
Extend the Haskell interpreter to implement functions using Haskell functions
to represent functions in the interpreted language. Ensure that the interpreted
language evaluates under an eager, not lazy, regime.
\end{Exercise}
