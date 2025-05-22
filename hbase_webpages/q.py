# import happybase

# def get_popular_pages(host='localhost', port=9090, table_name='webpages', top_n=10):
#     connection = happybase.Connection(host, port=port)
#     connection.open()
#     table = connection.table(table_name)

#     page_inlink_counts = []

#     for row_key, data in table.scan(columns=[b'inlinks:in_links']):
#         inlinks_bytes = data.get(b'inlinks:in_links')
#         if not inlinks_bytes:
#             # No inbound links
#             count = 0
#         else:
#             inlinks_str = inlinks_bytes.decode('utf-8')
#             if inlinks_str.strip() == '':
#                 count = 0
#             else:
#                 count = len(inlinks_str.split(','))
#         page_inlink_counts.append((row_key.decode('utf-8'), count))

#     connection.close()

#     sorted_pages = sorted(page_inlink_counts, key=lambda x: x[1], reverse=True)

#     print(f"Top {top_n} pages by inbound links:")
#     for page, count in sorted_pages[:top_n]:
#         print(f"{page} - {count} inbound links")



# def get_largest_pages(host='localhost', port=9090, table_name='webpages', top_n=10):
#     connection = happybase.Connection(host, port=port)
#     connection.open()
#     table = connection.table(table_name)

#     page_sizes = []

#     for row_key, data in table.scan(columns=[b'content:html']):
#         content_bytes = data.get(b'content:html')
#         if content_bytes is None:
#             size = 0
#         else:
#             size = len(content_bytes)  # size in bytes
#         page_sizes.append((row_key.decode('utf-8'), size))

#     connection.close()

#     # Sort pages by content size descending
#     sorted_pages = sorted(page_sizes, key=lambda x: x[1], reverse=True)

#     print(f"Top {top_n} largest pages by content size:")
#     for page, size in sorted_pages[:top_n]:
#         print(f"{page} - {size} bytes")


# def find_error_pages(host='localhost', port=9090, table_name='webpages', error_codes=None):
#     """
#     Find pages with HTTP error status codes.

#     :param error_codes: List of status codes to filter, e.g., ['404', '500']
#     """
#     if error_codes is None:
#         # Default common HTTP error codes (client and server errors)
#         error_codes = ['400', '401', '403', '404', '500', '502', '503', '504']

#     connection = happybase.Connection(host, port=port)
#     connection.open()
#     table = connection.table(table_name)

#     error_pages = []

#     for row_key, data in table.scan(columns=[b'metadata:http_status']):
#         status_bytes = data.get(b'metadata:http_status')
#         if status_bytes:
#             status_code = status_bytes.decode('utf-8')
#             if status_code in error_codes:
#                 error_pages.append((row_key.decode('utf-8'), status_code))

#     connection.close()

#     print(f"Pages with HTTP error status codes:")
#     for page, code in error_pages:
#         print(f"{page} - HTTP Status: {code}")

# if __name__ == "__main__":
#     print('...')
#     # get_popular_pages()
#     # get_largest_pages()
#     # find_error_pages()
    
