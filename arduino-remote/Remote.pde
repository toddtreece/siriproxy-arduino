#include <IRremote.h>
#include <avr/pgmspace.h>
#include "WiFly.h"
#include "Credentials.h"
#include "Codes.h"


Server server(8000);
IRsend irsend;

void setup() {
  
  Serial.begin(115200);
  Serial.println("Connecting");
  
  WiFly.begin();

  if (!WiFly.join(ssid, passphrase)) {
    Serial.println("Died");
    while (1) {
      // Hang on failure. 
    }
  }

  WiFly.configure(WIFLY_BAUD, 38400);
  Serial.print("IP: ");
  Serial.println(WiFly.ip());
  
  server.begin();

}

void loop() {
  
  Client client = server.available();
  
  if (client) {
    
    boolean start_data = false;
    boolean next = false;

    char command[32];
    char value[32];
    int index = 0;
    
    while (client.connected()) {

      if (client.available()) {
        char c = client.read();
        Serial.print(c);
  
        if (c == '}') {
          break;
        }
        
        if(start_data == true) {
          
          if(c != ',') {
            
            if(next)
              value[index] = c;
            else
              command[index] = c;
            
            index++;
          } else {
            next = true;
            command[index] = '\0';
            index = 0;
          }
            
        }
        
        if (c == '{') {
          start_data = true;
        }

      }
      
    }
    
    value[index] = '\0';
    client.stop();
    
    sendCommand(command,value);
  }

}

void channel(char* numbers) {
  
  int i = 0;
  
  for(i = 0; i < 2; i++) {
   
    if(numbers[i] == '0') {
      irsend.sendRaw(get(cable_zero), cable_length, 38);
    } else if(numbers[i] == '1') {
      irsend.sendRaw(get(cable_one), cable_length, 38);      
    } else if(numbers[i] == '2') {
      irsend.sendRaw(get(cable_two), cable_length, 38);
    } else if(numbers[i] == '3') {
      irsend.sendRaw(get(cable_three), cable_length, 38);
    } else if(numbers[i] == '4') {
      irsend.sendRaw(get(cable_four), cable_length, 38);
    } else if(numbers[i] == '5') {
      irsend.sendRaw(get(cable_five), cable_length, 38);
    } else if(numbers[i] == '6') {
      irsend.sendRaw(get(cable_six), cable_length, 38);
    } else if(numbers[i] == '7') {
      irsend.sendRaw(get(cable_seven), cable_length, 38);
    } else if(numbers[i] == '8') {
      irsend.sendRaw(get(cable_eight), cable_length, 38);
    } else if(numbers[i] == '9') {
      irsend.sendRaw(get(cable_nine), cable_length, 38);
    }
    
  }
  
}

void power(char* device) {
 
  if(strcmp(device,"system") == 0) {
    irsend.sendRC5(0xC, 12);
    irsend.sendRaw(get(cable_power), cable_length, 38);
  } else if (strcmp(device,"cable") == 0) {
    irsend.sendRaw(get(cable_power), cable_length, 38);
  } else if (strcmp(device,"tv") == 0) {
    irsend.sendRC5(0xC, 12);
  }
  
}

void source(char* source) {

  if(strcmp(source,"cable") == 0) {
    irsend.sendRC5(0x0, 12);
    delay(100);
    irsend.sendRC5(0x3, 12);
  } else if(strcmp(source,"netflix") == 0) {
    irsend.sendRC5(0x0, 12);
    delay(100);
    irsend.sendRC5(0x3, 12);
    delay(100);
    irsend.sendRC5(0x21, 12);
    delay(100);
    irsend.sendRC5(0x821, 12);
  } else if(strcmp(source,"apple") == 0) {
    irsend.sendRC5(0x0, 12);
    delay(100);
    irsend.sendRC5(0x3, 12);
    delay(100);
    irsend.sendRC5(0x21, 12);
    delay(100);
    irsend.sendRC5(0x821, 12);
    delay(100);
    irsend.sendRC5(0x21, 12);
  }
  
}

void sendCommand(char *command, char *value) {

  if(strcmp(command,"power") == 0)
    power(value);
  else if(strcmp(command,"source") == 0)
    source(value);
  else if(strcmp(command,"channel") == 0)
    channel(value);
    
}

unsigned int* get(prog_uint16_t code[]) {

  unsigned int arr[72];
  unsigned int c;
  int index = 0;
  
  while((c = pgm_read_word(code++))) {
    arr[index] = c;
    index++;
  }
  
  return arr;

}
