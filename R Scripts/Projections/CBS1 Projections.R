###########################
# File: CBS1 Projections.R
# Description: Downloads Fantasy Football Projections from cbssports.com
# Date: 3/3/2013
# Author: Isaac Petersen (isaac@fantasyfootballanalytics.net)
# Notes:
# To do:
###########################

#Load libraries
library("XML")
library("stringr")
library("ggplot2")
library("plyr")

#Functions
source(paste(getwd(),"/R Scripts/Functions/Functions.R", sep=""))
source(paste(getwd(),"/R Scripts/Functions/League Settings.R", sep=""))

#Download fantasy football projections from cbssports.com
qb_cbs1 <- readHTMLTable("http://fantasynews.cbssports.com/fantasyfootball/stats/weeklyprojections/QB/season/jamey_eisenberg/standard", stringsAsFactors = FALSE)[7]$'NULL'
rb1_cbs1 <- readHTMLTable("http://fantasynews.cbssports.com/fantasyfootball/stats/weeklyprojections/RB/season/jamey_eisenberg/standard", stringsAsFactors = FALSE)[7]$'NULL'
rb2_cbs1 <- readHTMLTable("http://fantasynews.cbssports.com/fantasyfootball/stats/weeklyprojections/RB/season/jamey_eisenberg/standard?&start_row=51", stringsAsFactors = FALSE)[7]$'NULL'
rb3_cbs1 <- readHTMLTable("http://fantasynews.cbssports.com/fantasyfootball/stats/weeklyprojections/RB/season/jamey_eisenberg/standard?&start_row=101", stringsAsFactors = FALSE)[7]$'NULL'
wr1_cbs1 <- readHTMLTable("http://fantasynews.cbssports.com/fantasyfootball/stats/weeklyprojections/WR/season/jamey_eisenberg/standard", stringsAsFactors = FALSE)[7]$'NULL'
wr2_cbs1 <- readHTMLTable("http://fantasynews.cbssports.com/fantasyfootball/stats/weeklyprojections/WR/season/jamey_eisenberg/standard?&start_row=51", stringsAsFactors = FALSE)[7]$'NULL'
wr3_cbs1 <- readHTMLTable("http://fantasynews.cbssports.com/fantasyfootball/stats/weeklyprojections/WR/season/jamey_eisenberg/standard?&start_row=101", stringsAsFactors = FALSE)[7]$'NULL'
te_cbs1 <- readHTMLTable("http://fantasynews.cbssports.com/fantasyfootball/stats/weeklyprojections/TE/season/jamey_eisenberg/standard", stringsAsFactors = FALSE)[7]$'NULL'

#Add variable names for each object
names(qb_cbs1) <- c("player_cbs1","passAtt_cbs1","passComp_cbs1","passYds_cbs1","passTds_cbs1","passInt_cbs1","passCompPct_cbs1","passYdsPerAtt_cbs1","rushAtt_cbs1","rushYds_cbs1","rushYdsPerAtt_cbs1","rushTds_cbs1","fumbles_cbs1","pts_cbs1")
names(rb1_cbs1) <- names(rb2_cbs1) <- names(rb3_cbs1) <- c("player_cbs1","rushAtt_cbs1","rushYds_cbs1","rushYdsPerAtt_cbs1","rushTds_cbs1","rec_cbs1","recYds_cbs1","recYdsPerRec_cbs1","recTds_cbs1","fumbles_cbs1","pts_cbs1")
names(wr1_cbs1) <- names(wr2_cbs1) <- names(wr3_cbs1) <- c("player_cbs1","rec_cbs1","recYds_cbs1","recYdsPerRec_cbs1","recTds_cbs1","fumbles_cbs1","pts_cbs1")
names(te_cbs1) <- c("player_cbs1","rec_cbs1","recYds_cbs1","recYdsPerRec_cbs1","recTds_cbs1","fumbles_cbs1","pts_cbs1")

#Trim dimensions
qb_cbs1 <- qb_cbs1[3:(dim(qb_cbs1)[1]-1),]
rb1_cbs1 <- rb1_cbs1[3:(dim(rb1_cbs1)[1]-1),]
rb2_cbs1 <- rb2_cbs1[3:(dim(rb2_cbs1)[1]-1),]
rb3_cbs1 <- rb3_cbs1[3:(dim(rb3_cbs1)[1]-1),]
wr1_cbs1 <- wr1_cbs1[3:(dim(wr1_cbs1)[1]-1),]
wr2_cbs1 <- wr2_cbs1[3:(dim(wr2_cbs1)[1]-1),]
wr3_cbs1 <- wr3_cbs1[3:(dim(wr3_cbs1)[1]-1),]
te_cbs1 <- te_cbs1[3:(dim(te_cbs1)[1]-1),]

#Merge within position
rb_cbs1 <- rbind(rb1_cbs1,rb2_cbs1,rb3_cbs1)
wr_cbs1 <- rbind(wr1_cbs1,wr2_cbs1,wr3_cbs1)

#Add variable for player position
qb_cbs1$pos <- as.factor("QB")
rb_cbs1$pos <- as.factor("RB")
wr_cbs1$pos <- as.factor("WR")
te_cbs1$pos <- as.factor("TE")

#Merge across positions
projections_cbs1 <- rbind.fill(qb_cbs1, rb_cbs1, wr_cbs1, te_cbs1)

#Add variables from other projection sources
projections_cbs1$twoPts_cbs1 <- NA

#Convert variables from character strings to numeric
projections_cbs1[,c("twoPts_cbs1","fumbles_cbs1","pts_cbs1",
                   "rec_cbs1","recYds_cbs1","recYdsPerRec_cbs1","recTds_cbs1",
                   "rushAtt_cbs1","rushYds_cbs1","rushYdsPerAtt_cbs1","rushTds_cbs1",
                   "passAtt_cbs1","passComp_cbs1","passYds_cbs1","passTds_cbs1","passInt_cbs1","passCompPct_cbs1","passYdsPerAtt_cbs1")] <- convert.magic(projections_cbs1[,c("twoPts_cbs1","fumbles_cbs1","pts_cbs1",
                                                                                                                                                                      "rec_cbs1","recYds_cbs1","recYdsPerRec_cbs1","recTds_cbs1",
                                                                                                                                                                      "rushAtt_cbs1","rushYds_cbs1","rushYdsPerAtt_cbs1","rushTds_cbs1",
                                                                                                                                                                      "passAtt_cbs1","passComp_cbs1","passYds_cbs1","passTds_cbs1","passInt_cbs1","passCompPct_cbs1","passYdsPerAtt_cbs1")], "numeric")

#Player names
projections_cbs1$name_cbs1 <- str_sub(projections_cbs1$player, end=str_locate(string=projections_cbs1$player, ',')[,1]-1)
projections_cbs1$name <- nameMerge(projections_cbs1$name_cbs1)

#Remove Duplicates
projections_cbs1[projections_cbs1$name %in% projections_cbs1[duplicated(projections_cbs1$name),"name"],]
#projections_cbs1[projections_cbs1$name_cbs1 == "James Casey","pos"] <- "TE"

#Rename Players
#projections_cbs1[projections_cbs1$name_cbs1=="EJ Manuel", "name_cbs1"] <- "E.J. Manuel"

#Player teams
projections_cbs1$team_cbs1 <- str_trim(str_sub(projections_cbs1$player, start= -3))

#Calculate overall rank
projections_cbs1$overallRank_cbs1 <- rank(-projections_cbs1$pts_cbs1, ties.method="min")

#Calculate Position Rank
projections_cbs1$positionRank_cbs1 <- NA
projections_cbs1[which(projections_cbs1$pos == "QB"), "positionRank_cbs1"] <- rank(-projections_cbs1[which(projections_cbs1$pos == "QB"), "pts_cbs1"], ties.method="min")
projections_cbs1[which(projections_cbs1$pos == "RB"), "positionRank_cbs1"] <- rank(-projections_cbs1[which(projections_cbs1$pos == "RB"), "pts_cbs1"], ties.method="min")
projections_cbs1[which(projections_cbs1$pos == "WR"), "positionRank_cbs1"] <- rank(-projections_cbs1[which(projections_cbs1$pos == "WR"), "pts_cbs1"], ties.method="min")
projections_cbs1[which(projections_cbs1$pos == "TE"), "positionRank_cbs1"] <- rank(-projections_cbs1[which(projections_cbs1$pos == "TE"), "pts_cbs1"], ties.method="min")

#Order variables in data set
projections_cbs1 <- projections_cbs1[,c("name","name_cbs1","pos","team_cbs1","positionRank_cbs1","overallRank_cbs1",
                                      "passAtt_cbs1","passComp_cbs1","passYds_cbs1","passTds_cbs1","passInt_cbs1","passCompPct_cbs1","passYdsPerAtt_cbs1",
                                      "rushAtt_cbs1","rushYds_cbs1","rushYdsPerAtt_cbs1","rushTds_cbs1",
                                      "rec_cbs1","recYds_cbs1","recYdsPerRec_cbs1","recTds_cbs1","twoPts_cbs1","fumbles_cbs1","pts_cbs1")]

#Order players by overall rank
projections_cbs1 <- projections_cbs1[order(projections_cbs1$overallRank_cbs1),]
row.names(projections_cbs1) <- 1:dim(projections_cbs1)[1]

#Density Plot
ggplot(projections_cbs1, aes(x=pts_cbs1)) + geom_density(fill="red", alpha=.3) + xlab("Player's Projected Points") + ggtitle("Density Plot of CBS1 Projected Points from")
ggsave(paste(getwd(),"/Figures/CBS1 projections.jpg", sep=""), width=10, height=10)
dev.off()

#Save file
save(projections_cbs1, file = paste(getwd(),"/Data/CBS1-Projections.RData", sep=""))
write.csv(projections_cbs1, file=paste(getwd(),"/Data/CBS1-Projections.csv", sep=""), row.names=FALSE)

save(projections_cbs1, file = paste(getwd(),"/Data/Historical Projections/CBS1-Projections-2014.RData", sep=""))
write.csv(projections_cbs1, file=paste(getwd(),"/Data/Historical Projections/CBS1-Projections-2014.csv", sep=""), row.names=FALSE)
