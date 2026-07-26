module Main (main) where

import Lib (tryTransformFirst)

safeDivide100 :: Int -> Either String Int
safeDivide100 0 = Left "division by zero"
safeDivide100 n = Right (100 `div` n)

main :: IO ()
main = do
  let result = tryTransformFirst (> 0) safeDivide100 []
  print result
