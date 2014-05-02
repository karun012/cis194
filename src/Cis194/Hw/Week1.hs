module Cis194.Hw.Week1 where

-------------
-- Ex 1-4  --
-------------

toDigits :: Integer -> [Integer]
toDigits x
  | x < 1  = []
  | x < 10 = [x]
  | otherwise = toDigits(x `div` 10) ++ [(x `mod` 10)]

toDigitsRev :: Integer -> [Integer]
toDigitsRev x = reverse(toDigits(x))

doubleEveryOther :: [Integer] -> [Integer]
doubleEveryOther [] = []
doubleEveryOther x  = reverse (map (\(digit, offset) -> if (offset `mod` 2) == 1 then digit * 2 else digit) (zip (reverse x) [0..]))

sumDigits :: [Integer] -> Integer
sumDigits [] = 0
sumDigits (x:xs)
  | x < 10    = x + sumDigits(xs)
  | otherwise = sumDigits(toDigits(x)) + sumDigits(xs)

validate :: Integer -> Bool
validate x = (sumDigits (doubleEveryOther (toDigits x)) `mod` 10) == 0

---------------------
-- Towers of Hanoi --
---------------------

type Peg = String
type Move = (Peg, Peg)

hanoi :: Integer -> Peg -> Peg -> Peg -> [Move]
hanoi _ _ _ _ = []

hanoi4 :: Integer -> Peg -> Peg -> Peg -> Peg -> [Move]
hanoi4 _ _ _ _ _ = []
