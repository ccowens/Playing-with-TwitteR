##
## This is a script file for looking at twitter hashtag frequencies for related accounts
##

if(!require(twitteR)) {install.packages("twitteR"); library(twitteR)}
if(!require(dplyr)) {install.packages("dplyr"); library(dplyr)}
if(!require(tidyr)) {install.packages("tidyr"); library(tidyr)}   
if(!require(ggplot2)) {install.packages("ggplot2"); library(ggplot2)}

# API housekeeping to open connection to Twitter --------------------------

# information for opening connection is kept in a single-row CSV file with the various 
# API keys derived from creating an app at https://apps.twitter.com/ (CSV file created 
# by created by fill_API_info.R script
secrets <- read.csv("private/secret_stuff.csv", stringsAsFactors = FALSE)

setup_twitter_oauth(consumer_key=secrets$Consumer.Key, 
                    consumer_secret=secrets$Consumer.Secret, 
                    access_token=secrets$Access.Token, 
                    access_secret=secrets$Access.Token.Secret)

# analyzing hashtag usage  ----------------------------------------------------------


# decide which accounts to look at
tw_accounts <- c("Gartner_inc", "forrester", "idc")

#tw_accounts <- c("HillaryClinton", "DrJillStein", "GovGaryJohnson", "realDonaldTrump")

# read in the user timelines for these accounts with a cap of 1200 
tweets <- unlist(lapply(tw_accounts, userTimeline, n=1200, excludeReplies=FALSE))

# convert this tweet info to a dataframe
tw <- twListToDF(tweets)

# locate where hashtags are in each tweet's text producing a list 
hashtag_matches <- gregexpr("#[[:alnum:]]+", tw$text) 

# make a vector of the  hashtags for each tweet by (1) using this match list to create a list of vectors of hash tags 
# for each tweet, (2) replacing the value for no-hashtag tweets with a simple empty string, (3) collapsing the
# hashtags as single commas-separated-value strings, and (4) unpakcking the lists into a vector suitable for use
# as a column in a dataframe
extracted_hashtags <- regmatches(tw$text, hashtag_matches) %>% 
                      lapply(function (x) {if(length(x) == 0) "" else x}) %>%
                      lapply(paste, collapse = ", ") %>%
                      unlist() %>%
                      tolower() 

# build the table of hashtags by (1) grabbing the two existing columns we need, (2) adding the hashtags vector 
# as a third column, (3) creating a duplicate row for each hash tag in a given tweet using the tidyr package, (4)
# renaming the column heads, and (5) removing the non-hash-tag tweets 
hashtags_df <- select(tw, screenName, created) %>%
               cbind(extracted_hashtags) %>% 
               separate_rows(extracted_hashtags, sep = ", ") %>% # from tidyr package
               rename(account = screenName, time = created, hashtag = extracted_hashtags) %>%
               filter(hashtag != "")

earliest <- min(hashtags_df$time)


# build a table of the top 20 hashtags by frequency
hashtag_freq <- as.data.frame(table(hashtags_df$hashtag)) %>%
  rename(Hashtag = Var1) %>%
  arrange(desc(Freq)) %>% 
  head(n=20) %>% 
  mutate(Hashtag = reorder(Hashtag, Freq))
  
  
# make the title for the chart
title_txt <- paste0("Top 20 Hashtags\nAccounts: ", paste(tw_accounts, collapse = ", "), "\n", "From: ", format(earliest, "%B %d, %Y"))

# make a flipped bat chart
p = ggplot(hashtag_freq, aes(x = Hashtag, y = Freq)) + geom_bar(stat="identity", fill = "blue")
p + coord_flip() + labs(title = title_txt)

# loosely based on https://www.r-bloggers.com/using-r-to-find-obamas-most-frequent-twitter-hashtags/
