{-# OPTIONS_HADDOCK ignore-exports#-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures             #-}
{-# LANGUAGE PatternSynonyms            #-}
{-# LANGUAGE StandaloneDeriving         #-}
{-# LANGUAGE Strict                     #-}
{-# LANGUAGE TypeSynonymInstances       #-}
module Graphics.Vulkan.Types.Enum.SwapchainCreateFlagsKHR
       (VkSwapchainCreateBitmaskKHR(VkSwapchainCreateBitmaskKHR,
                                    VkSwapchainCreateFlagsKHR, VkSwapchainCreateFlagBitsKHR),
        VkSwapchainCreateFlagsKHR, VkSwapchainCreateFlagBitsKHR)
       where
import Data.Bits                       (Bits, FiniteBits)
import Foreign.Storable                (Storable)
import GHC.Read                        (choose, expectP)
import Graphics.Vulkan.Marshal         (FlagBit, FlagMask, FlagType)
import Graphics.Vulkan.Types.BaseTypes (VkFlags (..))
import Text.ParserCombinators.ReadPrec (prec, step, (+++))
import Text.Read                       (Read (..), parens)
import Text.Read.Lex                   (Lexeme (..))

newtype VkSwapchainCreateBitmaskKHR (a ::
                                       FlagType) = VkSwapchainCreateBitmaskKHR VkFlags
                                                   deriving (Eq, Ord, Storable)

type VkSwapchainCreateFlagsKHR =
     VkSwapchainCreateBitmaskKHR FlagMask

type VkSwapchainCreateFlagBitsKHR =
     VkSwapchainCreateBitmaskKHR FlagBit

pattern VkSwapchainCreateFlagBitsKHR ::
        VkFlags -> VkSwapchainCreateBitmaskKHR FlagBit

pattern VkSwapchainCreateFlagBitsKHR n =
        VkSwapchainCreateBitmaskKHR n

pattern VkSwapchainCreateFlagsKHR ::
        VkFlags -> VkSwapchainCreateBitmaskKHR FlagMask

pattern VkSwapchainCreateFlagsKHR n = VkSwapchainCreateBitmaskKHR n

deriving instance Bits (VkSwapchainCreateBitmaskKHR FlagMask)

deriving instance FiniteBits (VkSwapchainCreateBitmaskKHR FlagMask)

instance Show (VkSwapchainCreateBitmaskKHR a) where
    showsPrec p (VkSwapchainCreateBitmaskKHR x)
      = showParen (p >= 11)
          (showString "VkSwapchainCreateBitmaskKHR " . showsPrec 11 x)

instance Read (VkSwapchainCreateBitmaskKHR a) where
    readPrec
      = parens
          (choose [] +++
             prec 10
               (expectP (Ident "VkSwapchainCreateBitmaskKHR") >>
                  (VkSwapchainCreateBitmaskKHR <$> step readPrec)))
