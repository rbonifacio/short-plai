module F3LAE where 

import Prelude hiding (lookup)

type Name = String  
type FormalArg = String 
type Id = String 

data FunDec = FunDec Name FormalArg Exp 

data Exp = Num Integer
         | Add Exp Exp 
         | Sub Exp Exp 
         | Let Id Exp Exp
         | Ref Id 
         | App Name Exp 
         | Lambda FormalArg Exp
         | LambdaApp Exp Exp
     deriving(Show, Eq)     

type DefrdSub = [(Id, Value)] 

data Value = NumValue Integer
           | Closure FormalArg Exp DefrdSub  

interp :: Exp -> DefrdSub -> [FunDec] -> Value

interp (Num n) ds decs     = NumValue n
    
interp (Add e1 e2) ds decs = NumValue (v1 + v2) 
  where
    Num v1 = interp e1 ds decs
    Num v2 = interp e2 ds decs 

interp (Sub e1 e2) ds decs = NumValue (v1 - v2) 
  where
    Num v1 = interp e1 ds decs
    Num v2 = interp e2 ds decs 

interp (Let v e1 e2) ds decs = interp (LambdaApp (Lambda v e2) e1) ds decs

interp (Ref v) ds decs =
  let res = lookup v fst ds
  in case res of
    (Nothing)    -> error "variavel nao declarada"
    (Just (_, value)) -> value 

interp (App n a) ds decs =
  let res = lookup n (\(FunDec n _ _) -> n) decs
  in case res of
    (Nothing) -> error "variaval nao declarada"
    (Just (Fundec _ fa body)) -> interp body [(fa, interp a ds decs)] decs 

interp (Lambda a body) ds decs = Closure a body ds

interp (LambdaApp e1 e2) ds decs = interp body ds2 decs 
  where
    (Closure a body ds0) = interp e1 ds decs
    v2  = interp e2 ds decs
    ds2 = (a,v2):ds0
  
lookup :: Id -> [a] -> (a -> String) -> Maybe a
lookup v [] _ = Nothing
lookup v (x:xs) f 
 | v == f x = Just x
 | otherwise = lookup v f xs


-- let x = 10
--  in let f = \y -> x + y
--   in let x = 5
--    in f 20
 


-- let x = 10
--  in let x = 5
--   in (\y -> x + y) 20

-- Lazy = Outermost + Sharing


-- {with {f {+ 4 5}} f} => let f = 4 + 5 in f


  
