module Lib
  ( Rule (..),
    RuleError (..),
    evaluateRule,
  )
where

data Rule
  = Fact String
  | All [Rule]
  | Any [Rule]
  | Not Rule
  deriving (Eq, Show)

data RuleError
  = UnknownFact String
  deriving (Eq, Show)

evaluateRule ::
  (String -> Maybe Bool) ->
  Rule ->
  Either RuleError Bool
evaluateRule lookupFunc (Fact name) =
  case lookupFunc name of
    Just val -> Right val
    Nothing -> Left (UnknownFact name)
evaluateRule lookupFunc (Not innerRule) =
  case evaluateRule lookupFunc innerRule of
    Right True -> Right False
    Right False -> Right True
    Left err -> Left err
evaluateRule _ (All []) = Right True
evaluateRule lookupFunc (All (x : xs)) =
  case evaluateRule lookupFunc x of
    Right True -> evaluateRule lookupFunc (All xs)
    Left err -> Left err
    Right False -> Right False
evaluateRule _ (Any []) = Right False
evaluateRule lookupFunc (Any (x : xs)) =
  case evaluateRule lookupFunc x of
    Left err -> Left err
    Right True -> Right True
    Right False -> evaluateRule lookupFunc (Any xs)
