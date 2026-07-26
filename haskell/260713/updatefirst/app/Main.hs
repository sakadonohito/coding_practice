module Main (main) where

import Lib ( updateFirst )

main :: IO ()
main = do
  let updated = updateFirst even (* 10) [12, 15, 8, 0]
  print updated
