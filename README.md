# Trump's New World: Media Framing in Taiwan

A Comparative Study of the 2024 Election

## Project Context

This project explores how Taiwanese media framed Donald Trump during the 2024 U.S. presidential election by building a full-stack NLP pipeline for large-scale sentiment and framing analysis. We collected over 7,000 Mandarin-language news articles via authorized web crawling from sources such as UDN, PTS, Liberty Times, and ETtoday, all filtered using the keyword “川普” (Trump). After cleaning and structuring the data with dplyr and exporting to CSV, we used CKIPTagger for Mandarin-specific word segmentation, POS tagging, and named entity recognition.

Sentiment labeling was performed using both traditional NLP tools (e.g., CSentiPackage from Academia Sinica) and a comparative evaluation of leading LLMs (ChatGPT-4o/4.1, LLaMA 3.3, Qwen, DeepSeek). Two evaluation approaches were designed: direct single-stage classification and a two-step reasoning process with custom prompts. We benchmarked accuracy against human-labeled samples, revealing notable variance across models and prompt strategies.

Our analysis included chi-square tests, topic modeling, and correspondence analysis to uncover framing patterns and ideological bias across outlets. This project demonstrates how NLP workflows and LLMs can be integrated for multilingual media analysis, offering insights into geopolitical narrative construction and the challenges of sentiment modeling in non-English contexts.

## Getting Started

[Provide instructions on how to get started with your project, including any necessary software or data. Include installation instructions and any prerequisites or dependencies that are required.]

## File Structure

[Describe the file structure of your project, including how the files are organized and what each file contains. Be sure to explain the purpose of each file and how they are related to one another.]

```plaintext
ici_big_data_social_analysis\
├── LLMsSCORE\                          # 各 LLM 以兩種 Prompt 對 100 筆 Sample 進行分類的分數
│   ├── [LLM 結果相關檔案]
│
├── NDCdata\                            # NDC 新聞相關資料
│   ├── ndc_articles_sampled\           # 儲存隨機挑選出的 100 筆 Sample 的全文
│   ├── trump_articles\                 # 儲存所有新聞分類的全文
│   ├── trump_articles_POS_TXT\         # 儲存所有新聞分類的 WS+POS 處理後的全文
│   ├── 各新聞分類資料夾（如兩岸新聞、即時新聞等）
│   │   ├── trump_articles\             # 該分類的新聞全文
│   │   ├── trump_articles_[分類].R     # 該分類的爬取與處理程式
│   │   ├── [分類].csv                  # 該分類的新聞匯出檔案
│   ├── ndc_articles.csv                # NDC 新聞的完整資料集
│   ├── ndc_articles_NER.csv            # NDC 新聞的實體辨識結果
│   ├── ndc_articles_POS.csv            # NDC 新聞的 WS+POS 處理結果
│   ├── ndc_articles_sampled.csv        # 隨機挑選出的 100 筆 Sample 資料
│   ├── PTSdata.py                      # 使用 Playwright 爬取公視新聞資料
│
├── UDNdata\                            # UDN 新聞相關資料
│   ├── trump_articles\                 # 儲存所有新聞分類的全文
│   ├── trump_articles_POS_TXT\         # 儲存所有新聞分類的 WS+POS 處理後的全文
│   ├── udn_articles_sampled\           # 儲存隨機挑選出的 100 筆 Sample 的全文
│   ├── udn_articles.csv                # UDN 新聞的完整資料集
│   ├── udn_articles_NER.csv            # UDN 新聞的實體辨識結果
│   ├── udn_articles_POS.csv            # UDN 新聞的 WS+POS 處理結果
│   ├── udn_articles_sampled.csv        # 隨機挑選出的 100 筆 Sample 資料
│   ├── UDNdata.py                      # 使用 Selenium 爬取 UDN 新聞資料
│
├── sample_articles\                    # 儲存隨機挑選出的 100 筆 Sample 的全文（整合自 NDC 與 UDN）
│
├── all_articles.csv                    # 所有新聞的完整資料集
├── all_articles_results.csv            # 使用 AI 模型分析後的所有新聞結果
├── sampled_articles.csv                # 隨機挑選出的 100 筆新聞資料
├── Labelled.csv                        # 人工標註完成的 100 筆新聞資料
|
├── CKIP_UDN.R                          # 使用 CKIPTagger 分析 UDN 新聞資料
├── CKIP_NDC.R                          # 使用 CKIPTagger 分析 NDC 新聞資料
├── MergeData.R                         # 整合與處理多個資料集
├── Label_OneStep.py                    # 使用 OpenAI API 進行單步驟的新聞情感與標籤分析
├── Label_TwoSteps.py                   # 使用 OpenAI API 進行兩步驟的新聞情感與標籤分析
├── Sample.py                           # 隨機挑選出 100 筆新聞供人工標記的程式
```
---

### **R Requirements**

```R
install.packages("readr")       # 用於讀寫 CSV
install.packages("rvest")       # 用於網頁爬取
install.packages("dplyr")       # 資料處理
install.packages("stringr")     # 字串處理
install.packages("purrr")       # 函數式編程
install.packages("httr")        # HTTP 請求
install.packages("progressr")   # 進度條
install.packages("reticulate")  # 用於在 R 中調用 Python 套件
```

---

### **Python Requirements**

```plaintext
openai==1.78.1                # 與 OpenAI API 的交互
pandas==2.0.3                 # 資料處理
playwright==1.48.0            # 非同步瀏覽器自動化
selenium==4.10.0              # 瀏覽器自動化
ckiptagger==0.2.1             # 中文分詞（R 中透過 reticulate 使用）
tqdm==4.67.1                  # 進度條顯示
```

## Analysis

### Analysis Methods & Visualizations
We applied a full-stack NLP pipeline and multiple visualization techniques to uncover how Taiwanese media framed Donald Trump during the 2024 U.S. presidential election. Below are the core analyses and their associated insights:

### 🧠 Vocabulary & Framing Patterns
![Q1_ Top 20 Trump-Related Words (Media Composition)](https://github.com/user-attachments/assets/2cf27ff1-8fb6-4772-a875-26af842ed947)

We analyzed word usage across outlets using CKIPTagger-based segmentation. Common patterns included high-frequency personal names (Trump, Biden, Harris) and evaluative terms like believe, may, and state, indicating personalized and subjective media framing.

### 📰 Sentiment by Media Outlet
![Q2 Framing Distribution](https://github.com/user-attachments/assets/3152fcfc-411d-4d51-b109-ccbb7e901784)

We compared sentiment polarity (Supportive / Neutral / Oppositional) using both CSentiPackage and LLM-based labeling. PTS and Liberty Times showed more positive framing, while CNA and ETtoday remained mostly neutral—reflecting ideological variance across the media landscape.

### 🔍 Statistical Significance of Framing
![Q2_ Standardized Residual Heatmap of Media × Framing Labels](https://github.com/user-attachments/assets/f1a8fab0-90c7-4701-8182-f8b0025b60d3)

A chi-square test revealed statistically significant framing deviations. For instance, PTS had more positive coverage than expected, while ETtoday significantly underrepresented such framing—highlighting bias patterns aligned with outlet orientation.

### 🕒 Temporal Coverage Trends
![Q4_ 報導數量時間圖(完整的)](https://github.com/user-attachments/assets/e2fc6140-e650-41ef-b88f-9c93ab8af58b)

Media attention followed a U-shaped curve: peaking after Biden’s withdrawal (July) and Trump’s victory (November), with a lull mid-campaign. The sharp rise in late October aligned with election momentum and reflected media re-engagement.

### 📈 Sentiment Shifts Over Time
![Q4_ 立場變化時間圖(完整的)](https://github.com/user-attachments/assets/13cf260a-8c63-4d5f-87aa-4a4e4d56e7eb)

Neutral reporting dominated (>75%) throughout the cycle. However, positive sentiment peaked after Trump’s election win, suggesting media shifted tone in response to political outcomes. Negative coverage remained minimal.

### 🧾 Entity Network Analysis
![Q4_ Distribution of Entity Types (Trump-Related News)](https://github.com/user-attachments/assets/a6435686-a950-4e3a-8045-7d4cbabfef74)

Using NER, we observed that PERSON entities (Trump, Harris, etc.) dominated, followed by geopolitical (GPE) and organizational (ORG) terms. This reflects both the personalization of news and its anchoring in global political context.

### 🤖 LLM Performance Benchmark
![InnoFest (1)](https://github.com/user-attachments/assets/c06e6ebe-68a6-45e2-a243-b1a56051416a)

![InnoFest (4)](https://github.com/user-attachments/assets/d07fe31a-63e0-47f3-84b4-609ee8eda014)

We evaluated multiple LLMs (ChatGPT-4o/4.1, DeepSeek, Qwen, LLaMA 3.3, etc.) in both single-stage and multi-stage sentiment classification. ChatGPT and DeepSeek performed best in one-step reasoning, but complex prompts exposed limitations in model reliability and precision across tasks.
## Results

[Provide a summary of your findings and conclusions, including any recommendations or implications for future research. Be sure to explain how your results address your research question or problem statement.]

## Contributors

[List the contributors to your project and describe their roles and responsibilities.]

## Acknowledgments

[Thank any individuals or organizations who provided support or assistance during your project, including funding sources or data providers.]

## References

### Data Sources
UDN Knowledge Database (聯合報資料庫) – via National Development Council Open Data Portal

News articles from:

United Daily News (UDN) / PTS News Network (公視新聞) / Liberty Times (自由時報) / Economic Daily News (經濟日報) / ETtoday News / Central News Agency (CNA)

### Analytical Tools & Methods
Web Crawling & Data Cleaning: 
R with dplyr, CSV conversion

Text Preprocessing: 
CKIPTagger for Mandarin NLP / Word Segmentation (WS) / Part-of-Speech Tagging (POS) / Named Entity Recognition (NER)

Sentiment Analysis Tools:
CSentiPackage by Academia Sinica NLP Lab

Custom prompt engineering with multiple LLMs:
ChatGPT (4o, 4.1) / Meta LLaMA 3.3 / DeepSeek R1 / Qwen-3 / Microsoft Phi-4 / Google Gemma 3

### Statistical & Text Analysis
Chi-Square Test for independence / Standardized Residuals (Z-scores) / Topic Modeling / Correspondence Analysis
