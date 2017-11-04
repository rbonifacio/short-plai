\documentclass{book}

%include polycode.fmt 
%options ghci -fglasgow-exts

\usepackage{xspace}
\usepackage{tikz}
\usepackage{pgfplots}
\usepackage{exercise}
\usepackage{bussproofs}
\usepackage{syntax}

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

\usepackage{amssymb,amsmath}

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

\newcommand{\bnf}{\texttt{BNF}}
\newcommand{\lae}{\textsc{LAE}\xspace}
\renewcommand{\ae}{\textsc{AE}\xspace}
\renewcommand{\emph}[1]{{\color{blue}\textit{#1}}}

\input{definition.tex}

\title{A Short Introduction to Programming 
Languages: Application and Interpretation} 

\author{Rodrigo Bonif\'{a}cio, Luisa Fantin, Gabriel Lob\~{a}o, and Jo\~{a}o Sousa}

\begin{document}

\maketitle


%include preface.lhs
%include c2/c2.lhs
%include c3/c3.lhs 
%include ctypes/ctypes.lhs

\end{document}
