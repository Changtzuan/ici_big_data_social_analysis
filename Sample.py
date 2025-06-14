# %%
import os
import pandas as pd
import shutil

# %%
# UDNdata 版本
udn_folder = r"UDNdata\trump_articles"
csv_file = r"UDNdata\udn_articles.csv"
udn_data = pd.read_csv(csv_file, encoding="utf-8-sig")

# NDCdata 版本
trump_folder = r"NDCdata\trump_articles"
csv_file = r"NDCdata\ndc_articles.csv"
trump_data = pd.read_csv(csv_file, encoding="utf-8-sig")

# %%
# 在每個 ["報紙"] 中隨機選擇 2% 筆資料，並存入新的 DataFrame
udn_sampled = pd.DataFrame(columns=udn_data.columns)
for newspaper, group in udn_data.groupby(["報紙"]):
    # 隨機選擇 2% 的資料
    sample_size = max(1, int(len(group) * 0.021))  # 至少選擇 1 筆資料
    sampled_group = group.sample(n=sample_size, random_state=42)
    
    # 將選擇的資料加入新的 DataFrame
    udn_sampled = pd.concat([udn_sampled, sampled_group], ignore_index=True)

# 在每個 ["來源媒體", "新聞分類"] 的組合中隨機選擇 2% 筆資料，並存入新的 DataFrame
trump_sampled = pd.DataFrame(columns=trump_data.columns)
for (source, category), group in trump_data.groupby(["來源媒體", "新聞分類"]):
    # 隨機選擇 2% 的資料
    sample_size = max(1, int(len(group) * 0.0203))  # 至少選擇 1 筆資料
    sampled_group = group.sample(n=sample_size, random_state=42)
    
    # 將選擇的資料加入新的 DataFrame
    trump_sampled = pd.concat([trump_sampled, sampled_group], ignore_index=True)

# %%
# 將選擇的資料儲存到新的 CSV 檔案
udn_sampled.to_csv(r"UDNdata\udn_articles_sampled.csv", index=False, encoding="utf-8-sig")
trump_sampled.to_csv(r"NDCdata\ndc_articles_sampled.csv", index=False, encoding="utf-8-sig")

# 新增資料夾，並將選到的ID的檔案複製到該資料夾中
os.makedirs(r"UDNdata\udn_articles_sampled", exist_ok=True)
os.makedirs(r"NDCdata\ndc_articles_sampled", exist_ok=True)

for index, row in udn_sampled.iterrows():
    file_name = row['UUID'] + ".txt"
    file_path = os.path.join(udn_folder, file_name)
    if os.path.exists(file_path):
        new_file_path = os.path.join(r"UDNdata\udn_articles_sampled", file_name)
        shutil.copy(file_path, new_file_path)
        print(f"檔案: {file_name} 已複製到新資料夾")
    else:
        print(f"檔案: {file_name} 不存在")

# 遍歷每個新聞檔案
for index, row in trump_sampled.iterrows():
    file_name = row['folder'] + "_"+ row['識別碼'] + ".txt"
    # 組合檔案路徑
    file_path = os.path.join(trump_folder, file_name)
    if os.path.exists(file_path):
        new_file_path = os.path.join(r"NDCdata\ndc_articles_sampled", file_name)
        shutil.copy(file_path, new_file_path)
        print(f"檔案: {file_name} 已複製到新資料夾")
    else:
        print(f"檔案: {file_name} 不存在")

# %%
