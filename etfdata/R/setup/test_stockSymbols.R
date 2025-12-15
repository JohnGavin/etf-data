library(TTR)
try({
  lse <- stockSymbols(exchange = "LSE")
  print(head(lse))
  print(nrow(lse))
})
