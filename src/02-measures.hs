{-@ LIQUID "--short-names"    @-}
{-@ LIQUID "--no-warnings"    @-}
{-@ LIQUID "--no-termination" @-}
{-@ LIQUID "--totality"       @-}
{-@ LIQUID "--diff"           @-}

module Refinements where

import Prelude hiding (sum, length, map, filter, foldr, foldr1)

map    :: (a -> b) -> List a -> List b
foldr1 :: (a -> a -> a) -> List a -> a
head   :: List a -> a
tail   :: List a -> List a
append :: List a -> List a -> List a
filter :: (a -> Bool) -> List a -> List a
die    :: String -> a
average       :: List Int -> Int
annualAverage :: Annual Int -> Int
wtAverage     :: List (Int, Int) -> Int

-----------------------------------------------------------------------
-- | A List Data Type
-----------------------------------------------------------------------

data List a = Emp | (:::) a (List a) deriving (Eq, Ord, Show)

infixr 9 :::

-----------------------------------------------------------------------
-- | Specifying the length of a List
-----------------------------------------------------------------------

{-@ measure length @-}
length :: List a -> Int
length Emp        = 0
length (_ ::: xs) = 1 + length xs

-- | Non Empty Lists

{-@ type ListNE a = {v:List a | 0 < length v } @-}

-----------------------------------------------------------------------
-- | A few Partial Functions
-----------------------------------------------------------------------

{-@ head :: ListNE a -> a      @-}
head (x ::: _)  = x
head _          = die "ok"

{-@ tail :: ListNE a -> List a @-}
tail (_ ::: xs) = xs
tail _          = die "ok"


-- | Lists of a given size N

{-@ type ListN a N = {v:List a | length v == N } @-}

-----------------------------------------------------------------------
-- | The Usual Suspects
-----------------------------------------------------------------------

{-@ append :: xs:List a -> ys:List a -> ListN a {length ys + length xs} @-}
append Emp ys      = ys
append (x:::xs) ys = x ::: (append xs ys)


{-@ reverse :: xs:List a -> ListN a {length xs} @-}
reverse             = go Emp
  where
    go acc Emp      = acc
    go acc (x:::xs) = go (x:::acc) xs

-----------------------------------------------------------------------
-- | A few Higher-Order Functions
-----------------------------------------------------------------------


{-@ filter :: (a -> Bool) -> xs:List a -> {v: List a | length v <= length xs} @-}
filter _ Emp      = Emp
filter f (x:::xs)
  | f x           = x ::: ys
  | otherwise     = ys
  where
    ys            = filter f xs

foldr :: (a -> b -> b) -> b -> List a -> b
foldr _ acc Emp        = acc
foldr f acc (x ::: xs) = f x (foldr f acc xs)


{-@ foldr1 :: (a -> a -> a) -> ListNE a -> a @-}
foldr1 f (x ::: xs) = foldr f x xs
foldr1 _ Emp        = die "foldr1"

-----------------------------------------------------------------------
-- | Average
-----------------------------------------------------------------------

{-@ average :: ListNE Int -> Int @-}
average xs = total `div` n
  where
    total  = foldr1 (+) xs
    n      = length xs

-----------------------------------------------------------------------
-- | Annual Average
-----------------------------------------------------------------------

data Month = Jan | Feb | Mar | Apr | May | Jun
           | Jul | Aug | Sep | Oct | Nov | Dec
           deriving (Eq, Ord, Show)


-- An `a` value for each month

type Annual a = List (Month, a)

{-@ type Annual a = ListN (Month, a) 12 @-}

{-@ annualAverage :: Annual Int -> Int @-}
annualAverage = average . map snd            -- fix


-- | Lists of size equal to that of another Xs

{-@ type ListX a X = ListN a (length X) @-}

{-@ map :: (a -> b) -> xs:List a -> ListX b xs @-}
map _ Emp         = Emp
map f (x ::: xs)  = f x ::: map f xs

-----------------------------------------------------------------------
-- | Weighted Average
-----------------------------------------------------------------------

{-@ wtAverage :: ListNE (Pos, Pos)  -> Nat @-}
wtAverage wxs = total `div` weights
  where
    total     = sum $ map (\(w, x) -> w * x) wxs
    weights   = sum $ map (\(w, _) -> w    ) wxs
    sum       = foldr1 plus -- (+)
    plus      = (+)





-----------------------------------------------------------------------
-- | Definitions from 01-refinements.hs
-----------------------------------------------------------------------

{-@ type Nat     = {v:Int | v >= 0} @-}
{-@ type Pos     = {v:Int | v >  0} @-}
{-@ type NonZero = {v:Int | v /= 0} @-}

{-@ die :: {v:_ | false} -> a @-}
die = error
