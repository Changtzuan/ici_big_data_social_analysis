# Trump's New World: Media Framing in Taiwan

A Comparative Study of the 2024 Election

## Project Context

This project explores how Taiwanese media framed Donald Trump during the 2024 U.S. presidential election by building a full-stack NLP pipeline for large-scale sentiment and framing analysis. We evaluated over 100,000 data and ultimately collected over 7,000 Mandarin-language news articles via authorized web crawling from sources such as UDN, PTS, Liberty Times, and ETtoday, all filtered using the keyword “川普” (Trump). After cleaning and structuring the data with dplyr and exporting to CSV, we used CKIPTagger for Mandarin-specific word segmentation, POS tagging, and named entity recognition.

For the sentiment evaluation, the core aim of the project was to benchmark the labeling and reasoning performance of leading large language models (LLMs) on Mandarin political news. We evaluated several LLMs such as ChatGPT-4o/4.1/o3, LLaMA 3.3, Qwen, and DeepSeek, using two classification frameworks: a single-stage direct sentiment classification, and a two-step reasoning-based labeling process with custom prompts. Accuracy was compared and calculated against human-labeled samples, revealing significant differences across models and prompt strategies.

Eventually, ChatGPT-o3 demonstrated the most reliable and consistent performance. All visualizations and analytical results in this project are then based on its labeling output. Our analysis included chi-square tests, topic modeling, and correspondence analysis to reveal ideological patterns and framing biases across media outlets. This project illustrates how LLM-driven NLP workflows can be applied to multilingual media research, providing insight into political discourse and the computational challenges of sentiment modeling in non-English contexts.

## Getting Started

This project analyzes news sentiment regarding Trump using multiple data sources and AI models. Follow the instructions below to set up and run the complete analysis pipeline.


### **Data Sources**

Our research utilizes two primary data sources for comprehensive news analysis:

#### **🏛️ National Development Council (NDC) Open Data Portal**
- **Source Type**: Government authorized data
- **Data Volume**: ~6,000 articles (filtered from over 900,000 articles)
- **Content Filter**: All articles contain keyword "川普" (Trump)
- **Data Quality**: Official government data with high reliability
- **Access Method**: Web scraping through R scripts

#### **📰 UDN Knowledge Database** 
- **Source Type**: Commercial news media
- **Data Volume**: ~1,000 articles with full text
- **Content Filter**: All articles contain keyword "川普" (Trump)
- **Coverage**: Two major news sources
- **Access Method**: Web scraping through Python scripts

#### **📊 Data Structure**
Each collected article contains:
- **Headlines and subheadlines**: Primary content identifiers
- **Full article content**: Complete text for analysis
- **News category/section**: Topic classification
- **Publication date**: Temporal analysis capability
- **Source media outlet**: Origin identification

#### **🗞️ Covered News Sources**
**UDN Group:**
- UDN (聯合報)
- Economic Daily News (經濟日報)

**NDC Sources:**
- PTS News (公視新聞)
- Liberty Times (自由時報)
- ETtoday News (ETtoday 新聞)
- Central News Agency (中央社)


### **AI Models Used**

This project evaluates multiple state-of-the-art language models for sentiment classification:

#### **📋 Model List**
- **OpenAI Models**: ChatGPT-o3, ChatGPT-o1, ChatGPT-o1-mini, ChatGPT-gpt-4o
- **DeepSeek Models**: DeepSeek R1 0528, DeepSeek V3 0324
- **Meta Models**: Llama 3.3 (70B), Llama 3.3 (19B)
- **NVIDIA Models**: Llama 3.1 (253B)
- **Google Models**: Gemma 3 (27B)
- **Microsoft Models**: Phi 4
- **Qwen Models**: Qwen3-235B-A22B, QwQ (32B)
- **Local Models**: Llama-3-Taiwan-70B

#### **🎯 Classification Approaches**

**Single-Stage Classification (Approach 1):**
```python
prompt = (
    "你現在是新聞情緒分類專家，將分類新聞內容對於川普是支持、中立、反對、無關。\n\n"
    "請按照下列標準進行情緒分類：\n\n"
    "中立：對於川普的相關內容，客觀陳述事實，文字平鋪直敘，不帶情緒色彩。\n\n"
    "支持：對於川普的相關內容，正面傳達對川普有利的訊息，或讓讀者對川普產生好印象。例如：強調其政績、領袖特質、正面詞彙、支持者的聲音，或明顯貶低其對手。\n\n"
    "反對：對於川普的相關內容，負面傳達對川普不利的訊息，或讓讀者對川普產生負面印象。例如：強調爭議、負面事件、批評性措辭、引用反對者觀點居多。\n\n"
    "無關：如果內容與川普完全無關。\n\n"
    "請仔細閱讀以下新聞標題及內容，評估這篇新聞對川普的立場，請不要回傳其他文字或標點符號，只回傳支持、中立、反對、無關：\n\n"
    f"新聞標題：{title}\n"
    f"新聞出自：{media}\n"
    f"新聞全文：{news_content}"
)
```

**Two-Stage Reasoning Classification (Approach 2):**

*Step 1: Emotion Sentence Extraction*
```python
prompt_step1 = (
    "你是一位專精於新聞情感分析的AI。你的任務是仔細閱讀以下新聞內容，並專注於找出任何對主要實體「川普」帶有情感色彩的描述。\n\n"
    "請遵循以下指示：\n\n"
    "1.  **識別情感句：** 從新聞文本中，逐句提取所有直接描述「川普」並帶有明顯正面或負面情感（例如：讚揚、批評、喜愛、厭惡、嘲諷、同情等）的句子。請列出這些句子的原文。\n"
    "2.  **中立內容處理：** 如果新聞內容僅為客觀事實陳述，用詞中性，未對「川普」表達任何情感偏向，且可能平衡呈現了不同觀點，請直接回覆「本新聞內容為中立。」，無需列舉句子。\n"
    "3.  **無關內容處理：** 如果新聞內容完全未提及「川普」，或者僅在與新聞主題無關的背景資訊中極其簡略地提及，且該提及不帶任何情感色彩，請直接回覆「本新聞內容為無關。」，無需列舉句子。\n"
    "4.  **輸出格式：**\n"
    "    *   若為情感句，請直接列出原文，每句一行。不要添加任何額外的解釋、編號或評論。\n"
    "    *   若為中立或無關，則按上述指示回覆特定短語。\n\n"
    "請開始分析以下新聞標題與內容："
)

completion = client.chat.completions.create(
    model="o3",  # 使用最新的模型
    messages=[{"role": "system", "content": prompt_step1},
              {"role": "user", "content": f"{title}\n\n{news_content}"}],
    service_tier="flex"
)
```

*Step 2: Sentiment Classification*
```python
prompt_step2 = (
    "你是一位情感分析專家。以下文字是從一篇關於「川普」的新聞中提取出的帶有情感色彩的句子。請基於這些句子，判斷新聞內容對「川普」的整體情感立場。\n\n"
    "請遵循以下指示：\n\n"
    "1.  **判斷立場：** 綜合分析提供的所有句子，判斷整體情感是「支持」川普還是「反對」川普。\n"
    "2.  **簡潔回覆：** 你的回答必須且只能是「支持」或「反對」這兩個詞中的一個。不要包含任何其他文字、解釋、標點符號或空格。\n\n"
    "請分析以下內容並給出你的判斷："
)

senti_completion = client.chat.completions.create(
    model="o3",  # 使用最新的模型
    messages=[{"role": "system", "content": prompt_step2}, 
              {"role": "user", "content": response_content}],
    service_tier="flex"
)
```

### Project Workflow

#### Workflow Diagram

```mermaid
flowchart LR
    subgraph DC ["📊 Data Collection Phase"]
      direction TB
      subgraph NEWS ["News Sources"]
        direction TB
        A1["🏛️ NDC News Collection<br/>(Various Category R Scripts)"] 
        A2["📺 PTS News Collection<br/>(PTSdata.py)"]
        A3["📰 UDN News Collection<br/>(UDNdata.py)"]
      end
      A1 --> B1["📄 NDC Articles<br/>ndc_articles.csv"]
      A2 -.-> B2["📄 PTS Articles<br/>pts_articles.csv"]
      A3 --> B3["📄 UDN Articles<br/>udn_articles.csv"]
      B2 -.->|Manual Merge| B1
    end
    
    DC --> TP_DIST[ ]
    DC --> SB_DIST[ ]
    DC --> DI_DIST[ ]
    
    subgraph TP ["🔍 Text Processing Branch"]
      direction TB
      TP_DIST -.-> D1["⚙️ CKIP_NDC.R<br/>Chinese NLP Processing"]
      TP_DIST -.-> D2["⚙️ CKIP_UDN.R<br/>Chinese NLP Processing"]
      D1 --> E1["📋 NDC Processed<br/>• ndc_articles_POS.csv<br/>• ndc_articles_NER.csv"]
      D2 --> E2["📋 UDN Processed<br/>• udn_articles_POS.csv<br/>• udn_articles_NER.csv"]
    end
    
    subgraph SB ["🎯 Sampling Branch"]
      direction TB
      SB_DIST -.-> F1["🎲 Sample.py<br/>Random Selection<br/>(NDC + UDN Articles)"]
      F1 --> G1["📝 100 Sampled Articles<br/>• ndc_articles_sampled.csv<br/>• udn_articles_sampled.csv"]
      G1 --> H2["🔧 MergeData.R<br/>(Sampling)"]
      H2 --> I2["📊 Sampled Dataset<br/>sampled_articles.csv"]
    end
    
    subgraph DI ["🔗 Data Integration Branch"]
      direction TB
      DI_DIST -.-> H1["🔧 MergeData.R<br/>(Complete Dataset)<br/>(NDC + UDN Articles)"]
      H1 --> I1["📊 Complete Dataset<br/>all_articles.csv"]
    end
    
    I2 --> MA_DIST[ ]
    
    subgraph MA ["👥 Manual Analysis Phase"]
      direction TB
      MA_DIST -.-> J1["✍️ Manual Labeling<br/>Ground Truth Creation"]
      J1 --> K1["📋 Labelled Dataset<br/>Labelled.csv"]
    end
    
    I1 --> AI_DIST1[ ]
    K1 --> AI_DIST2[ ]
    
    subgraph AI ["🤖 AI Analysis Phase"]
      direction TB
      AI_DIST1 -.-> L1["🚀 AI Analysis<br/>(Complete Dataset)"]
      AI_DIST2 -.-> L2["🚀 AI Analysis<br/>(Labeled Dataset)"]
      L1 --> M1["🔧 Label_OneStep.py<br/>Label_TwoSteps.py"]
      L2 --> M2["🔧 Label_OneStep.py<br/>Label_TwoSteps.py"]
      M1 --> N1["📈 AI Results<br/>all_articles_results.csv"]
      M2 --> N2["📊 LLMsSCORE<br/>Model Comparison Results"]
    end
    
    E1 --> FA_DIST1[ ]
    E2 --> FA_DIST2[ ]
    N1 --> FA_DIST3[ ]
    N2 --> FA_DIST4[ ]
    
    %% ========== Final Analysis Phase with Q1-Q4 ==========
    subgraph FA ["📈 Final Analysis Phase"]
      direction TB
      FA_DIST1 -.-> Q1["Q1: Vocabulary &<br/> Framing Patterns<br/>資料來源: POS (NDC, UDN)"]
      FA_DIST2 -.-> Q4["Q4: Entity Network Analysis<br/>資料來源: NER (NDC, UDN)"]
      FA_DIST3 -.-> Q2["Q2: Sentiment by Media Outlet <br/>& Statistical Significance of Framing"]
      FA_DIST3 -.-> Q3["Q3: Temporal Coverage Trends <br/>& Sentiment Shifts Over Time"]
      FA_DIST4 -.-> O1["🔬 Comprehensive Analysis"]
      Q1 --> O1
      Q2 --> O1
      Q3 --> O1
      Q4 --> O1
      O1 --> P1["📋 Final Research Results<br/>Combined Insights"]
    end

    style DC fill:#e1f5fe,stroke:#01579b,stroke-width:4px,color:#000
    style NEWS fill:#f0f8ff,stroke:#4682b4,stroke-width:2px,color:#000
    style TP fill:#f3e5f5,stroke:#4a148c,stroke-width:4px,color:#000
    style SB fill:#fff3e0,stroke:#e65100,stroke-width:4px,color:#000
    style DI fill:#e8f5e8,stroke:#1b5e20,stroke-width:4px,color:#000
    style MA fill:#fce4ec,stroke:#880e4f,stroke-width:4px,color:#000
    style AI fill:#fff8e1,stroke:#f57f17,stroke-width:4px,color:#000
    style FA fill:#f1f8e9,stroke:#33691e,stroke-width:4px,color:#000
    
    classDef collection fill:#e1f5fe,stroke:#01579b,stroke-width:3px,color:#000,font-size:14px
    classDef processing fill:#f3e5f5,stroke:#4a148c,stroke-width:3px,color:#000,font-size:14px
    classDef sampling fill:#fff3e0,stroke:#e65100,stroke-width:3px,color:#000,font-size:14px
    classDef integration fill:#e8f5e8,stroke:#1b5e20,stroke-width:3px,color:#000,font-size:14px
    classDef manual fill:#fce4ec,stroke:#880e4f,stroke-width:3px,color:#000,font-size:14px
    classDef ai fill:#fff8e1,stroke:#f57f17,stroke-width:3px,color:#000,font-size:14px
    classDef final fill:#f1f8e9,stroke:#33691e,stroke-width:4px,color:#000,font-size:14px
    classDef data fill:#f5f5f5,stroke:#424242,stroke-width:2px,color:#000,font-size:12px
    classDef invisible fill:transparent,stroke:transparent,color:transparent
    
    class A1,A2,A3 collection
    class D1,D2 processing
    class F1 sampling
    class H1,H2 integration
    class J1 manual
    class L1,L2,M1,M2 ai
    class Q1,Q2,Q3,Q4,O1 final
    class B1,B2,B3,E1,E2,G1,I1,I2,K1,N1,N2,P1 data
    class TP_DIST,SB_DIST,DI_DIST,MA_DIST,AI_DIST1,AI_DIST2,FA_DIST1,FA_DIST2,FA_DIST3,FA_DIST4 invisible
```

#### Legend
- 📊 **Data Collection**: Gathering news articles from multiple sources
- 🔍 **Text Processing**: NLP processing using CKIP tools
- 🎯 **Sampling**: Random selection for manual analysis
- 🔗 **Data Integration**: Combining all datasets
- 👥 **Manual Analysis**: Human labeling for ground truth
- 🤖 **AI Analysis**: Automated labeling and comparison
- 📈 **Final Analysis**: Comprehensive results synthesis


### **Installation Requirements**

#### **Prerequisites**
- **R**: Version 4.0+ recommended
- **Python**: Version 3.8+ recommended
- **OpenAI API Key**: Required for AI analysis
- **Internet Connection**: Required for data collection and API calls

#### **R Environment**
Make sure you have R installed. Install the required R packages by running the following commands in your R console:

```R
# Data reading and manipulation
install.packages("readr")        # For reading and writing CSV files
install.packages("dplyr")        # For data manipulation
install.packages("tidyr")        # For data tidying

# String processing
install.packages("stringr")      # For string processing

# Data visualization
install.packages("ggplot2")      # For data visualization
install.packages("showtext")     # For font support in plots
install.packages("systemfonts")  # For system font management

# Date and time handling
install.packages("lubridate")    # For date and time processing

# Advanced functionality
install.packages("purrr")        # For functional programming
install.packages("httr")         # For HTTP requests
install.packages("rvest")        # For web scraping
install.packages("progressr")    # For progress bar display
install.packages("reticulate")   # To call Python from R
```

#### **Python Environment**
Ensure you have Python installed (recommended version: 3.8+). Install the required Python packages using `pip`:

```plaintext
pip install openai==1.78.1       # Interaction with OpenAI API
pip install pandas==2.0.3        # Data manipulation
pip install playwright==1.48.0   # Asynchronous browser automation
pip install selenium==4.10.0     # Browser automation
pip install ckiptagger==0.2.1    # Chinese word segmentation
pip install tqdm==4.67.1         # Progress bar display
pip install wordcloud==1.9.4     # Word cloud visualization
pip install networkx==3.1        # Network analysis
```

#### **CKIPTagger Setup**
CKIPTagger is essential for Chinese NLP processing. Follow these steps:

1. **Installation**: Follow the official guide at [https://github.com/ckiplab/ckiptagger](https://github.com/ckiplab/ckiptagger)
2. **Model Download**: Download the required pre-trained models as specified in their documentation
3. **Verification**: Test the installation before running the main scripts

#### **API Configuration**
- **OpenAI API**: 
   - Obtain an API key from OpenAI
   - Set the API key in your environment variables
   - Configure rate limits to avoid API quota issues

```python
import openai
client = openai.OpenAI(api_key="your-api-key-here")
```


### **Execution Flow Summary**

```
Data Collection → [Text Processing | Sampling | Data Integration] 
                     ↓              ↓            ↓
                Text Results   Manual Analysis  Complete Dataset
                     ↓              ↓            ↓
                     └──── AI Analysis Phase ────┘
                              ↓
                        Final Analysis
```


### **Important Notes**

- **Parallel Execution**: Phases 2 (Branches A, B, C) can be run in parallel after Phase 1 completion
- **Dependencies**: 
  - Phase 3 (Manual Analysis) requires Branch B (Sampling) completion
  - Phase 4 (AI Analysis) requires Branches B and C completion
  - Phase 5 (Final Analysis) requires all previous phases
- **CKIPTagger Setup**: Ensure CKIPTagger models are properly installed before running text processing scripts
- **API Configuration**: Configure OpenAI API keys before running AI analysis scripts
- **File Management**: Ensure output directories exist and have proper write permissions

### **Expected Outputs**

After completing all steps, you should have:

- **📊 Raw Data**: `ndc_articles.csv`, `udn_articles.csv`, `pts_articles.csv`
- **🔍 Processed Data**: `*_POS.csv`, `*_NER.csv` files with NLP annotations
- **🎯 Sample Data**: `sampled_articles.csv` with 100 selected articles
- **👥 Ground Truth**: `Labelled.csv` with manual sentiment labels
- **🤖 AI Results**: Model performance comparisons and sentiment predictions
- **📈 Final Analysis**: Comprehensive research insights and findings

### **Troubleshooting**

#### **Common Issues**
- **Memory Errors**: Process large datasets in smaller batches
- **API Rate Limits**: Implement delays between API calls
- **Encoding Issues**: Ensure UTF-8 encoding for Chinese text
- **Missing Dependencies**: Verify all packages are properly installed
- **Network Timeouts**: Check internet connection for data collection

#### **Support Resources**
- **CKIPTagger Issues**: Refer to their GitHub repository
- **OpenAI API Problems**: Check OpenAI documentation
- **R Package Issues**: Use `install.packages()` with dependencies=TRUE
- **Python Environment**: Consider using virtual environments

## File Structure

### **Project Directory Structure**

```plaintext
ici_big_data_social_analysis\                                                 # Project root directory
|
├── .git\                                                                     # Git version control folder
|
├── Analysis\                                                                 # Analytical scripts, plots, and results
├── Q1 Vocabulary & Framing Patterns\                                         # Vocabulary and framing pattern analysis
│   │   ├── [word cloud images]
│   │   ├── [top-20 words plots]
│   │   ├── Q1.R
│   │   ├── WordCloud.py
│   ├── Q2 Sentiment by Media Outlet & Statistical Significance of Framing\   # Sentiment & framing significance
│   │   ├── [chi-square test plots, distribution charts]
│   │   ├── Q2.R
│   ├── Q3 Temporal Coverage Trends & Sentiment Shifts Over Time\             # Temporal trends & sentiment shift
│   │   ├── [trend charts, event-marked plots]
│   │   ├── Q3.R
│   ├── Q4 Entity Network Analysis\                                           # Entity network analysis
│   │   ├── [network graphs, entity distribution plots]
│   │   ├── Q4.R
│   │   ├── WordNetwork.py
│   │   ├── [font files/other resources]
|
├── LLMsSCORE\                                                               # Scores of various LLMs for classifying 100 sampled articles using two prompts
│   ├── [LLM result-related files]
│
├── NDCdata\                                                                 # NDC news-related data
│   ├── ndc_articles_sampled\                                                # Stores full text of 100 randomly sampled articles
│   ├── trump_articles\                                                      # Stores full text of all categorized news articles
│   ├── trump_articles_POS_TXT\                                              # Stores WS+POS processed full text of all categorized news articles
│   ├── [News category folders]                                              # E.g., Cross-Strait News, Breaking News, etc.
│   │   ├── trump_articles\                                                  # Full text of news articles in the specific category
│   │   ├── trump_articles_[category].R                                      # Script for scraping and processing news articles in the category
│   │   ├── trump_articles_[category].csv                                    # Exported news data for the category (output from trump_articles_[category].R)
│   ├── ndc_articles.csv                                                     # Complete dataset of NDC news (output from CKIP_NDC.R)
│   ├── ndc_articles_NER.csv                                                 # NER results for NDC news (output from CKIP_NDC.R)
│   ├── ndc_articles_POS.csv                                                 # WS+POS results for NDC news (output from CKIP_NDC.R)
│   ├── ndc_articles_sampled.csv                                             # 100 randomly sampled NDC news articles (output from Sample.py)
│   ├── PTSdata.py                                                           # Script using Playwright to scrape NDC news
│
├── UDNdata\                                                                 # UDN news-related data
│   ├── trump_articles\                                                      # Stores full text of all categorized news articles
│   ├── trump_articles_POS_TXT\                                              # Stores WS+POS processed full text of all categorized news articles
│   ├── udn_articles_sampled\                                                # Stores full text of 100 randomly sampled articles
│   ├── udn_articles.csv                                                     # Complete dataset of UDN news (output from UDNdata.py)
│   ├── udn_articles_NER.csv                                                 # NER results for UDN news (output from CKIP_UDN.R)
│   ├── udn_articles_POS.csv                                                 # WS+POS results for UDN news (output from CKIP_UDN.R)
│   ├── udn_articles_sampled.csv                                             # 100 randomly sampled UDN news articles (output from Sample.py)
│   ├── UDNdata.py                                                           # Script using Selenium to scrape UDN news
│
├── sample_articles\                                                         # Stores full text of 100 randomly sampled articles (combined from NDC and UDN)
│
├── all_articles.csv                                                         # Complete dataset of all news articles (output from MergeData.R)
├── all_articles_results.csv                                                 # AI model analysis results for all news articles (using OpenAI-o3, output from Label_OneStep.py)
├── sampled_articles.csv                                                     # 100 randomly sampled articles (output from MergeData.R)
├── Labelled.csv                                                             # 100 manually labeled news articles
|
├── CKIP_NDC.R                                                               # Uses CKIPTagger to analyze NDC news data
├── CKIP_UDN.R                                                               # Uses CKIPTagger to analyze UDN news data
├── MergeData.R                                                              # Combines and processes multiple datasets
|
├── Label_OneStep.py                                                         # Uses OpenAI API for one-step sentiment and label analysis of news articles
├── Label_TwoSteps.py                                                        # Uses OpenAI API for two-step sentiment and label analysis of news articles
├── Sample.py                                                                # Randomly selects 100 news articles for manual labeling
```

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
| **Q1: POS Results**              | `ndc_articles_POS.csv`, `udn_articles_POS.csv` | Used for vocabulary & framing pattern analysis (word clouds, top words, etc.)    |
| **Q2: Sentiment & Framing**      | `all_articles_results.csv`  | Used for sentiment by media outlet & framing significance (Q2 analysis)         |
| **Q3: Temporal & Sentiment Trends** | `all_articles_results.csv`  | Used for temporal coverage trends & sentiment shifts over time (Q3 analysis)     |
| **Q4: NER Results**              | `ndc_articles_NER.csv`, `udn_articles_NER.csv` | Used for entity network analysis (Q4 analysis)                                  |

## Analysis

### Analysis Methods & Visualizations
We applied a full-stack NLP pipeline and multiple visualization techniques to uncover how Taiwanese media framed Donald Trump during the 2024 U.S. presidential election. Below are the core analyses and their associated insights:

### 🧠 Vocabulary & Framing Patterns

#### 1. High-Frequency Words & Media Composition

![Q1_ Top 20 Trump-Related Words (Media Composition)](Analysis/Q1%20Vocabulary%20&%20Framing%20Patterns/Top-20%20Words%20(Media%20Composition).png)

The bar chart of the top 20 Trump-related words shows that **personal names and country names**—such as `USA`, `Trump`, `Harris`, `President`, `Biden`, and `Taiwan`—dominate the coverage. These terms vary in frequency across different media sources, indicating diverse editorial focuses. Other frequent terms include `Report`, `Candidate`, `China`, and `Democrats`, reflecting an emphasis on political figures, countries, and election-related issues.

#### 2. Word Cloud Comparison: With vs. Without Stopwords

![Q1_ Wordcloud)](Analysis/Q1%20Vocabulary%20&%20Framing%20Patterns/Wordcloud.png)

- **With Stopword Removal:**  
  The word cloud highlights evaluative and action-oriented terms like `support`, `voter`, `policy`, `believe`, and `activity`. These words suggest that media framing often involves subjective assessments, attitudes toward candidates, and policy discussions. Across various news categories (politics, international, finance), words such as `support` and `policy` are consistently prominent.

![Q1_ Wordcloud)](Analysis/Q1%20Vocabulary%20&%20Framing%20Patterns/Wordcloud_NoStop.png)

- **Without Stopword Removal:**  
  In the absence of stopword filtering, the word cloud is heavily dominated by **proper nouns** and **geopolitical terms**: `USA`, `Trump`, `Biden`, `Harris`, `President`, `Taiwan`, `TSMC`, and `market`. This demonstrates that, without filtering, the discourse is shaped primarily by the main actors and locations in the news stories.

### 📰 Framing Patterns by Media Outlet


#### 1. Framing Distribution

![Q2_ Framing Distribution by Media Outlet](Analysis/Q2%20Sentiment%20by%20Media%20Outlet%20&%20Statistical%20Significance%20of%20Framing/Framing%20Distribution%20by%20Media%20Outlet.png)

The distribution of framing stances varies noticeably across different media outlets. Most outlets tend to adopt a predominantly neutral stance in their reporting. However, some outlets, such as Liberty Times and PTS, display a higher proportion of supportive or oppositional frames compared to others. This suggests that while neutrality is common, certain outlets are more likely to take a clear stance in their coverage.

#### 2. Statistical Significance

To determine whether these differences in framing are meaningful, a chi-square test was conducted. The results indicate that the variation in framing across media outlets is highly significant (p < 2.2e-16). This confirms that the distribution of stances is not random; rather, each media outlet systematically exhibits its own framing patterns.

#### 3. Residual Heatmap: Media vs. Framing

![Q2_ Standardized Residual Heatmap (Media x Framing)](Analysis/Q2%20Sentiment%20by%20Media%20Outlet%20&%20Statistical%20Significance%20of%20Framing/Standardized%20Residual%20Heatmap%20(Media%20x%20Framing).png)

The residual heatmap further illustrates how each media outlet deviates from what would be expected if framing were distributed randomly. For instance, Liberty Times and ETtoday show a much higher frequency of supportive framing than expected, while United Daily News (聯合報) demonstrates a stronger oppositional stance. In contrast, Central News Agency (中央通訊社) significantly underrepresents supportive framing. These patterns, highlighted in the heatmap by positive (red) and negative (blue) residuals, reveal the unique framing biases of each outlet.

### 🕒 Temporal Coverage Trends
![Q3_ Number of Trump-related news reports during the 2024 election period with big events (weekly statistics).png](Analysis/Q3%20Temporal%20Coverage%20Trends%20&%20Sentiment%20Shifts%20Over%20Time/Number%20of%20Trump-related%20news%20reports%20during%20the%202024%20election%20period%20with%20big%20events%20(weekly%20statistics).png)

The volume of Trump-related news reports during the 2024 election period displayed a distinct U-shaped pattern. Coverage surged sharply following Biden’s withdrawal in late July, marking the first major peak. After this event, the number of articles gradually declined and remained relatively steady through August and September, with only minor fluctuations around other campaign milestones, such as polling leads and candidate debates. However, as the election approached, media attention intensified again. There was a pronounced spike in late October, coinciding with the final campaign push, and coverage reached its highest point immediately after Trump’s victory in early November. These trends suggest that media interest was closely tied to major electoral events, with significant increases in reporting activity both at the outset and conclusion of the campaign period.

### 📈 Sentiment Shifts Over Time
![Q3_ Trend of stance proportions over time (by week).png](Analysis/Q3%20Temporal%20Coverage%20Trends%20&%20Sentiment%20Shifts%20Over%20Time/Trend%20of%20stance%20proportions%20over%20time%20(by%20week).png)

Throughout the campaign, neutral reporting was the dominant framing category, consistently accounting for the majority of coverage each week. The proportion of neutral articles generally hovered above 50% and often approached or exceeded 70%, especially during periods of less dramatic political activity. Negative (oppositional) framing maintained a steady presence but rarely surpassed the neutral category, while positive (supportive) coverage remained minimal for most of the campaign. Notably, there was a slight increase in supportive sentiment immediately following Trump’s election victory in early November, indicating a temporary shift in media tone in response to the outcome. Despite this brief uptick, oppositional and supportive stances were both overshadowed by the prevalence of neutral reporting, highlighting the media’s tendency to maintain a balanced perspective during the election cycle.

### 🧾 Entity Network Analysis
![Q4_ Network of Words](Analysis/Q4%20Entity%20Network%20Analysis/All_TrumpNetwork.png)

The entity network analysis of Trump-related news reveals several important patterns in both the structure of associations and the types of entities most frequently mentioned. The word network diagram, with Trump at its center, highlights the dense web of connections linking him to a diverse array of individuals, locations, organizations, and political topics. Notably, Trump is closely associated with other key political figures such as Kamala Harris and Joe Biden, as well as with major U.S. states, political parties, and international actors like China, Taiwan, Japan, and Russia. This illustrates the global scope and multifaceted nature of media coverage surrounding Trump, extending beyond domestic politics into international relations and economic affairs. Additionally, the presence of media organizations and news agencies as prominent nodes underscores the influential role of the press in shaping the narrative around Trump.

![Q4_ Distribution of Entity Types (Trump-Related News)](Analysis/Q4%20Entity%20Network%20Analysis/Distribution%20of%20Entity%20Types%20(Trump-Related%20News).png)
The bar chart depicting the distribution of entity types in Trump-related news further clarifies the focus of media reporting. The most frequently mentioned entities are people (PERSON) and geopolitical entities (GPE), emphasizing the centrality of individuals and countries or regions in news stories about Trump. Organizations (ORG) and dates (DATE) also feature prominently, reflecting the importance of institutions, political parties, and the timing of events in the news cycle. Quantitative entities, such as numbers, percentages, and monetary amounts, appear regularly, indicating that economic analysis and statistical reporting are common themes. Other entity types, including demographic groups, locations, and specific events, point to the broad and varied contexts in which Trump is discussed.

### 🤖 LLM Performance Benchmark
![InnoFest (1)](https://github.com/user-attachments/assets/c06e6ebe-68a6-45e2-a243-b1a56051416a)

![InnoFest (4)](https://github.com/user-attachments/assets/d07fe31a-63e0-47f3-84b4-609ee8eda014)

We evaluated multiple LLMs—including ChatGPT (4o, 4.1, o3), DeepSeek, Qwen, and LLaMA 3.3, with the use of both single-stage and multi-stage sentiment classification strategies. Our goal was to assess their ability to accurately label politically nuanced Mandarin news content. ChatGPT o3 consistently demonstrated the most balanced performance across precision, contextual reasoning, and label stability. 
## Results

[Provide a summary of your findings and conclusions, including any recommendations or implications for future research. Be sure to explain how your results address your research question or problem statement.]

## Contributors

| Avatar | Name | Role(s) |
|--------|------|---------|
| <img src="https://github.com/CJuuuuuuu.png" width="40"/> | [林佳瑢 Julia Lin](https://github.com/CJuuuuuuu) | Project manager, program writer, data mining, data labelling, LLM evaluation tester |
| <img src="https://github.com/Tang-Yunuo.png" width="40"/> | [唐羽諾 Ronald Tang](https://github.com/Tang-Yunuo) | Program writer, data visualization |
| <img src="https://github.com/abw77.png" width="40"/> | [魏予瑄 Annabelle Wei](https://github.com/abw77) | Program writer, data collection, data visualization |
| <img src="https://github.com/Changtzuan.png" width="40"/> | [張子安 Andy Chang](https://github.com/Changtzuan) | Program writer, data collection, presentation design |

## Acknowledgments

We would like to sincerely thank **Professor Pien** for every valuable guidance and support throughout this project. We also acknowledge the **United Daily News (UDN)** and the **National Development Council (NDC) Open Data Portal** for providing access to the news and open government datasets that made our analysis possible. This project would not have been achievable without the support of our academic mentors and data providers.

## References

### Data Sources
**UDN Knowledge Database** – Provided by United Daily News

**National Development Council Open Data Portal** – Used to access additional government-authorized media data

News articles were collected from:
- United Daily News (UDN)
- PTS News Network (公視新聞)
- Liberty Times (自由時報)
- Economic Daily News (經濟日報)
- ETtoday News
- Central News Agency (CNA)

### Analytical Tools & Methods
**Web Crawling & Data Cleaning:**
- R with dplyr
- CSV conversion

**Text Preprocessing:**
- CKIPTagger for Mandarin NLP
- Word Segmentation (WS)
- Part-of-Speech Tagging (POS)
- Named Entity Recognition (NER)

**Sentiment Analysis Tools:**
Custom prompt engineering with multiple LLMs:
- **OpenAI Models**: ChatGPT-o3, ChatGPT-o1, ChatGPT-o1-mini, ChatGPT-gpt-4o
- **DeepSeek Models**: DeepSeek R1 0528, DeepSeek V3 0324
- **Meta Models**: Llama 3.3 (70B), Llama 3.3 (19B)
- **NVIDIA Models**: Llama 3.1 (253B)
- **Google Models**: Gemma 3 (27B)
- **Microsoft Models**: Phi 4
- **Qwen Models**: Qwen3-235B-A22B, QwQ (32B)
- **Local Models**: Llama-3-Taiwan-70B

### Statistical & Text Analysis
- Chi-Square Test for independence
- Standardized Residuals (Z-scores)
- Topic Modeling
- Correspondence Analysis
