{-# LANGUAGE OverloadedStrings #-}
import           Control.Monad
import           Data.Maybe          (isJust)
import           Data.Monoid         (mappend)
import qualified Data.Text           as T
import           Hakyll
import           System.Environment  (lookupEnv)
import           Text.Pandoc         (readOrg)
import           Text.Pandoc.Options

main :: IO ()
main =
  do prod <- isJust <$> lookupEnv "PROD"
     let config :: Configuration
         config = defaultConfiguration
                   { previewHost = "0.0.0.0",
                     previewPort = 9001 }
         myDefaultContext = mconcat
                            [ boolField "prod" (const prod)
                            , constField "root" root
                            , constField "keywords" keywords
                            , defaultContext ]
     hakyllWith config $ do
       match "images/*" $ do
         route   idRoute
         compile copyFileCompiler

       match "css/*" $ do
         route   idRoute
         compile compressCssCompiler

       -- TODO JavaScript (compiler?)
       forM_ ["js/*"] $ \f -> match f $ do
         route idRoute
         compile copyFileCompiler

       match (fromList ["CNAME", "favicon.ico", "robots.txt"]) $ do
         route   idRoute
         compile copyFileCompiler

       match "pages/*" $ do
         route   $ gsubRoute "pages/" (const "") `composeRoutes` setExtension "html"
         compile $ pandocCompiler
           >>= loadAndApplyTemplate "templates/default.html" myDefaultContext
           >>= relativizeUrls

       tags <- buildTags "posts/**" (fromCapture "tags/*.html")
       let myPostCtx = mconcat
                       [ dateField "date" "%B %e, %Y"
                       , tagsField "tags" tags
                       , myDefaultContext ]
       tagsRules tags $ \tag pat -> do
         route idRoute
         compile $ do
           posts <- recentFirst =<< loadAll pat
           let myTagPageCtx = mconcat
                 [ listField "posts" myPostCtx (return posts)
                 , constField "title" $ "Posts tagged \"" ++ tag ++ "\""
                 , boolField "noindex" (pure True)
                 , myDefaultContext ]

           makeItem ""
             >>= loadAndApplyTemplate "templates/tag.html" myTagPageCtx
             >>= loadAndApplyTemplate "templates/default.html" myTagPageCtx
             >>= relativizeUrls

       match "posts/**" $ do
         route $ setExtension "html"
         compile $ customPandocCompiler
           >>= saveSnapshot "content"
           >>= loadAndApplyTemplate "templates/post.html"    myPostCtx
           >>= loadAndApplyTemplate "templates/default.html" myPostCtx
           >>= replaceTeaserSeparator "(.more.)" "<!--more-->"
           >>= relativizeUrls

       create ["archive.html"] $ do
         route idRoute
         compile $ do
           posts <- recentFirst =<< loadAll "posts/**"
           tagList <- renderTagList tags
           let myArchiveCtx =
                 listField "posts" myPostCtx (return posts) `mappend`
                 constField "taglist"  tagList              `mappend`
                 constField "title" "Archives"              `mappend`
                 myDefaultContext

           makeItem ""
             >>= loadAndApplyTemplate "templates/archive.html" myArchiveCtx
             >>= loadAndApplyTemplate "templates/default.html" myArchiveCtx
             >>= relativizeUrls

       create ["sitemap.xml"] $ do
         route   idRoute
         compile $ do
           posts <- recentFirst =<< loadAll "posts/*"
           pages <- loadAll "pages/*"
           let allPages = return (pages ++ posts)
           let sitemapCtx = mconcat
                            [ listField "pages" myPostCtx allPages
                            , myDefaultContext
                            ]
           makeItem ""
             >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx

       create ["rss.xml"] $ do
         route idRoute
         compile $ do
           let feedCtx = mconcat
                         [ teaserFieldWithSeparator "(.more.)" "teaser" "content"
                         , bodyField "description"
                         , myPostCtx
                         ]
               absolutizeUrl u = if isExternal u then u else root ++ u
           posts <- fmap (take 10) . recentFirst =<<
             loadAllSnapshots "posts/*" "content"
           processedPosts <- forM posts $
             \p -> do pp <- loadAndApplyTemplate "templates/rss-description.html" feedCtx p
                      return $ fmap (withUrls absolutizeUrl) pp
           renderRss myFeedConfiguration feedCtx processedPosts

       match "index.html" $ do
         route idRoute
         compile $ do
           posts <- fmap (take 5) . recentFirst =<< loadAllSnapshots "posts/*" "content"
           let myTeaserPostCtx =
                 teaserFieldWithSeparator "(.more.)" "teaser" "content" <> myPostCtx
               myIndexCtx = mconcat
                            [ listField "posts" myTeaserPostCtx (return posts)
                            , constField "canonical" (root ++ "/")
                            , constField "homepage" "yes"
                            , myDefaultContext ]

           getResourceBody
             >>= applyAsTemplate myIndexCtx
             >>= loadAndApplyTemplate "templates/default.html" myIndexCtx
             >>= relativizeUrls

       match "about/*" $ compile templateBodyCompiler
       match "templates/*" $ compile templateBodyCompiler

root :: String
root = "https://photonsphere.org"

keywords :: String
keywords = "mari donkers,maridonkers,donkers,nederland,netherlands,eindhoven,computer,software,software development,blog,photonsphere,photon sphere,internet,linux,nixos,nix,html,css,clojure,clojurescript,haskell,hakyll,functional,functional programming,docker,gui,python,perl,php,c,c++,rust"

customPandocCompiler :: Compiler (Item String)
customPandocCompiler =
  let defaultReaderExtensions = readerExtensions defaultHakyllReaderOptions
      readerOptions = defaultHakyllReaderOptions {
        readerExtensions = enableExtension Ext_tex_math_single_backslash defaultReaderExtensions
        }

      defaultWriterExtensions = writerExtensions defaultHakyllWriterOptions
      writerOptions = defaultHakyllWriterOptions {
        writerExtensions = enableExtension Ext_tex_math_single_backslash defaultWriterExtensions,
          writerHTMLMathMethod = MathJax ""
        }
  in pandocCompilerWith readerOptions writerOptions

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
    { feedTitle       = "THE PHOTON SPHERE"
    , feedDescription = "The Photon Sphere - where light travels in circles."
    , feedAuthorName  = "Mari Donkers"
    , feedAuthorEmail = ""
    , feedRoot        = root
    }

-- | Replace teaser separator in item.
replaceTeaserSeparator :: String
                       -> String
                       -> Item String
                       -> Compiler (Item String)
replaceTeaserSeparator tsFrom tsTo item = do
    return $ fmap (replaceTeaserSeparatorWith tsFrom tsTo) item

-- | Teaser separator in HTML
replaceTeaserSeparatorWith :: String  -- ^ teaser separator to replace
                           -> String  -- ^ replacement teaser separator
                           -> String  -- ^ HTML to replace in
                           -> String  -- ^ Resulting HTML
replaceTeaserSeparatorWith tsFrom tsTo html =
    T.unpack $ T.replace tsFrom' tsTo' html'
    where tsFrom' = T.pack tsFrom
          tsTo' = T.pack tsTo
          html' = T.pack html
