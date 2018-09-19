library(data.table)     #fread 함수로 데이터를 받아오기 위해 사용.
library(lubridate)      #문자열 데이터를 시간 정보로 바꾸고 데이터를 추출하기 위해 사용.
library(ggplot2)        #그래프 그리기 용.
library(dplyr)
library(stringr)
library(plotly)         #인터렉티브 그래프 그리기 용.
library(corrplot)       #상관계수를 보기 좋게 그래프로 나타내기 용.

energy = fread("C:\\Users\\LHY\\Documents\\r_project\\output\\3\\22.csv" , header = T,
               stringsAsFactors = T , data.table = F , na = "-")

data = select(energy , -vol_bat , -Amp_solar , -Amp_bat, -created_at)
data = data %>% filter(vol_solar > 0)

cor_cor = cor(data)
corrplot(cor_cor , method = "number")

