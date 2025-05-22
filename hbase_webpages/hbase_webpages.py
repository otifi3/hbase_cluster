import happybase
import hashlib
import random
import logging
from faker import Faker


def setup_logging():
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s')
    return logging.getLogger(__name__)


class HBaseConnectionManager:
    _connection = None

    @classmethod
    def get_connection(cls, host, port):
        if cls._connection is None:
            cls._connection = happybase.Connection(host, port=port)
            cls._connection.open()
        return cls._connection

    @classmethod
    def close_connection(cls):
        if cls._connection is not None:
            cls._connection.close()
            cls._connection = None


class WebPage:
    def __init__(self, url, title, description, author,
                  crawl_date, content, out_links=None, in_links=None):
        self.url = url
        self.title = title
        self.description = description
        self.author = author
        self.crawl_date = crawl_date
        self.content = content
        self.out_links = out_links if out_links else []
        self.in_links = in_links if in_links else []

    def row_key(self):
        prefix = hashlib.md5(self.url.encode()).hexdigest()[:4]
        return f"{prefix}|{self.url}"
    
    def to_dict(self):
        return {
            'metadata:title': self.title,
            'metadata:description': self.description,
            'metadata:author': self.author,
            'metadata:crawl_date': self.crawl_date,
            'content:html': self.content,
            'outlinks:out_links': ','.join(self.out_links),
            'inlinks:in_links': ','.join(self.in_links),
        }


class HBaseWebPages:
    def __init__(self, host, port, table_name):
        connection = HBaseConnectionManager.get_connection(host, port)
        self.table = connection.table(table_name)
        self.domains = ['example.com', 'test.org', 'sample.net', 'demo.io', 'mysite.edu']
        self.faker = Faker()

    def generate_content(self, size='small'):
        paragraphs = [self.faker.paragraph(nb_sentences=5) for _ in range({
            'small': 1,
            'medium': 5,
            'large': 20
        }[size])]
        return "<p>" + "</p><p>".join(paragraphs) + "</p>"

    def random_crawl_date(self):
        date = self.faker.date_time_between(start_date='-60d', end_date='now')
        return date.strftime("%Y-%m-%d %H:%M:%S")

    def generate_url(self, domain, idx):
        slug = self.faker.slug()
        return f"www.{domain}/{slug}-{idx}"

    def generate_pages(self, num_pages):
        pages = []
        for i in range(num_pages):
            domain = self.domains[i % len(self.domains)]
            url = self.generate_url(domain, i + 1)
            content_size = random.choice(['small', 'medium', 'large'])
            content = self.generate_content(content_size)
            crawl_date = self.random_crawl_date()
            title = self.faker.sentence(nb_words=6)
            description = self.faker.text(max_nb_chars=100)
            author = self.faker.name()
            pages.append(WebPage(url, title, description, author, crawl_date, content))
        for i, page in enumerate(pages):
            num_links = random.randint(1, 3)
            linked_indices = [(i + j) % num_pages for j in range(1, num_links + 1)]
            page.out_links = [pages[idx].url for idx in linked_indices]
            for idx in linked_indices:
                pages[idx].in_links.append(page.url)
        return pages

    def insert_pages(self, pages):
        for page in pages:
            self.table.put(page.row_key(), page.to_dict())
            print(f"Inserted: {page.row_key()}")


class SecondaryIndex:
    def __init__(self, host, port, index_table_name):
        connection = HBaseConnectionManager.get_connection(host, port)
        self.index_table = connection.table(index_table_name)

    def add_to_index(self, domain: str, main_row_key: str):
        column = f"pages:{main_row_key}"
        self.index_table.put(domain, {column.encode(): b''})


def main():
    try:
        logger = setup_logging()
        logger.info("Starting HBaseWebPages client.")

        host = 'localhost'
        port = 9090
        webpages_table = 'webpages'
        domain_index_table = 'domain_index'

        hbase_client = HBaseWebPages(host, port, webpages_table)
        secondary_index = SecondaryIndex(host, port, domain_index_table)

        logger.info("Generating sample web pages.")
        sample_pages = hbase_client.generate_pages(20)

        logger.info("Inserting sample web pages into HBase and updating secondary index.")
        for page in sample_pages:
            main_key = page.row_key()
            hbase_client.table.put(main_key, page.to_dict())
            domain = page.url.split('/')[0].replace('www.', '')
            secondary_index.add_to_index(domain, main_key)
            logger.info(f"Inserted page {main_key} and indexed under domain '{domain}'.")

    except Exception as e:
        logger.error(f"An error occurred: {e}")
    finally:
        HBaseConnectionManager.close_connection()
        logger.info("HBase connection closed.")


if __name__ == "__main__":
    main()
