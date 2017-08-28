module F2LAE where 

type Id = String 
type Arg = String 

data FunDec = FunDec Id Arg Exp
  
data Exp = Num Integer
          | Add Exp Exp
          | Sub Exp Exp 
          | Let Id Exp Exp
          | Ref Id
          | App Id Exp 
          | Lambda Id Exp
          | AppLambda Exp Exp 


interp :: Exp -> [FunDec] -> Exp 
interp = undefined 

