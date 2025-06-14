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
        # timeout=900.0
    )

    # 定義提示
    prompt = (
        # "detailed thinking on\n"
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

    # 發送請求到 OpenAI API
    completion = client.chat.completions.create(
        model="o3",  # 使用最新的模型
        # model="nvidia/llama-3.1-nemotron-ultra-253b-v1",
        # model="yentinglin/llama-3-taiwan-70b-instruct",
        messages=[{"role": "system", "content": prompt},
                  {"role": "user", "content": f"{title}\n\n{news_content}"}],
        # temperature=0,
        # top_p=1
        # max_tokens=1024,
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
    response_content = clean_response(response_content)
    # print(f"Response content: {response_content}")

    if "本新聞內容為中立。" in response_content:
        return "中立"
    elif "本新聞內容為無關。" in response_content:
        return "無關"

    # prompt_sentiment = ("以下是出現在川普相關新聞的情緒性內容，請判斷整體立場為「支持」或「反對」川普。\n"
    #                     "- 僅回覆「支持」或「反對」，不需其他說明或標點。")
    prompt_sentiment = (
        # "detailed thinking on\n"
        "你是一位情感分析專家。以下文字是從一篇關於「川普」的新聞中提取出的帶有情感色彩的句子。請基於這些句子，判斷新聞內容對「川普」的整體情感立場。\n\n"
        "請遵循以下指示：\n\n"
        "1.  **判斷立場：** 綜合分析提供的所有句子，判斷整體情感是「支持」川普還是「反對」川普。\n"
        "2.  **簡潔回覆：** 你的回答必須且只能是「支持」或「反對」這兩個詞中的一個。不要包含任何其他文字、解釋、標點符號或空格。\n\n"
        "請分析以下內容並給出你的判斷："
    )


    senti_completion = client.chat.completions.create(
        model="o3",  # 使用最新的模型
        # model="nvidia/llama-3.1-nemotron-ultra-253b-v1",
        # model="yentinglin/llama-3-taiwan-70b-instruct",
        messages=[{"role": "system", "content": prompt_sentiment}, 
                  {"role": "user", "content": response_content}],
        # temperature=0,
        # top_p=1
        # max_tokens=1024,
        # max_completion_tokens=16,
        # stream=True,
        # service_tier="flex"
    )

    response_sentiment = senti_completion.choices[0].message.content

    sentiment_score = clean_response(response_sentiment)

    return sentiment_score

def clean_response(raw_text):
    """
    去除 <think>...</think> 區塊與其他標籤
    """
    cleaned = re.sub(r"<think>.*?</think>", "", raw_text, flags=re.DOTALL)
    cleaned = re.sub(r"<.*?>", "", cleaned)  # 萬一有其他標籤也清除
    return cleaned.strip()

# input_folder = r"sampled_articles"
input_folder = r"sampled_articles"
csv_file = r"Labelled.csv"
output_file = r"LLMsSCORE\Labelled_o3_reasoning_judged.csv" 

if __name__ == "__main__":
    # 讀取 CSV 檔案
    df = pd.read_csv(csv_file)

    # 初始化情感評分列表
    sentiment_scores = []

    # 遍歷每個新聞檔案
    for index, row in df.iterrows():

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