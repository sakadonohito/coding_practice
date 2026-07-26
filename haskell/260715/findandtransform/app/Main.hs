module Main (main) where

import Lib ( findAndTransform )

main :: IO ()
main = do
  let tuppled = findAndTransform even (* 10) [1, 2, 4, 6]
  print tuppled
