# %% 匯入必要的套件
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties
import matplotlib.patches as mpatches
import re
import numpy as np

# 指定字型路徑
font_path = "NotoSansCJKtc-Regular.otf"  # 確保路徑正確
font_prop = FontProperties(fname=font_path)

# %% 讀取兩個檔案
# 讀取數據
df1 = pd.read_csv("../UDNdata/udn_articles_NER.csv") 
df2 = pd.read_csv("../NDCdata/ndc_articles_NER.csv") 
df = pd.read_csv("../all_articles.csv")

# 合併新聞類型到 df1
df1 = pd.merge(df1, df[['識別碼', 'folder']], left_on='ID', right_on='識別碼', how='left')
df1.rename(columns={'folder': 'Type'}, inplace=True)
df1 = df1[['ID', 'Type', 'ner_result']]  # 假設 df1 已含 ner_result
df2 = df2[['ID', 'Type', 'ner_result']]  # 假設 df2 已含 ner_result

# 合併兩個檔案
df_combined = pd.concat([df1, df2], ignore_index=True)

# %% 過濾資料
def parse_ner_result(text):
    if pd.isnull(text) or text.strip() == "" or text.strip() == "nan":
        return set()
    # 匹配 (數字, 數字, '標籤', '實體')
    pattern = r"\((\d+), (\d+), '([^']+)', '([^']+)'\)"
    result = set()
    for match in re.findall(pattern, text):
        start, end, label, word = match
        result.add((int(start), int(end), label, word.strip()))
    return result

# 將 ner_result 欄位從字串轉回 set
df_combined["ner_result"] = df_combined["ner_result"].apply(parse_ner_result)

important_labels = {"PERSON", "ORG", "GPE", "LOC", "EVENT", "NORP"}

def extract_important_entities(ner_set):
    return [item[3] for item in ner_set if item[2] in important_labels]

df_combined["ner_words"] = df_combined["ner_result"].apply(extract_important_entities)

# %% 展開 ner_words
filtered_df = df_combined.explode("ner_words").rename(columns={"ner_words": "word"})
# 只保留有實體的行
filtered_df = filtered_df[filtered_df["word"].notnull() & (filtered_df["word"] != "")]
# 去掉標點符號
filtered_df["word"] = filtered_df["word"].replace(r"[，。]", '', regex=True)

# 篩選 Type 欄位
allowed_types = {"財經新聞"}
filtered_df = filtered_df[filtered_df["Type"].isin(allowed_types)]

# %% 建立共現矩陣
# 初始化共現字詞的字典
co_occurrence = {}

# 按新聞 ID 分組，計算字詞共現
for news_id, group in filtered_df.groupby("ID"):
    words = group["word"].tolist()
    for i, word1 in enumerate(words):
        for j, word2 in enumerate(words):
            if i < j:  # 防止重複計算
                pair = tuple(sorted([word1, word2]))
                co_occurrence[pair] = co_occurrence.get(pair, 0) + 1

# %% 建立網絡圖
# 篩選出現次數大於 100 的邊

# 1. 取得所有 weight
all_weights = np.array(list(co_occurrence.values()))

# 2. 計算前 0.1% 的門檻值
threshold = np.percentile(all_weights, 99.8)  # 99.9百分位

filtered_co_occurrence = {
    pair: weight
    for pair, weight in co_occurrence.items()
    if (weight > threshold) and (pair[0] != '英特爾')
}

# 初始化 NetworkX 圖
G = nx.Graph()

# 添加邊和權重
for (word1, word2), weight in filtered_co_occurrence.items():
    if word1 != word2:  # 確保不添加自環
        if not G.has_node(word1):
            G.add_node(word1)
        if not G.has_node(word2):
            G.add_node(word2)
        # 添加邊和權重
        G.add_edge(word1, word2, weight=weight)

# 添加節點屬性（新聞分類 Type）
for node in G.nodes:
    node_types = filtered_df[filtered_df["word"] == node]["Type"]
    if not node_types.empty:
        # 取眾數（次數最多的 Type），若有多個眾數則取第一個
        most_common_type = node_types.mode().iloc[0]
        G.nodes[node]["Type"] = most_common_type

# %% 設置川普為核心
core_word = "川普"
if core_word in G.nodes:
    core_edges = [(core_word, neighbor) for neighbor in G.neighbors(core_word)]
    edge_colors = ["red" if edge in core_edges else "black" for edge in G.edges]
else:
    edge_colors = "black"

# %% 畫圖
plt.figure(figsize=(15, 15))

# 設置節點顏色，根據新聞分類 (Type)
node_colors = []
color_map = {
    "兩岸新聞": "blue",
    "國際新聞": "green", 
    "政治新聞": "orange",
    "財經新聞": "purple",
    "即時新聞": "red",
}

for node in G.nodes:
    node_type = G.nodes[node].get("Type", "其他")  # 直接取字串
    node_colors.append(color_map.get(node_type, "gray"))

# 使用 spring_layout 來調整節點位置
pos = nx.spring_layout(G, seed=42, k=2, iterations=50)

# 繪製網絡圖（不顯示標籤）
nx.draw_networkx_edges(G, pos, edge_color=edge_colors, width=0.5, alpha=0.5)

base_size = 800
size_per_char = 1200

node_sizes = []
for node in G.nodes:
    node_length = len(node)
    node_sizes.append(base_size + (node_length - 1) * size_per_char)

nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=node_sizes, alpha=0.8)

# 手動添加中文標籤
for node, (x, y) in pos.items():
    plt.text(x, y, node, fontproperties=font_prop, fontsize=10, 
             ha='center', va='center', color='white', weight='bold')

# 添加標題
plt.title("Network of Words - Trump as the center (Top 0.2%)", fontproperties=font_prop, fontsize=20)

# 創建圖例
legend_elements = [
    mpatches.Patch(color='blue', label='兩岸新聞'),
    mpatches.Patch(color='green', label='國際新聞'),
    mpatches.Patch(color='orange', label='政治新聞'),
    mpatches.Patch(color='purple', label='財經新聞'),
    mpatches.Patch(color='red', label='即時新聞'),
    mpatches.Patch(color='gray', label='其他')
]
plt.legend(handles=legend_elements, prop=font_prop, loc='upper right', fontsize=12)

# 移除軸
plt.axis('off')

# 顯示圖表
plt.tight_layout()
plt.show()
# %%
