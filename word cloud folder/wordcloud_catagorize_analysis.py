
# 安裝必要套件
!pip install wordcloud jieba matplotlib pandas

# 下載字型
!wget -O /usr/share/fonts/truetype/NotoSansCJKtc-Regular.otf https://github.com/googlefonts/noto-cjk/raw/main/Sans/OTF/TraditionalChinese/NotoSansCJKtc-Regular.otf

# 匯入套件
import pandas as pd
import jieba
from wordcloud import WordCloud
import matplotlib.pyplot as plt
import re

# 上傳檔案
from google.colab import files
uploaded = files.upload()

# 讀取資料
import io
file_name = list(uploaded.keys())[0]
df = pd.read_csv(io.StringIO(uploaded[file_name].decode('utf-8')))

# 過濾特定 LLM 類別
df_filtered = df[df['LLM'].isin(['支持', '中立', '反對'])]

# 聚合標題文字
text = ' '.join(df_filtered['新聞標題'].dropna().tolist())

# 自訂停用詞
stopwords = set([
    '的', '了', '在', '是', '和', '與', '及', '也', '就', '都', '而', '被',
    '對', '說', '記者', '指出', '表示', '可能', '目前', '如果', '我', '最新'
])

# jieba 斷詞
words = jieba.cut(text)

# 過濾：去標點、數字、單字、停用詞
clean_words = []
for w in words:
    w = w.strip()
    if len(w) < 2:
        continue
    if re.match(r'^\d+$', w):
        continue
    if w in stopwords:
        continue
    clean_words.append(w)

# 詞頻統計
from collections import Counter
word_freq = Counter(clean_words)
print(word_freq.most_common(20))

# 產生文字雲
wc = WordCloud(
    font_path='/usr/share/fonts/truetype/NotoSansCJKtc-Regular.otf',
    background_color='white',
    width=1000,
    height=700
).generate(' '.join(clean_words))

plt.figure(figsize=(12, 9))
plt.imshow(wc, interpolation='bilinear')
plt.axis('off')
plt.show()
