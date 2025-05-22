 # HBase Webpages Data Management System with 🐳 HBase HA Cluster Setup with Docker (HMaster + RegionServers)

## Overview

This project implements a highly available **Apache HBase** cluster running in Docker containers, integrated with **Hadoop HDFS** and **ZooKeeper**. It provides a scalable solution for storing, versioning, and querying large-scale web page data with optimized row key design and secondary indexing.

A Python script using `happybase` generates realistic sample webpage data, inserts it into HBase, and maintains a secondary index for efficient domain-based queries.

---

## Cluster Architecture

The cluster is designed for **fault tolerance** and **scalability**, consisting of:

### ZooKeeper Ensemble (3 nodes)

* `zk1`, `zk2`, `zk3` provide coordination and leader election for HBase and Hadoop.
* Maintains quorum-based fault tolerance.

### Hadoop JournalNodes (2 nodes)

* Persistent shared edit log service for HDFS NameNode HA.
* Ensure metadata durability and consistency.

### Hadoop NameNodes (2 nodes)

* HA pair: `m1` (active) and `m2` (standby).
* Manage HDFS namespace and metadata.

### Hadoop DataNodes (2 nodes)

* Store HDFS data blocks, serve read/write requests.

### HBase Masters (2 nodes)

* HA pair: `hm1` and `hm2`.
* Manage region assignments and cluster state.

### HBase RegionServers

* Run on nodes `s1` and `s2`.
* Serve reads/writes for HBase table regions.

## Ports
| Service              | Purpose                                       | Typical Ports (Host\:Container) |
| -------------------- | --------------------------------------------- | ------------------------------- |
| ZooKeeper            | Coordination and leader election              | 2181-2183:2181                  |
| Hadoop NameNode UI   | HDFS status and management                    | 9870-9871:9870                  |
| YARN ResourceManager | Resource scheduling UI                        | 8088-8089:8088                  |
| HBase RegionServers  | Region server communication                   | 16020-16021:16020               |
| Thrift RPC (HBase)   | Client API access (happybase, Thrift clients) | 9090-9093:9090                  |
| HBase Master UI      | HBase master monitoring                       | 16010-16011:16010               |
| HBase Master RPC     | Internal cluster communication                | 16000-16001:16000               |

---

## Docker Setup

* Multi-stage Dockerfile builds Hadoop base, ZooKeeper, and HBase images.
* Docker Compose orchestrates containers with:

  * Proper volumes for persistence.
  * Healthchecks and dependency ordering.
  * Custom network `hnet` for inter-container communication.
* Ports exposed for UIs and client APIs (e.g., HBase Master UI, ZooKeeper client port).

---

## Python Data Insertion Script

* Uses `happybase` for HBase interaction.
* Generates realistic webpage data with `Faker`:

  * Multiple domains (`example.com`, `test.org`, etc.)
  * Varied content sizes and crawl dates.
  * Interconnected link structure (inlinks and outlinks).
* Row keys combine 4-char MD5 hash prefix + full URL for load balancing and exact lookups.
* Maintains a secondary index table (`domain_index`) mapping domains to page row keys.
* Provides logging to track progress and errors.

---

## HBase Table Design

### Table: `webpages`

| Column Family | Description                   | Versions | TTL (seconds)         |
| ------------- | ----------------------------- | -------- | --------------------- |
| `content`     | HTML content (`content:html`) | 3        | 7,776,000 (90 days)   |
| `metadata`    | Title, author, crawl date     | 1        | None                  |
| `outlinks`    | Outbound links                | 2        | 15,552,000 (180 days) |
| `inlinks`     | Inbound links                 | 2        | 15,552,000 (180 days) |

## Row Key Design and Secondary Indexing for Scalable Domain Queries

In the `webpages` HBase table, each row key is carefully designed by prefixing the URL with a 4-character MD5 hash, for example:
9c12|www.example.com/page1


This design serves several important purposes:

- **Balanced Data Distribution:**  
  The MD5 hash prefix ensures that rows are evenly spread across HBase region servers. This prevents "hotspots" — situations where many writes or reads target a single region — improving performance and scalability.

- **Efficient Exact Lookups:**  
  Including the full URL after the hash allows quick exact-match queries, which is the most common access pattern when retrieving a single webpage.

- **Versioning and TTL Compatibility:**  
  The key format fits well with HBase’s storage model, supporting multiple versions per row and automatic expiry (TTL) without sacrificing query efficiency.

---

### Weaknesses of This Hash-Prefixed Key Design:

- **Broken Natural Ordering:**  
  Because of the hash prefix, all pages from the same domain are scattered across different regions rather than stored together. This breaks natural lexicographic ordering of URLs.

- **Inefficient Domain-Based Scans:**  
  Queries like "list all pages from `example.com`" cannot simply scan a contiguous row key range because domain pages are distributed randomly. This makes such scans slow and resource-intensive.

- **Pagination Challenges:**  
  Since domain pages aren’t grouped physically, implementing domain-specific pagination is complicated and inefficient.

---

### Role of the Secondary Index Table (`domain_index`):

To overcome these issues, a secondary index table is created with:

- **Domain names as row keys** (e.g., `example.com`).
- **All main table row keys (URLs) belonging to that domain stored as column qualifiers** in the domain's row.

This provides:

- **Efficient Domain Queries:**  
  Retrieving all pages for a domain becomes a single fast fetch from the secondary index, which lists all URLs (row keys) for that domain.

- **Simplified Pagination:**  
  Pagination is done over the list of URLs stored in the secondary index, enabling smooth “next page” navigation within a domain’s pages.

- **Performance Improvements:**  
  This offloads expensive scans from the large main `webpages` table, reducing disk IO and network overhead for domain-centric queries.

---

### Conclusion:

Using a combination of a **hash-prefixed row key** and a **domain-based secondary index** balances the needs for:

- High write throughput and efficient exact page reads.
- Efficient, scalable domain-based querying and pagination.
- Avoiding common performance pitfalls of purely hash-based or purely lexicographically ordered keys.

This design supports all key business access patterns with good overall performance.



---

## Key Features

* Retrieve latest or historical versions of pages.
* Automatic TTL-based expiry of old content.
* Manual purge of outdated versions supported.
* Efficient domain queries using secondary index.
* SEO and link structure analytics (inlinks, outlinks, dead ends).
* Pagination to improve query performance.

---

## Sample Commands

```hbase
# Get latest page version
get 'webpages', '9c12|www.example.com/page1'

# Get last 3 content versions
get 'webpages', '9c12|www.example.com/page1', {COLUMN => 'content:html', VERSIONS => 3}

# List pages for a domain
get 'domain_index', 'example.com'

# Find pages modified after a date
scan 'webpages', {FILTER => "SingleColumnValueFilter('metadata', 'crawl_date', >=, 'binary:2025-04-01 00:00:00')"}
```

---

## How to Run

1. Clone this repository.

2. Start the cluster:

   ```bash
   docker-compose up -d
   ```

3. Run the Python data insertion script:

   ```bash
   python3 hbase_webpages/hbase_webpages.py
   ```

4. Use HBase shell or client APIs to interact with data.

---

## Failover Testing

* Stop active NameNode or HBase Master container.
* Observe automatic failover to standby instances.
* Verify service continuity via UI or logs.

---

## Dependencies

* Docker & Docker Compose
* Python 3.x with `happybase`, `faker`
* Apache HBase 2.4.9
* Apache Hadoop 3.3.6
* ZooKeeper 3.9.3

---

## Author

Created by Ahmed Otifi
🔗 GitHub: https://github.com/otifi3

---
