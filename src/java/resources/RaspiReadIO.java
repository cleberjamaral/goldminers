package resources;
/*
 * Based on: http://www.admfactory.com/blinking-led-on-raspberry-pi-using-java/
 */

import jason.asSemantics.*;
import jason.asSyntax.*;
import com.pi4j.wiringpi.Gpio;
import com.pi4j.io.gpio.GpioController;
import com.pi4j.io.gpio.GpioFactory;
import com.pi4j.io.gpio.GpioPinDigitalInput;
import com.pi4j.io.gpio.GpioPinDigitalOutput;
import com.pi4j.io.gpio.RaspiPin;

public class RaspiReadIO extends DefaultInternalAction {

	private static final long serialVersionUID = 1L;
	private static GpioController gpio;
	private static GpioPinDigitalInput sensorPin;

	@Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	
        try {
	        /** create gpio controller */
	        System.setProperty("pi4j.linking", "dynamic"); //Because this issue: https://github.com/Pi4J/pi4j/issues/349
	        if (gpio == null) {
	    		gpio = GpioFactory.getInstance();
	    		sensorPin = gpio.provisionDigitalInputPin(RaspiPin.GPIO_00);
	    		sensorPin.setProperty("pull_up_down", "GPIO.PUD_UP");
	    	}

	        /** Sensor is activated */
	        if (sensorPin.isLow()) {
		        System.out.println("Sensor activated!");
	        	return true;
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }
        return false;
    }
}