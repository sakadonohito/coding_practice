module Main (main) where

import Lib ( filterPositive, filterPositiveGuard )

main :: IO ()
main = do
  let fpList = filterPositive [3, -2, 8, 0, 1]
      fpgList = filterPositiveGuard [3, -2, 8, 0, 1]
  print fpList
  print fpgList
