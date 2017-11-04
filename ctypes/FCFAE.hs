module FCFAE where

type Id = String

type Env = [(Id, ValueE)]

type DeferedSub = [(Id, Exp)]

data ValueE = VInt Int
            | FClosure Id Exp Env
            | EClosure Exp Env
    deriving(Show, Eq)

data Exp = Num Int
         | Add Exp Exp
         | Sub Exp Exp
         | Let Id Exp Exp
         | Ref Id
         | Lambda Id Exp
         | App Exp Exp
         | If0 Exp Exp Exp
         | Rec Id Exp Exp
    deriving(Show, Eq)

interp :: Exp -> Env -> ValueE
interp (Num n) env          = VInt n
interp (Add lhs rhs) env    = interpBinExp lhs rhs (+) env
interp (Sub lhs rhs) env    = interpBinExp lhs rhs (-) env
interp (Let v e c) env      = interp(App(Lambda v c) e) env
interp (Ref v) env          = search v env
interp (Lambda a c) env     = FClosure a c env
interp (App e1 e2) env      = 
    let
        v = strictEval (interp e1 env)
        e = EClosure e2 env
    in case v of
        (FClosure a c env1) -> interp c ((a, e): env1)
        otherwise -> error "Trying to apply a non-anonymous function."

interp (If0 v e d) env
        | interp v env == VInt 0 = interp e env
        | otherwise = interp d env

interp (Rec name e1 e2) env =
    let
        v = strictEval (interp e1 env)
        e = EClosure e2 env
        env2 = (searchApp name v env)++env
    in case v of
        (FClosure a c env1) -> interp c ((a, e):env2)
        otherwise -> error "Trying to apply a non-anonymous function."

searchApp :: Id -> ValueE -> Env -> Env
searchApp n v [] = [(n, v)]
searchApp n v ((i, e):xs)
        | n == i = []
        | otherwise = searchApp n v xs

strictEval :: ValueE -> ValueE
strictEval (EClosure e env) = strictEval(interp e env)
strictEval e = e

search :: Id -> Env -> ValueE
search v [] = error "Variable not declared."
search v ((i, e):xs)
        | v == i = strictEval e
        | otherwise = search v xs

interpBinExp :: Exp -> Exp -> (Int -> Int -> Int) -> Env -> ValueE
interpBinExp e d op env = VInt (op ve vd)
        where
            (VInt ve) = interp e env
            (VInt vd) = interp d env'
            env' = case e of
                (Ref v) -> ((v, VInt ve):env)
                otherwise -> env

--replace :: Id -> Exp -> Env
--replcace n v [] = [(n, v)]
