install.packages("corrplot")

library(tidyquant)
library(timetk)
library(ggplot2)
library(dplyr)
library(tidyr)
library(corrplot)

netflix <- tq_get("NFLX",
                  from = '2009-01-01',
                  to = "2018-03-01",
                  get = "stock.prices")

netflix %>%
  ggplot(aes(x = date, y = adjusted)) +
  geom_line() +
  ggtitle("Netflix since 2009") +
  labs(x = "Date", "Price") +
  scale_x_date(date_breaks = "years", date_labels = "%Y") +
  labs(x = "Date", y = "Adjusted Price") +
  theme_bw()

# Calculate daily returns

netflix_daily_returns <- netflix %>%
  tq_transmute(select = adjusted,           # this specifies which column to select
               mutate_fun = periodReturn,   # This specifies what to do with that column
               period = "daily",      # This argument calculates Daily returns
               col_rename = "nflx_returns") # renames the column

#Calculate monthly returns just change the argument "period"

netflix_monthly_returns <- netflix %>%
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = "monthly",      # This argument calculates Monthly returns
               col_rename = "nflx_returns")


netflix_daily_returns %>%
  ggplot(aes(x = nflx_returns)) +
  geom_histogram(binwidth = 0.015) +
  theme_classic() +
  labs(x = "Daily returns") +
  ggtitle("Daily Returns for Netflix") +
  scale_x_continuous(breaks = seq(-0.5,0.6,0.05),
                     labels = scales::percent) +
  annotate(geom = 'text', x = -0.30, y= 200, label = "Extremely\nnegative\nreturns") +
  annotate(geom = 'segment', x = -0.305, xend = -0.35,  y = 120, yend = 20, color = 'red', arrow = arrow()) +
  annotate(geom = 'segment', x = 0.405, xend = 0.42,  y = 120,
           yend = 20, color = 'blue', arrow = arrow(type = "open")) +
  annotate(geom = 'text', x = 0.430, y = 200, label = "Extremely\npositive\nreturns")


# Charting the monthly returns for Netflix. Using bar charts

netflix_monthly_returns %>%
  ggplot(aes(x = date, y = nflx_returns)) +
  geom_bar(stat = "identity") +
  theme_classic() +
  labs(x = "Date", y = "Monthly returns") +
  ggtitle("Monthly Returns for Netflix") +
  geom_hline(yintercept = 0) +
  scale_y_continuous(breaks = seq(-0.6,0.8,0.1),
                     labels = scales::percent) +
  scale_x_date(date_breaks = "years", date_labels = "%Y")

#Calculating the cumulative returns for the Netflix stock
netflix_cum_returns <- netflix_daily_returns %>%
  mutate(cr = cumprod(1 + nflx_returns)) %>%      # using the cumprod function
  mutate(cumulative_returns = cr - 1)

netflix_cum_returns %>%
  ggplot(aes(x = date, y = cumulative_returns)) +
  geom_line() +
  theme_classic() +
  labs(x = "Date", y = "Cumulative Returns") +
  ggtitle("Cumulative returns for Netflix since 2009",
          subtitle = "$1 investment in 2009 grew to $85")

netflix_monthly_returns %>%
  mutate(cr = cumprod(1 + nflx_returns)) %>%
  mutate(cumulative_returns = cr - 1) %>%
  ggplot(aes(x = date, y = cumulative_returns)) +
  geom_line() +
  theme_classic() +
  labs(x = "Date", y = "Cumulative Returns") +
  ggtitle("Cumulative returns for Netflix since 2010")

#Multiple stocks
# Setting our stock symbols to a variable

tickersOld1 <- c("META", "AMZN", "AAPL", "NFLX", "GOOG", "WEGE3.SA", "BTC-USD")

tickers <- c("AMZN", "GOOG", "WEGE3.SA", "BTC-USD", "ADA-USD")

# Dowload the stock price data

multpl_stocks <- tq_get(tickers,
                        from = "2009-01-01",
                        to = "2023-09-09",
                        get = "stock.prices")

#one chart to all stoks
multpl_stocks %>%
  ggplot(aes(x = date, y = adjusted, color = symbol)) +
  geom_line() +
  ggtitle("Price chart for multiple stocks")

#many chart to all stoks
multpl_stocks %>%
  ggplot(aes(x = date, y = adjusted)) +
  geom_line() +
  facet_wrap(~symbol, scales = "free_y") +  # facet_wrap is used to make diff frames
  theme_classic() +       # using a new theme
  labs(x = "Date", y = "Price") +
  ggtitle("Price chart FAANG stocks")

#Calculating the daily returns for multiple stocks

multpl_stock_daily_returns <- multpl_stocks %>%
  group_by(symbol) %>%                            # We are grouping the stocks by the stock symbol
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = 'daily',
               col_rename = 'returns')

#Calculating the monthly returns for multiple stocks

multpl_stock_monthly_returns <- multpl_stocks %>%
  group_by(symbol) %>%                             # We are grouping the stocks by symbol
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = 'monthly',
               col_rename = 'returns')

#Charting the returns for multiple stocks
multpl_stock_daily_returns %>%
  ggplot(aes(x = date, y = returns)) +
  geom_line() +
  geom_hline(yintercept = 0) +
  facet_wrap(~symbol, scales = "free_y") +
  scale_y_continuous(labels = scales::percent) +
  ggtitle("Daily returns for FAANG stock") +
  labs(x = "Date", y = "Returns") +
  scale_color_brewer(palette = "Set2",
                     name = "",
                     guide = FALSE) +
  theme_classic()

multpl_stock_monthly_returns %>%
  ggplot(aes(x = date, y = returns)) +
  geom_bar(stat = "identity") +
  geom_hline(yintercept = 0) +
  facet_wrap(~symbol, scales = "free_y") +
  scale_y_continuous(labels = scales::percent,
                     breaks = seq(-0.5,0.75,0.05)) +
  ggtitle("Monthly returns for FAANG stock") +
  labs(x = "Date", y = "Returns") +
  scale_fill_brewer(palette = "Set1",   # We will give them different colors instead of black
                     name = "",
                     guide = FALSE) +
  theme_classic()

#Calculating Cumulative returns for multiple stocks
multpl_stock_monthly_returns %>%
  mutate(returns = if_else(date == "2009-01-31", 0, returns)) %>%
  group_by(symbol) %>%  # Need to group multiple stocks
  mutate(cr = cumprod(1 + returns)) %>%
  mutate(cumulative_returns = cr - 1) %>%
  ggplot(aes(x = date, y = cumulative_returns, color = symbol)) +
  geom_line() +
  labs(x = "Date", y = "Cumulative Returns") +
  ggtitle("Cumulative returns for all since 2003") +
  scale_y_continuous(breaks = seq(0,20,2),
                     labels = scales::percent) +
  scale_color_brewer(palette = "Set1",
                     name = "") +
  theme_bw()

Calculating the Mean, standard deviation for Individual Stock
# Calculating the mean
nflx_daily_mean_ret <- netflix_daily_returns %>%
  select(nflx_returns) %>%
  .[[1]] %>%
  mean(na.rm = TRUE)

nflx_monthly_mean_ret <- netflix_monthly_returns %>%
  select(nflx_returns) %>%
  .[[1]] %>%
  mean(na.rm = TRUE)

# Calculating the standard deviation

nflx_daily_sd_ret <- netflix_daily_returns %>%
  select(nflx_returns) %>%
  .[[1]] %>%
  sd()

nflx_monthly_sd_ret <- netflix_monthly_returns %>%
  select(nflx_returns) %>%
  .[[1]] %>%
  sd()

nflx_stat <- tibble(period = c("Daily", "Monthly"),
                    mean = c(nflx_daily_mean_ret, nflx_monthly_mean_ret),
                    sd = c(nflx_daily_sd_ret, nflx_monthly_sd_ret))

nflx_stat

netflix_monthly_returns %>%
  mutate(year = year(date)) %>%
  group_by(year) %>%
  summarise(Monthly_Mean_Returns = mean(nflx_returns),
            MOnthly_Standard_Deviation = sd(nflx_returns))

netflix_monthly_returns %>%
  mutate(year = year(date)) %>%
  group_by(year) %>%
  summarise(Mean_Returns = mean(nflx_returns),
            Standard_Deviation = sd(nflx_returns)) %>%
  gather(Mean_Returns, Standard_Deviation, key = statistic, value = value) %>%
  ggplot(aes(x = year, y = value, fill = statistic)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(breaks = seq(-0.1,0.4,0.02),
                     labels = scales::percent) +
  scale_x_continuous(breaks = seq(2009,2018,1)) +
  labs(x = "Year", y = "") +
  theme_bw() +
  theme(legend.position = "top") +
  scale_fill_brewer(palette = "Set1",
                    name = "",
                    labe = c("Mean", "Standard Deviation")) +
  ggtitle("Netflix Monthly Mean and Standard Deviation since 2009")

#Calculating the Mean, standard deviation for Multiple Stocks
multpl_stock_daily_returns %>%
  group_by(symbol) %>%
  summarise(mean = mean(returns),
            sd = sd(returns))

multpl_stock_monthly_returns %>%
  group_by(symbol) %>%
  summarise(mean = mean(returns),
            sd = sd(returns))

multpl_stock_monthly_returns %>%
  mutate(year = year(date)) %>%
  group_by(symbol, year) %>%
  summarise(mean = mean(returns),
            sd = sd(returns))

multpl_stock_monthly_returns %>%
  mutate(year = year(date)) %>%
  group_by(symbol, year) %>%
  summarise(mean = mean(returns),
            sd = sd(returns)) %>%
  ggplot(aes(x = year, y = mean, fill = symbol)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  scale_y_continuous(breaks = seq(-0.1,0.4,0.02),
                     labels = scales::percent) +
  scale_x_continuous(breaks = seq(2009,2018,1)) +
  labs(x = "Year", y = "Mean Returns") +
  theme_bw() +
  theme(legend.position = "top") +
  scale_fill_brewer(palette = "Set1",
                    name = "Stocks") +
  ggtitle("Monthly Mean returns for FAANG stocks")

multpl_stock_monthly_returns %>%
  mutate(year = year(date)) %>%
  group_by(symbol, year) %>%
  summarise(mean = mean(returns),
            sd = sd(returns)) %>%
  ggplot(aes(x = year, y = sd, fill = symbol)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  scale_y_continuous(breaks = seq(-0.1,0.4,0.02),
                     labels = scales::percent) +
  scale_x_continuous(breaks = seq(2009,2018,1)) +
  labs(x = "Year", y = "Std Dev") +
  theme_bw() +
  theme(legend.position = "top") +
  scale_fill_brewer(palette = "Set1",
                    name = "Stocks") +
  ggtitle("Monthly Standard Deviation returns for FAANG stocks")


# Calculating the Covariance
multpl_stock_monthly_returns %>%
  spread(symbol, value = returns) %>%
  tk_xts(silent = TRUE) %>%
  cov()

# Calculating the correlation
multpl_stock_monthly_returns %>%
  spread(symbol, value = returns) %>%
  tk_xts(silent = TRUE) %>%
  cor()

multpl_stock_monthly_returns %>%
  spread(symbol, value = returns) %>%
  tk_xts(silent = TRUE) %>%
  cor() %>%
  corrplot()

#Fonte:
#https://www.codingfinance.com/post/2018-04-03-calc-returns/
