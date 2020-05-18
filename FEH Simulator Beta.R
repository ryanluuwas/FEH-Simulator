library(dplyr)
library(ggplot2)

# FEH SUMMON SIMULATOR;

# Set Number of Simulations to run
n <- 10000

# If regular banner, set to False. If Legendary Banner, set to true. 
legendary_banner <- F

# Start of Simulation
for (start in 1:n) {
  
  #------------ Creating Initial Variables ----------------#
  
  # Stores Number of Orbs spent
  OrbSpent <- 0
  
  # 11 = one base + 10 merges. 
  Focus_summon_rqt <- 11
  
  # Will use later in the code to calculate the number of color troll summons
  goal <- Focus_summon_rqt
  
  # Because no summons occured, pity_try is at 0. Everytime you get a non-5 * unit, add to pity_try
  pity_try = 0
  
  # Adjusts probability rates based on banner
  # Add a "dummy' unit of each type in units vector. Sometimes in simulation, you do not get a particular unit and it messes up the columns. 
  if (legendary_banner == FALSE){
    p_focus <- 5
    p_non_focus <- 3
    units <- c("Focus","Non-Focus","Off-Color Focus", "Off-Color Non-Focus", "Trash")
  } else if (legendary_banner == TRUE){
    p_focus <- 8
    p_non_focus <- 0
    units <- c("Legendary 1", "Legendary 2", "Legendary 3", "Off-Color Legendary 1", "Off-Color Legendary 2", "Off-Color Legendary 3", "Trash")
  }
  
  # Function to convert Number into Color
  color_conv <- function(color) {
    i <- gsub(1, "red", color)
    i <- gsub(2, "blue", i)
    i <- gsub(3, "green", i)
    return(gsub(4, "colorless", i))
  }
  
  #---------------------------------------------------------#
  
  # Create a 'session' variable to track how many summoning sessions take place
  session <- 0
  
  # Modify How many Summoning Sessions to Occur. Will keep running until you get 10 DESIRED focus units 
  while (Focus_summon_rqt != 0) {
    
    print("--------------------------------")
    session = session + 1
    print(paste("Summonning Session:", session))
    
    # Because each Summoning Session has 5 Colors, Take 5 Samples, Because there are 4 colors, take numbers 1-4;
    color <- sample(1:4,5, replace = T)
    
    # Use the custom color_conv function to transform the number into Colors: 1 = red, 2 = blue, 3 = green, 4 = colorless
    circle <- color_conv(color)
    
    print("Colors in the Circle:")
    print(circle)
    
    # Empty Vector; Will Count the number of Target Color you want; If 2 red occur in summoning circle, target <- c('red','red')
    target <- c()
    
    # Loops in the summoning circle. Takes the color you want and adds it into a vector
    for (y in circle) {
      if (y == "red") {
        target <- c(target, y)
      } 
    }
    
    # Counts the desired color in the vector
    n.summon <- length(target)
    
    # If you open a summoning session and there are no desired colors, you got color trolled. Set default to False
    troll <- FALSE
    
    # In FEH, you can't back out of a summoning session. If there are no desired colors, then number of summons = 1
    if (n.summon == 0){
      n.summon <- 1
      # Because You got trolled, set troll varibale to TRUE
      troll <- TRUE
    }
    
    print(paste("Number of Summons: ",n.summon))
    
    # In FEH, for every 5 'Fodder Summons", increase the chance of both Focus and Non-Focus unit by 0.25. For legendary, pity increase by 0.5
    if (legendary_banner == FALSE){
      pity_incr <- floor(pity_try/5)
      pity <- 0.25 * pity_incr
    } else if(legendary_banner == TRUE){
      pity_incr <- floor(pity_try/5)
      pity <- 0.5 * pity_incr
    }
    
    # Actual Summoning Simulation
    for (x in 1:n.summon) { 
      
      # Orbs Spent; First Summon in a Session Costs 5 orbs. Second, third, and Fourth costs 4. 5th Sessions cost 5.
      if (x == 1) {
        print("--------------------------------")
        print("Spending 5 Orbs")
        OrbSpent <- OrbSpent - 5
        
      } else if(x >= 2 & x < 5){
        print("--------------------------------")
        print("Spending 4 Orbs")
        OrbSpent <- OrbSpent - 4
        
      } else {
        print("--------------------------------")
        print("Spending 3 orbs")
        OrbSpent <- OrbSpent - 3
      }
      
      # UNIT RNG from a scale of 1.00-100.00  
      rng <- sample(1:10000,1, replace = T)/100
      
      if (legendary_banner == FALSE){
        print(paste("Roll", rng, "| Focus Rate: ", (p_focus + pity), "; Non Focus Rate:", (p_non_focus + pity)))
      } else if (legendary_banner == TRUE){
        print(paste("Roll", rng, "| Focus Rate: ", (p_focus + pity)))
      }
      
      # DETERMINING FOCUS, NON-FOCUS, AND FODDER
      # If RNG is <= Focus + Pity Rate, add Focus Unit; If Focus + Pity Rate < RNG < Focus + Non_Focus + Pity + Pity; else Fodder
      
      # For Normal Banners (test)
      if (legendary_banner == FALSE){
        if (rng <= p_focus + pity & troll == FALSE) {
          units <- c(units, "Focus")
          print("Adding 5* Focus Unit to Barrack")
          pity_try <- 0
          Focus_summon_rqt = Focus_summon_rqt - 1
          
        } else if (rng > p_focus + pity & rng < p_focus + p_non_focus + pity + pity & troll == FALSE){
          units <- c(units, "Non-Focus")
          print("Adding 5* Non-Focus Unit to Barrack")
          pity_try <- 0
          
        } else if (rng <= p_focus + pity & troll == TRUE){
          units <- c(units, "Off-Color Focus")
          print("Adding 5* Off-Color Focus Unit to Barrack")
          pity_try <- 0
          
        } else if (rng > p_focus + pity & rng < p_focus + p_non_focus + pity + pity & troll == TRUE){
          units <- c(units, "Off-Color Non-Focus")
          print("Adding 5* Off-Color Non-Focus Unit to Barrack")
          pity_try <- 0
          
        } else {
          units <- c(units, "Trash")
          print("Adding 3*/4* Unit to Barrack")
          pity_try <- pity_try + 1
        }
      }

      # For Legendary Banner
      
      if (legendary_banner == TRUE){
        if (rng <= p_focus + pity) {
          chance <- sample(1:3,1, replace = T)
          
          if (chance == 1 & troll == FALSE){
            units <- c(units, "Legendary 1")
            print("Adding 5* Legendary to Barrack")
            pity_try <- 0
            Focus_summon_rqt = Focus_summon_rqt - 1
            
          } else if (chance == 2 & troll == FALSE){
            units <- c(units, "Legendary 2")
            print("Adding 5* Legendary 2 to Barrack")
            pity_try <- 0
          } else if (chance == 3 & troll == FALSE){
            units <- c(units, "Legendary 3")
            print("Adding 5* Legendary 3 to Barrack")
            pity_try <- 0
          } else if (chance == 1 & troll == TRUE){
            units <- c(units, "Off-Color Legendary 1")
            print("Adding Off-Color Legendary 1 to Barrack")
            pity_try <- 0
          } else if (chance == 2 & troll == TRUE){
            units <- c(units, "Off-Color Legendary 2")
            print("Adding Off-Color Legendary 2 to Barrack")
            pity_try <- 0
          } else if (chance == 3 & troll == TRUE){
            units <- c(units, "Off-Color Legendary 3")
            print("Adding Off-Color Legendary 3 to Barrack")
            pity_try <- 0
          }
          
        } else {
          units <- c(units, "Trash")
          print("Adding 3/4* Fodder Unit to Barrack")
          pity_try <- pity_try + 1
          
        } 
      }
      # Breaks while loop once focus_summon_rqt = 0
      if (Focus_summon_rqt == 0){
        break
      }
    }
  }
  
  print("--------------------------------")
  print("Summon Summary:")
  print(summary(as.factor(units)))
  print(paste("Orbs Spent:",abs(OrbSpent)))
  
  # On the first simulation, create a dataframe. If it's already created, append it
  if (start == 1){
    sim.df <- as.data.frame(summary(as.factor(units))) %>%
      rbind('OrbSpent' = c(abs(OrbSpent)))
    
    # For every simulation after the first one, add it to the exising simulation dataframe
  } 
  else if (start > 1) {
    
    i <- data.frame(summary(as.factor(units))) %>%
      rbind('OrbSpent' = c(abs(OrbSpent)))

    sim.df <- cbind(sim.df, i)
    
    # Once all the simulations finished running
    # when transposing, it converts it to atomic vector so make sure to convert it back to dataframe. Then convert row names to #'s
    if (start == n) {
      sim.df <- sim.df %>%
        t() %>%
        as.data.frame()
      
      # change the row names to numbers.
      row.names(sim.df) <- 1:nrow(sim.df)
      
      # Loop through each column in dataframe and subtract 1 (to remove dummy units)
      for (x in names(sim.df)){
        sim.df[[x]] <- sim.df[[x]] - 1
      }
      
      # Add 1 back to Trash and OrbSpent.
      sim.df$Trash <- sim.df$Trash + 1
      sim.df$OrbSpent <- sim.df$OrbSpent + 1
      
      # Prints first 10 Simulation Results
      print(paste(ifelse(legendary_banner == FALSE, 'Normal Banner','Legendary Banner'),'Simulation Results:'))
      print(head(sim.df, n =10))
    }
  }
}
#-------------------------------------------------------------------------------------------------------

# Writing to csv section

# Get Current Path
path <- getwd()

# Save csv file to data folder
write.csv(sim.df, file = paste(path,'/data/CYL_Banner_Simulation.csv', sep=""), row.names = F)

#-------------------------------------------------------------------------------------------------------

# Statistical Analysis here

# Read CSV
setwd("~/GitHub/FEH-Simulator")
CYL.df <- read.csv("data/CYL_Banner_Simulation.csv")
Focus.df <- read.csv("data/Focus_Banner_Simulation.csv")
Legendary.df <- read.csv("data/Legendary_Banner_Simulation.csv")

# Average orb spent to get 11 targeted Units

mean(CYL.df$OrbSpent) # On average, 1136 orbs to +10 a unit on CYL banner
mean(Focus.df$OrbSpent) # On average, 1749 orbs to +10 a unit Focus Banner
mean(Legendary.df$OrbSpent) # On average, 2095 orbs to +10 a unit Legendary Banner

sd(CYL.df$OrbSpent) # Standard Deviation is 325 orbs for CYL banner
sd(Focus.df$OrbSpent) # Standard Deviation is 491 orbs for Focus banner
sd(Legendary.df$OrbSpent) # Standard Deviation is 609 orbs for Legendary Banner


# ggplot
ggplot(master.df, aes(x = OrbSpent)) +
  geom_histogram(data = CYL.df,
                 aes(x = OrbSpent, y = ..count.., fill = 'CYL'),
                 bins = 50,
                 color = 'white',
                 alpha = 0.5) +
  geom_histogram(data = Focus.df,
                 aes(x = OrbSpent, y = ..count.., fill = 'Focus'),
                 bins = 50,
                 color = 'white',
                 alpha = 0.5) +
  geom_histogram(data = Legendary.df,
                 aes(x = OrbSpent, y = ..count.., fill = 'Legendary'),
                 bins = 50,
                 color = 'white',
                 alpha = 0.5) +
  theme_minimal() +
  scale_fill_manual(values = c("#FF0053", "#023FFF", "#02FFF1")) +
  labs(title = 'Orb Distribution of each Banner',
       x = 'Orb Spent',
       y = 'Frequency',
       fill = 'Banner Type')
