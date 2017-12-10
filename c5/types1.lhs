\section{Introduction to Types(in Haskell)}

Differently from Scheme, Haskell is a \emph{statically typed
programming language}, which means this language does the
type checking and the variable's type is known at compile time.
This facilitates the detection of trivial bugs very early on.

In most statically typed programming languages this means 
the programmer must constantly inform the types of variables and functions.
However, Haskell is equipped with a type inference mechanism,
allowing the system itself to deduce function types.
Suppose we define a function "adds" and don't specify it's type:

\begin{verbatim}
Prelude> adds a b = a + b
\end{verbatim}

When questioned about this particular function's type, our compiler
gives us the broadest possible answer.

\begin{verbatim}
Prelude> :t adds
adds :: Num a => a -> a -> a
\end{verbatim}

It returns simply that any numeric type "a" may be applied to this 
particular function. This gives us flexibility; however, if more
specific typing is required, we must do it manually.

Let's see:

\begin{verbatim}
adds :: Int -> Int -> Int
adds a b = a + b
\end{verbatim}

Suppose we define a function in our language:

\begin{verbatim}
inc = FunDec "inc" "x" (Add(Ref "x")(Num 1))
decs = [inc]

interp(App "inc")decs
\end{verbatim}

This function will be rejected, because it's not syntactically legal - every
function must have a body. But what if, instead, we were to write:

\begin{verbatim}
inc = FunDec "inc" "x" (Add(Ref "x")(Num 1))
decs = [inc]

interp(App "inc" 'x')decs
\end{verbatim}

Our interpreter will produce an error such as:

\begin{verbatim}
<interactive>:14:18: error:
    * Couldn't match expected type `Exp' with actual type `Char'
    * In the second argument of `App', namely 'x'
      In the first argument of `interp', namely `(App "inc" 'x')'
      In the expression: interp (App "inc" 'x') decs
\end{verbatim}

The error above is an error at syntactic level, because the interpreter is
checking for the correct use of its internal representation. Suppose we
had divisions in the interpreted language, and the corresponding \textit{num/}
procedure failed to check that the denominator was non-zero; then the
interpreter's behavior would be that of Haskell's on division-by-zero.
If we had expected an error and Haskell did not flag one(or vice versa),
then the interpreter would be unfaithful to the intent of the interpreted
language.

Our compiler rejects that program. Due to Haskell being a \textit{strongly 
typed programming language} it verifies every term to match its expected
type.

Rejecting the example above is pretty trivial. Let's think more broadly.
Sometimes it does not seem much harder, for instance

\begin{verbatim}
interp(Let "f" (Lambda "x" (Add(Ref "x")(Num 1)))
            (Add (Num 3)
                (App(Ref "f")(Num 5))))[]
\end{verbatim}

is clearly legal, whereas

\begin{verbatim}
interp(Let "f" (Lambda "x" 
            (Lambda "y" (Add (Ref "x")(Ref "y"))))
                (Add (Num 3)(App (Ref "f")(Num 5))))[]
\end{verbatim}

is not. Here, simply replacing \textit{f} in the body seems to be enough. This
problem does not quite reduce to the parsing problem that we had earlier,
as a function application is necessary to determine the program's validity.
But consider this program:

\begin{verbatim}
Lambda "f" (Add (Num 3)(App(Ref "f")(Num 5)))
\end{verbatim}

Is this program valid? Clearly, it depends on whether or not \textit{f},
when applied to 5, evaluates to a number. Since this expression may be
used in many different contexts, we cannot know whether or not this is
legal without examining each application, which in turn may depend on other
substitutions, and so on. In short, it appears that we will need to run
the program just to determine whether \textit{f} is always bound to a function,
and one that can accept numbers - but running the program is precisely what
we're trying to avoid.

We now commence the study of types and type systems, which are designed 
to identify the abuse of types before executing a program. First, we need
to build an intuition for the problems that types can address, and the obstacles
that they face. Consider the following program:

\begin{verbatim}
Add(Num 3)(If0 mystery 
               Num 5
               Lambda "x" (Ref "x"))
\end{verbatim}

This program executes successfully (and evaluates to 8) if \textit{mystery} is 
bound to 0, otherwise it returns in an error. The value of \textit{mystery}
might arise from any number of sources. For instance, it may be bound
to 0 only if some mathematical statement, such as the Collatz conjecture,
is true. In fact, we don't even need to explore something quite so exotic:
our program may simply be

\begin{verbatim}
Add(Num 3)(If0 (Num y))
                Num 5
                Lambda "x" (Ref "x"))
\end{verbatim}

Unless we can read the user's mind, we have no way of knowing whether this
program will execute without error. In general, even without involving the
mystery of mathematical conjectures or the vicissitudes of users, we cannot
statically determine whether a program will halt with an error, because of
the Halting Problem.

This highlights an important moral:\\

\textit{ Type systems are always prey to the Halting Problem. Consequently,
a type system for a general-purpose language must always either over or
under-approximate: either it must reject programs that might have run
without an error, or it must accept programs that will result in an error when executed.}\\

While this is a problem in theory, what impact does this have on practice?
Quite a bit, it turns out. In languages like Java, programmers \textit{think}
they have the benefit of a type system, but in fact many common programming
patterns force programmers to employ casts instead. Casts intentionally 
subvert the type system and leave checking for execution time. This indicates
that Java's evolution is far from complete. In contrast, most of the type 
problems of Java are not manifested in a language like ML; yet, ML's type system
still holds a few (subtler) lurking problems. In short, there is still much to
do before we can consider type system design a solved problem.

\subsection{What Are Types?}

A \textit{type} is any property of a program that we can establish without
executing the program. In particular, types capture the intuition above that
we would like to predict a program's behavior without executing it. Of course,
given a general-purpose programming language, we cannot predict its behavior
without execution(think of user inputs, for instance). So any static
prediction of behavior must necessarily be an approximation of what happens.
People conventionally use the term \textit{type} to refer not just to any
approximation, but to one that is an abstraction of the set of values.

A type labels every expression in the language, recording what kind of value
evaluating that expression will yield. That is, types describe invariants that
hold for all executions of a program. They approximate this information in
that they typically record only what \textit{kind} of value the expression 
yields, not the precise value itself. For instance, types for a language we
have seen so far might include \texttt{number} and \texttt{function}. The 
operator + consumes only values of type \texttt{number}, thereby
rejecting a program of the form

\begin{verbatim}
Add (Num 3) (Lambda "x" (Ref "x"))
\end{verbatim}

To reject this program, we did not need to know precisely which function was
the second argument to +, be it \texttt{Lambda "x" (Ref "x")} or \texttt{Lambda "x" 
(Lambda "y" (Add (Ref "x")(Ref "y")))}. Since we can easily infer that \texttt{3} has
type \texttt{number} and \texttt{Lambda "x" (Ref "x")} has type \texttt{function}, we have
all the information we need to reject the program without executing it.

Note that we are careful to refer to \textit{valid} programs, but never \textit{correct}
ones. Types do not ensure the correctness of a program. They only guarantee 
that the program does not make certain kinds of errors. Many errors lie beyond 
the ambit of a type system, however, and are therefore not caught by it. Many 
type systems will not, for instance, distinguish between a program that sorts
values in ascending order from one that sorts them in descending order, yet the
difference between those two is usually critical for a program's overall correctness.

\subsection{Type System Design Forces}

Designing a type system involves finding a careful balance between two competing
forces:

\begin{enumerate}
\item Having more information makes it possible to draw richer conclusions about a
program's behavior, thereby rejecting fewer valid programs or permitting fewer 
buggy ones.

\item Acquiring more information is difficult:
\begin{itemize}
\item It may place unacceptable restrictions on the programming language.

\item It may incur greater computational expense.

\item It may force the user to annotate parts of a program. Many programmers
(sometimes unfairly) balk at writing anything beyond executable code, and may
thus view the annotations as onerous.

\item It may ultimately hit the limits of computation, an unsurpassable barrier.
(Often, designers can surpass this barrier by changing the problem slightly, though
this usually moves the task into one of the three categories above.)
\end{itemize}
\end{enumerate}

\subsection{Why Types?}

Types form a valuable first line of defense against program errors. Of course,
a poorly-designed type system can be quite frustrating: Java programming 
sometimes has this flavor. A powerful type system such as that of ML, however, 
is a pleasure to use. ML programmers, for instance, claim that programs that 
type correctly often work correctly within very few development iterations.

Types that have not been subverted (by, for instance, casts in Java) perform
several valuable roles:
\begin{itemize}
\item When type systems detect legitimate program errors, they help reduce 
the time spent debugging.

\item Type systems catch errors in code that is not executed by the programmer.
This matters because if a programmer constructs a weak test suite, many parts 
of the system may receive no testing. The system may thus fail after deployment
rather that during the testing stage. (Dually, however, passing a type checker
makes many programmers construct poorer test suites - a most undesirable and
unfortunate consequence!)

\item Types help document the program. As we discussed above, a type is an
abstraction of the values that an expression will hold. Explicit type declarations
therefore provide an approximate description of code's behavior.

\item Compilers can exploit types to make programs execute faster, consume
less space, spend less time in garbage collection, and so on.

\item While no language can eliminate arbitrarily ugly code, a type system 
imposes a baseline of order that prevents at least a few truly impenetrable
programs - or, at least, prohibits \textit{certain kinds} of terrible coding
styles.
\end{itemize}