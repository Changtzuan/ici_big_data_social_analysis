#Q1 處理
#What vocabulary patterns distinguish Trump coverage across Taiwanese media outlets?

#dataset: trump_articles_POS +udn_articles_POS + all_articles_result

library(readr)
library(dplyr)

#先讀取trump_articles_POS +udn_articles_POS
ndc_articles_POS<- read_csv("ndc_articles_POS.csv")
udn_articles_POS <- read_csv("udn_articles_POS.csv")
all_articles_results <- read_csv("all_articles_results.csv")

# 合併資料集
combined_pos <- bind_rows(ndc_articles_POS, udn_articles_POS)

#------------------------------------------------------------------
#Step 1：篩選實質詞性（去除非語意標記）、過濾無用詞
#有效：名詞（Nouns）動詞（Verbs）形容詞（Adjectives）	副詞（Adverbs）	專有名詞/外來語	
#無效或無用的類別：
#1.虛詞/標點	WHITESPACE, PERIODCATEGORY, COMMACATEGORY, DASHCATEGORY, COLONCATEGORY 等
#2.語助詞/介系詞	T, P, DE
#3.表情符號類	EMOJICATEGORY, EXCLAMATIONCATEGORY, QUESTIONCATEGORY

#確認種類數量：共（60種）
unique(combined_pos$pos)

# 定義語意有用的 POS 類別 (36類) 無用：（24種）
valid_pos <- c(
    "Na", "Nb", "Nc", "Ncd", "Nd", "Nh", "Neu", "Nv",
    "VA", "VB", "VC", "VE", "VH", "VHC", "VJ", "VK", "VL", "VCL", "VF", "VI", "VAC", "VG",
    "A",
    "D", "Di", "Dfa", "Dfb", "Dk", "Da", "DM",
    "FW",
    "Ng",
    "Neqa", "Neqb", "Nep", "Nes"
  )

# 過濾語意詞
combined_pos_filtered_pos <- combined_pos %>%
  filter(pos %in% valid_pos, !is.na(word), !is.na(count))

#確認資料清理正確
any(combined_pos_filtered_pos$pos %in% c("WHITESPACE", "PAUSECATEGORY", "PERIODCATEGORY", "PARENTHESISCATEGORY", "COMMACATEGORY", "COLONCATEGORY", "SEMICOLONCATEGORY", "QUESTIONCATEGORY", "EXCLAMATIONCATEGORY", "DOTCATEGORY", "DASHCATEGORY", "ETCCATEGORY", "SHI", "T", "DE", "P", "I", "Caa", "Cab", "Cba", "Cbb"))

#進一步清理符號，確保真的只保留需要的（大範圍清理）

install.packages("stringr")
library(stringr)

combined_pos_filtered_pos_step_1 <- combined_pos_filtered_pos %>%
  filter(
    !is.na(word),
    
    # 移除 URL、社群格式、圖片連結
    !str_detect(word, "https?://|@|#|pic\\.twitter"),
    
    # 移除空白或內含空格的詞（句子或片段）
    str_count(word, "\\s") == 0,
    
    # 移除數字開頭詞（純數字或數字+英文字）
    !str_detect(word, "^[0-9]+.*"),
    
    # 移除非中文字母組成的亂碼（如 00952、009cf）
    !str_detect(word, "^[0-9A-Za-z]+$"),
    
    # 移除只有特殊符號的詞（半形+全形）
    !str_detect(word, "^[[:punct:]]+$"),
    !str_detect(word, "^[，。、：「」！？（）【】《》]+$"),
    
    # 移除符號+數字（如 +1, #2024）
    !str_detect(word, "^[+/#]+[0-9]+$"),
    
    # 移除符號+文字（如 ▲川粉）
    !str_detect(word, "^[^\\p{Han}a-zA-Z0-9]+[\\p{Han}a-zA-Z0-9]+$"),
    
    # 移除單一中文字（如「一」、「的」、「他」）
    !str_detect(word, "^[\u4e00-\u9fff]$"),
    
    # 移除單一字母或數字（如 a、7）
    !str_detect(word, "^[A-Za-z0-9]$"),
    
    # 移除不可見字元（如零寬空白符、U+FFFC、U+FEFF）
    !str_detect(word, "[\\u200B\\u200C\\u200D\\uFEFF\\uFFFC]")
  )



#檢查是否有其於需要清理的資料，例如：「川普 應該要變為 川普
clean_and_trim_word <- function(word) {
  word <- str_remove_all(word, "^\\s*|\\s*$")  # 去除開頭/結尾空白
  word <- str_replace_all(word, "^[:punct:]+|[:punct:]+$", "")  # 去除半形標點
  word <- str_replace_all(word, "^[，。：、「」！？（）]+|[，。：、「」！？（）]+$", "")  # 去除全形標點
  return(word)
}

combined_pos_filtered_pos_step_2 <- combined_pos_filtered_pos_step_1 %>%
  mutate(word_clean = clean_and_trim_word(word))


#完成基本資料清理後，將"來源媒體以(media_source)"的名稱，從all_articles_result 由篩選識別碼(ID)與來源媒體匯入

#先改欄位名稱 ID = 識別碼, media_source = 來源媒體
all_articles_results <- all_articles_results %>%
  rename(
    ID = 識別碼,
    media_source = 來源媒體
  )

#依照all_articles_results的資料，對應ID 與 media_source 整合到combined_pos_final
combined_pos_final <- combined_pos_filtered_pos_step_2 %>%
  left_join(all_articles_results %>% select(ID ,media_source ) %>% distinct(), by = "ID")

#將2011 ETtoday.net. All Rights Reserved. 的資料 簡化名為 ETtoday
combined_pos_final <- combined_pos_final %>%
  mutate(media_source = recode(media_source,
                               "2011 ETtoday.net. All Rights Reserved." = "ETtoday"))


#------------------------------------------------------------------
#統計詞頻前 20 名（整體）
top20_words_overall <- combined_pos_final %>%
  group_by(word_clean) %>%
  summarise(total_count = sum(count, na.rm = TRUE)) %>%
  arrange(desc(total_count)) %>%
  slice_head(n = 20)

#結果
print(top20_words_overall)


total_words <- sum(combined_pos_final$count, na.rm = TRUE)

top20_words_normalized <- top20_words_overall %>%
  mutate(freq_per_1000 = total_count / total_words * 1000)


#--------------------------------------------------------------------------------
#畫圖 (words/千次詞頻 比較) 不包括媒體來源

library(ggplot2)

# 建立中文→中英對照表（只針對前 20 名）
labels_map <- c(
  "川普" = "川普 (Trump)",
  "美國" = "美國 (USA)",
  "賀錦麗" = "賀錦麗 (Harris)",
  "總統" = "總統 (President)",
  "拜登" = "拜登 (Biden)",
  "台灣" = "台灣 (Taiwan)",
  "報導" = "報導 (Report)",
  "候選人" = "候選人 (Candidate)",
  "中國" = "中國 (China)",
  "民主黨" = "民主黨 (Democrats)",
  "表示" = "表示 (Said)",
  "大選" = "大選 (Election)",
  "支持" = "支持 (Support)",
  "可能" = "可能 (Possibly)",
  "共和黨" = "共和黨 (Republicans)",
  "選舉" = "選舉 (Vote)",
  "經濟" = "經濟 (Economy)",
  "選民" = "選民 (Voter)",
  "認為" = "認為 (Believe)",
  "政策" = "政策 (Policy)"
)

install.packages("showtext")
library(showtext)

install.packages("systemfonts")  
library(systemfonts)

# 指定中文字型（macOS 預設常用：儷黑體；Windows 可試試微軟正黑體）
font_add("msjh", regular = "msjh.ttc")    # Windows

# 設定 ggplot 預設字型
theme_set(theme_gray(base_family = "PingFang TC"))


ggplot(top20_words_normalized, aes(x = reorder(word_clean, freq_per_1000), y = freq_per_1000)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  scale_x_discrete(labels = labels_map) +  
  labs(title = "Top 20 Trump-Related Words (Per 1,000 Words)",
       x = "Word",
       y = "Frequency per 1,000 Words") +
  theme_minimal()

#--------------------------------------------------------------------------------
# 根據媒體的數量來做結構) 
# 計算全語料總詞數（唯一分母）

# 總詞數
total_words <- sum(combined_pos_final$count)

# top 20 詞
top20_words <- combined_pos_final %>%
  group_by(word_clean) %>%
  summarise(total = sum(count), .groups = "drop") %>%
  arrange(desc(total)) %>%
  slice_head(n = 20) %>%
  pull(word_clean)

# 各媒體對 top20 詞的頻率（每千詞）
word_media_freq <- combined_pos_final %>%
  filter(word_clean %in% top20_words) %>%
  group_by(word_clean, media_source) %>%
  summarise(count = sum(count), .groups = "drop") %>%
  mutate(freq_per_1000 = count / total_words * 1000)

# 加總總頻率並排序
word_total_freq <- word_media_freq %>%
  group_by(word_clean) %>%
  summarise(word_total = sum(freq_per_1000), .groups = "drop") %>%
  arrange(desc(word_total))


# 新增排序變數
word_media_freq$word_clean <- factor(word_media_freq$word_clean, levels = word_total_freq$word_clean)


# 自訂媒體顏色
media_colors <- c(
  "ETtoday" = "#E15759",
  "中央通訊社" = "#F28E2B",
  "公視新聞網" = "#76B7B2",
  "自由時報" = "#59A14F",
  "經濟日報" = "#4E79A7",
  "聯合報" = "#AF7AA1"
)



# 畫圖
ggplot(word_media_freq, aes(
  x = reorder(word_clean, freq_per_1000, FUN = sum),
  y = freq_per_1000,
  fill = media_source
)) +
  geom_col(position = "stack") +
  coord_flip() +
  scale_fill_manual(values = media_colors) +
  scale_x_discrete(labels = labels_map)+
  labs(
    title = "Top 20 Trump-Related Words (Media Composition)",
    x = "Word",
    y = "Frequency per 1,000 Words",
    fill = "Media Source"
  ) +
  theme_minimal(base_family = "msjh") +
  theme(
    text = element_text(size = 14),
    axis.text = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold")
  )






