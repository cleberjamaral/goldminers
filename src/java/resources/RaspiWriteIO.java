/*
 * Based on: http://www.admfactory.com/blinking-led-on-raspberry-pi-using-java/
 */

package resources;

import jason.asSemantics.*;
import jason.asSyntax.*;
import com.pi4j.io.gpio.GpioController;
import com.pi4j.io.gpio.GpioFactory;
import com.pi4j.io.gpio.GpioPinDigitalOutput;
import com.pi4j.io.gpio.RaspiPin;

public class RaspiWriteIO extends DefaultInternalAction {

	private static final long serialVersionUID = 1L;
	private static GpioController gpio;
	private static GpioPinDigitalOutput ledPin;

	@Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	
        try {
	        /** create gpio controller */
	        System.setProperty("pi4j.linking", "dynamic"); //Because this issue: https://github.com/Pi4J/pi4j/issues/349
	        if (gpio == null) {
	    		gpio = GpioFactory.getInstance();
	    		ledPin = gpio.provisionDigitalOutputPin(RaspiPin.GPIO_01);
	    	}

	        /** put gpio HIGH */
	        if (args[0].toString().equals("high")) {
		        System.out.println("Changing pin to HIGH!");
	        	ledPin.high();
	        	return true;
	        }
	        
	        /** put gpio LOW */
	        if (args[0].toString().equals("low")) {
		        System.out.println("Changing pin to LOW!");
	        	ledPin.low();
	        	return true;
	        }

	        /** toggle gpio state */
	        if (args[0].toString().equals("toggle")) {
		        System.out.println("Switched pin state!");
	        	ledPin.toggle();
	        	return true;
	        }

        } catch (Exception e) {
	        e.printStackTrace();
	    }
        return false;
    }
}