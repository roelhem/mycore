{-# LANGUAGE BlockArguments #-}

-- | Docs server
module Mycore.Docs.Server where

import           Data.Aeson
import           Data.Text
import           GHC.Generics
import           Lucid
import           Network.Wai.Handler.Warp
import           Servant
import           Servant.HTML.Lucid

type UserAPI =
    "users" :> Get '[JSON, HTML] [User]
        :<|> "text" :> Get '[PlainText] Text

data User
    = User
        { name :: !String
        , age  :: !Int
        }
    | Client
        { name :: !String
        }
    deriving (Eq, Show, Generic)

instance ToJSON User

instance ToHtml User where
    toHtml User{..} = tr_ do
        td_ [style_ "font-weight:bold"] "User"
        td_ $ toHtml name
    toHtml Client{..} = tr_ do
        td_ [style_ "font-weight:bold"] "Client"
        td_ $ toHtml name

    toHtmlRaw = toHtml

instance ToHtml [User] where
    toHtml xs = table_ do
        tr_ do
            th_ "type"
            th_ "name"

        foldMap toHtml xs
    toHtmlRaw = toHtml

users :: [User]
users = [User "Roel" 31, User "Maysa" 27, Client "home"]

usersServer :: Server UserAPI
usersServer = return users :<|> return "abc"

userAPI :: Proxy UserAPI
userAPI = Proxy

userApp :: Application
userApp = serve userAPI usersServer

runUserServer :: IO ()
runUserServer = run 8081 userApp
