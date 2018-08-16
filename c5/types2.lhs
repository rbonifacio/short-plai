\section{Type Judgments}

\subsection{What They Are}
First, we must agree on a language os types. Recall that types
need to abstract over sets of values; in our current language
\texttt{TRCFAE}, we have three possible types, \texttt{TInt},
\texttt{TBool} and \texttt{TFunction}.

\begin{verbatim}
data MyType = TInt | TBool | TFunction MyType MyType
    deriving(Show, Eq)
\end{verbatim}

We present a type system as a collection of rules, known as
texttt{type judgments}, which describe how to determine the
type of an expression.\footnote{A type system for us is usually
a collection of types, the corresponding judgments that ascribe
types to expressions, and an algorithm to perform this ascription.
For many languages a simple algorithm suffices, but as languages
get more sophisticated, devising this algorithm can become quite
difficult, as we will see in the chapter about Type Inference.}
There must be at least one type rule for every kind of syntactic
construct so that, given a program, at least one type rule applies
to every sub-term. Judgments are often recursive, determining an
expression's type from the types of its parts.

The type of a \texttt{ValueI n} is \texttt{TInt}:
{\center ValueI n: \texttt{TInt}\par}

Same with booleans:
{\center ValueB b: \texttt{TBool}\par}

(read this as saying "any ValueI \textit{n} has type \texttt{TInt}") and of
any function is \texttt{TFunction T1 T2}:
{\center(Lambda(v, t1) t2 expr): TFunction t1 t2\par}

\noindent but what is the type of an identifier? Clearly, we need type
environment (a mapping from identifiers to types). It's conventional
to use $\Gamma$ (the upper-case Greek "gamma") fir the type environment.
As with the value environment, the type environment must appear on the
left of every type judgment. All type judgments will have the
following form:

{\center $\Gamma$$\vdash$e: t}
where \textit{e} is an expression and \textit{t} is a type, which
we read as "$\Gamma$ proves that \textit{e} has type \textit{t}". Thus,

{\center $\Gamma$$\vdash$ n:TInt}
{\center Lambda a b:TFunction}
{\center $\Gamma$$\vdash$\textit{i}:$\Gamma$(\textit{i})}

The last rule simply says that the type of identifier \textit{i} is
whatever type it is bound to in the environment.

This leaves only addition and application. Addition is quite easy:
\begin{prooftree}
\AxiomC{$\Gamma$$\vdash$l:TInt}
\AxiomC{$\Gamma$$\vdash$r:TInt}
\BinaryInfC{$\Gamma$$\vert$-(Add l r):TInt}
\end{prooftree}

All this leaves is the rule for application. We know ot must have roughly
the following form:
\begin{prooftree}
\AxiomC{$\Gamma$$\vdash$ \textit{f}: TFunction}
\AxiomC{$\Gamma$$\vdash$ a: $\tau_{a}$}
\BinaryInfC{$\Gamma$$\vdash$ \textit{{f a}:???}}
\end{prooftree}

\noindent where $\tau_{a}$ is the type of the expression \textit{a}
(we will often use $\tau$ to name an unknows type).

What's missing? Compare this against the semantics rule for applications.
There, the representation of a function held an environment to ensure
we implement static scoping. Do we need to do something similar here?

For now, we'll take a much simpler route. We'll demand that the programmer
\textit{annotate} each function with the type is consumes and the type it
returns. This will become part of a modified function syntax. That is, the
language becomes

\begin{verbatim}
data Exp = ...
         | Lambda (Id, MyType) MyType Exp
\end{verbatim}

\noindent where the two type annotations are now required: the one immediately after
the argument dictates what type of value the function consumes, while that
after the argument but before that body dictates what type it returns. An
example of a function definition in this language is

\begin{verbatim}
Lambda ("x", TInt) TInt (Add(Ref "x")(ValueI 1))
\end{verbatim}

We must also change our type grammar; to represent function types we
conventionally use an arrow, where the type at the tail of the arrow
represents the type of the argument and that at the arrow's head represents
the type of the function's return value:

\begin{verbatim}
data MyType = TInt
            | TBool
            | TArrow MyType MyType
\end{verbatim}

\noindent (notice that we have dropped the overly naive type \texttt{TFunction}
from our type language). Thus, the type of the function above would be
(TArrow TInt TInt). The type of the outer function below

\begin{verbatim}
Lambda ("x", TInt) (TArrow TInt TInt)
    (Lambda ("y", TInt) (TInt) (Add (Ref "x")(Ref "y")))
\end{verbatim}

\noindent is (TArrow TInt(TArrow TInt TInt)), while the inner function has type
(TArrow TInt TInt).

Equipped with these types, the problem of checking applications becomes easy:

\begin{prooftree}
\AxiomC{$\Gamma$$\vdash$ \textit{f}:($\tau_{1}$ \rightarrow $\tau_{2}$)}
\AxiomC{$\Gamma$$\vdash$ \textit{a}: $\tau_{1}$}
\BinaryInfC{$\Gamma$$\vdash$ {\textit{f a}}: $\tau_{2}$}
\end{prooftree}

That is, if you provide an argument of the type the function is expecting, it
will provide a value of the type it promises. Notice how the judicious use of
the same type name $\tau_{1}$ and $\tau_{2}$ accurately captures the sharing
we desire.

There is one final bit to the introduction type puzzle: how can we be sure the
programmer will not lie? That is, a programmer might annotate a function with
a type that is completely wrong(or even malicious). (A different way to look at
this is, having rid ourselves of the type \texttt{TFunction}, we must revisit the
typing rule for a function declaration.) Fortunately, we can guard against cheating
and mistakes quite easily: instead of blindly accepting the programmer's type
annotation, we check it:

\begin{prooftree}
\AxiomC{$\Gamma$[\textit{i}\leftarrow $\tau_{1}$]$\vdash$ \textit{b}:$\tau_{2}$]}
\UnaryInfC{$\Gamma$$\vdash$ [Lambda(\textit{i}: $\tau_{1}$): $\tau_{2}$ \textit{b}] : ($\tau_{1}$ \rightarrow $\tau_{2}$)}
\end{prooftree}

This rule says that we will believe the programmer's annotation if the body has type
$\tau_{2}$ when we extend the environment with \textit{i} bound to $\tau_{1}$.

There is an important relationship between the type judgments for function declaration
and for application:

\begin{itemize}
\item When typing the function declaration, we \textit{assume} the argument will
have the right type and \textit{guarantee} that the body, or result, will have the
function promises.

\item When typing a function application, we \textit{guarantee} the argument has
the type the function demands, and \textit{assume} the result will have the type the
function promises.
\end{itemize}

This interplay between assumptions and guarantees is quite crucial to typing functions.
The two "sides" are carefully balanced against each other to avoid fallacious reasoning
about program behavior. In addition, just as \textit{TInt} does not specify which number
will be used, a function type does not limit which of many functions will be used. If, for
instance, the type of a function is (TArrow TInt TInt), the function could be either increment
or decrement(or a lot else, besides). The type checker is able to reject misuse of any function
that has this type without needing to know which actual function the programmer will use.

By the way, it would help to understand the status of terms like \textit{i} and \textit{b} and \textit{n}
in these judgments. They are "variable" in the sense that they will be replaced by some
program term: for instance, {Lambda (\textit{i}: $\tau_{1}$):$\tau_{2}$ \textit{b}} may be
instantiated to {Lambda (\textit{x}: TInt): TInt \textit{x}}, with \textit{i} replaced by \textit{x},
and so forth. But they are not program variables; rather, they are variables that stand
for program text (including program variables). They are therefore called \textit{metavariables}.

\subsection{How Type Judgmentsa Work}

Let's see how the set of type judgments described above accepts and rejects programs.

\begin{enumerate}
\item Let's take a simple program,
\begin{verbatim}
verifyType(Add(ValueI 2)(Add(ValueI 5)(ValueI 7)))[]
\end{verbatim}
We stack type judgments for this term as follows:

\begin{prooftree}
\AxiomC{[ ]$\vdash$ 2: TInt}
\AxiomC{[ ]$\vdash$ 5: TInt}
\AxiomC{[ ]$\vdash$ 7: TInt}
\BinaryInfC{[ ]$\vdash$ (Add 5 7): TInt}
\BinaryInfC{[ ]$\vdash$ (Add 2(Add 5 7)): TInt}
\end{prooftree}

This is a \textit{type judgment tree}.\footnote{If it doesn't look like a tree to you, it's because
you've been in computer science too long and have forgotten that real trees grow upward, not downward.
Botanically, however, most of these "trees" are really shrubs.}. Each node in the tree uses one of the
type judgments to determine the type of an expression. At the leaves(the "tops") are, obviously, the
judgments that do not have an antecedent (technically knows as the axioms); in this program, we only
use the axiom that judges Ints. The other two nodes in the tree both use the judgment on addition. The
metavariables in the judgments (such as \textit{l} and \textit{r} for addition) are replaced here by
actual expressions (such as 2, 5, 7 and (Add 5 7)): we can employ a judgment only when the pattern
matches consistently. Just as we begin evaluating in the empty environment, we begin type checking in
the empty \textit{type} environment; hence we have [] in place of the generic $\Gamma$.

Observe that at the end, the result is the type \textit{TInt}, not the value 14.

\item Now let's examine a program that contains a function
\begin{verbatim}
verifyType(App(Lambda("x", TInt)TInt (Add (Ref "x")(ValueI 3)))(ValueI 5))[]
\end{verbatim}
The type judgment tree looks as follows:

\begin{prooftree}
\AxiomC{[x \leftarrow TInt]$\vdash$ x: TInt}
\AxiomC{[x \leftarrow TInt]$\vdash$ 3: TInt}
\BinaryInfC{[x \leftarrow TInt]$\vdash$(Add x 3): TInt}
\UnaryInfC{[ ]$\vdash$ Lambda (x: TInt) TInt (Add x 3): (TArrow TInt TInt)}
\AxiomC{[ ]$\vdash$ 5: TInt}
\BinaryInfC{[ ]$\vdash$ App(Lambda (x: TInt) TInt (Add x 3))5 : TInt}
\end{prooftree}

When matching the sub-tree at the top-left, where we have just $\Gamma$ in the type judgment, we have the
extended environment in the actual derivation tree. We must use the same (extended) environment consistently,
otherwise the type judgment for addition cannot be applied. The set of judgments used to assign this type
is quite different from the set of judgments we would use to evaluate the program: in particular, we type
"under the Lambda", i.e., we go into the body of the Lambda even if the function is never applied. In contrast,
we would never evaluate the body of a function unless and until the function was applied to an actual parameter.

\item Finally, let's see what the type judgments do with a program that we know to contain a type error:

\begin{verbatim}
verifyType(Add(ValueI 3)(Lambda("x", TInt) TInt (Ref "x")))
\end{verbatim}
\end{enumerate}

The type judgment tree begins as follows:

\begin{prooftree}
\AxiomC{???}
\UnaryInfC{[ ]$\vdash$(Add 3 (Lambda (x: TInt): TInt x)): ???}
\end{prooftree}

We don't yet know what type (if any) we will be able to ascribe to the program, but let's forge on: hopefully
it'll become clear soon. Since the expression is an addition, we should discharge the obligation that each
sub-expression must have a numeric type. First for the left child:

\begin{prooftree}
\AxiomC{[ ]$\vdash$ 3: TInt}
\AxiomC{???}
\BinaryInfC{[ ]$\vdash$(Add 3 (Lambda (x: TInt): TInt x)): ???}
\end{prooftree}

As per the judgments we have defined, any function expression must have an TArrow type:
\begin{prooftree}
\AxiomC{[ ]$\vdash$ 3: TInt}
\AxiomC{[ ]$\vdash$ (Lambda(x: TInt): TInt x): TArrow ??? ???}
\BinaryInfC{[ ]$\vdash$(Add 3 (Lambda (x: TInt): TInt x)): ???}
\end{prooftree}

This does the type checker no good, however, because arrow types are distinct from numeric types, so the resulting
tree above does not match the form of the addition judgment(no matter what goes in place of the two ???'s). To match
the addition the tree must have the form?

\begin{prooftree}
\AxiomC{[ ]$\vdash$ 3: TInt}
\AxiomC{[ ]$\vdash$ (Lambda(x: TInt): TInt x): TInt}
\BinaryInfC{[ ]$\vdash$(Add 3 (Lambda (x: TInt): TInt x)): ???}
\end{prooftree}

Unfortunately, we do not have any judgment that let us conclude that a syntactic function term can have a numeric type.
So this doesn't work either.

In short, we cannot construct a legal type derivation tree for the original term. Notice that this is not the same as
saying that the tree directly identifies an error: it does not. A type error occurs when we are \textit{unable to construct
a type judgment tree.}

This is subtle enough to bear repeating: To flag a program as erroneous, we must \textit{prove} that no type derivation
tree can possibly exist for that term. But perhaps some sequence of judgments that we haven't thought of exists that
(a) is legal and (b) correctly ascribe a type to the term! To avoid this we may need to employ quite a sophisticated
proof technique, even human knowledge. (In the third example above, for instance, we say, "we do not have any judgments
that let us conclude that a syntactic function term can have a numeric type". But how do we know this is true? We can only
conclude this by carefully studying the structure of the judgments. A computer program might not b e so lucky, and get
stuck endlessly trying judgments!)

This is why a set of type judgments alone does not suffice: what we're really interested in is a type system that includes
an algorithm for type-checking. For the set of judgments we've written here, and indeed for the ones we'll study initially,
a simple top-down, syntax-directed algorithm suffices for (a) determining the type of each expression, and (b) concluding that
some expressions manifest type errors. As our type judgments get more sophisticated, we will need to develop more complex
algorithms to continue producing traceable and useful type systems.
