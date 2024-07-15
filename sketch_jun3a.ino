#include <WiFi.h>
#include <SimpleDHT.h>
#include <WebServer.h>
#include <ESPmDNS.h>
#include <InfluxDbClient.h>
#include <InfluxDbCloud.h>

#if defined(ESP32)
#include <WiFiMulti.h>
WiFiMulti wifiMulti;
#define DEVICE "ESP32"
#elif defined(ESP8266)
#include <ESP8266WiFiMulti.h>
ESP8266WiFiMulti wifiMulti;
#define DEVICE "ESP8266"
#endif

// DHT11 sensor pin
int pinDHT11 = 15;
SimpleDHT11 dht11;

// WiFi credentials
const char* default_ssid = "DMIA-GUEST";
const char* default_password = "#dM1@2024";
char ssid[32];
char password[32];

// InfluxDB configuration
#define INFLUXDB_URL "https://us-east-1-1.aws.cloud2.influxdata.com"
#define INFLUXDB_TOKEN "IwtgCMHBwhAkrLXoTGaZy8AFXAY5VH61YAvrh5VnezwJxaFl69gEA0zE94hSNqQoaBj4wA6-5kwvFZDEphoGWg=="
#define INFLUXDB_ORG "66f9fed068c7d0ac"
#define INFLUXDB_BUCKET "UAS"
#define TZ_INFO "UTC7"

InfluxDBClient client(INFLUXDB_URL, INFLUXDB_ORG, INFLUXDB_BUCKET, INFLUXDB_TOKEN, InfluxDbCloud2CACert);
Point sensor("dht_sensor");

// Web server
WebServer server(80);

void handleRoot();
void handleConfig();
void handleIP();
void connectWiFi(const char* ssid, const char* password);

void setup() {
  Serial.begin(115200);
  strcpy(ssid, default_ssid);
  strcpy(password, default_password);
  
  connectWiFi(ssid, password);

  // Setup handler for root page
  server.on("/", handleRoot);
  // Setup handler for WiFi configuration
  server.on("/config", HTTP_POST, handleConfig);
  // Setup handler for displaying IP address
  server.on("/ip", handleIP);

  // Start the server
  server.begin();
  Serial.println("HTTP server started");

  // Start mDNS
  if (!MDNS.begin("esp32")) {
    Serial.println("Error setting up MDNS responder!");
  } else {
    Serial.println("mDNS responder started: https://esp32.local");
  }

  // Accurate time is necessary for certificate validation and writing in batches
  timeSync(TZ_INFO, "pool.ntp.org", "time.nis.gov");

  // Check server connection
  Serial.print("Validating InfluxDB connection to ");
  Serial.println(INFLUXDB_URL);
  if (client.validateConnection()) {
    Serial.print("Connected to InfluxDB: ");
    Serial.println(client.getServerUrl());
  } else {
    Serial.print("InfluxDB connection failed: ");
    Serial.println(client.getLastErrorMessage());
  }

  // Add tags to the data point
  sensor.addTag("device", DEVICE);
}

void loop() {
  server.handleClient();

  // Read data from DHT11 sensor
  byte temperature = 0;
  byte humidity = 0;
  int err = SimpleDHTErrSuccess;
  if ((err = dht11.read(pinDHT11, &temperature, &humidity, NULL)) == SimpleDHTErrSuccess) {
    // Clear fields for reusing the point. Tags will remain the same as set above.
    sensor.clearFields();

    // Store measured values into point
    sensor.addField("humidity_", humidity);
    sensor.addField("temperature_", temperature);

    // Print what we are exactly writing
    Serial.print("Writing: ");
    Serial.println(sensor.toLineProtocol());

    // Check WiFi connection and reconnect if needed
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("WiFi connection lost");
      return;
    }

    // Write point
    if (!client.writePoint(sensor)) {
      Serial.print("InfluxDB write failed: ");
      Serial.println(client.getLastErrorMessage());
    } else {
      Serial.println("InfluxDB write successful");
    }

    // Display data on Serial Monitor
    Serial.print("Temperature: ");
    Serial.print((int)temperature);
    Serial.println(" °C");
    Serial.print("Humidity: ");
    Serial.print((int)humidity);
    Serial.println(" %");
    Serial.println("===================");
  } else {
    Serial.println("Failed to read from DHT sensor");
  }

  delay(3000); // Send data every 3 seconds
}

// Connect to WiFi
void connectWiFi(const char* ssid, const char* password) {
  Serial.print("Connecting to WiFi ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  // Wait until the connection succeeds or fails
  int attempts = 0;
  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    attempts++;
    if (attempts > 20) {
      Serial.println("Connection failed.");
      return;
    }
  }

  Serial.println("");
  Serial.println("WiFi connected successfully");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Restart mDNS with the new IP address
  MDNS.end();
  if (!MDNS.begin("esp32")) {
    Serial.println("Error setting up mDNS responder!");
  } else {
    Serial.println("mDNS responder started: https://esp32.local");
  }
}

// Handle requests to the root page
void handleRoot() {
  // HTML form for configuring WiFi
  String html = "<html><head><title>ESP32 WiFi Configuration</title>";
  html += "<style>";
  html += "body { font-family: Arial, sans-serif; margin: 0; padding: 0;}";
  html += "h1 { text-align: center; margin-top: 20px; }";
  html += "form { max-width: 300px; margin: 0 auto; }";
  html += "input[type='text'], input[type='password'] { width: 100%; padding: 10px; margin: 5px 0; }";
  html += "input[type='submit'] { width: 100%; padding: 10px; margin-top: 10px; background-color: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer; }";
  html += "</style>";
  html += "</head><body>";
  html += "<h1>ESP32 WiFi Configuration</h1>";
  html += "<form method='post' action='/config'>";
  html += "SSID: <input type='text' name='ssid'><br>";
  html += "Password: <input type='password' name='password'><br>";
  html += "<input type='submit' value='Submit'></form>";
  html += "</body></html>";

  server.send(200, "text/html", html);
}

// Function to handle POST requests from the WiFi configuration form
void handleConfig() {
  if (server.method() == HTTP_POST) {
    String new_ssid = server.arg("ssid");
    String new_password = server.arg("password");
    new_ssid.toCharArray(ssid, sizeof(ssid));
    new_password.toCharArray(password, sizeof(password));

    // Attempt to connect to WiFi with new SSID and password
    connectWiFi(ssid, password);

    // Send response with new IP address
    String html = "<html><head><title>ESP32 IP</title></head><body>";
    html += "<h1>ESP32 IP Address</h1><p>IP address: ";
    html += WiFi.localIP().toString();
    html += "</p></body></html>";
    server.send(200, "text/html", html);
  }
}

// Function to display IP address when connected to a hotspot
void handleIP() {
  // HTML response displaying IP address
  String html = "<html><head><title>ESP32 IP Address</title></head><body>";
  html += "<h1>ESP32 IP Address</h1><p>IP address: ";
  html += WiFi.localIP().toString();
  html += "</p></body></html>";

  server.send(200, "text/html", html);
}
