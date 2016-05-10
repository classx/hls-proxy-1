{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TemplateHaskell   #-}

module Lib.Types where

import           Control.Concurrent.STM      (STM ())
import           Control.Concurrent.STM.TVar (TVar (), readTVar)
import           Control.Lens                (makeLenses, (^.))
import           Data.Default                (Default (), def)
import           Data.Monoid                 ((<>))
import Control.Applicative (empty)
import qualified Network.URI as URI
import qualified Data.Text                   as T

newtype Port = Port Int
  deriving (Read, Show)

unPort :: Port -> Int
unPort (Port i) = i

-- | Command line options provided to start up the server.
data ServerOptions = ServerOptions
  { _url  :: String
  , _port :: Port
  }

makeLenses ''ServerOptions

data RuntimeOptions = RuntimeOptions
  { _enableEmptyPlaylist :: Bool
  , _overrideMasterPlaylist :: Maybe URI.URI
  }

makeLenses ''RuntimeOptions

defRuntimeOptions :: RuntimeOptions
defRuntimeOptions = RuntimeOptions
  { _enableEmptyPlaylist = False
  , _overrideMasterPlaylist = empty
  }

tshow :: Show a => a -> T.Text
tshow = T.pack . show

showRuntimeOptions :: TVar RuntimeOptions -> STM T.Text
showRuntimeOptions ropts = do
  ropts' <- readTVar ropts
  let _enableEmptyPlaylist = ropts' ^. enableEmptyPlaylist
  let _overrideMasterPlaylist = ropts' ^. overrideMasterPlaylist
  return $ "{ enableEmptyPlaylist = " <> tshow _enableEmptyPlaylist <> "\n"
        <> ", overrideMasterPlaylist = " <> tshow _overrideMasterPlaylist <> "\n"
        <> "}"

instance Default Port where
  def = Port 3000
