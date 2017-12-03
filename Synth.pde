import oscP5.*;
import netP5.*;

class Synth {
  OscP5 _osc;
  NetAddress _remoteLocation;
  
  Synth (OscP5 oscSend, NetAddress remoteLocation) {
    _osc = oscSend;
    _remoteLocation = remoteLocation;
  }
  
  void createSynth(int id) {
    OscMessage message = new OscMessage("/SC/CreateSynth");
    message.add(id);
    _osc.send(message, _remoteLocation);
  }
  
  void adjustSynth(int id, int freq, float amp) {
    OscMessage message = new OscMessage("/SC/AdjustSynth");
    message.add(id);
    message.add(freq);
    message.add(amp);
    _osc.send(message, _remoteLocation); 
  }
  
  void stopRange(int lowId, int amount) {
    int upper = lowId + amount;
    for (int i = lowId; i < upper; i++) {
      OscMessage message = new OscMessage("/SC/FreeSynth");
      message.add(i);
      _osc.send(message, _remoteLocation); 
    }
  }
}