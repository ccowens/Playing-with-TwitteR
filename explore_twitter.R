##
## This is a script file for playing aroun with the twitteR package for accessing Twitter in R
##

# Setting everything up ---------------------------------------------------

# This assumes I've created a single-row CSV with the various API keys
#   from creating an app at https://apps.twitter.com/

if(!require("twitteR")) {install.packages("twitteR"); library(twitteR)}

secrets <- read.csv("private/secret_stuff.csv", stringsAsFactors = FALSE)

setup_twitter_oauth(consumer_key=secrets$Consumer.Key, 
                    consumer_secret=secrets$Consumer.Secret, 
                    access_token=secrets$Access.Token, 
                    access_secret=secrets$Access.Token.Secret)

# Playing around ----------------------------------------------------------

# Searching for tweets that mention Adams and charter to put into a table
tweets = searchTwitter('adams AND charter')
adams_charter <- twListToDF(tweets)

# Searching for my tweets to put into a table
tweets = userTimeline('ccowens', n=100)
my_tweets <- twListToDF(tweets)
