module Main (main) where

import Lib ( firstPositive )

main :: IO ()
main = do
  let result = firstPositive [0, -1, 7]
  print result
