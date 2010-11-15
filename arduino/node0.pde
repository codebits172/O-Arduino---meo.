#include <EthernetBonjour.h>
#include <Ethernet.h>
#include <IRremote.h>
#include "Dhcp.h"
#include <string.h>

#define LED_PIN 4
#define SONY 'S'
#define RC5 'Z'
IRsend irsend;

// network configuration.  gateway and subnet are optional.
byte mac[] = { 0x00, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

int port = 80;
Server server(port);
//Client client();

void setup()
{
  Serial.begin(9600);
  
  Serial.println("LOG: getting ip...");
  int result = Dhcp.beginWithDHCP(mac);
    if(result == 1)
  {
    
    byte buffer[6];
    Serial.println("ip acquired...");
    
    Dhcp.getMacAddress(buffer);
    Serial.print("mac address: ");
    printArray(&Serial, ":", buffer, 6, 16);
    
    Dhcp.getLocalIp(buffer);
    Serial.print("ip address: ");
    printArray(&Serial, ".", buffer, 4, 10);
    
    Dhcp.getSubnetMask(buffer);
    Serial.print("subnet mask: ");
    printArray(&Serial, ".", buffer, 4, 10);
    
    Dhcp.getGatewayIp(buffer);
    Serial.print("gateway ip: ");
    printArray(&Serial, ".", buffer, 4, 10);
    
    Dhcp.getDhcpServerIp(buffer);
    Serial.print("dhcp server ip: ");
    printArray(&Serial, ".", buffer, 4, 10);
    
    Dhcp.getDnsServerIp(buffer);
    Serial.print("dns server ip: ");
    printArray(&Serial, ".", buffer, 4, 10);
    
    Serial.print("LOG: HTTP server on port ");
    Serial.print(port);
    server.begin();
    Serial.println(" running.");
    Serial.print("LOG: Starting Bonjour/Zeroconf -> ");
    if(EthernetBonjour.begin("arduinohttp"))
      Serial.print(" done.");
    else
      Serial.print(" fail.");
    EthernetBonjour.addServiceRecord("O Arduino e Meo._http", port, MDNSServiceTCP);
    pinMode(LED_PIN, OUTPUT);     
  }
  else
    Serial.println("LOG: unable to acquire ip address...");
}


int readCode(Client* client) {
  client->read();
  client->read();
  
  unsigned long code = 0;
  char ch;
  while((ch = client->read()) != ' ') {
    
    if (ch >= '0' && ch <= '9') {
      code = code * 16 + ch - '0';
    } 
    
    else if (ch >= 'a' && ch <= 'f') {
      code = code * 16 + ch - 'a' + 10;
    } 
    
    else if (ch >= 'A' & ch <= 'F') {
      code = code * 16 + ch - 'A' + 10;
    } 
    
    else {
      Serial.print("Unexpected hex char: ");
      Serial.println(ch);
      Serial.flush();
      code = 0;
      break;
    }
  }
  return code; 
}

void sendCommand(char type, int code) {
  /*
  switch(type) {
    case SONY:
      for (int i = 0; i < 3; i++) {
        
        digitalWrite(LED_PIN, HIGH);   // set the LED on
        irsend.sendSony(code, 12); // Sony TV power code
        delay(100);
        digitalWrite(LED_PIN, LOW);   // set the LED on
      }
      break;
    case RC5:
        digitalWrite(LED_PIN, HIGH);   // set the LED on
        irsend.sendRC5(code, 12); // Sony TV power code
        delay(100);
        digitalWrite(LED_PIN, LOW);   // set the LED on
      break;
  } 
  */
    digitalWrite(LED_PIN, HIGH);
    delay(1000);
    digitalWrite(LED_PIN, LOW);
    delay(1000);
}

void printArray(Print *output, char* delimeter, byte* data, int len, int base)
{
  char buf[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  
  for(int i = 0; i < len; i++)
  {
    if(i != 0)
      output->print(delimeter);
      
    output->print(itoa(data[i], buf, base));
  }
  
  output->println();
}

void loop(){

  EthernetBonjour.run();
  Client client = server.available();
  if (client) {
    unsigned long code;
    // an http request ends with a blank line
    boolean current_line_is_blank = true;
    while (client.connected()) {
      if (client.available()) {
        
/*******************************************************************/ 
        char c = client.read();

        /*Insert Parsing and IR code here*/
        
        if(c == 'G'){
          c = client.read();
          if(c == 'E'){
            c = client.read();
            if(c == 'T'){
              c = client.read();
              c = client.read();
              c = client.read();
              c = client.read();
              if( c == 'i' ){
                c = client.read();// =
                char type;
                //i = STDID
                while((c = client.read()) != '&'){
                  type = c;              
                }
                Serial.print("Type: ");
                Serial.println(type);
                //c = CODE
                code = readCode(&client);
                if(code != 0)
                  sendCommand(type, code);
               Serial.print("Code: ");
               Serial.println(code);
              }
            }    
            Serial.println("GET");
          }
        }  
        
        // if we've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so we can send a reply
        if (c == '\n' && current_line_is_blank) {
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();
          
          // output the value of each analog input pin
          for (int i = 0; i < 6; i++) {
            client.print("analog input ");
            client.print(i);
            client.print(" is ");
            client.print(analogRead(i));
            client.println("<br />");
          }
          break;
        }
        if (c == '\n') {
          // we're starting a new line
          current_line_is_blank = true;
        } else if (c != '\r') {
          // we've gotten a character on the current line
          current_line_is_blank = false;
        }
      }
/*******************************************************************/ 

    }
    // give the web browser time to receive the data
    delay(1);
    client.stop();
  }
}
