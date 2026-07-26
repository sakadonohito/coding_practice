module Lib
  ( doubleAll,
    doubleMap,
  )
where

doubleAll :: [Int] -> [Int]
doubleAll [] = []
doubleAll (x : xs) = (x * 2) : doubleAll xs

doubleMap :: [Int] -> [Int]
-- doubleMap [] = []
doubleMap = map (* 2)
