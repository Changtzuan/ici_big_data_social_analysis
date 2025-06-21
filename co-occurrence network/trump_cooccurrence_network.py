
# 安裝套件
!pip install jieba networkx matplotlib

# 安裝中文字體
!wget -O NotoSansCJKtc-Regular.otf https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/TraditionalChinese/NotoSansCJKtc-Regular.otf
!mkdir -p /usr/share/fonts/truetype/custom/
!mv NotoSansCJKtc-Regular.otf /usr/share/fonts/truetype/custom/
!fc-cache -fv

# 匯入
import pandas as pd
import jieba
import networkx as nx
import matplotlib.pyplot as plt
from collections import defaultdict, Counter
import matplotlib.font_manager as fm

# 設定字型
font_path = '/usr/share/fonts/truetype/custom/NotoSansCJKtc-Regular.otf'
my_font = fm.FontProperties(fname=font_path)

# 停用詞
stopwords = set([
    '的', '了', '在', '是', '與', '和', '或', '以', '對', '為', '將', '於', '把', '從', '到',
    '被', '由', '及', '之', '等', '而', '並', '且', '其', '這', '那', '此', '每', '各',
    '指出', '表示', '稱', '說', '強調', '認為', '據悉', '據稱', '透露', '報導', '發表',
    '公布', '宣布', '宣佈', '宣稱', '今日', '昨日', '明日', '目前', '今年', '上週', '上月',
    '近期', '近日', '近日來', '當前', '當日', '今晨', '昨晚', '剛剛', '稍早', '快訊'
])

# 上傳檔案
from google.colab import files
uploaded = files.upload()
df = pd.read_csv(list(uploaded.keys())[0])

# 計算共現
co_occurrence = defaultdict(Counter)

for _, row in df.iterrows():
    text = row['新聞標題']
    words = [w for w in jieba.lcut(text) if w not in stopwords and len(w) > 1]

    if '川普' in words:
        for w in words:
            if w != '川普':
                co_occurrence['川普'][w] += 1
                co_occurrence[w]['川普'] += 1

# 取前 N 個高頻詞
N = 20
top_words = dict(co_occurrence['川普'].most_common(N))

# 建圖
G = nx.Graph()
for w, count in top_words.items():
    distance = 1 / (count + 1)
    G.add_edge('川普', w, weight=count, distance=distance)

# 畫圖
plt.figure(figsize=(10, 6))
pos = nx.spring_layout(G, seed=42)
node_size = [G.degree(n) * 600 for n in G.nodes]

nx.draw_networkx_nodes(G, pos, node_size=node_size)
nx.draw_networkx_edges(G, pos)

# 手動畫中文標籤
for node, (x, y) in pos.items():
    plt.text(x, y, node, fontproperties=my_font, fontsize=12, ha='center', va='center')

plt.title('川普與高頻共現詞 Top {} 網絡圖'.format(N), fontproperties=my_font)
plt.axis('off')
plt.show()
