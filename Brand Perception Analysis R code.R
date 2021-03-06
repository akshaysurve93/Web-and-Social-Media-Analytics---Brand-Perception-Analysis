# Setup the environment
rm(list=ls())

# Loading Required Packages
library(SnowballC)
library(tm)
library(ggplot2)
library(RColorBrewer)
library(wordcloud)
library(topicmodels)
library(data.table)
library(stringi)
library(syuzhet)
library(qdapRegex)
library(dplyr)
library(plyr)
library(grid)
library(gridExtra)
library(DT)
library(stringr)
library(RSentiment)
library(readr)

#################################################################
# Topic Selected - IPL
#################################################################
# Read Twitter Data
setwd("C:/Users/DELL/Desktop/Akshay/Group Assignments/Group Assignment WSMA")
tweets.df <- read.csv("WSMA.csv")

# Convert char date to correct date format
tweets.df$created <- as.Date(tweets.df$created, format= "%d-%m-%y")
tweets.df$text <- as.character(tweets.df$text)
str(tweets.df)

# Create document corpus with tweet text
myCorpus<- Corpus(VectorSource(tweets.df$text))
writeLines(strwrap(myCorpus[[792]]$content,60))
myCorpusCopy<- myCorpus

#################################################################
# Data Cleaning
#################################################################
# Remove character string between < >
remove_unicode <- function(x) gsub("\\<U[^\\>]*\\>","", x)
myCorpus <- tm_map(myCorpus, content_transformer(remove_unicode))
writeLines(strwrap(myCorpus[[792]]$content,60))

# Convert to Lowercase 
myCorpus <- tm_map(myCorpus, content_transformer(stri_trans_tolower))
writeLines(strwrap(myCorpus[[792]]$content,60))

# Remove the Links (URLs) 
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)  
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))
writeLines(strwrap(myCorpus[[792]]$content,60))

# Remove the @ (usernames)  
removeUsername <- function(x) gsub("@[^[:space:]]*", "", x)  
myCorpus <- tm_map(myCorpus, content_transformer(removeUsername))
writeLines(strwrap(myCorpus[[792]]$content,60))

# Stemming words in the corpus 
myCorpus<-tm_map(myCorpus, stemDocument)
writeLines(strwrap(myCorpus[[792]]$content,60))

# Remove Single Letter Words 
removeSingle <- function(x) gsub(" . ", " ", x)   
myCorpus <- tm_map(myCorpus, content_transformer(removeSingle))
writeLines(strwrap(myCorpus[[792]]$content,60))

# Replace words with the proper ones
replaceWord <- function(corpus, oldword, newword)
{
  tm_map(corpus, content_transformer(gsub), pattern=oldword, replacement=newword)
}
myCorpus<- replaceWord(myCorpus, "precautionari", "precautionary")
myCorpus<- replaceWord(myCorpus, "meeting|meets", "meet")
myCorpus<- replaceWord(myCorpus, "franchisee|franchis|owners|ownerse", "owners")
myCorpus<- replaceWord(myCorpus, "effici|efficientently|efficientent","efficient")
myCorpus<- replaceWord(myCorpus, "measuree|measur","measure")
myCorpus<- replaceWord(myCorpus, "srk|shah|khan|shahrukhkhan|baadsrk","srk")
myCorpus<- replaceWord(myCorpus, "games|game|match","game")

# Remove anything except the english language and space 
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)   
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))
writeLines(strwrap(myCorpus[[792]]$content,60))

# Remove Extra Whitespaces 
myCorpus<- tm_map(myCorpus, stripWhitespace)
writeLines(strwrap(myCorpus[[792]]$content,60))

# Remove Stopwords 
myStopWords<- c((stopwords('english')),
                c("rt", "use", "used","say","can","wh","says","wh","amp","bhi","th","r","ho","hq"
                  ,"dont","reiter","b","reiterate","ipl","style","go","will","mi","hi","htt","psl","ht",
                  "khelbolega","sr","m","one","t","bbl","h","ms","wi","till","re","meet","u","efficient","field","wonderful","owners","srk","play","game","efficientently","ownerse","baadsrk","measuree"))
myCorpus<- tm_map(myCorpus,removeWords , myStopWords) 
writeLines(strwrap(myCorpus[[792]]$content,60))

##############################################################
# Analyzing Text frequency
##############################################################
# Creating a Term Document Matrix
tdm<- TermDocumentMatrix(myCorpus, control= list(wordLengths= c(1, Inf)))
tdm

# Find the terms used most frequently
(freq.terms <- findFreqTerms(tdm, lowfreq = 25))
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq > 25)
df <- data.frame(term = names(term.freq), freq= term.freq)

# Frequency Analysis
(freq.terms <- findFreqTerms(tdm, lowfreq = 10))
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq > 10)
df1 <- data.frame(term = names(term.freq), freq= term.freq)

(freq.terms <- findFreqTerms(tdm, lowfreq = 55))
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq > 55)
df2 <- data.frame(term = names(term.freq), freq= term.freq)

(freq.terms <- findFreqTerms(tdm, lowfreq = 85))
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq > 85)
df3 <- data.frame(term = names(term.freq), freq= term.freq)

# Plotting the graph of frequent terms
p1=ggplot(df1, aes(reorder(term, freq),freq)) + theme_bw() + geom_bar(stat = "identity")  + coord_flip() +labs(list(main="@10", x="Terms", y="Term Counts")) + theme(axis.text.y = element_text(size=8))

p2=ggplot(df, aes(reorder(term, freq),freq)) + theme_bw() + geom_bar(stat = "identity")  + coord_flip() +labs(list(main="@25", x="Terms", y="Term Counts"))+
  theme(axis.text.y = element_text(size=8))

p3=ggplot(df2, aes(reorder(term, freq),freq)) + theme_bw() + geom_bar(stat = "identity")  + coord_flip() +labs(list(main="@55", x="Terms", y="Term Counts"))

p4=ggplot(df3, aes(reorder(term, freq),freq)) + theme_bw() + geom_bar(stat = "identity")  + coord_flip() +labs(list(main="@85", x="Terms", y="Term Counts")) 

p1
p2
p3
p4
# Plotting the graph of frequent terms
grid.arrange(p1,p2,ncol=2)
grid.arrange(p3,p4,ncol=2)

################################################################
# word cloud( overall, positive, negative all 3 separately)
################################################################
# Creating the Wordcloud
word.freq <-sort(rowSums(as.matrix(tdm)), decreasing= F)
pal<- brewer.pal(8, "Dark2")
wordcloud(words = names(word.freq), freq = word.freq, min.freq = 2, random.order = F, colors = pal, max.words = 170)

# Creating Seprate wordcloud for Positive and Negative Sentiments.
setwd("C:/Users/DELL/Desktop/Akshay/Group Assignments/Group Assignment WSMA")
tweets.df <- read.csv("WSMA.csv")
r1 = as.character(tweets.df$text)

## Data Preprocessing
set.seed(100)
sample = sample(r1, (length(r1)))
corpus = Corpus(VectorSource(list(sample)))
corpus = tm_map(corpus, removePunctuation)
corpus = tm_map(corpus, content_transformer(tolower))
corpus = tm_map(corpus, removeNumbers)
corpus = tm_map(corpus, stripWhitespace)
corpus = tm_map(corpus, removeWords, stopwords('english'))
corpus = tm_map(corpus, stemDocument)
dtm_up = DocumentTermMatrix(VCorpus(VectorSource(corpus[[1]]$content)))
freq_up <- colSums(as.matrix(dtm_up))

## Calculating Sentiments
sentiments_up = calculate_sentiment(names(freq_up))
sentiments_up = cbind(sentiments_up, as.data.frame(freq_up))
sent_pos_up = sentiments_up[sentiments_up$sentiment == 'Positive',]
sent_neg_up = sentiments_up[sentiments_up$sentiment == 'Negative',]

cat("We have far lower negative Sentiments: ",sum(sent_neg_up$freq_up)," than positive: ",sum(sent_pos_up$freq_up))

DT::datatable(sent_pos_up)

layout(matrix(c(1, 2), nrow=2), heights=c(1, 4))
par(mar=rep(0, 4))
plot.new()
set.seed(100)
wordcloud(sent_pos_up$text,sent_pos_up$freq,min.freq=10,colors=brewer.pal(6,"Dark2"))

DT::datatable(sent_neg_up)

plot.new()
set.seed(100)
wordcloud(sent_neg_up$text,sent_neg_up$freq, min.freq=10,colors=brewer.pal(6,"Dark2"))
################################################################
# sentiment analysis, polarity- positive or negative
################################################################
##### Sentiment Analysis: understanding emotional valence in tweets using syuzhet

# Sentiment Analysis: understanding emotional valence in tweets using syuzhet
mysentiment<-get_nrc_sentiment((tweets.df$text))

# Get the sentiment score for each emotion
mysentiment.positive =sum(mysentiment$positive)
mysentiment.anger =sum(mysentiment$anger)
mysentiment.anticipation =sum(mysentiment$anticipation)
mysentiment.disgust =sum(mysentiment$disgust)
mysentiment.fear =sum(mysentiment$fear)
mysentiment.joy =sum(mysentiment$joy)
mysentiment.sadness =sum(mysentiment$sadness)
mysentiment.surprise =sum(mysentiment$surprise)
mysentiment.trust =sum(mysentiment$trust)
mysentiment.negative =sum(mysentiment$negative)

# Create the bar chart
yAxis <- c(mysentiment.positive,
           + mysentiment.anger,
           + mysentiment.anticipation,
           + mysentiment.disgust,
           + mysentiment.fear,
           + mysentiment.joy,
           + mysentiment.sadness,
           + mysentiment.surprise,
           + mysentiment.trust,
           + mysentiment.negative)

xAxis <- c("Positive","Anger","Anticipation","Disgust","Fear","Joy","Sadness",
           "Surprise","Trust","Negative")
colors <- c("green","red","blue","orange","red","green","orange","blue","green","red")
yRange <- range(0,yAxis)
bp <- barplot(yAxis, names.arg = xAxis, xlab = "Emotional valence", ylab = "Score", main = "Twitter sentiment", sub = "Ipl", col = colors, border = "black", xpd = F, ylim = yRange, axisnames = T, cex.axis = 0.8, cex.sub = 0.8, col.sub = "blue")
text(bp, 0, round(yAxis,1), cex = 0.8, pos = 3)
bp

# Sentiment Analysis : Plot by date - understanding cummulative sentiment score movement 
mysentimentvalues <- data.frame(get_sentiment((tweets.df$text)))
colnames(mysentimentvalues)<-"polarity"
mysentimentvalues$date <- tweets.df$created

result <- aggregate(polarity ~ date, data = mysentimentvalues, sum)
result
plot(result, type = "l")

# Sentiment Analysis: Plot by date - Understanding average sentiment score movement 
result1 <- aggregate(polarity ~ date, data = mysentimentvalues, mean)
result1
plot(result1, type = "l")


#################################################################
# correlation chart of top keywords, including word association
#################################################################
# Find association with a specific keyword in the tweets - vivoipl,covid
list1<- findAssocs(tdm, "vivoipl", 0.25)
corrdf1 <- t(data.frame(t(sapply(list1,c))))
corrdf1
barplot(t(as.matrix(corrdf1)), beside=TRUE,xlab = "Words",ylab = "Corr",col = "blue",main = "vivoipl",border = "black")

list1<- findAssocs(tdm, "covid", 0.20)
corrdf1 <- t(data.frame(t(sapply(list1,c))))
corrdf1
barplot(t(as.matrix(corrdf1)), beside=TRUE,xlab = "Words",ylab = "Corr",col = "green",main = "covid",border = "black")

# Topic Modelling to identify latent/hidden topics using LDA technique
dtm <- as.DocumentTermMatrix(tdm)
rowTotals <- apply(dtm , 1, sum)
NullDocs <- dtm[rowTotals==0, ]
dtm   <- dtm[rowTotals> 0, ]

if (length(NullDocs$dimnames$Docs) > 0) {
  tweets.df <- tweets.df[-as.numeric(NullDocs$dimnames$Docs),]
}
lda <- LDA(dtm, k = 5) # find 5 topic
term <- terms(lda, 7) # first 7 terms of every topic
(term <- apply(term, MARGIN = 2, paste, collapse = ", "))

topics<- topics(lda)
topics<- data.frame(date=(tweets.df$created), topic = topics)
qplot (date, ..count.., data=topics, geom ="bar", fill= term[topic], position="stack")



