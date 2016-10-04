##
## This is a script file for looking at twitter hashtag frequencies for related accounts
##


# Set up required libraries and graphics file directory -------------------

if(!require(twitteR)) {install.packages("twitteR"); library(twitteR)}
if(!require(dplyr)) {install.packages("dplyr"); library(dplyr)}
if(!require(tidyr)) {install.packages("tidyr"); library(tidyr)}   
if(!require(ggplot2)) {install.packages("ggplot2"); library(ggplot2)}
if(!require(stringi)) {install.packages("stringi"); library(stringi)}

if(!dir.exists("graphics")) dir.create("graphics")

# API housekeeping to open connection to Twitter --------------------------

# information for opening connection is kept in a single-row CSV file with the various 
# API keys derived from creating an app at https://apps.twitter.com/ (CSV file created 
# by created by fill_API_info.R script
secrets <- read.csv("private/secret_stuff.csv", stringsAsFactors = FALSE)

setup_twitter_oauth(consumer_key=secrets$Consumer.Key, 
                    consumer_secret=secrets$Consumer.Secret, 
                    access_token=secrets$Access.Token, 
                    access_secret=secrets$Access.Token.Secret)


# get the tweets for certain accounts of interest  ----------------------------------------------------------

# decide which accounts to look at
tw_accounts <- c("Gartner_inc", "forrester", "idC")

#major tech industry consultants "thought leaders"
#tw_accounts <- c("Gartner_inc", "forrester", "idC")

#presidential candidates in 2016
#tw_accounts <- c("HillaryClinton", "DrJillStein", "GovGaryJohnson", "realDonaldTrump")

# read in the user timelines for these accounts with a cap of 1000 
tweets <- unlist(lapply(tw_accounts, userTimeline, n=1000, excludeReplies=FALSE))

# convert this tweet info to a dataframe
tw <- twListToDF(tweets)
# clean up the tweet texts for any character issues
tw$text <- stri_trans_general(tw$text, "latin-ascii")
# the Twitter API is forgiving of account name capitalization in fetching tweets, but 
# it's better that the accounts vector exactly matches what Twitter sends back as an account name,
# so let's reset the tw_accounts variable using this
tw_accounts <- unique(tw$screenName)


# identify hashtags and form a dataframe with a separate row for e --------


# locate where hashtags are in each tweet's text producing a list 
hashtag_matches <- gregexpr("#[[:alnum:]]+", tw$text) 

# make a vector of the  hashtags in every tweet by (1) using this match list to create a list of vectors of hash tags 
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
# renaming the column heads, and (5) removing the rows for non-hash-tag tweets 
hashtags_df <- select(tw, screenName, created) %>%
               cbind(extracted_hashtags) %>% 
               separate_rows(extracted_hashtags, sep = ", ") %>% # from tidyr package
               rename(account = screenName, time = created, hashtag = extracted_hashtags) %>%
               filter(hashtag != "")

# stire away earliest tweet time
earliest <- min(hashtags_df$time)


# define function to display top (20) hashtags for one or more acccounts --------

top_hashtags <- function (use_tw_accounts) {
  
  use_hashtags_df <- filter(hashtags_df, account %in% use_tw_accounts)

  # build a table of the top 20 hashtags by frequency
  hashtag_freq <- data.frame(table(use_hashtags_df$hashtag))

  hashtag_freq <- arrange(hashtag_freq, desc(Freq)) %>% 
                  head(n=20) %>% 
                  mutate(Hashtag = reorder(Var1, Freq))
  
  # make the title for the chart
  title_txt <- paste0("Top 20 Hashtags\nAccounts: ", paste(use_tw_accounts, collapse = ", "), "\n", "From ", format(earliest, "%B %d, %Y"), " to Now")
    # make a flipped bat chart
  p <- ggplot(hashtag_freq, aes(x = Hashtag, y = Freq)) + geom_bar(stat="identity", fill = "blue") + 
       coord_flip() + labs(title = title_txt)
  # print it to the console
  print(p)
  # save it as a file with a name based on the account names used
  ggsave(filename=paste0(paste(use_tw_accounts, collapse = "-"),"-tophts.png"), path="graphics", plot=p)
}


# define function to display freuencies of tweeting or hash tagging -------


freq_by_account <- function (the_vector, the_title) {
  # tabulate the vector of the accunts in the appropriate dataframess
  account_freq <- as.data.frame(table(the_vector)) %>%
    setNames(c("Account", "Freq")) %>%
    mutate(Account = reorder(Account, Freq))
  
  # make the title for the chart comparing different accounts using the 2d parameter text
  title_txt <- paste0(the_title, "\nAccounts: ", paste(tw_accounts, collapse = ", "), "\n", "From ", format(earliest, "%B %d, %Y"), " to Now")
  # make a flipped bat chart
  p = ggplot(account_freq, aes(x = Account, y = Freq)) + geom_bar(stat="identity", fill = "blue") + 
      coord_flip() + labs(title = title_txt)
  # print it to the console
  print(p)
  # save it as a file with a name based on the account names used
  ggsave(filename=paste0(the_title,"-comparison.png"), path="graphics", plot=p)  
  
}


# Do it -------------------------------------------------------------------

top_hashtags(tw_accounts)
lapply(tw_accounts, top_hashtags)
freq_by_account(hashtags_df$account, "Hashtags Used")
freq_by_account(tw$screenName, "Tweets")


# loosely based on https://www.r-bloggers.com/using-r-to-find-obamas-most-frequent-twitter-hashtags/
