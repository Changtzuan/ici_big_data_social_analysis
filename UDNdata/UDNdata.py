# 將原本的 requests 程式改成 Selenium 版本
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import pandas as pd
import time
import random
import os
import hashlib
import uuid

# 設定 Chrome Driver 路徑
chrome_path = "chromedriver-win64/chromedriver.exe"  # 根據你的系統調整路徑
options = Options()
# options.add_argument("--headless")  # 若不需顯示畫面，可啟用這行
options.add_argument("--start-maximized")
driver = webdriver.Chrome(service=Service(chrome_path), options=options)

# 建立資料夾
os.makedirs("debug_pages", exist_ok=True)
os.makedirs("udn_articles", exist_ok=True)

# 隨機延遲模擬人類行為
def random_delay(min_seconds=1, max_seconds=4):
    delay = random.uniform(min_seconds, max_seconds)
    print(f"隨機等待 {delay:.2f} 秒...")
    time.sleep(delay)

# 安全的檔名生成器
def safe_filename(url):
    return hashlib.md5(url.encode()).hexdigest()

# 搜尋頁解析
def get_search_results(page_num):
    base_url = f"https://udndata.com/ndapp/Searchdec?udndbid=udnfree&page={page_num}&SearchString=%26%2324029%3B%26%2326222%3B%2B%A4%E9%B4%C1%3E%3D20240722%2B%A4%E9%B4%C1%3C%3D20241107%2B%B3%F8%A7%4F%3D%C1%70%A6%58%B3%F8%7C%B8%67%C0%D9%A4%E9%B3%F8%7C%C1%70%A6%58%B1%DF%B3%F8%7CUpaper&sharepage=20&select=1&kind=2"
    print(f"\n===== 處理第 {page_num} 頁 =====")
    driver.get(base_url)
    
    try:
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "div.news h2.control-pic a"))
        )
    except:
        print("⚠️ 搜尋結果未在 10 秒內出現")
        return []

    random_delay(2, 4)
    articles = []
    try:
        elems = driver.find_elements(By.CSS_SELECTOR, "div.news h2.control-pic a")
        for elem in elems:
            title = elem.text.strip()
            link = elem.get_attribute("href")
            if title and link:
                print(f"找到文章: {title}")
                articles.append((title, link))
    except Exception as e:
        print("抓取搜尋頁失敗:", e)

    print(f"總共找到 {len(articles)} 篇文章")
    return articles

# 抓取文章內文
def get_article_content(url):
    print(f"\n抓取文章: {url}")
    driver.get(url)
    random_delay(2, 4)

    try:
        info = {
            "標題": "",
            "副標": "",
            "記者": "",
            "版次": "",
            "全文": "",
            "發稿日期": "",
            "報紙": ""
        }

        title_elem = driver.find_element(By.CSS_SELECTOR, ".story-title h1")
        info["標題"] = title_elem.text.strip()

        try:
            subtitle_elem = driver.find_element(By.CSS_SELECTOR, ".story-title h2")
            info["副標"] = subtitle_elem.text.strip()
        except:
            pass

        try:
            reporter_elem = driver.find_element(By.CSS_SELECTOR, ".story-report")
            info["記者"] = reporter_elem.text.strip()
        except:
            pass

        try:
            source_elem = driver.find_element(By.CSS_SELECTOR, ".story-source")
            source_text = source_elem.text.strip().replace("【", "").replace("】", "")
            parts = source_text.split("/")
            if len(parts) >= 3:
                info["發稿日期"] = parts[0]
                info["報紙"] = parts[1]
                info["版次"] = parts[2] + " " + parts[3]
        except:
            pass

        paras = driver.find_elements(By.CSS_SELECTOR, "article p")
        content = "\n".join([p.text.strip() for p in paras if p.text.strip()])

        if "川普" in content:
            count = content.count("川普")
            print(f"文章中「川普」出現 {count} 次")
            info["全文"] = content
            return info
        else:
            print("文章內文未包含關鍵字")
            return None

    except Exception as e:
        print("❌ 抓內文失敗:", e)
        return None

# 主執行程式
all_data = []
max_pages = 50

for page in range(1, max_pages + 1):
    results = get_search_results(page)
    for title, link in results:
        article_info = get_article_content(link)
        if article_info:
            article_id = str(uuid.uuid4())
            with open(os.path.join("udn_articles", f"{article_id}.txt"), "w", encoding="utf-8") as f:
                # f.write(f"標題: {article_info['標題']}\n")
                # if article_info["副標"]:
                #     f.write(f"副標: {article_info['副標']}\n")
                # if article_info["記者"]:
                #     f.write(f"記者: {article_info['記者']}\n")
                # if article_info["報紙"]:
                #     f.write(f"報紙: {article_info['報紙']}\n")
                # if article_info["版次"]:
                #     f.write(f"版次: {article_info['版次']}\n")
                # if article_info["發稿日期"]:
                #     f.write(f"發稿日期: {article_info['發稿日期']}\n")
                # f.write("\n正文:\n")
                f.write(article_info["全文"])

            all_data.append({
                "UUID": article_id,
                "標題": article_info["標題"],
                "副標": article_info["副標"],
                "記者": article_info["記者"],
                "報紙": article_info["報紙"],
                "版次": article_info["版次"],
                "發稿日期": article_info["發稿日期"],
                "連結": link
            })
        random_delay(1, 3)

# 儲存資料
if all_data:
    df = pd.DataFrame(all_data)
    df.to_csv("udn_articles.csv", index=False, encoding="utf-8-sig")
    print("✅ 已儲存結果到 udn_articles.csv 並輸出每篇文章 txt 檔案")
else:
    print("⚠️ 沒有抓到任何文章")

# 關閉瀏覽器
driver.quit()