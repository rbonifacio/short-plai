module F6LAE where

import Prelude hiding (lookup)

-- | Several type synonymous to improve readability
type Name = String
type FormalArg = String
type Id = String

-- | A representation of the types of our language
data Type = TInt | TBool | TFunc Type Type | TError
 deriving(Show, Eq)

-- | A type for representing function declaration
data FunDec = FunDec Name FormalArg Exp
     deriving(Show, Eq)

-- | The abstract syntax of F6LAE
data Exp = Num Integer
         | Bool Bool
         | Add Exp Exp
         | Sub Exp Exp
         | Div Exp Exp
         | And Exp Exp | Or Exp Exp | Not Exp
         | Let Id Exp Exp
         | Ref Id
         | App Name Exp
         | Lambda (FormalArg, Type) Exp
         | LambdaApp Exp Exp
         | IF0 Exp Exp Exp
     deriving(Show, Eq)

-- | The environment with the list of deferred substitutions.
type DefrdSub = [(Id, Value)]

-- | The value data type.
--
-- In this language (F6LAE), an expression
-- is reduced to a value: either a number or
-- a closure. A closure is a lambda expression
-- that *closes* together its definition with the
-- pending substitutions at definition time.
--
data Value = NumValue Integer
           | BoolValue Bool
           | Closure (FormalArg, Type) Exp DefrdSub
           | ExpV Exp DefrdSub
     deriving(Show, Eq)

-- | The interpreter function \0/
interp :: Exp -> DefrdSub -> [FunDec] -> Value

-- the simple interpreter for numbers.
interp (Num n) ds decs = NumValue n

-- the interpreter for an add expression.
interp (Add e1 e2) ds decs = NumValue (v1 + v2)
  where
    NumValue v1 = strict (interp e1 ds decs) decs
    NumValue v2 = strict (interp e2 ds decs) decs

-- the interpreter for a sub expression.
interp (Sub e1 e2) ds decs = NumValue (v1 - v2)
  where
    NumValue v1 = strict (interp e1 ds decs) decs
    NumValue v2 = strict (interp e2 ds decs) decs

interp (Div e1 e2) ds decs = NumValue (v1 `div` v2)
 where
   NumValue v1 = strict (interp e1 ds decs) decs
   NumValue v2 = strict (interp e2 ds decs) decs

-- the interpreter for a let expression.
-- note here that, to improve reuse, we actually
-- convert a let exprssion in the equivalent
-- lambda application (ela), and then interpret it.
interp (Let v e1 e2) ds decs = undefined

-- the interpreter for a reference to a variable.
-- here, we make a lookup for the reference, in the
-- list of deferred substitutions.
interp (Ref v) ds decs =
  let res = lookup v fst ds
  in case res of
    (Nothing) -> error $ "variable " ++ v ++ " not found"
    (Just (_, value)) -> value

-- the interpreter for a function application.
-- here, we first make a lookup for the function declaration,
-- evaluates the actual argument (leading to the parameter pmt),
-- and then we interpret the function body in a new "local" environment
-- (env).
interp (App n e) ds decs =
  let res = lookup n (\(FunDec n _ _) -> n) decs
  in case res of
    (Nothing) -> error $ "funtion " ++ n ++ " not found"
    (Just (FunDec _ farg body)) -> interp body env decs
     where
       expV = ExpV e ds
       env = [(farg, expV)]

-- the interpreter for a lambda abstraction.
-- that is the most interesting case (IMO). it
-- just returns a closure!
interp (Lambda (farg, t) body) ds decs = Closure (farg, t) body ds

-- the interpreter for a lambda application.
-- please, infer what is going on here in this
-- case
interp (LambdaApp e1 e2) ds decs = interp body env decs
  where
    Closure (farg, t) body ds0 = strict (interp e1 ds decs) decs
    expV = ExpV e2 ds
    env  = (farg,expV):ds0

strict :: Value -> [FunDec] -> Value
strict n@(NumValue v) _ = n
strict c@(Closure farg body ds) _ = c
strict (ExpV e1 ds) decs = strict (interp e1 ds decs) decs

-- a new lookup function.
lookup :: Id -> (a -> String) -> [a] -> Maybe a
lookup _ f [] = Nothing
lookup v f (x:xs)
 | v == f x = Just x
 | otherwise = lookup v f xs
