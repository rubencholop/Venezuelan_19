# This a special case study to Venezuela cases confirmed.


# Libraries ----
library(coronavirus)
library(dplyr)
library(ggplot2)

# Data ----
confirmed <- readr::read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")


# Wrangling ----
.ncols <- length(colnames(confirmed))

colnames(confirmed)[5:.ncols] %<>% 
  stringr::str_replace("X", "")

confirmed_df <- confirmed %>% 
  tidyr::gather("date", "cases", 5:.ncols) %>% 
  janitor::clean_names() %>% 
  mutate(date = lubridate::mdy(date), 
         type = 'confirmed') %>% 
  filter(country_region == "Venezuela") %>% 
  select(country_region, date, cases) %>% 
  mutate(
    daily_cases = cases - dplyr::lag(cases),
    lag = lag(cases),
    change_cases = round((cases / lag -1) * 100 , 1))

# Events ----

who_events <- tribble(
  ~ date, ~ event,
  "2020-03-17", "Quarantine declared",
  "2020-06-22", "Quarantine in 7 states"
) %>%
  mutate(date = as.Date(date)) %>% as.data.frame()

who_events2 <- tribble(
  ~ date, ~ event,
  "2020-06-01", "Quarantine diminished"
) %>%
  mutate(date = as.Date(date)) %>% as.data.frame()
# Plots ----

confirmed_df %>% ggplot(
  aes(y = cases ,
      x = date,
      fill = "red")
) +
  geom_line() +
  geom_vline(
    aes(xintercept = date), 
    data = who_events,
    linetype = 'dashed'
  ) +
  geom_vline(
    aes(xintercept = date), 
    data = who_events2,
    linetype = 'dashed'
  ) +
  geom_text(
    aes(x = date,
        label = event),
    data = who_events,
    y = 6500) +
  geom_text(
    data = who_events2,
    y = 4500,
    aes(x = date, label = event)
  ) + 
  labs(title = "COVID-19 Venezuela cases confirmed",
       caption = "Data source: JHU Github | Data analyst: Ruben Lopez") +
  xlab("Months")  +
  ylab("Cases") +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14))


confirmed_df %>% ggplot(
  aes(y = change_cases ,
      x = date,
      fill = "red")
) +
  geom_line() 

# Outputs ----