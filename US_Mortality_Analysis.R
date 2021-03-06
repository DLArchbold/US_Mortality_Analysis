## -----------------------------------------------
#install.packages(c("maps", "mapdata"))
#install.packages(c("ggplot2", "devtools", "dplyr", "stringr"))
#install.packages(c("ggplot2"))
#install.packages(c("devtools"))
#install.packages(c("dplyr"))
#install.packages(c("stringr"))

#devtools::install_github("dkahle/ggmap")


## -----------------------------------------------

datas <- read.csv("NCHS_-_Leading_Causes_of_Death__United_States.csv")
library(tidyverse)
library(mapdata)
library(ggplot2)
library(ggmap)
library(maps)
datas

## -----------------------------------------------

k<- subset(datas, State == "United States" &Cause.Name == "All causes")
print(k)
k<- subset(k, Cause.Name == "All causes")
print(k)
#k<-with(datas, order(Year))
k<-datas[order(k$Year),]
print(k)
#k<- k[k, order(Year)]
print(typeof(k))




## -----------------------------------------------
test <- datas
#Subset according to rows for rows where Cause.Name is "All causes" AND where State is "United States"
test <- subset(test, Cause.Name == "All causes" )
test <- subset(test, State == "United States")
#Order/sort according to the Year column, display rows
test <- test[with (test,order(Year)),]
test

#Group by x var (Year)
ggplot(data=test, aes(x=Year, y=Age.adjusted.Death.Rate, group=1)) +
  geom_line()+
  geom_point()
ggplot(data=test, aes(x=Year, y=Deaths, group=1)) +
  geom_line()+
  geom_point()


## -----------------------------------------------
test <- datas
test <- subset(test, Cause.Name != "All causes")
test <- subset(test, State == "United States")
test <- test[with (test,order(Year)),]
test = subset(test, select = -c(X113.Cause.Name,State))#remove extra column
test

#Group by Cause.Name, color automatically does that without group argument
ggplot(data=test, aes(x=Year, y=Age.adjusted.Death.Rate, )) +
  geom_line()+
  geom_point()
ggplot(data=test, aes(x=Year, y=Deaths, color=Cause.Name)) +
  geom_line()+
  geom_point()



## -----------------------------------------------
#Reference link:https://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html

#combine all region
td<-subset(datas, Cause.Name != "All causes")
td <- aggregate(x= td$Deaths, by=list(td$State),
          FUN=sum)

colnames(td) = c("region", "Deaths")
td$region <- tolower(td$region)
#to remove united states deaths count
td<-subset(td, region != "united states")

td # total deaths dataset grouped by region/state w/o total United States death count

#import usa map data (Geographical outlines converted into data frames)
states <- map_data("state")
states #usa map data
#Join states dataset and td according to the "region" column
tdpoly <- inner_join(states, td, by = "region")
tdpoly 

#make usa ggplot map (Plot empty US map)
usa <- ggplot(data = states, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(color = "black", fill = NA) #Fill is not mapped to anything (could be mapped to each states/regions eg: California and New York), and state lines are black (could be any other color)
usa

# get the state border back on top
# usa <- usa + 
#   theme_nothing()  #remove axes and gray background 
# usa

#Remove axes without removing legend
ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
  )


# output <- usa + 
#     geom_polygon(data = tdpoly, aes(fill = Deaths), color = "green") + 
#     geom_polygon(color = "white", fill = NA) + #re-color state lines to white bcs fill for deaths per state/region is dark
#     ditch_the_axes


#Plot total deaths for each state/region
output <- usa + 
    geom_polygon(data = tdpoly, aes(fill = Deaths), color = "white") + #re-color state lines to white bcs fill for deaths per state/region is dark
    ditch_the_axes

#no need to change scale because differences in deaths per state/region are obvious by color
#output + scale_fill_gradient(trans = "log10")
output

maxd <- max(td$Deaths)

#Use more colors
output2 <- output + 
    scale_fill_gradientn(colours = rev(rainbow(7)),
                         limits = c(min(td$Deaths), maxd),
                         #breaks = c(0, maxd*0.2, maxd*0.4, maxd*0.6, maxd*0.8, maxd) ,
                         )
output2



# 
# output3 <- output + scale_fill_gradient(limits = c(min(td$Deaths), maxd))
# output3


## -----------------------------------------------
sum(td$Deaths)
max(td$Deaths)
tdd<-subset(td, region != "united states")
sum(tdd$Deaths)


## -----------------------------------------------
# #-------------------------testing--------------
#Test alabama first?
# 
# alabama <- filter(datas, State == "Alabama" & Cause.Name != "All causes" )
# alabama_2017 <- filter(alabama, Year == 2017)
# alabama_2017_max_dr<- arrange(alabama_2017, desc(Age.adjusted.Death.Rate))
# alabama_2017_max_dr[1, ]
# 
# 
# 
# by_year<-alabama %>% group_by(Year)
# by_year
# 
# 
# 
# by_year %>% summarise(
#   Deaths = max(Deaths),
#   Cause.Name
#   
# )
# 
# summarise(
#   select(
#     group_by(alabama, Year),
#     Cause.Name
#   
#   )
# 
# )
# 
# 
# 
# alabama %>%
#   group_by(Year) %>%
#   select(Deaths, Cause.Name) %>%
#   summarise(
#     Deaths = max(Deaths)
#     
#   )

# #Sort by desc Deaths so that disease with most death has row on top of table grouped by year
# alabama_sorted<- arrange(alabama, Year, desc(Deaths))
# head(alabama_sorted, 6)
# 
# #Get the disease with most deaths grouped by year
# most_yearly<-alabama_sorted %>%
#   group_by(Year) %>%
#   summarise(
#     Deaths = max(Deaths),
#     Cause.Name = first(Cause.Name)
#   )
# 
# #Get most frequent Cause.Name
# mode <-most_yearly %>%
#   group_by(Cause.Name)%>%
#   mutate(N = n()) %>%
#   ungroup() %>%
#   filter(N == max(N))
# 
# mode <- mode[1, ]
# most <- mode$Cause.Name
# 
# 
# #-------------------------testing--------------
# 
# #--------------add df records-------------------------
# 
# test_mode <- data.frame(
#   id= c(1, 2, 3, 4, 5, 6),
#   name = c("heart", "kidney", "kidney", "heart", "heart", "none")
# )
# 
# 
# 
# 
# testing <- data.frame(
#   id= character(),
#   name= character()
# 
# )
# 
# test_mode %>% add_row(id = 7, name = "bone")
# test_mode
# 
# 
# 
# test_mode %>%
#   group_by(name)%>%
#   mutate(N = n()) %>%
#   ungroup() %>%
#   filter(N == max(N))

# #--------------add df records-------------------------


# #--------------get mode CoD per state-------------------------

# 
# #Sort by desc Deaths so that disease with most death has row on top of table grouped by year
# alabama_sorted<- arrange(alabama, Year, desc(Deaths))
# head(alabama_sorted, 6)
# 
# #Get the disease with most deaths grouped by year
# most_yearly<-alabama_sorted %>%
#   group_by(Year) %>%
#   summarise(
#     Deaths = max(Deaths),
#     Cause.Name = first(Cause.Name)
#   )
# 
# #Get most frequent Cause.Name
# mode <-most_yearly %>%
#   group_by(Cause.Name)%>%
#   mutate(N = n()) %>%
#   ungroup() %>%
#   filter(N == max(N))
# 
# mode <- mode[1, ]
# most <- mode$Cause.Name

# #--------------get mode CoD per state-------------------------



## -----------------------------------------------

#------------------------Get most common cause of death per state-----------




all_states = unique(datas$State)

state_cause <- data.frame(
  state = character(),
  cause = character()

)


z = 1
for( i in all_states){

  ind_state <- filter(datas, State == i & State != "United States" & Cause.Name != "All causes" )
  ind_state_sorted <- arrange(ind_state, Year, desc(Age.adjusted.Death.Rate))
  
  most_yearly<-ind_state_sorted %>%
  group_by(Year) %>%
  summarise(
    Age.adjusted.Death.Rate = max(Age.adjusted.Death.Rate),
    Cause.Name = first(Cause.Name)
  )
  
  mode <-most_yearly %>%
  group_by(Cause.Name)%>%
  mutate(N = n()) %>%
  ungroup() %>%
  filter(N == max(N))
  
  mode <- mode[1, ]
  most <- mode$Cause.Name
  
  state_cause <- state_cause %>% add_row(state = i, cause = most)
  # if(z == 10 || z== 20 || z==30 || z == 40){
  #   print(state_cause)
  # }
  # z = z+1

}

#------------------------Get most common cause of death per state-----------
#------------------------Mapping-----------

state_cause <- filter(state_cause, state!="United States")
state_cause


#cols: state, cause
state_cause_mode = state_cause

colnames(state_cause) = c("region", "mode_cause")
state_cause$region <- tolower(state_cause$region)

#state_cause 

#import usa map data (Geographical outlines converted into data frames)
states <- map_data("state")
#states #usa map data
#Join states dataset and state_cause according to the "region" column
state_cause_poly <- inner_join(states, state_cause, by = "region")
#state_cause_poly

#make usa ggplot map (Plot empty US map)
usa <- ggplot(data = states, mapping = aes(x = long, y = lat, group = group)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = NA) #Fill is not mapped to anything (could be mapped to each states/regions eg: California and New York), and state lines are black due to local mapping (could be any other color)
#usa

#Remove axes without removing legend
ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
  )


#Plot most common cause of death for each state
output <- usa +
    geom_polygon(data = state_cause_poly, aes(fill = mode_cause), color = "white") + #color state-lines white to differentiate states
    labs(fill = "Most common cause of death")+
    ditch_the_axes


output
#------------------------Mapping-----------



## -----------------------------------------------

#------------------------Get yearly death rates for each state for most lethal disease-----------
all_states = unique(datas$State)
state_cause_mode =state_cause_mode

death_rate_yearly_10 <- data.frame(
  year = numeric(),
  state = character(),
  cause = character(),
  rate = numeric()
  
)

death_rate_yearly_5 <- data.frame(
  year = numeric(),
  state = character(),
  cause = character(),
  rate = numeric()
  
)

death_rate_yearly_0 <- data.frame(
  year = numeric(),
  state = character(),
  cause = character(),
  rate = numeric()
  
)



j = 1
for(i in 1:length(all_states)){
  cur_row <- filter(state_cause_mode, state == all_states[i])
  mode_cause <- cur_row[1,2]
  one_state_one_disease_all_years_death_rate = filter(datas, State == all_states[i], Cause.Name == mode_cause )
  one_state_one_disease_all_years_death_rate = select(one_state_one_disease_all_years_death_rate, Year, State, Cause.Name, Age.adjusted.Death.Rate)
  
  
   dec_year <- arrange(one_state_one_disease_all_years_death_rate, desc(Year))
  latest_death_rate <- dec_year[1,4]
  #print(latest_death_rate)
 
    lowest_death_rate <- arrange(dec_year, Age.adjusted.Death.Rate)
    lowest_death_rate<- lowest_death_rate[1, 4]
    # print(lowest_death_rate)
    
    
    #Some states like Montana/Utah/Vermont look like lowest_death_rate == latest_death_rate using geom_smooth, but in actual fact using a geom_line plot can see that lowest is actually < latest
    if(all_states[i] == "Montana"){
      print(one_state_one_disease_all_years_death_rate)
      p<-ggplot(data = one_state_one_disease_all_years_death_rate, mapping = aes(x = Year, y = Age.adjusted.Death.Rate, color = State))+
     geom_line()
    print(p)
    } 
    
    
    #Use lowest_death_rate <latest_death_rate - (variable) to filter out states negligible increases in death rate
    #The smaller (variable) is, the more that states with smaller increases show
     if(all_states[i] != "United States" & lowest_death_rate <latest_death_rate-10){
      death_rate_yearly_10<-rbind(death_rate_yearly_10, one_state_one_disease_all_years_death_rate)
     }
    
     if(all_states[i] != "United States" & lowest_death_rate <latest_death_rate-5){
      death_rate_yearly_5<-rbind(death_rate_yearly_5, one_state_one_disease_all_years_death_rate)
     }
  
     if(all_states[i] != "United States" & lowest_death_rate <latest_death_rate){
      death_rate_yearly_0<-rbind(death_rate_yearly_0, one_state_one_disease_all_years_death_rate)
     }
 
  # if(i == "Colorado"){
  #   print(one_state_one_disease_all_years_death_rate)
  # }
  # j=j+1
  # 

  
}

#------------------------Visualize-----------
p<-ggplot(data = death_rate_yearly_10, mapping = aes(x = Year, y = Age.adjusted.Death.Rate, color = State))+
     geom_smooth(se=FALSE)
    print(p)
    
    
p<-ggplot(data = death_rate_yearly_5, mapping = aes(x = Year, y = Age.adjusted.Death.Rate, color = State))+
 geom_smooth(se=FALSE)
print(p)

p<-ggplot(data = death_rate_yearly_0, mapping = aes(x = Year, y = Age.adjusted.Death.Rate, color = State))+
 geom_smooth(se=FALSE)
print(p)

 
    
    
#------------------------Visualize-----------  
#------------------------Get yearly death rates for each state for most lethal disease-----------






## -----------------------------------------------
#combine all region
death_rate<-subset(datas, Cause.Name != "All causes")
death_rate
death_rate <- aggregate(x= death_rate$Age.adjusted.Death.Rate, by=list(death_rate$State),FUN=sum)
# 
colnames(death_rate) = c("region", "Age.adjusted.Death.Rate")
death_rate$region <- tolower(death_rate$region)
#to remove united states deaths rates
death_rate<-subset(death_rate, region != "united states")

death_rate # total death rates dataset grouped by region/state w/o total United States death rates

#import usa map data (Geographical outlines converted into data frames)
states <- map_data("state")
states #usa map data
#Join states dataset and td according to the "region" column
death_rate_poly <- inner_join(states, death_rate, by = "region")
death_rate_poly

#make usa ggplot map (Plot empty US map)
usa <- ggplot(data = states, mapping = aes(x = long, y = lat, group = group)) +
  coord_fixed(1.3) +
  geom_polygon(color = "black", fill = NA) #Fill is not mapped to anything (could be mapped to each states/regions eg: California and New York), and state lines are black (could be any other color)
usa

#Remove axes without removing legend
ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
  )


#Plot total deaths for each state/region
output <- usa +
    geom_polygon(data = death_rate_poly, aes(fill = Age.adjusted.Death.Rate), color = "white") + #re-color state lines to white bcs fill for death rate per state/region is dark
  labs(fill = "Death rate distribution")  +
  ditch_the_axes

output


## -----------------------------------------------

#Reference: http://www.sthda.com/english/wiki/correlation-test-between-two-variables-in-r

head(datas, 6)

whole_us <- subset(datas, State == "United States")
head(whole_us, 6)
causes <- unique(datas$Cause.Name)
causes
whole_us_heart_disease <- subset(whole_us, Cause.Name == "Heart disease")
head(whole_us_heart_disease, 6)
whole_us_kidney_disease <- subset(whole_us, Cause.Name == "Kidney disease")
head(whole_us_kidney_disease, 6)

whole_us_kidney_and_heart <- inner_join(whole_us_heart_disease, whole_us_kidney_disease, by = "Year")
whole_us_kidney_and_heart <- whole_us_kidney_and_heart[order(whole_us_kidney_and_heart$Year),]
#test <- test[with (test,order(Year)),]
head(whole_us_kidney_and_heart, 6)



par(mfrow = c(1, 2), xpd = F)
qqnorm(whole_us_kidney_and_heart$Deaths.x, main = "Q-Q plot", cex.main = 0.85)
qqline(whole_us_kidney_and_heart$Deaths.x, col="blue")
qqnorm(whole_us_kidney_and_heart$Deaths.y, main = "Q-Q plot", cex.main = 0.85)
qqline(whole_us_kidney_and_heart$Deaths.y, col="blue")






## -----------------------------------------------


whole_us_kidney_and_heart <- whole_us_kidney_and_heart[order(whole_us_kidney_and_heart$Year),]
whole_us_kidney_and_heart
res<- cor.test(whole_us_kidney_and_heart$Deaths.x, whole_us_kidney_and_heart$Deaths.y, method= "pearson")

res

