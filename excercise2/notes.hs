module Notes where

import           Prelude hiding (False, True)

data Stmt = Assignment Val Expr
          | If Expr Stmt Stmt
          | Twice Stmt
          | While Expr Stmt
          | Return Expr
          deriving Show

type Count = Integer

data Val = Nat Integer
         | Id String
         | True
         | False
         deriving (Show, Eq)

mkNat :: Integer -> Val
mkNat n = if n < 0 then error("n < 0")
                   else Nat n

data Expr = Add Val Val
          | Const Val
          deriving Show

data Unit = MkUnit Stmt [Unit]
          deriving Show

{-

x = 10;

if true then
 twice x = x + 1;;
else {
 twice x = x + 1;;
 twice x = x + 1;;
}

return x;

-}

-- x
x = Id "x"

-- x = 10;
stmt0 = Assignment x (Const $ mkNat 1) :: Stmt
node0 = MkUnit stmt0 [node1] :: Unit

-- if true then .. else ..
stmt1 = If (Const True) stmt2 stmt3 :: Stmt
node1 = MkUnit stmt1 [node2, node3] :: Unit

-- x = x + 1;
stmtRepeat = Assignment x (Add x (mkNat 1)) :: Stmt

-- twice x = x + 1;;
stmt2 = Twice stmtRepeat :: Stmt
node2 = MkUnit stmt3 [node4] :: Unit

-- twice x = x + 1;;
-- twice x = x + 1;;
stmt3 = Twice stmtRepeat :: Stmt
node3 = MkUnit stmt3 [node5] :: Unit
node4 = MkUnit stmt3 [node5] :: Unit

-- return x;
stmt5 = Return (Const x)
node5 = MkUnit stmt5 []

{-
merge :: [in]               -> tempOut          -> out

merge :: [[(Stmt, Count)]]  -> [(Stmt, Count)]  -> [(Stmt, Count)]
merge (stmts : sstmts) finalList =
  let finalList' = map (\s, c -> if contains s finalList  then (s, min(c, getCount s finalList)) -- max = Imprecise, min = Conservative
                                                          else (s, 0) stmts                      -- 1 = Imprecise, 0 = Conservative
  in merge sstmts finalList'
merge [] finalList = finalList
-}

{-
trans :: Stmt -> [(Stmt, Count)] -> [(Stmt, Count)]
trans stmt inStmts =
  if stmt in inStmts  then add1To  stmt inStmts
                      else initTo1 stmt inStmts
-}

-- traverse path-sensitive
-- in  = node0
-- out = [[Node]] where [Node] is a path, for every path we may calculate the # of stmt executions


main = do
  print node0
