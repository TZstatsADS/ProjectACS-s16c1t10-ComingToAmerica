#setwd("/Volumes/HDD Data/Chenlu files/Courses/Columbia/W4249/project1")
# run the above line first before calling a function inside this file

prepare_data <- function(){
  population <- read.csv("data/Chenlu.csv")
  return(population)
}

# total population
total <- function(population){
  tally(population, wt = PWGTP)
}

# English speaking ability
Eng_Pie <- function(population){
 nonnative0 <- population
 
 # Count number of different English levels
 cot <- count(nonnative0, ENG,  wt = PWGTP, sort = FALSE)
 cot2 <- cot$n
 
 #plot pie chart
 slices <- c(cot2[1], cot2[2], cot2[3], cot2[4]) 
 lbls <- c("Very well", "Well", "Not well", "Not at all")
 
 cols = brewer.pal(4, "Set3")
 percentage <- round(100*slices/sum(slices), 1)
 text <- c("Very well: ", "Well: ", "Not well: ", "Not at all: ")
 perlabels <- paste(text, percentage, "%", sep="")
 par(mfrow=c(1,1)) 
 png(filename = "figs/Eng.png", width = 680, height = 480)
 pie3D(slices, radius = 1.2, shade = 0.8, theta = 0.8, start = -0.1, border = "white",
       col = cols, main = "Pie Chart of Ability to Speak English", 
       labels = perlabels, labelrad = 1.3, labelcex = 1.2)
 #dev.copy(png, "figs/Eng.png")
 dev.off()
 }

Time_Series <- function(population){
  nonnative0 <- population
  
  nonnativelist <- list()
  nonnativelist[[1]] <- nonnative0
  nonnativelist[[2]] <- filter(nonnative0, ENG %in% c(1, 2)) # English: Well
  nonnativelist[[3]] <- filter(nonnative0, ENG %in% c(3, 4)) # English: Not Well
  
  ##2 Count vs. year of entry
  cotyoeA <- count(nonnativelist[[2]], YOEP, wt = PWGTP, sort = FALSE)
  yearA <- cotyoeA$YOEP
  cotyoeA2 <- cotyoeA$n
  cotyoeB <- count(nonnativelist[[3]], YOEP, wt = PWGTP, sort = FALSE)
  yearB <- cotyoeB$YOEP
  cotyoeB2 <- cotyoeB$n
  png("figs/Number_Year.png")
  plot(yearA, cotyoeA2, type = "o", col = "darksalmon", main = "Number of Immigrants in Each Year", 
       xlab = "Year", ylab = "Number of Immigrants", xaxt="n")
  points(yearA, cotyoeA2, type = "o", pch = 19, col = "darksalmon")
  points(yearB, cotyoeB2, type = "o", pch = 19, col = "lightseagreen")
  axis(1, at = c(1920, 1940, 1960, 1980, 2000, 2013))
  legend("topleft", c("English Ability: Well", "English Ability: Not Well"), 
         fill = c("darksalmon", "lightseagreen"))
  #dev.copy(png, "figs/Number_Year.png")
  dev.off()
}

Sex_Decades <- function(population){
  ##3 SEX
  # note: inside a "for loop", we have to use print(ggplot()) in order to output figures 
  nonnative <- population
  nonnative$SEX <- factor(nonnative$SEX)
  levels(nonnative$SEX) <- c("Male", "Female")
  
  # DECADE (decade of entry)
  nonnative$DECADE <- factor(nonnative$DECADE)
  levels(nonnative$DECADE) <- c("~1950's", "1950's", "1960's", "1970's", "1980's", 
                                "1990's", "2000's~")

  # Get the counts for ordered DEXADE and SEX
  cotsex <- tally(group_by(nonnative, DECADE, SEX), wt = PWGTP)
  
  # Get labels and position of labels
  cotsex <- mutate(cotsex, Percent = paste0(sprintf("%.1f", n/sum(n) * 100), "%")) 
  cotsex <- mutate(cotsex, pos = cumsum(n) - 0.5 * n)
  
  # Print out the image
  png("figs/SEX_Decade.png")
  print(ggplot(cotsex, aes(x = DECADE, y = n)) + 
          geom_bar(aes(fill = SEX), stat = "identity") + scale_fill_brewer(palette = "Set2") +
          geom_text(aes(y = pos, label = Percent)) +
          ggtitle("Sex Ratio by Decade") + labs(x = "Decade", y = "Count") +
          theme(panel.background = element_rect(fill = "lightsteelblue1")))
  #dev.copy(png, "figs/SEX_Decade.png")
  dev.off()
}

Age_Decades <- function(population){
  nonnative <- population
  nonnative$DECADE <- factor(nonnative$DECADE)
  levels(nonnative$DECADE) <- c("~1950's", "1950's", "1960's", "1970's", "1980's", 
                                "1990's", "2000's~")
  ##4 Age group at immigrant decade
  nonnative$AGEE <- nonnative$AGEP - (2013-nonnative$YOEP) # age at entry
  nonnative$AGEG <- rep(0, nrow(nonnative)) # what does rep mean?
  nonnative$AGEG <- ifelse(nonnative$AGEE >= 0 & nonnative$AGEE < 10, 0, nonnative$AGEG)
  nonnative$AGEG <- ifelse(nonnative$AGEE >= 10 & nonnative$AGEE < 20, 1, nonnative$AGEG)
  nonnative$AGEG <- ifelse(nonnative$AGEE >= 20 & nonnative$AGEE < 30, 2, nonnative$AGEG)
  nonnative$AGEG <- ifelse(nonnative$AGEE >= 30 & nonnative$AGEE < 40, 3, nonnative$AGEG)
  nonnative$AGEG <- ifelse(nonnative$AGEE >= 40 & nonnative$AGEE < 50, 4, nonnative$AGEG)
  nonnative$AGEG <- ifelse(nonnative$AGEE >= 50 & nonnative$AGEE < 60, 5, nonnative$AGEG)
  nonnative$AGEG <- ifelse(nonnative$AGEE >= 60, 6, nonnative$AGEG)
  nonnative$AGEG <- factor(nonnative$AGEG)
  levels(nonnative$AGEG) <- c("0's", "10's", "20's", "30's", "40's", "50's", "60's~")
  png("figs/Age_entry.png")
  print(ggplot(nonnative, aes(x=DECADE)) + 
          geom_bar(aes(fill=AGEG, weight = PWGTP), position="fill") +
          ggtitle("Age Group at Immigrant Decade") + labs(x = "Decade", y = "Fraction"))
  #dev.copy(png, "figs/Age_entry.png")
  dev.off()
}