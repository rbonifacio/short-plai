module F3LAEParser where

import Prelude hiding (return, (>>=), (<*>))  
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

-- * Parsers for expressions

-- | The top level parser. It consumes a string and
-- then returns an Expression. 
expression :: Parser Exp
expression  =  numExp 
           <|> addExp
           <|> letExp 

-- | Parser for a number. 
numExp :: Parser Exp 
numExp = (number >>= \v -> return (Num v))

-- | Parser for the add expression "add(e1, e2)" 
addExp :: Parser Exp
addExp = string "add(" >>= \_  -> expression 
                       >>= \e1 -> char ',' 
                       >>= \_  -> expression
                       >>= \e2 -> char ')'
                       >>= \_  -> return (Add e1 e2)

-- | Parser for let expressions "let x = 10 in x + x"                                
letExp :: Parser Exp
letExp = string "let" >>= \_  -> many1 (char ' ')
                      >>= \_  -> identifier
                      >>= \x  -> many1 (char ' ')
                      >>= \_  -> char '='
                      >>= \_  -> many1 (char ' ')            
                      >>= \_  -> expression
                      >>= \e1 -> many1 (char ' ')
                      >>= \_  -> string "in"
                      >>= \_  -> many1 (char ' ')
                      >>= \_  -> expression
                      >>= \e2 -> return (Let x e1 e2)           

identifier :: Parser String
identifier = letter >>= \c  -> many ((letter <|> digit) <|> char '_') >>= \cs -> return (c:cs)
