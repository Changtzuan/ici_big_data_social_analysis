library(readr)
library(rvest)
library(dplyr)
library(stringr)
library(purrr)
library(httr)
library(progressr)


# 啟用進度條
handlers(global = TRUE)
handlers("progress")

setwd("D:/CJ/TRUMPdata/國際新聞")
# 載入CSV
df <- read_csv("國際新聞_2025-04-28.csv")

# 將「發布日期」轉換成日期時間
df <- df %>%
  mutate(發布日期 = as.POSIXct(發布日期, format = "%m/%d/%Y %H:%M:%S"))

# 建立抓取內文函數
get_article <- function(url) {
  tryCatch({
    response <- GET(url)
    content <- content(response, "text", encoding = "UTF-8")
    page <- read_html(content)
    
    if (str_detect(url, "cna.com.tw")) {
      content <- page %>% html_elements("div.paragraph p") %>% html_text2()
    } else if (str_detect(url, "ltn.com.tw")) {
      content <- page %>% html_elements("div.text p") %>% html_text2()
    } else if (str_detect(url, "ettoday.net")) {
      content <- page %>% html_elements("div.story p") %>% html_text2()
    } else {
      return("")
    }
    
    paste(content, collapse = "\n")
  }, error = function(e) {
    message("錯誤：", e$message)  # 打印錯誤訊息
    return(NA)  # 返回空字串
  })
}

# 過濾日期範圍
df_filtered <- df %>%
  filter(
    發布日期 >= as.POSIXct("2024-07-22") &
      發布日期 <= as.POSIXct("2024-11-07")
  )

# 過濾新聞來源
df_filtered <- df_filtered %>%
  filter(!str_detect(新聞連結, "pts.org.tw"))

# ✅ 加上進度條來抓全文
# 初始化一個累積的資料框
df_complete <- df_filtered
df_complete <- df_complete %>%
  mutate(新聞全文 = NA_character_)  # 初始化新聞全文欄位

repeat {
  # 使用進度條包裹處理邏輯
  df_filtered <- with_progress({
    p <- progressor(along = df_filtered$新聞連結)
    df_filtered %>%
      mutate(新聞全文 = map_chr(新聞連結, ~ {
        p()  # 每次進度更新
        get_article(.x)
      }))
  })
  df_filtered <- df_filtered %>%
    select(新聞連結, 新聞全文)
  
  # 更新累積的資料框
  df_complete <- df_complete %>%
    left_join(df_filtered, by = "新聞連結", suffix = c(".old", "")) %>%
    mutate(新聞全文 = ifelse(is.na(新聞全文), 新聞全文.old, 新聞全文)) %>%
    select(-新聞全文.old)
  
  # 檢查是否還有錯誤
  failed <- df_complete %>% filter(is.na(新聞全文))
  
  # 如果沒有失敗的項目，跳出迴圈
  if (nrow(failed) == 0) {
    break
  } else {
    # 將失敗的部分重新處理
    message("重試處理失敗的連結...")
    df_filtered <- failed
  }
}

# 篩選：標題、前言、或全文中出現「川普」
df_trump <- df_complete %>%
  filter(
    str_detect(新聞標題, "川普") |
      str_detect(新聞前言, "川普") |
      str_detect(新聞全文, "川普")
  )

# 建立資料夾
dir.create("trump_articles_global", showWarnings = FALSE)

# 儲存符合的全文為 .txt
walk2(df_trump$識別碼, df_trump$新聞全文, ~ {
  write_lines(.y, file = paste0("trump_articles_global/", .x, ".txt"))
})

# Using readr
write_csv(
  df_trump %>% select(-新聞全文),
  file = "trump_articles_global.csv",
  append = FALSE
)