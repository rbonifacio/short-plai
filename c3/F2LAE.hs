module F2LAE where

import Prelude hiding (lookup)

type Id = String
type Var  = String
type Name = String
type FArg = String


data FunDec = FunDec Id FArg Exp

data Exp = Num Integer
          | Add Exp Exp
          | Sub Exp Exp
          | Let Id Exp Exp
          | Ref Id
          | App Id Exp
          | Lambda Id Exp
          | AppLambda Exp Exp
  deriving(Show)

--instance Eq Exp where
  --(==) e1 e2 = interp e1 == interp e2
interp :: Exp -> [FunDec] -> Exp
interp (Num n) _              = Num n
interp (Add l r) decs         = binOperation (+) l r decs
interp (Sub l r) decs         = binOperation (-) l r decs
interp (Let x e1 e2) decs  =
  let sub = subst x e1 e2 decs
  in interp sub decs
interp (Ref v) _ = error "we are not expecting free variables here"
interp (Lambda v b) decs      = Lambda v b
interp (AppLambda e1 e2) decs = interp sub decs
 where
   (Lambda x e) = interp e1 decs
   sub = (subst x e2 e decs)
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

subst x v (App n a) decs    = App n (subst x v a decs)

subst x v (Lambda i e) decs
  | x == i = (Lambda i e)
  | otherwise = Lambda i (subst x v e decs)

subst x v (AppLambda e1 e2) decs = AppLambda (subst x v e1 decs) (subst x v e2 decs)

lookup :: Name -> [FunDec] -> Maybe FunDec
lookup _ [] = Nothing
lookup f (fun@(FunDec n a b):fs)
  | f == n = Just fun
  | otherwise = lookup f fs


--
binOperation :: (Integer -> Integer -> Integer) -> Exp -> Exp -> [FunDec] -> Exp
binOperation op e1 e2 decs = Num (op n1 n2)
 where
  (Num n1) = interp e1 decs
  (Num n2) = interp e2 decs



-- | samples
-- foo = FunDec "foo" "x" (Ref "y")
-- interp  (Let "y" (Num 10) (App "foo" (Num 3))) [foo]

inc = FunDec "inc" "x" (Add (Ref "x") (Num 1))
