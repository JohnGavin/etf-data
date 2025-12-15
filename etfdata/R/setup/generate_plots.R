# Generate static plots for vignette fallback
devtools::load_all("finance/data/etfs/etfdata")
library(ggplot2)
library(dplyr)

# Load data from updated snapshot
snap <- readRDS("finance/data/etfs/etfdata/inst/extdata/vignette_data.rds")
universe <- snap$universe
metadata <- snap$metadata
history <- snap$history

# 1. History Plot
p1 <- history %>%
  ggplot(aes(x = date, y = close, color = ticker)) +
  geom_line() +
  facet_wrap(~ticker, scales = "free_y") +
  labs(title = "ETF Price History (LSE)", y = "Close Price (GBP)") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("finance/data/etfs/etfdata/vignettes/history_plot.png", plot = p1, width = 8, height = 6)

# 2. Combined Plot
avg_vol <- history %>%
  group_by(ticker) %>%
  summarise(avg_daily_vol = mean(volume, na.rm = TRUE))

combined <- universe %>%
  inner_join(metadata, by = "isin") %>%
  inner_join(avg_vol, by = "ticker") %>%
  bind_cols(parse_aum(.$aum_text))

p2 <- ggplot(combined, aes(x = aum_amount, y = avg_daily_vol)) +
  geom_point() +
  scale_x_log10(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  scale_y_log10(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  labs(title = "ETF Size vs Liquidity",
       x = "Assets Under Management (AUM)",
       y = "Average Daily Volume") +
  theme_minimal()

ggsave("finance/data/etfs/etfdata/vignettes/combined_plot.png", plot = p2, width = 8, height = 6)
