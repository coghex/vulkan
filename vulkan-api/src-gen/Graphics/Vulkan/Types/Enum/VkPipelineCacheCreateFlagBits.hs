{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE Strict                     #-}
module Graphics.Vulkan.Types.Enum.VkPipelineCacheCreateFlagBits
       (VkPipelineCacheCreateFlagBits(..)) where
import           Data.Bits                       (Bits, FiniteBits)
import           Data.Coerce                     (coerce)
import           Data.Data                       (Data)
import           Foreign.Storable                (Storable)
import           GHC.Generics                    (Generic)
import           Graphics.Vulkan.Types.BaseTypes (VkFlags)

newtype VkPipelineCacheCreateFlagBits = VkPipelineCacheCreateFlagBits VkFlags
                                          deriving (Eq, Ord, Num, Bounded, Enum, Integral, Bits,
                                                    FiniteBits, Storable, Real, Data, Generic)

instance Show VkPipelineCacheCreateFlagBits where
        {-# INLINE show #-}
        show (VkPipelineCacheCreateFlagBits x) = show x

instance Read VkPipelineCacheCreateFlagBits where
        {-# INLINE readsPrec #-}
        readsPrec = coerce (readsPrec :: Int -> ReadS VkFlags)