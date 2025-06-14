library(reticulate)
library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(progress)

# 設定 Python 環境
use_python("C:/Users/user/ckip_env/Scripts/python.exe", required = TRUE)

# 匯入 CKIPTagger
ckiptagger <- import("ckiptagger")
ws <- ckiptagger$WS("./data", disable_cuda = FALSE)
pos <- ckiptagger$POS("./data", disable_cuda = FALSE)
ner <- ckiptagger$NER("./data", disable_cuda = FALSE)

# 設定資料夾路徑
input_folder <- "NDCdata"
output_folder <- "NDCdata/trump_articles"
output_csv <- "NDCdata/ndc_articles.csv"
output_tokenpos_csv <- "NDCdata/ndc_articles_POS.csv"
output_ner_csv <- "NDCdata/ndc_articles_NER.csv"
output_txt_folder <- "NDCdata/trump_articles_POS_TXT"
dir.create(output_txt_folder, showWarnings = FALSE)

# input_folder <- "D:/CJ/UDNdata/udn_articles/"
# df <- read_csv("D:/CJ/UDNdata/udn_articles.csv")

# 尋找資料夾底下的所有以trump_articles_開頭的CSV檔案
csv_files <- list.files(path = input_folder, pattern = "^trump_articles_.*\\.csv$", full.names = TRUE, recursive = TRUE)

# 讀取所有CSV檔案並合併成一個資料框
df <- lapply(csv_files, function(file) {
  print(file)
  
  # 讀取CSV檔案
  temp_df <- read_csv(file)
  
  # 取得其資料夾名稱
  folder_name <- basename(dirname(file))
  
  # 新增一個欄位存放資料夾名稱
  temp_df <- temp_df %>%
    mutate(folder = folder_name)
  
  # 將發布日期轉換為日期時間格式
  temp_df <- temp_df %>%
    mutate(發布日期 = case_when(
      # 嘗試標準格式 "%Y-%m-%d %H:%M:%S"
      !is.na(as.POSIXct(發布日期, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")) ~ 
        as.POSIXct(發布日期, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
      
      # 嘗試 "%m/%d/%Y %H:%M" 格式
      !is.na(as.POSIXct(發布日期, format = "%m/%d/%Y %H:%M", tz = "UTC")) ~ 
        as.POSIXct(發布日期, format = "%m/%d/%Y %H:%M", tz = "UTC"),
      
      # 如果兩種格式都不匹配，保留原始值
      TRUE ~ as.POSIXct(NA)
    ))
  
  return(temp_df)
}) %>%
  bind_rows()%>%
  # 移除重複的資料列
  distinct()

# 預備兩個空清單
all_tokenpos <- list()  # 存 (詞, 詞性, 次數)
all_ner <- list()       # 存 (實體, 類型)

# 建立進度條
pb <- progress_bar$new(
  total = nrow(df),
  format = "  處理中 [:bar] :current/:total (:percent) in :elapsed"
)

# Process each file
for (i in seq_len(nrow(df))) {
  tryCatch({
    id <- df$識別碼[i]  # Your ID column name
    folder <- df$folder[i]  # Your folder column name

    file_path <- file.path(input_folder, folder, "trump_articles", paste0(id, ".txt"))
    
    # id <- df$UUID
    # file_path <- paste0(input_folder, paste0(id, ".txt"))
    
    if (file.exists(file_path)) {
      text <- readLines(file_path, warn = FALSE)
      text <- paste(text, collapse = " ")
      
      # Select the text after "正文:"
      # text <- str_extract(text, "(?<=正文:).*")
      
      # Skip if no text was extracted
      # if (is.na(text) || text == "") {
      #   warning(paste0("No text found after '正文:' in file: ", file_path))
      #   next
      # }
      
      # WS + POS + NER
      ws_result <- ws(list(text))
      pos_result <- pos(ws_result)
      ner_result <- ner(ws_result, pos_result)

      tokens <- ws_result[[1]]
      pos_tags <- pos_result[[1]]

      ## ====== (1) 處理 WS + POS ======

      # 將詞和詞性組合成所需格式
      tokenpos_text <- paste0(tokens, "(", pos_tags, ")", collapse = "　")
      
      # 將結果寫入 TXT 文件
      output_txt_path <- file.path(output_txt_folder, paste0(id, ".txt"))
      writeLines(tokenpos_text, output_txt_path)
      output_txt_path <- file.path(output_folder, paste0(id, ".txt"))
      writeLines(text, output_txt_path)
      
      tokenpos_df <- tibble(
       ID = id,
       word = tokens,
       pos = pos_tags
      ) %>%
       count(ID, word, pos, name = "count")  # Count occurrences of each (word/POS)

      all_tokenpos[[i]] <- tokenpos_df

      ## ====== (2) 直接存儲 NER 結果 ======
      if (!is.null(ner_result) && length(ner_result) > 0) {
        # 將 NER 結果轉換為字符串並存儲
        # 使用 toString 或 as.character 存儲原始結果
        ner_string <- toString(ner_result[[1]])
        all_ner[[i]] <- tibble(ID = id, ner_result = ner_string)

        # 印出 NER 數量資訊
        ner_count <- ifelse(is.character(ner_result[[1]]),
                            str_count(ner_result[[1]], "\\("),
                            length(ner_result[[1]]))
        # print(paste0("ID: ", id, " NER: ", ner_count, " 個實體"))
      } else {
        all_ner[[i]] <- tibble(ID = id, ner_result = NA_character_)
      }
    } else {
      warning(paste0("找不到檔案：", file_path))
    }
  }, error = function(e) {
    warning(paste0("處理 ID ", df$UUID[i], " 時發生錯誤: ", e$message))
  })
  
  # 更新進度條
  pb$tick()
}

# 合併所有新聞結果
all_tokenpos1 <- Filter(function(df) nrow(df) > 0, all_tokenpos)
final_tokenpos <- bind_rows(all_tokenpos1)
final_ner <- bind_rows(all_ner)

# 輸出兩個表格
write_csv(final_tokenpos, output_tokenpos_csv)
write_csv(final_ner, output_ner_csv)
write_csv(df, output_csv)

cat("\n🎉 (詞+詞性) 表格、NER 表格都完成！已輸出兩個新CSV！\n")
