module Lib
  ( sumList,
  )
where

sumList :: [Int] -> Int
sumList [] = 0
-- sumList [x] = x
sumList (x : xs) = x + sumList xs
