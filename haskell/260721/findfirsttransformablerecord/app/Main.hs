module Main (main) where

import Lib
  ( TransformResult (..),
    TransformSuccess (..),
    findFirstTransformableRecord,
  )

safeDivide100 :: Int -> Either String Int
safeDivide100 0 = Left "division by zero"
safeDivide100 x
  | 100 `mod` x == 0 = Right (100 `div` x)
  | otherwise = Left "not divisible"

main :: IO ()
main = do
  let result = findFirstTransformableRecord odd safeDivide100 []
  print result
