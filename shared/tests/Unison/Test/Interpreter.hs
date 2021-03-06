module Unison.Test.Interpreter where

import Test.Tasty
import Test.Tasty.HUnit
import Unison.Parsers (unsafeParseTerm)
import qualified Unison.Node as Node
import qualified Unison.Note as Note
import qualified Unison.Test.Common as Common

tests :: TestTree
tests = withResource Common.node (\_ -> pure ()) $ \node ->
  let
    tests =
      [ t "1 + 1" "2"
      , t "1 + 1 + 1" "3"
      , t "(x -> x) 42" "42"
      , t "let x = 2; y = 3 in x + y" "5"
      , t "if False 0 1" "1"
      , t "if True 12 13" "12"
      , t "1 > 0" "True"
      , t "1 == 1" "True"
      , t "2 == 0" "False"
      , t "1 < 2" "True"
      , t "1 <= 1" "True"
      , t "1 >= 1" "True"
      , t "let rec fac n = if (n == 0) 1 (n * fac (n - 1)) in fac 5" "120"
      , t "let rec ping n = if (n >= 10) n (pong (n + 1)); pong n = ping (n + 1) in ping 0"
          "10"
      , t "let id x = x; g = id 42; p = id \"hi\" in g" "42"
      , t "let id : forall a . a -> a; id x = x; g = id 42; p = id \"hi\" in g" "42"
      , t "((let id x = x in id) : forall a . a -> a) 42" "42"
      ]
    t uneval eval = testCase (uneval ++ " ⟹  " ++ eval) $ do
      (node, _) <- node
      let term = unsafeParseTerm uneval
      _ <- Note.run $ Node.typeAt node term []
      [(_,_,result)] <- Note.run $ Node.evaluateTerms node [([], unsafeParseTerm uneval)]
      assertEqual "comparing results" (unsafeParseTerm eval) result
  in testGroup "Interpreter" tests

main = defaultMain tests
