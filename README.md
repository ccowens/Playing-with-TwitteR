# Playing with TwitteR

This is an exploration of the [twitteR package](https://cran.r-project.org/web/packages/twitteR/twitteR.pdf) for accessing the Twitter API in R. All the explore scripts first load the API key info from a non-shared (here) CSV file and then get API access. 

##Current Scripts
 
* `explore_hastags.R` looks at twitter hashtag frequencies for related accounts
* `fill_API_info.R` is a dummy version of the R script I use to create the CSV file with the Twitter API info 

##Setup in Twitter

2. Go to `https://apps.twitter.com/`
3. Log in if necessary
4. Create an app
5. Fill in this for Callback URL:  `http://127.0.0.1:1410`
6. Hit the submit button
7. Look for Consumer Key (API Key) on the screen
8. Click the "manage keys and access tokens" link
9. Note the Consumer Key (API Key) and Consumer Secret API Secret) IDs under Application Settings	
10. Go down to the "Create my access token" button under Token Actions and click it
11. Note the Access Token and Access Token Secret IDs

##Set Up Files

1. Create a directory called `private`
2. Move `fill_API_info.R` into this directory

##Setup in R

1. Fill in the 4 IDs from Twitter in the appropriate places inside `fill_API_info.R`
2. Run this script
3. Open an explore script like `explore_twitter.R` and run it

##Caveats

* Don't forget to fill in the Callback URL with `http://127.0.0.1:1410` when creating the app on the Twitter side
* Sometimes it's necessary to regenerate the keys to get the R function that sets up the connection to work
