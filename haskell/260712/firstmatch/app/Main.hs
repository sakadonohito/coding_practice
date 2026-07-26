module Main (main) where

import Lib ( firstMatch )

main :: IO ()
main = do
  let matched = firstMatch (< 10) [12, 15, 8, 0]
  print matched
