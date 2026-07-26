module Main (main) where

import Lib
  ( Person (..),
    ImportError (..),
    ImportResult,
    ImportSummary (..),
    addImportResult,
    summarizeImports,
  )

main :: IO ()
main = do
  -- テスト用データの作成（成功2件、エラー2件）
  let sampleResults :: [ImportResult]
      sampleResults =
        [ Right (Person {personName = "Alice", personAge = 30}),
          Left EmptyName,
          Right (Person {personName = "Bob", personAge = 25}),
          Left (InvalidAge (-5))
        ]
  -- summarizeImports の実行
  let summary = summarizeImports sampleResults
  -- 結果の表示
  print summary
