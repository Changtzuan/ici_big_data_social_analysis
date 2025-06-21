# %% 匯入必要套件
import pandas as pd
from wordcloud import WordCloud
import matplotlib.pyplot as plt
from PIL import Image
import numpy as np

# %% 讀取兩個檔案
df1 = pd.read_csv("UDNdata/udn_articles_POS.csv") 
df2 = pd.read_csv("NDCdata/ndc_articles_POS.csv") 
df = pd.read_csv("all_articles.csv")
df1 = pd.merge(df1, df[['識別碼', 'folder']], left_on='ID', right_on='識別碼', how='left')
df1 = df1[['ID', 'word', 'pos', 'count', 'folder']]
df1 = df1.rename(columns={'folder': 'Type'})

# 合併兩個檔案
df_combined = pd.concat([df1, df2], ignore_index=True)

# %% 自訂停用詞
stopwords = set([
    # '川普', '賀錦麗', '拜登', 
    # '美國', '台灣', '中國', '大陸', '台', '美',
    # '總統', '候選人', '報導', '記者',
    # '民主黨', '共和黨', '選舉', '大選', 
    # '表示', '說', '市場', '經濟', '大', '看',
])

# 定義有意義的詞性標籤
distinctive_tags = [
    'A', 'Da', 'Na', 'Nb', 'Nc', 'Ncd', 'Nd', 
    'VA', 'VAC', 'VB', 'VC', 'VCL', 'VD', 'VF', 'VE', 
    'VG', 'VH', 'VHC', 'VI', 'VJ', 'VK', 'VL'
]

# 讀取剪影圖片並生成遮罩
mask = np.array(Image.open("trump.webp"))  # 替換為你的剪影圖片檔案名稱

# 指定字型路徑
font_path = "NotoSansCJKtc-Regular.otf"  # 確保路徑正確

# %% 過濾停用詞和無效字
filtered_df = df_combined[~df_combined['word'].isin(stopwords)]
# filtered_df = filtered_df[filtered_df['Type']=='國際新聞']
filtered_df = filtered_df[filtered_df['pos'].isin(distinctive_tags)]
filtered_df = filtered_df[filtered_df['count'] > 0]  # 確保詞頻大於0

# %% 產生文字雲
# 按詞語分組並加總次數
aggregated_df = filtered_df.groupby('word', as_index=False)['count'].sum()
word_freq = dict(zip(aggregated_df['word'], aggregated_df['count']))
wc = WordCloud(
    font_path=font_path,
    background_color='white',
    mask=mask,
    # contour_width=3,
    contour_color='black'
).generate_from_frequencies(word_freq)

# %% 顯示文字雲
plt.figure(figsize=(12, 9))
plt.imshow(wc, interpolation='bilinear')
plt.axis('off')
plt.show()

# %%
