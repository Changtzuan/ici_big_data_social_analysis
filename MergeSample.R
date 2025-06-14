library(tidyverse)

trump_results <- read_csv("NDCdata/ndc_articles_sampled.csv")
udn_results <- read_csv("UDNdata/udn_articles_sampled.csv")

# 處理 UDN 資料
udn_results$folder <- sapply(udn_results$版次, function(x) {
  if (grepl("兩岸", x)) {
    "兩岸新聞"
  } else if (grepl("國際|全球|美國大選|紐約時報", x)) {
    "國際新聞"
  } else if (grepl("財經|基金|產業|經濟彭博|台股|證券|期貨|金融|上市櫃公司", x)) {
    "財經新聞"
  } else if (grepl("要聞|焦點|話題|川普|賴政府", x)) {
    "政治新聞"
  } else if (grepl("生活|文教|台股熱點|繽紛", x)) {
    "生活新聞"
  } else if (grepl("聯合副刊|ICT新訊", x)) {
    "文化體育新聞"
  } else if (grepl("民意論壇|經營管理|好讀周報", x)) {
    "專欄與評論"
  } else {
    "即時新聞"
  }
})

udn_results$新聞標題 <- ifelse(
  is.na(udn_results$副標),
  udn_results$標題,
  paste(udn_results$標題, udn_results$副標, sep = " - ")
)

udn_results$FULLTEXT <- udn_results$UUID
names(udn_results)[c(1, 5, 6, 7, 8)] <- c("識別碼", "來源媒體", "新聞分類", "發布日期", "新聞連結")


# 找出兩個Dataframe的共同欄位
common_columns <- intersect(names(udn_results), names(trump_results))

# 篩選兩個Dataframe只保留共同欄位
udn_filtered <- udn_results[, common_columns, drop = FALSE]
trump_filtered <- trump_results[, common_columns, drop = FALSE]

# 合併兩個Dataframe
combined_results <- rbind(
  trump_filtered %>% mutate(Source = "NDC"),
  udn_filtered %>% mutate(Source = "UDN")
)

write.csv(combined_results, "sampled_articles.csv", row.names = FALSE, fileEncoding = "UTF-8")
