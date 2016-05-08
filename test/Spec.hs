{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes        #-}

import           Control.Lens                 (to)
import           Control.Monad.IO.Class       (liftIO)
import qualified Data.Either.Combinators      as Either
import qualified Data.Text                    as T
import qualified Data.Text.IO                 as TIO
import qualified Lib.HLS.Parse                as HLS
import           System.Directory             (getCurrentDirectory)
import           System.FilePath              ((</>))
import           Test.Hspec
import           Test.Hspec.Expectations.Lens (shouldView, through)
import qualified Text.Megaparsec              as M

openFixture :: forall a. (FilePath -> IO a) -> FilePath -> IO a
openFixture f path = do
    dir <- getCurrentDirectory
    f $ dir </> "test" </> "fixtures" </> path

openTextFixture :: FilePath -> IO T.Text
openTextFixture = openFixture TIO.readFile

main :: IO ()
main = hspec .
  describe "HLS Parser" $ do
    it "read master playlist version" $ do
      doc <- liftIO $ openTextFixture "master-playlist.m3u8"
      let res = HLS.parseHlsPlaylist doc

      res `shouldSatisfy` Either.isRight
      unsafeFromRight res `shouldView` HLS.HLSVersion 3 `through` HLS.hlsVersion

    it "rejects invalid versioned master playlists" $ do
      doc <- liftIO $ openTextFixture "master-playlist-invalid-version.m3u8"
      let res = HLS.parseHlsPlaylist doc

      res `shouldSatisfy` Either.isLeft
      M.errorMessages (Either.fromLeft mempty res) `shouldBe` pure (M.Unexpected "Unsupported version 88")

    it "extracts media playlist URIs" $ do
      doc <- liftIO $ openTextFixture "master-playlist.m3u8"
      let res = HLS.parseHlsPlaylist doc

      unsafeFromRight res `shouldView` 2 `through` HLS.hlsEntries . to length

unsafeFromRight :: Either a b -> b
unsafeFromRight (Right a) = a
unsafeFromRight (Left _) = error "Left"
