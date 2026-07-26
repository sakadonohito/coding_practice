module Main (main) where

import Lib ( findAndTransformWithIndex )

main :: IO ()
main = do
  let result = findAndTransformWithIndex even (* 10) [1, 3, 4, 6]
  -- == (Just (4, 2), [1, 3, 40, 6])
  print result

{-
index 0, 
(Nothing, [1 : func])
->
(Nothing, [1 : 3 : func])
->
(Just (4, 2), [1 : 3 : 40 : func])
->
(Nothing, [1 : 3 : 40 : 6 : []]
-}
