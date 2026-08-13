module Lib
  ( Rule (..),
    NormalizedRule (..),
    RuleError (..),
    normalizeRule,
  )
where

data Rule
  = Fact String
  | All [Rule]
  | Any [Rule]
  | Not Rule
  deriving (Eq, Show)

data NormalizedRule
  = PositiveFact String
  | NegativeFact String
  | AllOf [NormalizedRule]
  | AnyOf [NormalizedRule]
  deriving (Eq, Show)

data RuleError
  = FactNameMustNotBeEmpty
  deriving (Eq, Show)

normalizeRule :: Rule -> Either RuleError NormalizedRule
normalizeRule rule = go False rule
  where
    go :: Bool -> Rule -> Either RuleError NormalizedRule
    go isNegated (Fact str) = evalFact isNegated str
    go False (All rules) = case mapRules False rules of
      Left err -> Left err
      Right norms -> Right (AllOf norms)
    go True (All rules) = case mapRules True rules of
      Left err -> Left err
      Right norms -> Right (AnyOf norms)
    go False (Any rules) = case mapRules False rules of
      Left err -> Left err
      Right norms -> Right (AnyOf norms)
    go True (Any rules) = case mapRules True rules of
      Left err -> Left err
      Right norms -> Right (AllOf norms)
    go isNegated (Not r) = go (not isNegated) r

    evalFact isNegated str
      | str == "" = Left FactNameMustNotBeEmpty
      | isNegated = Right (NegativeFact str)
      | otherwise = Right (PositiveFact str)

    mapRules :: Bool -> [Rule] -> Either RuleError [NormalizedRule]
    mapRules _ [] = Right []
    mapRules isNegated (x : xs) =
      case go isNegated x of
        Left err -> Left err
        Right norm ->
          case mapRules isNegated xs of
            Left err -> Left err
            Right norms -> Right (norm : norms)
