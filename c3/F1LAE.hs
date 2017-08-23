module F1LAE where 

import Test.HUnit 

type Id = String 

data F1LAE = Num Integer
           | Add F1LAE F1LAE
           | Sub F1LAE F1LAE 
           | Let Id F1LAE F1LAE
           | Ref Id
           | App Id F1LAE
 deriving(Read, Show, Eq)

data FunDec = FunDec Id Id F1LAE 
 deriving(Read, Show, Eq) 

double :: FunDec 
double = FunDec "double" "x" (Add (Ref "x") (Ref "x"))

interp :: F1LAE -> [FunDec] -> Integer 
interp (Num n) decs        = n
interp (Add lhs rhs) decs  = interp lhs decs + interp rhs decs
interp (Sub lhs rhs) decs  = interp lhs decs - interp rhs decs
interp (Let x e1 e2) decs  =
  let sub = subst x e1 e2
  in interp sub decs

-- note, it should be subst ::  Id -> F1LAE -> F1LAE -> [FunDec] -> F1LAE
subst :: Id -> F1LAE -> F1LAE  -> F1LAE
subst _ _ (Num n) = Num n
subst x v (Add lhs rhs) = Add (subst x v lhs) (subst x v rhs)
subst x v (Sub lhs rhs) = Sub (subst x v lhs) (subst x v rhs)
subst x v (Let i e1 e2) 
  | x == i = (Let i (subst x v e1) e2)
  | otherwise = (Let i (subst x v e1) (subst x v e2))
subst x v (Ref i)
  | x == i = v
  | otherwise = Ref i
