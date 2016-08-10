##
## Create CSV file with API key info
## This public version uses dummy values

write.csv(
  data.frame(
    Consumer.Key = "XX",
    Consumer.Secret = "XX",
    Access.Token = "XX",
    Access.Token.Secret = "XX",
    stringsAsFactors = FALSE
  ),
  file = "private/secret_stuff.csv",
  row.names = FALSE
)
