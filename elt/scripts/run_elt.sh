#!/bin/bash

LOG_FILE="/home/hadoop/scripts/elt.log"

echo "===== ELT Pipeline Started at $(date) =====" >> "$LOG_FILE"

# Step 1: Python script
echo "[INFO] Running Python script..." >> "$LOG_FILE"
python3 /home/hadoop/src/main.py 2>> "$LOG_FILE"
if [ $? -ne 0 ]; then
  echo "[ERROR] Python script failed at $(date)" >> "$LOG_FILE"
  exit 1
fi
echo "[INFO] Python script completed successfully." >> "$LOG_FILE"

# Step 2: Upload to HDFS
echo "[INFO] Uploading CSV files to HDFS..." >> "$LOG_FILE"
for file in /home/hadoop/tmp_data/*.csv; do
    filename=$(basename "$file" .csv)
    hdfs_path="/staging/$filename/$filename.csv"

    echo "[INFO] Putting $file to $hdfs_path" >> "$LOG_FILE"
    hdfs dfs -put -f "$file" "$hdfs_path" 2>> "$LOG_FILE"
    if [ $? -ne 0 ]; then
      echo "[ERROR] Failed to put $file to HDFS at $(date)" >> "$LOG_FILE"
      exit 1
    fi
done
echo "[INFO] All CSV files uploaded to HDFS successfully." >> "$LOG_FILE"

# Step 3: Run Hive script
echo "[INFO] Running Hive transformation script..." >> "$LOG_FILE"
beeline -u jdbc:hive2://h2:10000 -f /home/hadoop/scripts/schedule_elt.hql > /dev/null 2>> "$LOG_FILE"
if [ $? -ne 0 ]; then
  echo "[ERROR] Hive script failed at $(date)" >> "$LOG_FILE"
  exit 1
fi
echo "[INFO] Hive script executed successfully." >> "$LOG_FILE"

echo "===== ELT Pipeline Completed Successfully at $(date) =====" >> "$LOG_FILE"
