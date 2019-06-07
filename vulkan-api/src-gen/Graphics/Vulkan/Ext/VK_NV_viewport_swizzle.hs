{-# OPTIONS_HADDOCK not-home#-}
{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE MagicHash       #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE Strict          #-}
{-# LANGUAGE ViewPatterns    #-}
module Graphics.Vulkan.Ext.VK_NV_viewport_swizzle
       (-- * Vulkan extension: @VK_NV_viewport_swizzle@
        -- |
        --
        -- supported: @vulkan@
        --
        -- contact: @Piers Daniell @pdaniell-nv@
        --
        -- author: @NV@
        --
        -- type: @device@
        --
        -- Extension number: @99@
        VkExtent2D, VkExtent2D', module Graphics.Vulkan.Types.BaseTypes,
        VkOffset2D, VkOffset2D', module Graphics.Vulkan.Types.Bitmasks,
        VkPipelineViewportStateCreateInfo,
        VkPipelineViewportStateCreateInfo',
        VkPipelineViewportSwizzleStateCreateInfoNV,
        VkPipelineViewportSwizzleStateCreateInfoNV', VkRect2D, VkRect2D',
        module Graphics.Vulkan.Types.Enum.StructureType, VkViewport,
        VkViewport',
        module Graphics.Vulkan.Types.Enum.ViewportCoordinateSwizzleNV,
        VkViewportSwizzleNV, VkViewportSwizzleNV',
        -- > #include "vk_platform.h"
        VK_NV_VIEWPORT_SWIZZLE_SPEC_VERSION,
        pattern VK_NV_VIEWPORT_SWIZZLE_SPEC_VERSION,
        VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME,
        pattern VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME,
        pattern VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SWIZZLE_STATE_CREATE_INFO_NV)
       where
import GHC.Ptr                                                (Ptr (..))
import Graphics.Vulkan.Marshal
import Graphics.Vulkan.Types.BaseTypes
import Graphics.Vulkan.Types.Bitmasks
import Graphics.Vulkan.Types.Enum.StructureType
import Graphics.Vulkan.Types.Enum.ViewportCoordinateSwizzleNV
import Graphics.Vulkan.Types.Struct.Extent                    (VkExtent2D,
                                                               VkExtent2D')
import Graphics.Vulkan.Types.Struct.Offset                    (VkOffset2D,
                                                               VkOffset2D')
import Graphics.Vulkan.Types.Struct.Pipeline                  (VkPipelineViewportStateCreateInfo,
                                                               VkPipelineViewportStateCreateInfo',
                                                               VkPipelineViewportSwizzleStateCreateInfoNV,
                                                               VkPipelineViewportSwizzleStateCreateInfoNV')
import Graphics.Vulkan.Types.Struct.Rect                      (VkRect2D,
                                                               VkRect2D')
import Graphics.Vulkan.Types.Struct.Viewport                  (VkViewport,
                                                               VkViewport',
                                                               VkViewportSwizzleNV,
                                                               VkViewportSwizzleNV')

pattern VK_NV_VIEWPORT_SWIZZLE_SPEC_VERSION :: (Num a, Eq a) => a

pattern VK_NV_VIEWPORT_SWIZZLE_SPEC_VERSION = 1

type VK_NV_VIEWPORT_SWIZZLE_SPEC_VERSION = 1

pattern VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME :: CString

pattern VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME <-
        (is_VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME -> True)
  where VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME
          = _VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME

{-# INLINE _VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME #-}

_VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME :: CString
_VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME
  = Ptr "VK_NV_viewport_swizzle\NUL"#

{-# INLINE is_VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME #-}

is_VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME :: CString -> Bool
is_VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME
  = (EQ ==) . cmpCStrings _VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME

type VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME =
     "VK_NV_viewport_swizzle"

pattern VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SWIZZLE_STATE_CREATE_INFO_NV
        :: VkStructureType

pattern VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SWIZZLE_STATE_CREATE_INFO_NV
        = VkStructureType 1000098000
