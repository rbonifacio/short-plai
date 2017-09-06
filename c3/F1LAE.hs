module F1LAE where 

import Prelude hiding (lookup) 
import Test.HUnit 

type Var  = String 
type Name = String
type FArg = String

data Exp = Num Integer
           | Add Exp Exp
           | Sub Exp Exp 
           | Let Var Exp Exp
           | Ref Var
           | App Name Exp
 deriving(Read, Show, Eq)

data FunDec = FunDec Name FArg Exp 
 deriving(Read, Show, Eq) 

-- define the operational semantics of our language

interp :: Exp -> [FunDec] -> Integer 
interp (Num n) _           = n
interp (Add lhs rhs) decs  = interp lhs decs + interp rhs decs
interp (Sub lhs rhs) decs  = interp lhs decs - interp rhs decs

interp (Let x e1 e2) decs  =
  let sub = subst x e1 e2 decs 
  in interp sub decs

interp (App n e) decs =
  let f = lookup n decs
  in case f of
      (Nothing) -> error "Function not declared"
      (Just (FunDec m a b)) -> interp (subst a e b decs) decs  

subst :: Var -> Exp -> Exp -> [FunDec]-> Exp
subst _ _ (Num n) _ = Num n
subst x v (Add lhs rhs) ds = Add (subst x v lhs ds) (subst x v rhs ds)
subst x v (Sub lhs rhs) ds = Sub (subst x v lhs ds) (subst x v rhs ds)
subst x v (Let i e1 e2) ds
  | x == i = (Let i (subst x v e1 ds) e2)
  | otherwise = (Let i (subst x v e1 ds) (subst x v e2 ds))
subst x v (Ref i) ds
  | x == i = v
  | otherwise = Ref i

subst x v (App n a) decs = App n (subst x v a decs)
            
lookup :: Name -> [FunDec] -> Maybe FunDec
lookup _ [] = Nothing 
lookup f (fun@(FunDec n a b):fs)
  | f == n = Just fun
  | otherwise = lookup f fs 


-- samples.. 
double :: FunDec 
double = FunDec "double" "x" (Add (Ref "x") (Ref "x"))

