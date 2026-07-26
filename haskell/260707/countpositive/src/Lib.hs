module Lib ( countPositive ) where

countPositive :: [Int] -> Int
countPositive [] = 0
countPositive (x : xs)
  | x > 0 = 1 + countPositive xs
  | otherwise = countPositive xs
