module Lib
  ( Rule (..),
    RuleError (..),
    foldRule,
    countFacts,
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

foldRule ::
  (String -> result) ->
  ([result] -> result) ->
  ([result] -> result) ->
  (result -> result) ->
  Rule ->
  result
foldRule onFact onAll onAny onNot rule =
  case rule of
    Fact str -> onFact str
    All rules -> onAll (map (foldRule onFact onAll onAny onNot) rules)
    Any rules -> onAny (map (foldRule onFact onAll onAny onNot) rules)
    Not r -> onNot (foldRule onFact onAll onAny onNot r)

countFacts :: Rule -> Int
countFacts =
  foldRule
    (const 1)
    sum
    sum
    id

evaluateRule ::
  (String -> Maybe Bool) ->
  Rule ->
  Either RuleError Bool
evaluateRule lookupFact =
  foldRule
    evaluateFact
    evaluateAll
    evaluateAny
    evaluateNot
  where
    evaluateFact name =
      case lookupFact name of
        Just value -> Right value
        Nothing -> Left (UnknownFact name)

    evaluateAll [] = Right True
    evaluateAll (Left err : _) = Left err
    evaluateAll (Right False : _) = Right False
    evaluateAll (Right True : rest) = evaluateAll rest

    evaluateAny [] = Right False
    evaluateAny (Left err : _) = Left err
    evaluateAny (Right True : _) = Right True
    evaluateAny (Right False : rest) = evaluateAny rest

    evaluateNot (Left err) = Left err
    evaluateNot (Right value) = Right (not value)
