module Main (main) where

import Lib ( allPositive )

main :: IO ()
main = do
  let isPositive = allPositive [1, 2, -3]
  print isPositive
