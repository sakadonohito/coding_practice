module Main (main) where

import Lib ( countIf )

main :: IO ()
main = do
  let counter = countIf (>0) [-1,0,1]
  print counter
