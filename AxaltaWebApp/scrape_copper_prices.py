import requests
from bs4 import BeautifulSoup
import csv
import os

# URL to scrape
URL = "https://www.investing.com/commodities/real-time-futures"

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept-Language': 'en-US,en;q=0.9',
}

def fetch_and_save():
    response = requests.get(URL, headers=headers)
    soup = BeautifulSoup(response.text, 'html.parser')
    table = soup.find('table')
    data = []
    if table:
        header_row = table.find('thead').find_all('th') if table.find('thead') else table.find_all('th')
        csv_headers = [th.text.strip() for th in header_row]
        rows = table.find('tbody').find_all('tr') if table.find('tbody') else table.find_all('tr')[1:]
        for row in rows:
            cols = [td.text.strip() for td in row.find_all('td')]
            if cols:
                data.append(cols)
    else:
        print("No table found on the page.")
        csv_headers = []
    # Write to the web-accessible data directory
    output_dir = os.path.join(os.path.dirname(__file__), 'web', 'WEB-INF', 'data')
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, 'commodities_live.csv')
    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        if csv_headers:
            writer.writerow(csv_headers)
        writer.writerows(data)
    print(f"Data has been written to {output_path}")

if __name__ == "__main__":
    fetch_and_save()
