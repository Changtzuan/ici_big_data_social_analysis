##Temporal Coverage Trends & Sentiment proportion
# dataset : all_articles_results.csv

library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)

all_articles_results <- read_csv("all_articles_results.csv")

#改變來源媒體 和 LLM 的欄位名稱 以利作業
all_articles_results <- all_articles_results %>%
  rename(
    media_source = `來源媒體`,
    RESULT = LLM
  )

#清除 LLM 結果顯示為 "無關"的資料 總共為(119筆)
all_articles_results <- all_articles_results %>%
  filter(RESULT != "無關")

#將來源媒體中命名為2011 ETtoday.net. All Rights Reserved.的資料改為 ETtoday
all_articles_results <- all_articles_results %>%
  mutate(media_source = recode(media_source,
                               "2011 ETtoday.net. All Rights Reserved." = "ETtoday"))

#轉換發布日期的格式
all_articles_results <- all_articles_results %>%
  mutate(publish_date = as.Date(parse_date_time(
    `發布日期`,
    orders = c("m/d/Y H:M", "m/d/Y"))))

# 加入週起始日期欄位（以每週一為基準）
all_articles_results <- all_articles_results %>%
  mutate(week = floor_date(publish_date, unit = "week", week_start = 1)) %>%
  filter(media_source=='公視新聞網')

# 統計每週 framing 次數
framing_by_week <- all_articles_results %>%
  group_by(week, RESULT) %>%
  summarise(count = n(), .groups = "drop")

# 加入每週總新聞數，並計算 framing 百分比
framing_by_week <- framing_by_week %>%
  group_by(week) %>%
  mutate(
    total = sum(count),
    proportion = round(count / total, 3)
  ) %>%
  ungroup()

# 查看資料
head(framing_by_week)

# 建立每週總報導量統計（不分 framing 類別）
weekly_total <- all_articles_results %>%
  group_by(week) %>%
  summarise(total_articles = n(), .groups = "drop")

#報導數量折線圖（每週新聞篇數變化）#有加時間
ggplot(weekly_total, aes(x = week, y = total_articles)) +
  geom_line(color = "#4E79A7", size = 1.2) +
  geom_point(color = "#4E79A7", size = 2) +
  geom_text(aes(label = format(week, "%m/%d")), vjust = -0.8, size = 3.5, family = "msjh") +
  labs(
    title = "Number of Trump-related news reports during the 2024 election period (weekly statistics)",
    x = "Week Start Date",
    y = "Number of News Articles"
  ) +
  theme_minimal(base_family = "msjh") +
  theme(
    text = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 16)
  )

#報導數量折線圖（每週新聞篇數變化）#有加時間 #有加事件
event_df <- data.frame(
    event_date = as.Date(c("2024-07-21", "2024-08-15", "2024-09-11", "2024-10-14", "2024-10-29", "2024-11-05")),
    event_label = c("拜登退選\n(7/21)", "賀錦麗民調領先\n(8/15)", "候選人辯論\n(9/11)", "中共軍演\n(10/14)", "選前高峰\n(10/29)", "川普勝選\n(11/5)")
  )
  
ggplot(weekly_total, aes(x = week, y = total_articles)) +
  geom_line(color = "#4E79A7", size = 1.2) +
  geom_point(color = "#4E79A7", size = 2) +
  geom_text(aes(label = format(week, "%m/%d")), vjust = -0.8, size = 3.5, family = "msjh") +
  
  # 新增事件線與標籤 👇
  geom_vline(data = event_df, aes(xintercept = event_date), linetype = "dashed", color = "black", size = 0.7) +
  geom_text(
    data = event_df,
    mapping = aes(x = event_date, y = max(weekly_total$total_articles) * 1.03, label = event_label),
    inherit.aes = FALSE,
    size = 4,
    angle = 0,
    vjust = 2.5,
    hjust = 0.5,
    fontface = "bold",
    family = "msjh"
  ) +
  
  labs(
    title = "Number of Trump-related news reports during the 2024 election period with big events (weekly statistics)",
    x = "Week Start Date",
    y = "Number of News Articles"
  ) +
  theme_minimal(base_family = "msjh") +
  theme(
    text = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 16)
  )


#立場時間變化圖(有加特定事件)
ggplot(framing_by_week, aes(x = week, y = proportion, color = RESULT, group = RESULT)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  geom_text(
    aes(label = round(proportion, 2)),
    vjust = -0.8,
    size = 3,
    family = "msjh",
    show.legend = FALSE  # ← 關鍵修正，防止 a 出現在圖例
  ) +
  
  # 加事件線與標籤
  geom_vline(data = event_df, aes(xintercept = event_date), linetype = "dashed", color = "black", size = 0.7) +
  geom_text(
    data = event_df,
    mapping = aes(x = event_date, y = 1.01, label = event_label),
    inherit.aes = FALSE,
    size = 3.5,
    angle = 0,
    vjust = 0.8,
    hjust = 0.5,
    fontface = "bold",
    family = "msjh"
  ) +
  
  # 顏色與圖例名稱
  scale_color_manual(
    name = "Framing Category",
    values = c("支持" = "#6C91BF", "中立" = "#A9CBB7", "反對" = "#D08C79")
  ) +
  
  # 標題與軸標籤
  labs(
    title = "Trend of stance proportions over time (by week), PTS",
    x = "Week Start Date",
    y = "Stance Proportion"
  ) +
  
  # 主題設定
  theme_minimal(base_family = "msjh") +
  theme(
    text = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(size = 12),
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16)
  )

#立場比例結構時間變化圖(含事件)

ggplot(framing_by_week, aes(x = week, y = proportion, fill = RESULT)) +
  geom_area(alpha = 0.85, size = 0.5, color = "white") +
  scale_fill_manual(values = c("支持" = "#6C91BF", "中立" = "#A9CBB7", "反對" = "#D08C79")) +
  scale_x_date(
    date_breaks = "1 week",
    date_labels = "%m/%d",
    expand = expansion(mult = c(0.01, 0.02))
  )+

  
  # 加入多條事件線
  geom_vline(data = event_df, aes(xintercept = event_date), linetype = "dashed", color = "black", size = 0.8) +
  
  # 加上事件名稱標籤
  geom_text(
    data = event_df,
    mapping = aes(x = event_date, y = 0.98, label = event_label),
    inherit.aes = FALSE,
    angle = 0,           # 垂直顯示
    vjust = 1,         # 稍微貼近線條
    hjust = 0.5,          # 置中對齊
    size = 4,
    fontface = "bold",
    family = "msjh"
  )+
  
  labs(
    title = "Changes in framing structure over time (with major events marked)",
    x = "Week Start Date",
    y = "Stance Proportion",
    fill = "Framing Category"
  ) +
  theme_minimal(base_family = "msjh") +
  theme(
    text = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(size = 12),
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 16)
  )
