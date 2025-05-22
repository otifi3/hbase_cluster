import time
import happybase

connection = happybase.Connection('localhost', 9090)
connection.open()
table = connection.table('webpages')

row_key = 'f8d5|www.mysite.edu/no-hit-15'

for version in range(1, 4):
    data = {
        'content:html': f'<p>Version {version} content for testing versions.</p>',
        'metadata:title': f'Test Page Version {version}',
        'metadata:crawl_date': f'2025-05-21 12:0{version}:00',
    }
    table.put(row_key, data)
    print(f"Inserted version {version} for row {row_key}")
    time.sleep(1)  

connection.close()