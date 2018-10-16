module Notes where

import           Text.Parsec
import           Text.Parsec.Combinator

import           Data.Either
import           Data.Functor
import           Prelude                hiding (False, True)

import           Debug.Trace            (trace)

type Program = [Stmt]

data Stmt = Assignment Val Expr
          | If Expr Stmt Stmt
          | Twice Stmt
          | While Expr Stmt
          | Block [Stmt]
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

type P = Parsec String ()

-- Parse Common
natP        :: P Integer
natP        = do
  i <- read <$> many1 digit
  return (dbg i)

idP         :: P String
idP         = return <$> oneOf "xy"

-- Parse Val
valP        :: P Val
valP        = Nat            <$> natP  <|>
              string "false" $>  False <|>
              string "true"  $>  True  <|>
              Id             <$> idP

-- fulhack to not consume v1 twice
addP :: P Expr
addP = Add <$> valP <* char '+' <*> valP

constP :: P Expr
constP = Const <$> valP

-- fulhack to not consume v1 twice
exprP       :: P Expr
exprP       = try addP <|> try constP

endL        :: P Char
endL        = char ';'

-- Parse Statements
twiceP      :: P Stmt
twiceP      = Twice <$> (string "twice" *> stmtP <* endL)

ifP         :: P Stmt
ifP         = do
  string "if"
  e <- exprP
  string "then"
  s1 <- stmtP
  string "else"
  s2 <- stmtP

  return $ If e s1 s2

whileP      :: P Stmt
whileP      = string "while" *> (While <$> exprP <*> stmtP)

returnP     :: P Stmt
returnP     = string "return" *> (Return <$> exprP) <* endL

blockP      :: P Stmt
blockP      = char '{' *> (Block <$> many1 stmtP) <* char '}'


dbg x = trace (show x) x

assignmentP :: P Stmt
assignmentP = Assignment <$> valP <* char '=' <*> exprP <* endL

stmtP       :: P Stmt
stmtP       = choice [ ifP, twiceP, whileP, returnP, blockP, assignmentP ]

-- Parse Program
programP    :: P Program
programP    = many1 stmtP

main = do
  print node0
  programStr <- filter (\e -> not $ elem e " \n") <$> readFile "notes_test.atl"
  print programStr
  let pp = parse programP "" programStr

  case pp of
    Left err      -> print err
    Right program -> print program

  return ()
