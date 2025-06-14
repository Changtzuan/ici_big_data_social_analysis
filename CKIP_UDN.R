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
input_folder <- "D:/CJ/UDNdata/trump_articles/"
df <- read_csv("D:/CJ/UDNdata/udn_articles.csv")
output_tokenpos_csv <- "UDNdata/udn_articles_POS.csv"
output_ner_csv <- "UDNdata/udn_articles_NER.csv"
output_txt_folder <- "UDNdata/trump_articles_POS_TXT"
dir.create(output_txt_folder, showWarnings = FALSE)

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
    
    id <- df$UUID
    file_path <- paste0(input_folder, paste0(id, ".txt"))
    
    if (file.exists(file_path)) {
      text <- readLines(file_path, warn = FALSE)
      text <- paste(text, collapse = " ")
      
      # Select the text after "正文:"
      text <- str_extract(text, "(?<=正文:).*")
      
      # Skip if no text was extracted
      if (is.na(text) || text == "") {
        warning(paste0("No text found after '正文:' in file: ", file_path))
        next
      }
      
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

cat("\n🎉 (詞+詞性) 表格、NER 表格都完成！已輸出兩個新CSV！\n")
