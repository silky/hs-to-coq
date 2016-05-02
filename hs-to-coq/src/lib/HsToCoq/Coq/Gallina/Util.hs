{-# LANGUAGE PatternSynonyms #-}

module HsToCoq.Coq.Gallina.Util (
  pattern Var,    pattern App1,    pattern App2,    appList,
  pattern VarPat, pattern App1Pat, pattern App2Pat, appListPat,
  termHead
  ) where

import Data.List.NonEmpty (NonEmpty(..), nonEmpty)
import HsToCoq.Coq.Gallina

pattern Var  x       = Qualid (Bare x)
pattern App1 f x     = App f (PosArg x :| [])
pattern App2 f x1 x2 = App f (PosArg x1 :| PosArg x2 : [])

appList :: Term -> [Arg] -> Term
appList f = maybe f (App f) . nonEmpty

pattern VarPat  x       = QualidPat (Bare x)
pattern App1Pat f x     = ArgsPat f (x :| [])
pattern App2Pat f x1 x2 = ArgsPat f (x1 :| x2 : [])

appListPat :: Qualid -> [Pattern] -> Pattern
appListPat c = maybe (QualidPat c) (ArgsPat c) . nonEmpty

termHead :: Term -> Maybe Qualid
termHead (Forall _ t)         = termHead t
termHead (HasType t _)        = termHead t
termHead (CheckType t _)      = termHead t
termHead (ToSupportType t)    = termHead t
termHead (Parens t)           = termHead t
termHead (InScope t _)        = termHead t
termHead (App t _)            = termHead t
termHead (ExplicitApp name _) = Just name
termHead (Infix _ op _)       = Just $ Bare op
termHead (Qualid name)        = Just name
termHead _                    = Nothing