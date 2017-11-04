module FCFAETests where

import FCFAE

import Test.HUnit

test1 = interp(Let "f" (Lambda "x" (Add(Ref "x")(Num 1)))(Add (Num 3)(App(Ref "f")(Num 5))))[]

test2 = interp(Let "f" (Lambda "x" (Lambda "y" (Add (Ref "x")(Ref "y"))))(Add (Num 3)(App (Ref "f")(Num 5))))[]

test3 = interp(Lambda "f" (Add (Num 3)(App(Ref "f")(Num 5))))[]

test4 = interp(Add (Num 3) (Lambda "x" (Ref "x")))[]