{-|

 Module      : ParserLib
 Description : Another combinator library for Haskell
 Copyright   : (c) Rodrigo Bonifacio, 2017 (though based on G. Hutton, P. Wadler, and many other haskellers)
 License     : GPL-3
 Maintainer  : rbonifacio@unb.br
 Stability   : experimental
 Portability : POSIX

 This is just another combinator library for Haskell. We used many references for
 building it:

   (a) Programming in Haskell (G. Hutton)
   (b) Thinking Functionally with Haskell (R. Bird)
   (c) Monads for Functional Programming (P. Wadler).
   (d) and many others

 We follow a kind of layered architecture, where fundamental parsers
 are used to implement more complex parsers. 
-}

module ParserLib where

import Prelude hiding (return, (>>=))
import Data.Char

type Parser a = String -> [(a, String)]

-- * Parsers within a first layer (the most fundamental parsers). 

-- | A parser that allways fail. 
failure :: Parser a 
failure = \s -> [] 

-- | A parser that receives a value as input (v),
-- does not consume the input string (s), and then returns
-- [(v,s)]. It allways succeed without consuming the input string. 
return :: a -> Parser a
return v = \s -> [(v, s)]

-- | A parser that recognizes the first character of a non-null
-- string. It only fails when the input string is null. 
item :: Parser Char
item = \s -> case s of
              [] -> []
              (c:cs) -> [(c, cs)]

-- * Parsers within a second layer

-- | An operator for sequencing parsers. It receives
-- a parser (m :: Parser a) and a function (f :: a -> Parser b) that maps an "a" into a "Parser b",
-- and then returns a Parser b. If the first parse fails, the whole computation also fails.
-- Otherwise, we apply "f a cs", where "[(a, cs)]" is the result of (m s). 
(>>=) :: Parser a -> (a -> Parser b) -> Parser b
m >>= f = \s -> case m s of
                 [] -> []
                 [(a, cs)] -> f a cs


-- | A parser for representing alternatives between two parsers (p and q).
-- If p s succeeds with value res != [], then it returns res. Otherwise,
-- if p s == [], then it returns q s.  
alt :: Parser a -> Parser a -> Parser a
alt p q = \s -> let res = p s in
                case res of
                  [] -> q s
                  otherwise -> res

-- * Parsers within a third layer
                  
-- | A conditional parser. It receives a parser p :: Parser a and a
-- predicate pred :: a -> Bool. This parser might fail in two cases:
-- (a) the parser fails
-- (b) the predicate fails 
conditional :: Parser a -> (a -> Bool) -> Parser a
conditional p pred = p >>= \a -> if (pred a) then return a
  else failure

-- | Applies a parser (p :: Parser a) zero or more times, until it fails;
-- returning a Parser [a]. 
many :: Parser a -> Parser [a]
many p = (p >>= \v -> many p >>= \vs -> return (v : vs)) `alt` return [] 


-- | Applies a parser (p :: Parser a) one or more times, until it fails;
-- returning a Parser [a]. 
many1 :: Parser a -> Parser [a] 
many1 p = p >>= \v -> many p >>= \vs -> return (v : vs)

-- * Parsers within a fourth layer (more user specific, though not language specific yet). 

-- | Parser that recognizes a specific letter. 
char :: Char -> Parser Char
char c = conditional item (== c)

-- | Parser that recognizes a digit 
digit :: Parser Char
digit = conditional item isDigit

-- | Parser that recognizes a specific string 
string :: String -> Parser String
string [] = return ""
string (c:cs) = char c >>= \_ -> string cs >>= \_ -> return (c:cs)

-- | Parser for numbers. We might simplify this parser with a
-- many1 parser. Note, it uses a built in function read that translates
-- a string into an integer. 
number :: Parser Integer
number = many digit >>= \n -> if n == [] then failure else return (read n) 

