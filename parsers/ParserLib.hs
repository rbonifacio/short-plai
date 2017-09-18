module ParserLib where

import Prelude hiding (return, (>>=))
import Data.Char

type Parser a = String -> [(a, String)]

-- fundamental parsers

failure :: Parser a 
failure = \s -> [] 

return :: a -> Parser a
return v = \s -> [(v, s)]

item :: Parser Char
item = \s -> case s of
              [] -> []
              (c:cs) -> [(c, cs)]

(>>=) :: Parser a -> (a -> Parser b) -> Parser b
m >>= f = \s -> case m s of
                 [] -> []
                 [(a, cs)] -> f a cs

twoItems :: Parser (Char, Char)
twoItems = item >>= \c1 ->
           item >>= \c2 -> return (c1, c2) 
                 
conditional :: Parser a -> (a -> Bool) -> Parser a
conditional p pred = p >>= \a -> if (pred a) then return a
                                                     else failure
char :: Char -> Parser Char
char c = conditional item (== c)

digit :: Parser Char
digit = conditional item isDigit

alt :: Parser a -> Parser a -> Parser a
alt p1 p2 = \s -> let res = p1 s in
                  case res of
                   [] -> p2 s
                   otherwise -> res
                   
many :: Parser a -> Parser [a]
many p = p >>= \v -> many p >>= \vs -> return (v:vs)



                                                          
  
