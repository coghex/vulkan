{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE NamedFieldPuns      #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE Strict              #-}
{-# LANGUAGE TypeApplications    #-}
module Lib.Vulkan.Drawing
  ( RenderData (..)
  , createFramebuffers
  , createCommandBuffers
  , createFrameSemaphores
  , createFrameFences
  , drawFrame
  , _MAX_FRAMES_IN_FLIGHT
  ) where

import           Control.Monad                            (forM_, replicateM)
import           Data.IORef
import           Graphics.Vulkan
import           Graphics.Vulkan.Core_1_0
import           Graphics.Vulkan.Ext.VK_KHR_swapchain
import           Graphics.Vulkan.Marshal.Create
import           Graphics.Vulkan.Marshal.Create.DataFrame
import           Numeric.DataFrame

import           Lib.Program
import           Lib.Program.Foreign
import           Lib.Vulkan.Device
import           Lib.Vulkan.Presentation
import           Lib.Vulkan.Sync


_MAX_FRAMES_IN_FLIGHT :: Int
_MAX_FRAMES_IN_FLIGHT = 2


createFramebuffers :: VkDevice
                   -> VkRenderPass
                   -> SwapchainInfo
                   -> [VkImageView]
                   -> VkImageView
                   -> VkImageView
                   -> Program r [VkFramebuffer]
createFramebuffers dev renderPass SwapchainInfo{ swapExtent } swapImgViews depthImgView colorImgView =
    allocResource
      (liftIO . mapM_  (\fb -> vkDestroyFramebuffer dev fb VK_NULL) )
      (mapM createFB swapImgViews)
  where
    createFB swapImgView =
      let fbci = createVk @VkFramebufferCreateInfo
            $  set @"sType" VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
            &* set @"pNext" VK_NULL
            &* set @"flags" VK_ZERO_FLAGS
            &* set @"renderPass" renderPass
            &* setListCountAndRef @"attachmentCount" @"pAttachments" [colorImgView, depthImgView, swapImgView]
            &* set @"width" (getField @"width" swapExtent)
            &* set @"height" (getField @"height" swapExtent)
            &* set @"layers" 1
      in allocaPeek $ \fbPtr -> withVkPtr fbci $ \fbciPtr ->
          runVk $ vkCreateFramebuffer dev fbciPtr VK_NULL fbPtr


createCommandBuffers :: VkDevice
                     -> VkPipeline
                     -> VkCommandPool
                     -> VkRenderPass
                     -> VkPipelineLayout
                     -> SwapchainInfo
                     -> VkBuffer -- vertex data
                     -> (Word32, VkBuffer) -- nr of indices and index data
                     -> [VkFramebuffer]
                     -> [VkDescriptorSet]
                     -> Program r (Ptr VkCommandBuffer)
createCommandBuffers
    dev pipeline commandPool rpass pipelineLayout SwapchainInfo{ swapExtent }
    vertexBuffer
    (nIndices, indexBuffer) fbs descriptorSets
  | buffersCount <- length fbs = do
  -- allocate a pointer to an array of command buffer handles
  cbsPtr <- mallocArrayRes buffersCount
  vertexBufArr <- newArrayRes [vertexBuffer]
  vertexOffArr <- newArrayRes [0]

  allocResource
    (const $ liftIO $ vkFreeCommandBuffers dev commandPool (fromIntegral buffersCount) cbsPtr)
    $ do
    let allocInfo = createVk @VkCommandBufferAllocateInfo
          $  set @"sType" VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
          &* set @"pNext" VK_NULL
          &* set @"commandPool" commandPool
          &* set @"level" VK_COMMAND_BUFFER_LEVEL_PRIMARY
          &* set @"commandBufferCount" (fromIntegral buffersCount)

    withVkPtr allocInfo $ \aiPtr ->
      runVk $ vkAllocateCommandBuffers dev aiPtr cbsPtr
    commandBuffers <- peekArray buffersCount cbsPtr

    -- record command buffers
    forM_ (zip3 fbs descriptorSets commandBuffers) $
      \(frameBuffer, descriptorSet, cmdBuffer) -> do

      -- begin commands
      let cmdBufBeginInfo = createVk @VkCommandBufferBeginInfo
            $  set @"sType" VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
            &* set @"pNext" VK_NULL
            &* set @"flags" VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT

      withVkPtr cmdBufBeginInfo
        $ runVk . vkBeginCommandBuffer cmdBuffer

      -- render pass
      let renderPassBeginInfo = createVk @VkRenderPassBeginInfo
            $  set @"sType" VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO
            &* set @"pNext" VK_NULL
            &* set @"renderPass" rpass
            &* set @"framebuffer" frameBuffer
            &* setVk @"renderArea"
                (  setVk @"offset"
                   ( set @"x" 0 &* set @"y" 0 )
                &* set @"extent" swapExtent
                )
            &* setListCountAndRef @"clearValueCount" @"pClearValues"
                [ createVk @VkClearValue
                    $ setVk @"color"
                      $ setVec @"float32" (vec4 0 0 0.2 1)
                , createVk @VkClearValue
                    $ setVk @"depthStencil"
                      $  set @"depth" 1.0
                      &* set @"stencil" 0
                ]

      withVkPtr renderPassBeginInfo $ \rpibPtr ->
        liftIO $ vkCmdBeginRenderPass cmdBuffer rpibPtr VK_SUBPASS_CONTENTS_INLINE

      -- basic drawing commands
      liftIO $ vkCmdBindPipeline cmdBuffer VK_PIPELINE_BIND_POINT_GRAPHICS pipeline
      liftIO $ vkCmdBindVertexBuffers
                 cmdBuffer 0 1 vertexBufArr vertexOffArr
      liftIO $ vkCmdBindIndexBuffer cmdBuffer indexBuffer 0 VK_INDEX_TYPE_UINT32
      dsPtr <- newArrayRes [descriptorSet]
      liftIO $ vkCmdBindDescriptorSets cmdBuffer VK_PIPELINE_BIND_POINT_GRAPHICS pipelineLayout 0 1 dsPtr 0 VK_NULL
      liftIO $ vkCmdDrawIndexed cmdBuffer nIndices 1 0 0 0

      -- finishing up
      liftIO $ vkCmdEndRenderPass cmdBuffer

      runVk $ vkEndCommandBuffer cmdBuffer

    return cbsPtr


createFrameSemaphores :: VkDevice -> Program r (Ptr VkSemaphore)
createFrameSemaphores dev = newArrayRes =<< replicateM _MAX_FRAMES_IN_FLIGHT (createSemaphore dev)


createFrameFences :: VkDevice -> Program r (Ptr VkFence)
createFrameFences dev = newArrayRes =<< replicateM _MAX_FRAMES_IN_FLIGHT (createFence dev True)


data RenderData
  = RenderData
  { dev                :: VkDevice
  , swapInfo           :: SwapchainInfo
  , queues             :: DevQueues
  , imgIndexPtr        :: Ptr Word32
  , frameIndexRef      :: IORef Int
  , renderFinishedSems :: Ptr VkSemaphore
    -- ^ one per frame-in-flight
  , imageAvailableSems :: Ptr VkSemaphore
    -- ^ one per frame-in-flight
  , inFlightFences     :: Ptr VkFence
    -- ^ one per frame-in-flight
  , cmdBuffersPtr      :: Ptr VkCommandBuffer
    -- ^ one per swapchain image
  , memories           :: Ptr VkDeviceMemory
    -- ^ one per swapchain image
  , memoryMutator      :: forall r. VkDeviceMemory -> Program r ()
    -- ^ to execute on memories[*imgIndexPtr] before drawing
  }

drawFrame :: RenderData -> Program r Bool
drawFrame RenderData {..} = do
    frameIndex <- liftIO $ readIORef frameIndexRef
    let inFlightFencePtr = inFlightFences `ptrAtIndex` frameIndex
    runVk $ vkWaitForFences dev 1 inFlightFencePtr VK_TRUE (maxBound :: Word64)

    let SwapchainInfo {..} = swapInfo
        DevQueues {..} = queues

    imageAvailable <- peek (imageAvailableSems `ptrAtIndex` frameIndex)
    renderFinished <- peek (renderFinishedSems `ptrAtIndex` frameIndex)
    inFlightFence <- peek inFlightFencePtr
    -- Acquiring an image from the swapchain
    -- Can throw VK_ERROR_OUT_OF_DATE_KHR
    runVk $ vkAcquireNextImageKHR
          dev swapchain maxBound
          imageAvailable VK_NULL_HANDLE imgIndexPtr
    imgIndex <- fromIntegral <$> peek imgIndexPtr
    let bufPtr = cmdBuffersPtr `ptrAtIndex` imgIndex
    let memoryPtr = memories `ptrAtIndex` imgIndex
    mem <- peek memoryPtr
    memoryMutator mem

    -- Submitting the command buffer
    let submitInfo = createVk @VkSubmitInfo
          $  set @"sType" VK_STRUCTURE_TYPE_SUBMIT_INFO
          &* set @"pNext" VK_NULL
          &* set @"waitSemaphoreCount" 1
          &* setListRef @"pWaitSemaphores"   [imageAvailable]
          &* setListRef @"pWaitDstStageMask" [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT]
          &* set @"commandBufferCount" 1
          &* set @"pCommandBuffers" bufPtr
          &* set @"signalSemaphoreCount" 1
          &* setListRef @"pSignalSemaphores" [renderFinished]

    runVk $ vkResetFences dev 1 inFlightFencePtr
    withVkPtr submitInfo $ \siPtr ->
      runVk $ vkQueueSubmit graphicsQueue 1 siPtr inFlightFence

    -- Presentation
    let presentInfo = createVk @VkPresentInfoKHR
          $  set @"sType" VK_STRUCTURE_TYPE_PRESENT_INFO_KHR
          &* set @"pNext" VK_NULL
          &* set @"pImageIndices" imgIndexPtr
          &* set        @"waitSemaphoreCount" 1
          &* setListRef @"pWaitSemaphores" [renderFinished]
          &* set        @"swapchainCount" 1
          &* setListRef @"pSwapchains"    [swapchain]

    -- doing this before vkQueuePresentKHR because that might throw VK_ERROR_OUT_OF_DATE_KHR
    liftIO $ writeIORef frameIndexRef $ (frameIndex + 1) `mod` _MAX_FRAMES_IN_FLIGHT

    withVkPtr presentInfo $
      -- Can throw VK_ERROR_OUT_OF_DATE_KHR
      runVk . vkQueuePresentKHR presentQueue
    -- is suboptimal?
    (== VK_SUBOPTIMAL_KHR) . currentStatus <$> get
