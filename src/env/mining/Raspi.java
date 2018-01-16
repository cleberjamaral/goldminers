package mining;

import java.util.logging.Logger;

import com.pi4j.io.gpio.GpioController;
import com.pi4j.io.gpio.GpioFactory;
import com.pi4j.io.gpio.GpioPinDigitalInput;
import com.pi4j.io.gpio.RaspiPin;

import cartago.Artifact;
import cartago.OPERATION;

public class Raspi extends Artifact {

	private static GpioController gpio;
	private static GpioPinDigitalInput sensorPin;

    private static Logger logger = Logger.getLogger(Raspi.class.getName());
    
    @OPERATION
    public void init() {
        /** create gpio controller */
        System.setProperty("pi4j.linking", "dynamic"); //Because this issue: https://github.com/Pi4J/pi4j/issues/349
//        if (gpio == null) {
    		gpio = GpioFactory.getInstance();
    		sensorPin = gpio.provisionDigitalInputPin(RaspiPin.GPIO_00);
    		sensorPin.setProperty("pull_up_down", "GPIO.PUD_UP");
//    	}
    }
    
    
    @OPERATION void readIO() throws Exception {
        try {
	        /** Sensor is activated */
	        if (sensorPin.isLow()) {
	        	logger.info("Sensor activated!");
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }
        
    }

}
