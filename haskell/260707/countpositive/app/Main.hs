module Main (main) where

import Lib ( countPositive )

main :: IO ()
main = do
  let counted = countPositive [3, -2, 8, 0, 1, -4]
  print counted
