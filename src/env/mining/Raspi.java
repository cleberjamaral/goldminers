package mining;

import java.util.logging.Logger;

import com.pi4j.io.gpio.GpioController;
import com.pi4j.io.gpio.GpioFactory;
import com.pi4j.io.gpio.GpioPinDigitalInput;
import com.pi4j.io.gpio.GpioPinDigitalOutput;
import com.pi4j.io.gpio.PinPullResistance;
import com.pi4j.io.gpio.RaspiPin;

import cartago.Artifact;
import cartago.IBlockingCmd;
import cartago.OPERATION;

public class Raspi extends Artifact {

	private static GpioController gpio;
	private static GpioPinDigitalInput sensorPin;
	private static GpioPinDigitalOutput ledPin;
	
	/* Performance check */
	long startTime;
	long elapsedEstimatedTime;
	
	ReadPinChange pinChange;

    private static Logger logger = Logger.getLogger(Raspi.class.getName());
    
    @OPERATION
    public void init() {
    	pinChange = new ReadPinChange(false);
        /** create gpio controller */
        System.setProperty("pi4j.linking", "dynamic"); //Because this issue: https://github.com/Pi4J/pi4j/issues/349
   		gpio = GpioFactory.getInstance();
   		
		//Pinmap in http://pi4j.com/pins/model-3b-rev1.html
   		sensorPin = gpio.provisionDigitalInputPin(RaspiPin.GPIO_00, PinPullResistance.PULL_UP);
   		ledPin = gpio.provisionDigitalOutputPin(RaspiPin.GPIO_01);
    }
    
    @OPERATION 
    void readSensorPin() throws Exception {
        while (true) {
        	logger.info("Awaiting...");
        	await(pinChange);
        	
        	elapsedEstimatedTime = System.nanoTime() - startTime;
        	logger.info("Elapsed estimated time: "+elapsedEstimatedTime/1000+"us");
		System.out.println("Elapsed time: "+elapsedEstimatedTime/1000+"us");

        	signal("sensorChanged", pinChange.state);
	    }
    }
    
    @OPERATION 
    void changeLedPin(String newState) throws Exception {
        try {
	        /** put gpio HIGH */
	        if (newState.equals("high")) {
	        	logger.info("Changing pin to HIGH!");
	        	ledPin.high();
	        	startTime = System.nanoTime();
	        }
	        
	        /** put gpio LOW */
	        if (newState.equals("low")) {
	        	logger.info("Changing pin to LOW!");
	        	ledPin.low();
	        	startTime = System.nanoTime();
	        }

	        /** toggle gpio state */
	        if (newState.equals("toggle")) {
	        	logger.info("Switched pin state!");
	        	ledPin.toggle();
	        	startTime = System.nanoTime();
	        }

        } catch (Exception e) {
	        e.printStackTrace();
	    }

        
    }

    class ReadPinChange implements IBlockingCmd {
    	private boolean state;
    	
    	public ReadPinChange(boolean initialState) {
    		state = initialState;
    	}
    	
    	public void exec() {
    		try {
    			
    			while ( true )	{
        	        /** Sensor state has changed - Event read!*/
        	        if ((sensorPin.isLow()) && (state)) { //State changed to false
        	        	state = false;
        	        	break;
        	        } else if ((sensorPin.isHigh()) && (!state)) { //State changed to true!
        	        	state = true;
        	        	break;
        	        }
    			}
    		} catch (Exception ex) {
            	logger.info("Exception! "+ex);
    		}
    		
    	}
    }

}
