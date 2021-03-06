library(plyr)
library(zoo)
library(lubridate)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/amy- built environment/data")
# import data -------------------------------------------------------------

  #merge vector, climate, cases by day/month/year
  load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/MonthlyClimate.rda")

  load(file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector/vector.rda")
  load(file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector/Monthlyvector.rda")
  
  load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")

# merge data -------------------------------------------------------------
  vector$date_bg <-ymd(vector$date_bg)
  class(vector$date_bg)
  vector$month_bg <- as.yearmon(vector$date_bg)
  R01_lab_results$city<-R01_lab_results$id_city
  
  R01_lab_results <- within(R01_lab_results, city[R01_lab_results$city=="L"] <- "m")
  R01_lab_results <- within(R01_lab_results, city[R01_lab_results$city=="O"] <- NA)
  R01_lab_results <- within(R01_lab_results, city[R01_lab_results$city=="R"] <- "c")
  R01_lab_results <- within(R01_lab_results, city[R01_lab_results$city=="G"] <- "m")
  R01_lab_results$city<-tolower(R01_lab_results$city)
  table(R01_lab_results$city)
  
  denv_monthly <- ddply(R01_lab_results, .(month_year, city),
                summarise, infected_denv_stfd_monthly = sum(infected_denv_stfd, na.rm = TRUE))
  denv<-R01_lab_results
  
  MonthlyClimate <- within(MonthlyClimate, city[MonthlyClimate$city=="o"] <- "k")
  

  denv <- within(denv, infected_denv_stfd[is.na(denv$month_year)] <- 0)
  denv <-denv[which(!is.na(denv$month_year)), ]
  denv$month_year<-as.Date(denv$month_year)
#lag vectors by two weeks  
  Monthlyvector$month_year<-as.Date(Monthlyvector$month_year)
  Monthlyvector$month_year_lag<-Monthlyvector$month_year-15

#lag rain by one month  
  MonthlyClimate$month_year<-as.Date(MonthlyClimate$month_year)
  MonthlyClimate$month_year_lag<-MonthlyClimate$month_year-31

  MonthlyClimate$month_year_lag<- as.yearmon(MonthlyClimate$month_year_lag)
  Monthlyvector$month_year_lag<- as.yearmon(Monthlyvector$month_year_lag)
  denv$month_year<- as.yearmon(denv$month_year)
  R01_lab_results$month_year<- as.yearmon(R01_lab_results$month_year)
  
  names(MonthlyClimate)[names(MonthlyClimate) == 'month_year'] <- 'month_year_climate'
  
  
  vector_climate_cases<-Monthlyvector
  vector_climate_cases<-merge(vector_climate_cases, denv, by.x = c("month_year_lag","city"), by.y = c("month_year","city"), all = T) 
  vector_climate_cases<-merge(vector_climate_cases, MonthlyClimate, by.x = c("month_year","city"), by.y = c("month_year_lag","city"), all = T)
  vector_climate_cases<-merge(vector_climate_cases, denv_monthly, by.x = c("month_year","city"), by.y = c("month_year","city"), all = T)
  save(vector_climate_cases, file="vector_climate_cases.rda")
  load("vector_climate_cases.rda")
#  model data-------------------------------------------------------------
  names <- c('roof_type' ,'house_id', "house_number", "city","floor_type","dem_water_source","latrine_type","light_source","dem_cooking_fuel")
  vector_climate_cases[,names] <- lapply(vector_climate_cases[,names] , factor)

  
  library(MASS)
  glm_nb<-glm.nb(infected_denv_stfd_monthly~ city + Ttl_Aedes.spp.Indoor.ovi + ttl_Aedes_spp_Outdoor.ovi + Ttl_Aedes.spp.bg + Ttl_Aedes.spp_in.proko + Ttl_Aedes.spp_out.proko + Ttl_Aedes.spp.hlc + Ttl_Aedes.spp.larva + AvgTemp + AvgMaxTemp + AvgMinTemp + OverallMaxTemp + OverallMinTemp + AvgTempRange + AvgRH + AvgDewPt + TtlRainfall + RainfallAnomalies + TempRangeAnomalies + TempDewPtDiffAnomalies + TempAnomalies + RHAnomalies + RHTempAnomalies + number_windows + roof_type + floor_type + latrine_type + light_source, data = vector_climate_cases)
  summary(glm_nb)
  
  glm_binary<-glm(infected_denv_stfd~ city +  Ttl_Aedes.spp.Indoor.ovi + ttl_Aedes_spp_Outdoor.ovi + Ttl_Aedes.spp.bg + Ttl_Aedes.spp_in.proko + Ttl_Aedes.spp_out.proko + Ttl_Aedes.spp.hlc + Ttl_Aedes.spp.larva + AvgTemp + AvgMaxTemp + AvgMinTemp + OverallMaxTemp + OverallMinTemp + AvgTempRange + AvgRH + AvgDewPt + TtlRainfall + RainfallAnomalies + TempRangeAnomalies + TempDewPtDiffAnomalies + TempAnomalies + RHAnomalies + RHTempAnomalies + roof_type + number_windows + floor_type + latrine_type + light_source, family = binomial, data = vector_climate_cases)  
  summary(glm_binary)
  hist(vector_climate_cases$infected_denv_stfd_monthly)
#  Create Table 1 stratified by trt (omit strata argument for overall table) -------------------------------------------------------------
  library(tableone)
  
  vars <- c("month_year", "city", "month_year_lag", "Ttl_Aedes.spp.Indoor.ovi", "ttl_Aedes_spp_Outdoor.ovi", "Ttl_Aedes.spp.bg", "Ttl_Aedes.spp_in.proko", "Ttl_Aedes.spp_out.proko", "Ttl_Aedes.spp.hlc", "Ttl_Aedes.spp.larva", "month_year_date", "month_collected", "AvgTemp", "AvgMaxTemp", "AvgMinTemp", "OverallMaxTemp", "OverallMinTemp", "AvgTempRange", "AvgRH", "AvgDewPt", "TtlRainfall", "RainfallAnomalies", "TempRangeAnomalies", "TempDewPtDiffAnomalies", "TempAnomalies", "RHAnomalies", "RHTempAnomalies", 'roof_type' , "floor_type","latrine_type","light_source","dem_cooking_fuel","dem_water_source", "id_cohort")
  factorVars <- c("city",'roof_type',"floor_type","latrine_type","light_source","dem_cooking_fuel","dem_water_source", "id_cohort")
  tableOne <- CreateTableOne(vars = vars, factorVars=factorVars, strata = "infected_denv_stfd", data = vector_climate_cases)

# gps data -------------------------------------------------------------
  gps_denv<-vector_climate_cases[ , grepl( "latit|longit|house_id|house_number|infected_denv|infected_chikv" , names(vector_climate_cases) ) ]
  gps_vector<-vector_climate_cases[ , grepl( "latit|longit|house_id|house_number|aedes|ovi|bg|proko|larva|hlc" , names(vector_climate_cases) ) ]

  write.csv(as.data.frame(gps_denv), "gps_denv.csv")
  write.csv(as.data.frame(gps_vector), "gps_vector.csv")
  
# plot data -------------------------------------------------------------
  plot(vector_climate_cases$infected_denv_stfd[vector_climate_cases$infected_denv_stf>0], round(vector_climate_cases$TtlRainfall[vector_climate_cases$infected_denv_stf>0]))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$TempAnomalies))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$AvgTemp))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$AvgRH))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$RainfallAnomalies))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$Ttl_Aedes.spp.larva))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$Ttl_Aedes.spp.hlc))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$ttl_Aedes_spp_Outdoor.ovi))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$Ttl_Aedes.spp_in.proko))
  plot(vector_climate_cases$infected_denv_stfd, round(vector_climate_cases$Ttl_Aedes.spp.Indoor.ovi))
  
  
  library(plotly)
  
  t <- list(
    family = "sans serif",
    size = 28,
    color = 'black')
  
plot_ly(climate, x = ~date_collected, y = ~rainfall_hobo,  name = 'rainfall hobo' )%>%
#  add_lines(y = ~temp_mean_hobo, name = 'Mean Temp Hobo') %>%
#   add_lines(y = ~rh_mean_hobo, name = 'rh_mean_hobo') %>%
#   add_lines(y = ~climate$dewpt_mean_hobo, name = 'dewpt_mean_hobo',type = 'lines') %>%
    layout(yaxis = list(title = 'Climate variables'), 
     margin = list(b = 160), xaxis = list(type ="date", nticks = 30, tickangle =45)
   )


##---------------  mosquito, temp, cases plot
p3 <- plot_ly() %>% 
  add_trace(data=denv, x = ~month_year, y = ~infected_denv_stfd, name = 'DENV',type = 'scatter', mode = 'lines', yaxis = "y2") %>%
  #add_trace(data=climate, x = ~date_collected, y = ~temp_mean_hobo, type = 'scatter', mode = 'lines', name='Mean temperature', yaxis = "y")%>%
  #add_trace(data=climate, x = ~date_collected, y = ~rainfall_hobo, type = 'scatter', mode = 'lines', name='Total Rain', yaxis = "y")%>%
  add_trace(data=ovi, x = ~ovi$year_month, y = ~ovi$egg_count, type = 'bar', name = 'Ovitrap', yaxis = "y")%>%
  add_trace(data=prokopack, x = ~prokopack$year_month, y = ~prokopack$prokpack_sum, type = 'bar', name = 'Prokopack', yaxis = "y")%>%
  add_trace(data=larva_long_aedes, x = ~larva_long_aedes$month_year, y = ~larva_long_aedes$larva_sum, type = 'bar', name = 'Larva', yaxis = "y")%>%
  add_trace(data=bg, x = ~bg$month_year, y = ~bg$bg_aedes_sum, type = 'bar', name = 'BG', yaxis = "y")%>%
  add_trace(data=hlc, x = ~hlc$month_year, y = ~hlc$hlc_aedes_sum, type = 'bar', name = 'HLC', yaxis = "y")%>%
  layout(
          title = 'Total Aedes aegypti, temperature, and rainfall in Kenya 2014-2017',
          margin = list(b = 160), 
          xaxis = list(type ="date", nticks = 15, tickangle =45,title = "Date"),
          yaxis = list(side = 'left', title = 'Aedes Mosquito (count)', showgrid = FALSE, zeroline = TRUE, barmode='relative'),
          yaxis2 = list(side = 'right', overlaying = "y", title = 'Dengue Cases/Month', showgrid = FALSE, zeroline = FALSE),
          barmode = 'stack'
                        )
         
      p3
      
##--------------- z scores: mosquito, temp, cases plot
      
      larva_long_aedes$larva_z<-(larva_long_aedes$larva_sum-mean(larva_long_aedes$larva_sum))/sd(larva_long_aedes$larva_sum)
      bg$bg_z<-(bg$bg_aedes_sum -mean(bg$bg_aedes_sum))/sd(bg$bg_aedes_sum)
      hlc$hlc_z<-(hlc$hlc_aedes_sum -mean(hlc$hlc_aedes_sum))/sd(hlc$hlc_aedes_sum)
      ovi$ovi_z<-(ovi$egg_count -mean(ovi$egg_count))/sd(ovi$egg_count)
      denv$denv_z <-(denv$infected_denv_stfd -mean(denv$infected_denv_stfd))/sd(denv$infected_denv_stfd)
      prokopack$proko_z <-(prokopack$prokpack_sum -mean(prokopack$prokpack_sum))/sd(prokopack$prokpack_sum)
      
      
      p4 <- plot_ly() %>% 
        add_trace(data=denv, x = ~month_year, y = ~denv_z, name = 'z score DENV',type = 'scatter', mode = 'lines', yaxis = "y2") %>%
        #add_trace(data=climate, x = ~month_year_lag, y = ~temp_mean_hobo, type = 'scatter', mode = 'lines', name='Mean temperature', yaxis = "y")%>%
        #add_trace(data=climate, x = ~month_year_lag, y = ~rainfall_hobo, type = 'scatter', mode = 'lines', name='Total Rain', yaxis = "y")%>%
        add_trace(data=ovi, x = ~ovi$month_year_lag, y = ~ovi$ovi_z, type = 'bar', name = 'Z score Ovitrap', yaxis = "y")%>%
        add_trace(data=prokopack, x = ~prokopack$month_year_lag, y = ~proko_z, type = 'bar', name = 'Z score Prokopack', yaxis = "y")%>%
        add_trace(data=larva_long_aedes, x = ~larva_long_aedes$month_year_lag, y = ~larva_z, type = 'bar', name = 'Z score Larva', yaxis = "y")%>%
        add_trace(data=bg, x = ~bg$month_year_lag, y = ~bg_z , type = 'bar', name = 'Z score BG', yaxis = "y")%>%
        add_trace(data=hlc, x = ~hlc$month_year_lag, y = ~hlc_z, type = 'bar', name = 'Z score HLC', yaxis = "y")%>%

      layout(
          title = 'Z score: Aedes aegypti and DENV in Kenya 2014-2017',
          margin = list(b = 160, t = 160, r = 160, l = 160), 
          xaxis = list(type ="One month lagged date", nticks = 15, tickangle =45,title = "Date"),
          yaxis = list(side = 'left', title = 'Aedes Mosquito (Z score )', showgrid = FALSE, zeroline = TRUE, barmode='relative'),
          yaxis2 = list(side = 'right', overlaying = "y", title = 'Z score: Dengue Cases/Month', showgrid = FALSE, zeroline = FALSE),
          barmode = 'stack', font  = t, legend = list(orientation = "h",   # show entries horizontally
                                                      xanchor = "center",  # use center of legend as anchor
                                                      x = 0.5, y = -0.5)
          
        )
      p4
      

      
      p5 <- plot_ly() %>% 
        add_trace(data=denv, x = ~month_year, y = ~denv_z, name = 'z score DENV',type = 'scatter', mode = 'lines', yaxis = "y2") %>%
        #add_trace(data=climate, x = ~month_year, y = ~temp_mean_hobo, type = 'scatter', mode = 'lines', name='Mean temperature', yaxis = "y")%>%
        #add_trace(data=climate, x = ~month_year, y = ~rainfall_hobo, type = 'scatter', mode = 'lines', name='Total Rain', yaxis = "y")%>%
        add_trace(data=ovi, x = ~ovi$month_year, y = ~ovi$ovi_z, type = 'bar', name = 'Z score Ovitrap', yaxis = "y")%>%
        add_trace(data=prokopack, x = ~prokopack$month_year, y = ~proko_z, type = 'bar', name = 'Z score Prokopack', yaxis = "y")%>%
        add_trace(data=larva_long_aedes, x = ~larva_long_aedes$month_year, y = ~larva_z, type = 'bar', name = 'Z score Larva', yaxis = "y")%>%
        add_trace(data=bg, x = ~bg$month_year, y = ~bg_z , type = 'bar', name = 'Z score BG', yaxis = "y")%>%
        add_trace(data=hlc, x = ~hlc$month_year, y = ~hlc_z, type = 'bar', name = 'Z score HLC', yaxis = "y")%>%
        
        layout(
          title = 'Z score: Aedes aegypti and DENV in Kenya 2014-2017',
          margin = list(b = 160, t = 160, r = 160, l = 160), 
          xaxis = list(type ="date", nticks = 15, tickangle =45,title = "Date"),
          yaxis = list(side = 'left', title = 'Aedes Mosquito (Z score )', showgrid = FALSE, zeroline = TRUE, barmode='relative'),
          yaxis2 = list(side = 'right', overlaying = "y", title = 'Z score: Dengue Cases/Month', showgrid = FALSE, zeroline = FALSE),
          barmode = 'stack', font  = t, legend = list(orientation = "h",   # show entries horizontally
                                                      xanchor = "center",  # use center of legend as anchor
                                                      x = 0.5, y = -0.5)
          
        )
      p5      
      
      
      p6 <- plot_ly() %>% 
        add_trace(data=denv, x = ~month_year, y = ~denv_z, name = 'z score DENV',type = 'scatter', mode = 'lines', yaxis = "y2") %>%
        add_trace(data=climate, x = ~month_year_lag, y = ~temp_mean_hobo, type = 'bar',  name='Mean temperature', yaxis = "y")%>%
        add_trace(data=climate, x = ~month_year_lag, y = ~rainfall_hobo, type = 'bar', name='Total Rain', yaxis = "y")%>%
        
        layout(
          title = 'Z score: Aedes aegypti and DENV in Kenya 2014-2017',
          margin = list(b = 160, t = 160, r = 160, l = 160), 
          xaxis = list(type ="date", nticks = 15, tickangle =45,title = "One month lagged date"),
          yaxis = list(side = 'left', title = 'climate', showgrid = FALSE, zeroline = TRUE, barmode='relative'),
          yaxis2 = list(side = 'right', overlaying = "y", title = 'Z score: Dengue Cases/Month', showgrid = FALSE, zeroline = FALSE),
          font  = t, legend = list(orientation = "h",   # show entries horizontally
                                                      xanchor = "center",  # use center of legend as anchor
                                                      x = 0.5, y = -0.5)
          
        )
      p6
      
      