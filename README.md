# Trump's New World: Media Framing in Taiwan

A Comparative Study of the 2024 Election

## Project Context

This project explores how Taiwanese media framed Donald Trump during the 2024 U.S. presidential election by building a full-stack NLP pipeline for large-scale sentiment and framing analysis. We collected over 7,000 Mandarin-language news articles via authorized web crawling from sources such as UDN, PTS, Liberty Times, and ETtoday, all filtered using the keyword “川普” (Trump). After cleaning and structuring the data with dplyr and exporting to CSV, we used CKIPTagger for Mandarin-specific word segmentation, POS tagging, and named entity recognition.

Sentiment labeling was performed using both traditional NLP tools (e.g., CSentiPackage from Academia Sinica) and a comparative evaluation of leading LLMs (ChatGPT-4o/4.1, LLaMA 3.3, Qwen, DeepSeek). Two evaluation approaches were designed: direct single-stage classification and a two-step reasoning process with custom prompts. We benchmarked accuracy against human-labeled samples, revealing notable variance across models and prompt strategies.

Our analysis included chi-square tests, topic modeling, and correspondence analysis to uncover framing patterns and ideological bias across outlets. This project demonstrates how NLP workflows and LLMs can be integrated for multilingual media analysis, offering insights into geopolitical narrative construction and the challenges of sentiment modeling in non-English contexts.

## Getting Started

[Provide instructions on how to get started with your project, including any necessary software or data. Include installation instructions and any prerequisites or dependencies that are required.]

## File Structure

[Describe the file structure of your project, including how the files are organized and what each file contains. Be sure to explain the purpose of each file and how they are related to one another.]

## Analysis

[Describe your analysis methods and include any visualizations or graphics that you used to present your findings. Explain the insights that you gained from your analysis and how they relate to your research question or problem statement.]

## Results

[Provide a summary of your findings and conclusions, including any recommendations or implications for future research. Be sure to explain how your results address your research question or problem statement.]

## Contributors

[List the contributors to your project and describe their roles and responsibilities.]

## Acknowledgments

[Thank any individuals or organizations who provided support or assistance during your project, including funding sources or data providers.]

## References

[List any references or resources that you used during your project, including data sources, analytical methods, and tools.]
