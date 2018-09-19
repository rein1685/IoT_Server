library(data.table)     #fread 함수로 데이터를 받아오기 위해 사용.
library(lubridate)      #문자열 데이터를 시간 정보로 바꾸고 데이터를 추출하기 위해 사용.
library(ggplot2)        #그래프 그리기 용.
library(dplyr)
library(stringr)
library(plotly)         #인터렉티브 그래프 그리기 용.
library(corrplot)       #상관계수를 보기 좋게 그래프로 나타내기 용.

energy = fread("C:\\Users\\LHY\\Documents\\r_project\\output\\3\\22.csv" , header = T,
               stringsAsFactors = T , data.table = F , na = "-")

data = select(energy , -vol_bat , -Amp_solar , -Amp_bat)

raw_time_data = unlist(str_split(data$created_at , " "))
a = matrix(raw_time_data , ncol = 2 , byrow = T)

imsi_a = matrix(hour(strptime(a[,2] , format="%H:%M" , tz = "EST5EDT")) , ncol=1)
a = cbind(a, imsi_a)
colnames(a) = c("date" , "time" , "hour")
a = data.frame(a)
#a$hour = as.integer(a$hour)
a = a %>% select(-time)

total_data = cbind(a , data)
total_data = total_data %>% select(-created_at , -date)

total_data$hour = factor(total_data$hour , levels=c("0" , "1", "2", "3", "4", "5","6","7","8","9","10",
                                                    "11","12","13","14","15","16",
                                                    "17","18","19" , "20", "21", "22", "23"))

total_data = total_data %>% group_by(hour) %>% summarise(temp = mean(temp) , humidity = mean(humidity) ,
                                                                cds = mean(cds) , vol_solar = mean(vol_solar)) %>% arrange

imsi_data = total_data %>% group_by(hour) %>% summarise(vol_solar = mean(vol_solar))
ggplot(data = imsi_data , aes(x=hour , y = vol_solar)) + geom_col()
