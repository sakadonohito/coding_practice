module Main (main) where

import Lib ( anyPositive )

main :: IO ()
main = do
  let isPositive = anyPositive [-1,0,1]
  print isPositive
