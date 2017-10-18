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
        | "(" Id "->" Exp ")" Exp        -- Aplicacao de lambda 
        | "(" Id "->" Exp ")"            -- Abstracao sem a aplicacao
        | Id(Exp)                        -- aplicacao de funcao nomeada 
        | Id Exp                         -- aplicacao de lambda
        | Id 
-} 

-- * Parsers for expressions

-- | The top level parser. It consumes a string and
-- then returns an Expression (Exp) . 
expression :: Parser Exp
expression  =  numExp 
           <|> addExp
           <|> letExp
           <|> lambdaExp 

-- | Parser for a number. 
numExp :: Parser Exp 
numExp = (number >>= \v -> return (Num v))

-- | Parser for the add expression "add(e1, e2)" 
addExp :: Parser Exp
addExp = string "add(" >>= \_  -> spaces
                       >>= \_  -> expression 
                       >>= \e1 -> spaces
                       >>= \_  -> char ','
                       >>= \_  -> spaces
                       >>= \_  -> expression
                       >>= \e2 -> char ')'
                       >>= \_  -> return (Add e1 e2)

-- | Parser for let expressions "let x = 10 in x + x"                                
letExp :: Parser Exp
letExp = string "let" >>= \_  -> spaces
                      >>= \_  -> identifier
                      >>= \x  -> spaces
                      >>= \_  -> char '='
                      >>= \_  -> spaces 
                      >>= \_  -> expression
                      >>= \e1 -> spaces
                      >>= \_  -> string "in"
                      >>= \_  -> spaces
                      >>= \_  -> expression
                      >>= \e2 -> return (Let x e1 e2)           

lambdaExp :: Parser Exp
lambdaExp = char '(' >>= \_ -> spaces
                     >>= \_ -> identifier
                     >>= \x -> spaces
                     >>= \_ -> string "->"
                     >>= \_ -> spaces
                     >>= \_ -> expression
                     >>= \e -> spaces
                     >>= \_ -> char ')'
                     >>= \_ -> return (Lambda x e)
                               
-- * Other auxiliarly parsers

-- | Consumes many spaces and returns "void" () 
spaces :: Parser () 
spaces = many (char ' ') >>= \_ -> return ()

-- | A parser for identifiers. It might be also interesting for other languages. 
identifier :: Parser String
identifier = letter >>= \c  -> many ((letter <|> digit) <|> char '_') >>= \cs -> return (c:cs)

