\documentclass{book}

%include polycode.fmt 
%options ghci -fglasgow-exts

\usepackage{tikz}
\usepackage{pgfplots}
\pgfplotsset{compat=newest}
\usetikzlibrary{shapes.geometric,arrows,fit,matrix,positioning}
\tikzset
{
    treenode/.style = {circle, draw=black, align=center, minimum size=1cm},
    subtree/.style  = {isosceles triangle, draw=black, align=center, minimum height=0.5cm, minimum width=1cm, shape border rotate=90, anchor=north}
}


\newcounter{haskell}[chapter]
\newenvironment{haskell}[1][]{\refstepcounter{haskell}\par\medskip
   \noindent \textbf{Example~\thehaskell. #1} \rmfamily}{
\begin{code}
\end{code}
}


\usepackage{mdframed}
\usepackage{hyperref}

\global\mdfdefinestyle{default}{%
  linecolor=black,linewidth=0.5pt,
  backgroundcolor=gray!10
}

\usepackage[
    type={CC},
    modifier={by-nc-sa},
    version={4.0},
]{doclicense}

\title{A Short (Haskell Based) Introduction to Programming 
Languages: Application and Interpretation} 

\author{Rodrigo Bonif\'{a}cio}

\begin{document}

\maketitle


%include preface.lhs
%include c2/c2.lhs

\end{document}
