import psutil
import socket
import subprocess
import platform
import time
import datetime
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS
import pyodbc

# InfluxDB Configuration
token = "RsQWMDs3B_BEJjagB0LAa3PMigM1d612BMDuo2TpbBHOs8Rptt-ziuC6pzAYRw9UnQakHRqudwRCuffquNelsw=="
org = "DMIA"
bucket = "DMIA"
url = "http://10.73.142.75:8086/"

# Initialize InfluxDB client
client = InfluxDBClient(url=url, token=token, org=org)
write_api = client.write_api(write_options=SYNCHRONOUS)

# Initialize variables to store previous values
active_account = "None"
net_io = psutil.net_io_counters()
prev_bytes_sent = net_io.bytes_sent
prev_bytes_recv = net_io.bytes_recv

# Variable to store total data per minute
total_bytes_per_minute = 0
interval = 5  # Interval in seconds
intervals_per_minute = 60 // interval

# Variable to store total value of all fields
total_value = 0
total_megabytes_per_minute = 0  # Add this variable for per minute accumulation

# Function to read PC name
def get_computer_name():
    return socket.gethostname()

# Function to get connected WiFi SSID
def get_connected_wifi():
    system = platform.system()

    if system == "Windows":
        command = "netsh wlan show interfaces"
        output = subprocess.check_output(command, shell=True).decode()
        for line in output.split("\n"):
            if "SSID" in line and "BSSID" not in line:
                return line.split(":")[1].strip()

    elif system == "Darwin":  # macOS
        command = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I"
        output = subprocess.check_output(command, shell=True).decode()
        for line in output.split("\n"):
            if " SSID:" in line:
                return line.split(": ")[1].strip()

    elif system == "Linux":
        command = "iwgetid -r"
        try:
            output = subprocess.check_output(command, shell=True).decode().strip()
            return output
        except subprocess.CalledProcessError:
            return None

    return None

def get_network_io():
    global prev_bytes_sent, prev_bytes_recv, total_bytes_per_minute

    net_io = psutil.net_io_counters()

    bytes_sent = net_io.bytes_sent - prev_bytes_sent
    bytes_recv = net_io.bytes_recv - prev_bytes_recv

    prev_bytes_sent = net_io.bytes_sent
    prev_bytes_recv = net_io.bytes_recv

    total_bytes_per_minute += (bytes_sent + bytes_recv)

def get_active_local_accounts():
    users = psutil.users()
    active_users = {user.name for user in users}
    return list(active_users)

# Function to save data to SQL Server
def save_to_sql_server(time_ns, name, value, wifi_name):
    timestamp_seconds = time_ns / 1e9
    datetime_value = datetime.datetime.fromtimestamp(timestamp_seconds)
    formatted_datetime = datetime_value.strftime('%Y-%m-%d %H:%M:%S')

    conn = pyodbc.connect('DRIVER={SQL Server};SERVER=10.73.142.75;DATABASE=db_bandwidth_monitoring;UID=aine;PWD=aine1010')
    cursor = conn.cursor()
    cursor.execute("INSERT INTO bandwidth (time, name, value, wifi_name) VALUES (?, ?, ?, ?)", (formatted_datetime, name, value, wifi_name))
    conn.commit()
    conn.close()

# Example usage
if __name__ == "__main__":
    active_accounts = get_active_local_accounts()
    active_account = active_accounts[0]
    computer_name = get_computer_name()
    wifi_name = get_connected_wifi()  # Call the function to get connected WiFi name
    print(f"{active_account}/{computer_name}/{wifi_name}")

    interval_count = 0
    while True:
        get_network_io()
        interval_count += 1
        if interval_count >= intervals_per_minute:
            total_megabytes_per_minute += total_bytes_per_minute / 1048576
            #print(f"Total bandwidth per minute: {total_megabytes_per_minute:.2f} MB")
      
            if active_account != "None":
                try:
                    # Write data to InfluxDB
                    json_body = [
                        {
                            "measurement": "Test 3",
                            "time": time.time_ns(),
                            "fields": {
                                f"{active_account}/{computer_name}": total_megabytes_per_minute,
                                "total": total_megabytes_per_minute,
                                "wifi_name": wifi_name  # Update WiFi name in the InfluxDB data
                            },
                        }
                    ]
                    write_api.write(bucket=bucket, org=org, record=json_body)
                    #print("Data written to InfluxDB successfully.")

                    # Save data to SQL Server
                    save_to_sql_server(time.time_ns(), f"{active_account}/{computer_name}", total_megabytes_per_minute, wifi_name)
                    #print("Data saved to SQL Server successfully.")
                except Exception as e:
                    print(f"Error: {e}")

            total_bytes_per_minute = 0
            total_megabytes_per_minute = 0
            interval_count = 0
        
        # Update connected WiFi name for the next iteration
        wifi_name = get_connected_wifi()
        time.sleep(interval)

# Triger sqlServer
# USE [db_bandwidth_monitoring]
# GO
# /****** Object:  Trigger [dbo].[trg_after_insert]    Script Date: 19/08/2024 07:45:04 ******/
# SET ANSI_NULLS ON
# GO
# SET QUOTED_IDENTIFIER ON
# GO
# ALTER TRIGGER [dbo].[trg_after_insert]
# ON [dbo].[bandwidth_monitoring]
# AFTER INSERT
# AS
# BEGIN
#     IF NOT EXISTS (SELECT 1 FROM grafana WHERE name = (SELECT name FROM inserted))
#     BEGIN
#         INSERT INTO grafana (time, name, value, wifi_name)
#         SELECT time, name, value, wifi_name
#         FROM inserted;
#     END
#     ELSE
#     BEGIN
#         UPDATE bg
#         SET time = i.time, value = i.value
#         FROM bandwidth_grafana bg
#         INNER JOIN inserted i ON bg.name = i.name;
#     END;
# 	Delete from bandwidth where name = (SELECT name FROM inserted);
# END;


# tampilan grafana list
# select [Timestamp],Account,[PC Name],Value,isnull([Wifi Name],'')[Wifi Name],isnull(name,'')Name,isnull(department_name,'')[Section] from(SELECT
#     FORMAT([time], 'yyyy-MM-dd HH:mm:ss') AS [Timestamp],
# 	PARSENAME(REPLACE(name, '/', '.'), 2) AS Account,
# 	PARSENAME(REPLACE(name, '/', '.'), 1) AS [PC Name],
#     [value] AS [Value],
#     [wifi_name] AS [Wifi Name]
# FROM
#     [db_bandwidth_monitoring].[dbo].[grafana]
# where time > DATEADD(MINUTE,-15,GETDATE()))A
# left join db_central_user.dbo.Tb_user_login B on A.Account=b.user_name
# order by Value DESC;