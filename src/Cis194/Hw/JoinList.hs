{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}
import Data.Monoid

-- in ghci, you may need to specify an additional include path:
-- Prelude> :set -isrc/Cis194/Hw
import Sized
import Scrabble
import Buffer

data JoinList m a = Empty
                   | Single m a
                   | Append m (JoinList m a) (JoinList m a)
   deriving (Eq, Show)

-- ** Exercise 1
-- Write an append function for JoinLists
-- that yields a new JoinList whose monoidal annotation is derived from
-- those of the two arguments.

(+++) :: Monoid m => JoinList m a -> JoinList m a -> JoinList m a
(+++) jl1 jl2 = Append (tag jl1 `mappend` tag jl2) jl1 jl2

--  You may find it helpful to implement a helper function
--  which gets the annotation at the root of a JoinList.
tag :: Monoid m => JoinList m a -> m
tag (Single m a) = m
tag (Empty) = mempty
tag (Append m jl1 jl2) = tag jl1 `mappend` tag jl2


-- ** Exercise 2
--
-- Helper functions:
--

(!!?) :: [a] -> Int -> Maybe a
[]     !!? _         = Nothing
_      !!? i | i < 0 = Nothing
(x:xs) !!? 0 = Just x
(x:xs) !!? i = xs !!? (i-1)

jlToList :: JoinList m a -> [a]
jlToList Empty            = []
jlToList (Single _ a)     = [a]
jlToList (Append _ l1 l2) = jlToList l1 ++ jlToList l2

-- 1. Implement the function:
--    indexJ :: (Sized b, Monoid b) => Int -> JoinList b a -> Maybe a
--    ...which finds the JoinList element at the specified index

indexJ :: (Sized b, Monoid b) => Int -> JoinList b a -> Maybe a
indexJ _ (Empty)              = Nothing
indexJ 0 (Single m a)         = Just a
indexJ n (Single m a) | n > 0 = Nothing
indexJ n _            | n < 0 = Nothing
indexJ n (Append m jl1 jl2)
  | n < leftSize = indexJ n jl1
  | otherwise = indexJ (n - leftSize) jl2
  where leftSize = getSize . size $ (tag jl1)

-- 2. Implement the function:
-- dropJ :: (Sized b, Monoid b) => Int -> JoinList b a -> JoinList b a
-- ...which drops the first n elements from a JoinList.

dropJ :: (Sized b, Monoid b) => Int -> JoinList b a -> JoinList b a
dropJ _ (Empty)    = Empty
dropJ n jl | n < 1 = jl
dropJ n (Single m a) = Empty
dropJ n (Append m jl1 jl2)
  | n < leftSize = dropJ n jl1
  | otherwise = dropJ (n - leftSize) jl2
  where leftSize = getSize . size $ tag jl1

-- 3. Implement the function:
-- takeJ :: (Sized b, Monoid b) => Int -> JoinList b a -> JoinList b a
-- ...which returns the first n elements from a JoinList.

takeJ :: (Sized b, Monoid b) => Int -> JoinList b a -> JoinList b a
takeJ _ (Empty)      = Empty
takeJ n jl | n < 1   = Empty
takeJ n (Single m a) = Single m a
takeJ n (Append m jl1 jl2)
  | n > leftSize = Append m jl1 (takeJ (n - leftSize) jl2)
  | otherwise = takeJ n jl1
  where leftSize = getSize . size $ tag jl1


-- ** Exercise 3
--
-- Write the following function:
-- scoreLine :: String -> JoinList Score String

scoreLine :: String -> JoinList Score String
scoreLine s@(x:_) = Single (scoreString s) s
scoreLine _       = Empty


-- ** Exercise 4
--
-- Since we want to track both the size and score of a buffer, you should
-- provide a Buffer instance for the type:
-- JoinList (Score, Size) String
--

-- NOTE: I think we the value function can be improved... but how? new
-- Scored type class?
instance Buffer (JoinList (Score, Size) String) where
  fromString s               = Single (scoreString s, Size 1) s
  line n jl                  = indexJ n jl
  numLines jl                = getSize . size $ tag jl
  replaceLine n s jl         = takeJ (n-1) jl +++ fromString s +++ dropJ n jl
  toString jl                = unwords $ jlToList jl
  value (Empty)              = 0
  value (Single (sc, _) _)   = getScore sc
  value (Append (sc, _) _ _) = getScore sc
