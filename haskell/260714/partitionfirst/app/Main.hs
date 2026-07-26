module Main (main) where

import Lib ( partitionFirst )

main :: IO ()
main = do
  let tuppled = partitionFirst even [1,2,3,4]
  print tuppled
