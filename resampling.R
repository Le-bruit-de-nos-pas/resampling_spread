library(tidyverse)
library(data.table)
library(mosaic)


# STOCKS ---------------------------


DIA_Flows_Aux_Long <- fread("DIA Analysis Results 1.1/DIA_Flows_Aux_Long.txt", integer64 = "character", stringsAsFactors = F)

Treatment_exp_Vector <- fread("DIA Analysis Results 1.1/Treatment_exp_Vector.txt", integer64 = "character", stringsAsFactors = F)

DIA_Flows_Aux_Long <- merge(Treatment_exp_Vector, DIA_Flows_Aux_Long, all=FALSE)

DIA_Flows_Aux_Long <- DIA_Flows_Aux_Long[DIA_Flows_Aux_Long$p2 == 60, c("patient", "weight", "s1", "s2")]

DIA_Flows_Aux_Long[ , .(group_sum = round(sum(as.numeric(weight)))), by = s2] 


df <- DIA_Flows_Aux_Long

Pop <- df[ , .(round(sum(as.numeric(weight))))] 

Stocks <- c("x", "I", "S", "D", "b", "d", "G", "g")


start_time <- Sys.time()

Stock <- Stocks[1]

Stock_size <- df[ df$s2==Stock, .(round(sum(as.numeric(weight))))] 

phat <- length(unique(df$patient[df$s2==Stock])) / length(unique(df$patient))

bootstrap_phat <- do(100) * prop(~s2==Stock, data=resample(df, R = 10000))

dim(bootstrap_phat)[1]
head(bootstrap_phat)
names(bootstrap_phat)
mean(bootstrap_phat$prop_TRUE) ; phat

bootstrap_phat %>%
  ggplot(aes(100*prop_TRUE)) +
  geom_histogram(fill = "deepskyblue4", alpha = 0.7) +
  theme_minimal() +
  xlab(paste("\n Proportion ON Stock", Stock)) + ylab("(Re)sampling Count \n")

SE <- sd(bootstrap_phat$prop_TRUE)

Lower <- phat-2*SE
Upper <- phat+2*SE

paste(round(Stock_size*Lower/phat), 
      paste(round(Stock_size), 
            round(Stock_size*Upper/phat )))

paste( round(100 * (round(Stock_size)- round(Stock_size*Lower/phat) ) / round(Stock_size) , 2 ), "%")

end_time <- Sys.time()

end_time - start_time



# FLOWS ------------------------------------




DIA_Flows_Aux_Long <- fread("DIA Analysis Results 1.1/DIA_Flows_Aux_Long.txt", integer64 = "character", stringsAsFactors = F)

Treatment_exp_Vector <- fread("DIA Analysis Results 1.1/Treatment_exp_Vector.txt", integer64 = "character", stringsAsFactors = F)

DIA_Flows_Aux_Long <- merge(Treatment_exp_Vector, DIA_Flows_Aux_Long, all=FALSE)

DIA_Flows_Aux_Long <- DIA_Flows_Aux_Long[DIA_Flows_Aux_Long$p2 >= 49 & flow==1, c("weight", "s1", "s2")]

DIA_Flows_Aux_Long[ , .(group_sum = round(sum(as.numeric(weight)))), by = s2] 

df <- DIA_Flows_Aux_Long


Origin <- "x"
Dest  <- "b"

start_time <- Sys.time()

Pop <- df[ s1==Origin, .(round(sum(as.numeric(weight))))]

df[ s1==Origin &  s2==Dest, .(round(sum(as.numeric(weight))))]

Flow_size <- df[ s1==Origin & s2==Dest , .(round(sum(as.numeric(weight))))]

phat <- dim(df[ df$s1==Origin & df$s2==Dest, ])[1] / dim(df[s1==Origin,])[1]

bootstrap_phat <- do(100) * prop(~(s1==Origin & s2==Dest), data=resample(df, R = 100))

dim(bootstrap_phat)[1]
head(bootstrap_phat)
names(bootstrap_phat)
mean(bootstrap_phat$prop_TRUE) ; phat


# bootstrap_phat %>%
#   ggplot(aes(100*prop_TRUE)) +
#   geom_histogram(fill = "deepskyblue4", alpha = 0.7) +
#   theme_minimal() +
#   xlab(paste("\n Proportion Doing Target Flow")) + ylab("(Re)sampling Count \n")

SE <- sd(bootstrap_phat$prop_TRUE)

Lower <- phat-2*SE
Upper <- phat+2*SE

paste(round(Flow_size*Lower/phat), paste(round(Flow_size), round(Flow_size*Upper/phat)))

paste( round(100 * (round(Flow_size)- round(Flow_size*Lower/phat) ) / round(Flow_size) , 2 ), "%")

end_time <- Sys.time()

end_time - start_time
