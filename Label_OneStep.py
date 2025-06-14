import os
from openai import OpenAI
import pandas as pd
import re

def analyze_news_sentiment(file_path, title, media):
    # 讀取新聞內容
    with open(file_path, 'r', encoding='utf-8') as file:
        news_content = file.read()

    # 準備 OpenAI API 客戶端
    client = OpenAI(
        # 這裡改為你的 OpenAI API 金鑰
        api_key="",
        # base_url="https://openrouter.ai/api/v1",
        # api_key="",
        # base_url="https://integrate.api.nvidia.com/v1",
        # api_key=""  
        timeout=900.0
    )

    # 定義提示
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

    # 發送請求到 OpenAI API
    completion = client.chat.completions.create(
        model="o3",
        # model="google/gemma-3-27b-it",
        # model="yentinglin/llama-3-taiwan-70b-instruct",
        messages=[{"role": "user", "content": prompt}],
        # temperature=0,
        # max_completion_tokens=16,
        # stream=True,
        service_tier="flex"
    )

    # 解析回應
    # response_content = ""
    # for chunk in completion:
    #     if chunk.choices[0].delta.content is not None:
    #         response_content += chunk.choices[0].delta.content

    # 提取評分
    response_content = completion.choices[0].message.content
    sentiment_score = clean_response(response_content)
    return sentiment_score

def clean_response(raw_text):
    """
    去除 <think>...</think> 區塊與其他標籤
    """
    cleaned = re.sub(r"<think>.*?</think>", "", raw_text, flags=re.DOTALL)
    cleaned = re.sub(r"<.*?>", "", cleaned)  # 萬一有其他標籤也清除
    return cleaned.strip()

input_folder = r"sampled_articles"
csv_file = r"Labelled.csv"
output_file = r"LLMsSCORE\Labelled_o3_judged.csv" 

if __name__ == "__main__":
    # 讀取 CSV 檔案
    df = pd.read_csv(csv_file)

    # 初始化情感評分列表
    sentiment_scores = []

    # 遍歷每個新聞檔案
    for index, row in df.iterrows():

        file_name = row['FULLTEXT'] + ".txt"
        if row["folder"] == "UDN":
            file_name = row['識別碼'] + ".txt"
        else:
            file_name = row["folder"] + "_" + row['識別碼'] + ".txt"
            
        title = row['新聞標題']
        media = row['來源媒體']

        file_path = os.path.join(input_folder, file_name)
        if os.path.exists(file_path):
            score = analyze_news_sentiment(file_path, title, media)
            sentiment_scores.append(score)
            print(f"檔案: {file_name}, 情感評分: {score}")
        else:
            sentiment_scores.append("檔案不存在")

    # 將情感評分添加到 DataFrame
    df['LLM'] = sentiment_scores

    # 儲存結果到新的 CSV 檔案
    df.to_csv(output_file, index=False, encoding="utf-8-sig")