module F3LAEParser where

import Prelude hiding (return, (>>=))  
import F3LAE
import ParserLib
import Data.Char

{-

  Exp ::= Num
        | add(Exp, Exp)
        | sub(Exp, Exp)
        | "let" ID "=" Exp "in" Exp  
        | "\" Id "->" Exp
        | Id(Exp)
        | Exp Exp 
-} 

expression :: Parser Exp
expression = (number >>= \v -> return (Num v)) `alt` pAdd

pAdd :: Parser Exp
pAdd = string "add(" >>= \_  -> expression
                    >>= \e1 -> char ','
                    >>= \_  -> expression
                    >>= \e2 -> char ')'
                    >>= \_  -> return (Add e1 e2) 
pLet :: Parser Exp
pLet = string "let" >>= \_ -> many1 (char ' ')
                    >>= \_ -> pId
                    >>= \x -> many1
                    >>= \_ -> many1 (char ' ')
                    >>= \_ -> expression
                    >>= e1 -> return (Let x e1)           

pId :: Parser String
pId = (conditional item isLetter)
      >>= \c  -> many (((char '_') `alt` (conditional item isLetter))
                        `alt` digit)
      >>= \cs -> return (c:cs)
