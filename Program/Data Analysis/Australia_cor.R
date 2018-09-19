library(data.table)     #fread 함수로 데이터를 받아오기 위해 사용.
library(lubridate)      #문자열 데이터를 시간 정보로 바꾸고 데이터를 추출하기 위해 사용.
library(ggplot2)        #그래프 그리기 용.
library(dplyr)
library(stringr)
library(plotly)         #인터렉티브 그래프 그리기 용.
library(corrplot)       #상관계수를 보기 좋게 그래프로 나타내기 용.

energy = fread("C:\\Users\\LHY\\Downloads\\example\\pe20161129-20171129.csv" , header = T,
               stringsAsFactors = T , data.table = F , na = "-")

climate = fread("C:\\Users\\LHY\\Downloads\\example\\w20161129-20171129.csv" , header = T,
                stringsAsFactors = T , data.table = F , na = "-")

join_data = left_join(climate , energy , by="time")
colnames(join_data) = c("time" , "airtemp" , "humidity" , "insolation" ,"windspeed" ,
                        "winddirection" , "power" , "energy")

join_data = join_data %>% filter(!is.na(power) & !is.na(energy))


imsi_data = join_data[,c("airtemp" , "humidity" , "insolation" , "windspeed" , "winddirection" , "power" , "energy")]
cor_cor = cor(imsi_data)
corrplot(cor_cor , method = "number")
