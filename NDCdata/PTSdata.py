import asyncio
from playwright.async_api import async_playwright
import pandas as pd
import os

# 建立資料夾（如尚未存在）
os.makedirs(f"即時新聞/trump_articles_pts", exist_ok=True)

# 公視新聞抓取函數
async def get_pts_article(url):
    from playwright.async_api import async_playwright, TimeoutError

    async with async_playwright() as p:
        browser = await p.firefox.launch(headless=True)
        page = await browser.new_page()
        try:
            await page.goto(url, timeout=60000)
            await page.wait_for_selector("div.post-article")

            content_elements = await page.query_selector_all("div.post-article .articleimg, div.post-article p")
            content = []
            for el in content_elements:
                text = (await el.text_content() or '').strip()
                if text and text != '.':
                    content.append(text)

            if not content:
                print("⚠️ 沒有抓到任何內容！")
                return None
            return "\n".join(content)

        except TimeoutError:
            print("⚠️ 連線或載入超時，無法抓取內容。")
            return None
        except Exception as e:
            print(f"⚠️ 發生錯誤：{e}")
            return None
        finally:
            await browser.close()


# 主流程
async def main():
    # 載入 CSV 並轉換時間
    df = pd.read_csv(r"即時新聞\trump_articles_breaking.csv", parse_dates=["發布日期"])

    # 過濾時間範圍
    df = df[(df["發布日期"] >= "2024-07-22") & (df["發布日期"] <= "2024-11-07")]

    # 篩選公視新聞
    pts_df = df[df["新聞連結"].str.contains("pts.org.tw")].copy()

    # # 篩選有出現在資料夾的 uid
    # folder_path = "TRUMPdata/即時新聞/NoData"
    # existing_files = set(os.listdir(folder_path))
    # # 去掉副檔名
    # existing_files = {file.split(".")[0] for file in existing_files}
    # # 只保留在資料夾中的 uid
    # pts_df = pts_df[pts_df["uid"].isin(existing_files)]
    # pts_df = pts_df.reset_index(drop=True)

    # 抓取全文
    print("🔍 抓取公視新聞中...")
    articles = []
    for i, url in enumerate(pts_df["新聞連結"], 1):
        print(f"({i}/{len(pts_df)}) 抓取：{url}")
        try:
            article = await get_pts_article(url)
        except Exception as e:
            article = f"錯誤：{str(e)}"
        articles.append(article)

    pts_df["fulltext"] = articles
    pts_df["fulltext"] = pts_df["fulltext"].astype(str)

    # 篩選包含「川普」的新聞
    df_trump = pts_df[
        pts_df["新聞標題"].str.contains("川普", na=False) |
        pts_df["新聞前言"].str.contains("川普", na=False) |
        pts_df["fulltext"].str.contains("川普", na=False)
    ]

    # 儲存每篇文章成 txt
    for _, row in df_trump.iterrows():
        file_path = f"即時新聞/trump_articles_pts/{row['uid']}.txt"
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(row["fulltext"])

    # 儲存 CSV（不含「新聞全文」欄）
    df_trump.drop(columns=["fulltext"]).to_csv(f"即時新聞/trump_articles_pts.csv", index=False, encoding="utf-8-sig")
    print("✅ 完成：符合『川普』的公視新聞已儲存。")

# 執行
if __name__ == "__main__":
    asyncio.run(main())
