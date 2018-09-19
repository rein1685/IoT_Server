library(data.table)     #fread 함수로 데이터를 받아오기 위해 사용.
library(lubridate)      #문자열 데이터를 시간 정보로 바꾸고 데이터를 추출하기 위해 사용.
library(ggplot2)        #그래프 그리기 용.
library(dplyr)
library(stringr)
library(plotly)         #인터렉티브 그래프 그리기 용.
library(corrplot)       #상관계수를 보기 좋게 그래프로 나타내기 용.

energy = fread("C:\\Users\\LHY\\Downloads\\example\\pe20161129-20171129.csv" , header = T,
               stringsAsFactors = T , data.table = F , na = "-")

colnames(energy) = c("time" , "power" , "energy")
energy = energy %>% filter(!is.na(power) & !is.na(energy))

raw_time_data = unlist(str_split(energy$time , " "))
a = matrix(raw_time_data , ncol = 2 , byrow = T)


imsi_a = matrix(hour(strptime(a[,2] , format="%H:%M:%S" , tz = "EST5EDT")) , ncol=1)
a = cbind(a, imsi_a)
colnames(a) = c("date" , "time" , "hour")
a = data.frame(a)
a = a %>% select(-time)


total_data = cbind(a , energy)
total_data = total_data %>% select(-time)
total_data$hour = factor(total_data$hour , levels=c("5","6","7","8","9","10",
                                                    "11","12","13","14","15","16","17","18","19"))

imsi_data = total_data %>% group_by(hour) %>% summarise(power = mean(power))
ggplot(data = imsi_data , aes(x=hour , y = power)) + geom_col()

