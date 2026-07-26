module Main (main) where

import Lib

main :: IO ()
main = do
  let s = sumList [5,4,-2]
  print s
