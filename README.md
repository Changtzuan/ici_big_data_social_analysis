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

### **Project Directory Structure**

```plaintext
ici_big_data_social_analysis\                  # Project root directory
|
├── .git\                                      # Git version control folder
|
├── LLMsSCORE\                                 # Scores of various LLMs for classifying 100 sampled articles using two prompts
│   ├── [LLM result-related files]
│
├── NDCdata\                                   # NDC news-related data
│   ├── ndc_articles_sampled\                  # Stores full text of 100 randomly sampled articles
│   ├── trump_articles\                        # Stores full text of all categorized news articles
│   ├── trump_articles_POS_TXT\                # Stores WS+POS processed full text of all categorized news articles
│   ├── [News category folders]                # E.g., Cross-Strait News, Breaking News, etc.
│   │   ├── trump_articles\                    # Full text of news articles in the specific category
│   │   ├── trump_articles_[category].R        # Script for scraping and processing news articles in the category
│   │   ├── trump_articles_[category].csv      # Exported news data for the category (output from trump_articles_[category].R)
│   ├── ndc_articles.csv                       # Complete dataset of NDC news (output from CKIP_NDC.R)
│   ├── ndc_articles_NER.csv                   # NER results for NDC news (output from CKIP_NDC.R)
│   ├── ndc_articles_POS.csv                   # WS+POS results for NDC news (output from CKIP_NDC.R)
│   ├── ndc_articles_sampled.csv               # 100 randomly sampled NDC news articles (output from Sample.py)
│   ├── PTSdata.py                             # Script using Playwright to scrape NDC news
│
├── UDNdata\                                   # UDN news-related data
│   ├── trump_articles\                        # Stores full text of all categorized news articles
│   ├── trump_articles_POS_TXT\                # Stores WS+POS processed full text of all categorized news articles
│   ├── udn_articles_sampled\                  # Stores full text of 100 randomly sampled articles
│   ├── udn_articles.csv                       # Complete dataset of UDN news (output from UDNdata.py)
│   ├── udn_articles_NER.csv                   # NER results for UDN news (output from CKIP_UDN.R)
│   ├── udn_articles_POS.csv                   # WS+POS results for UDN news (output from CKIP_UDN.R)
│   ├── udn_articles_sampled.csv               # 100 randomly sampled UDN news articles (output from Sample.py)
│   ├── UDNdata.py                             # Script using Selenium to scrape UDN news
│
├── sample_articles\                           # Stores full text of 100 randomly sampled articles (combined from NDC and UDN)
│
├── all_articles.csv                           # Complete dataset of all news articles (output from MergeData.R)
├── all_articles_results.csv                   # AI model analysis results for all news articles (using OpenAI-o3, output from Label_OneStep.py)
├── sampled_articles.csv                       # 100 randomly sampled articles (output from MergeData.R)
├── Labelled.csv                               # 100 manually labeled news articles
|
├── CKIP_NDC.R                                 # Uses CKIPTagger to analyze NDC news data
├── CKIP_UDN.R                                 # Uses CKIPTagger to analyze UDN news data
├── MergeData.R                                # Combines and processes multiple datasets
|
├── Label_OneStep.py                           # Uses OpenAI API for one-step sentiment and label analysis of news articles
├── Label_TwoSteps.py                          # Uses OpenAI API for two-step sentiment and label analysis of news articles
├── Sample.py                                  # Randomly selects 100 news articles for manual labeling
```

---

### **File Relationships**

| **Output File**             | **Source Code**              | **Description**                                                                 |
|-----------------------------|-----------------------------|-------------------------------------------------------------------------------|
| `trump_articles_[category].csv` | `trump_articles_[category].R` | Exported news data for each category, including the full text of news articles |
| `ndc_articles.csv`          | `CKIP_NDC.R`               | Complete dataset of NDC news                                                 |
| `ndc_articles_NER.csv`      | `CKIP_NDC.R`               | NER results for NDC news                                                     |
| `ndc_articles_POS.csv`      | `CKIP_NDC.R`               | WS+POS results for NDC news                                                  |
| `ndc_articles_sampled.csv`  | `Sample.py`                | 100 randomly sampled NDC news articles                                       |
| `udn_articles.csv`          | `UDNdata.py`              | Complete dataset of UDN news                                                 |
| `udn_articles_NER.csv`      | `CKIP_UDN.R`              | NER results for UDN news                                                     |
| `udn_articles_POS.csv`      | `CKIP_UDN.R`              | WS+POS results for UDN news                                                  |
| `udn_articles_sampled.csv`  | `Sample.py`                | 100 randomly sampled UDN news articles                                       |
| `sampled_articles.csv`      | `MergeData.R`             | Combined 100 randomly sampled articles from NDC and UDN                      |
| `all_articles.csv`          | `MergeData.R`             | Combined dataset of all NDC and UDN news articles                            |
| `all_articles_results.csv`  | `Label_OneStep.py`        | Sentiment and label analysis results for all news articles using OpenAI-o3   |
| `Labelled.csv`              | Manual labeling           | 100 manually labeled news articles                                           |

---

### **Installation Requirements**

#### **R Requirements**

```R
install.packages("readr")       # Read and write CSV files
install.packages("rvest")       # Web scraping
install.packages("dplyr")       # Data manipulation
install.packages("stringr")     # String processing
install.packages("purrr")       # Functional programming
install.packages("httr")        # HTTP requests
install.packages("progressr")   # Progress bar display
install.packages("reticulate")  # Calling Python from R
```

#### **Python Requirements**

```plaintext
openai==1.78.1                # Interaction with OpenAI API
pandas==2.0.3                 # Data manipulation
playwright==1.48.0            # Asynchronous browser automation
selenium==4.10.0              # Browser automation
ckiptagger==0.2.1             # Chinese word segmentation (used in R via reticulate)
tqdm==4.67.1                  # Progress bar display
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
