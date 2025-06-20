#Sentiment by Media Outlet 

#dataset: all_articles_results

# 載入必要套件
install.packages("stringr")  
library(readr)
library(dplyr)
library(stringr)             

#讀取資料集
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


------------------------------------------------------------------

------------------------------------------------------------------
# 計算各媒體在三種 RESULT 標籤下的出現次數
media_result_count <- all_articles_results %>%
  group_by(media_source, RESULT) %>%
  summarise(count = n(), .groups = "drop")

# 計算每家媒體的總數
media_total <- media_result_count %>%
  group_by(media_source) %>%
  summarise(total = sum(count), .groups = "drop")

# 合併總數後，計算比例
media_result_prop <- media_result_count %>%
  left_join(media_total, by = "media_source") %>%
  mutate(proportion = round(count / total, 3))

# 檢查結果
print(media_result_prop)
-----------------------------------------------------------------
#畫圖 
library(ggplot2)
library(showtext)
library(systemfonts)


font_add("msjh", regular = "msjh.ttc")
showtext_auto()

ggplot(media_result_prop, aes(x = media_source, y = proportion, fill = RESULT)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Framing Distribution: Composition of Stance by Media Outlet",
    x = "Media Source",
    y = "Proportion",
    fill = "Framing Label"
  ) +
  scale_fill_manual(values = c("支持" = "darkblue", "中立" = "lightblue", "反對" = "#4682B4")) +
  theme_minimal(base_family = "msjh") +
  theme(
    text = element_text(size = 14),
    axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
    axis.text.y = element_text(size = 12),
    legend.title = element_text(size = 13),
    legend.text = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold")
  )
----------------------------------------------------------------
#以下為卡式檢定，去判斷（支持／中立／反對）與媒體來源之間是否具有高度顯著差異? 看 （p < 0.001）
# 建立交叉表（每個媒體在三種 framing 下的次數）
media_table <- table(all_articles_results$media_source, all_articles_results$RESULT)

# 執行卡方檢定
chisq_result <- chisq.test(media_table)

# 顯示檢定結果
print(chisq_result)
#> print(chisq_result)

#Pearson's Chi-squared test

#data:  media_table
#X-squared = 1601.1, df = 10, p-value < 2.2e-16  >>> 不同媒體在報導川普時所呈現的語氣與立場，並非隨機分佈，而是具有系統性差異。

#這邊看看各媒體是哪一類 framing 偏高／偏低（標準化殘差）
round(chisq_result$stdres, 2)

# > 2     | 該媒體對該類別 framing 出現次數「顯著高於預期」 |
# < -2    | 顯著低於預期
# -2 \~ 2 | 屬於預期範圍內

#結果: 

---------------------------------------------------------------
# 熱圖（Heatmap）
#快速檢視 哪些媒體對哪些 framing 偏高或偏低
  
install.packages("tidyverse")
library(dplyr)
library(tidyr)
library(ggplot2)

# Step 1：把標準化殘差矩陣轉換為 data frame 並加上行名與列名
residual_matrix <- chisq_result$stdres
residual_df <- as.data.frame(as.table(residual_matrix))  # 轉為三欄格式（Var1, Var2, Freq）
colnames(residual_df) <- c("media_source", "Framing", "Residual")  # 重命名欄位

# Step 2：畫熱圖
ggplot(residual_df, aes(x = Framing, y = media_source, fill = Residual)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(Residual, 2)), size = 4) +
  scale_fill_gradient2(low = "#4575b4", mid = "white", high = "#d73027", midpoint = 0) +
  labs(
    title = "Standardized Residual Heatmap of Media × Framing Labels",
    x = "Framing Category",
    y = "Media Source",
    fill = "Residual Value"
  ) +
  theme_minimal(base_family = "msjh") +
  theme(
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold")
  )

------------------------------------------------------------------
  
  
    
