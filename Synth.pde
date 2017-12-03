import oscP5.*;
import netP5.*;

class Synth {
  OscP5 _osc;
  NetAddress _remoteLocation;
  
  Synth (OscP5 oscSend, NetAddress remoteLocation) {
    _osc = oscSend;
  }
  
  void createSynth(int id) {
    OscMessage message = new OscMessage("/SC/CreateSynth");
    message.add(id);
    _osc.send(message, _remoteLocation); 
  }
}