// CroneEngine_PolySine
// A test engine with three independent, mono sinewaves

// Inherit methods from CroneEngine
Engine_PolySine : CroneEngine {
	// Define a getter for the synth variable
	var <synth;

	// Define a class method when an object is created
	*new { arg context, doneCallback;
		// Return the object from the superclass (CroneEngine) .new method
		^super.new(context, doneCallback);
	}
	// Rather than defining a SynthDef, use a shorthand to allocate a function and send it to the engine to play
	// Defined as an empty method in CroneEngine
	// https://github.com/monome/norns/blob/master/sc/core/CroneEngine.sc#L31
	alloc {
		// Define the synth variable, which is a function
		synth = {
			// define arguments to the function for three independent sine waves
			arg out,
			hz1=220, amp1=0.5, amplag1=0.02, hzlag1=0.01, // Parameters for sine wave 1
			hz2=330, amp2=0.5, amplag2=0.02, hzlag2=0.01, // Parameters for sine wave 2
			hz3=440, amp3=0.5, amplag3=0.02, hzlag3=0.01; // Parameters for sine wave 3

			// initialize local vars for Lag'd amp and hz for each sine wave
			var amp1_, hz1_, amp2_, hz2_, amp3_, hz3_;
			var sine1, sine2, sine3; // Variables to hold each sine wave's output

			// --- Sine Wave 1 ---
			// Allow Lag (Slew in modular jargon) for amplitude and frequency
			amp1_ = Lag.ar(K2A.ar(amp1), amplag1);
			hz1_ = Lag.ar(K2A.ar(hz1), hzlag1);
			// Create the first sine oscillator
			sine1 = SinOsc.ar(hz1_) * amp1_;

			// --- Sine Wave 2 ---
			// Allow Lag for amplitude and frequency
			amp2_ = Lag.ar(K2A.ar(amp2), amplag2);
			hz2_ = Lag.ar(K2A.ar(hz2), hzlag2);
			// Create the second sine oscillator
			sine2 = SinOsc.ar(hz2_) * amp2_;

			// --- Sine Wave 3 ---
			// Allow Lag for amplitude and frequency
			amp3_ = Lag.ar(K2A.ar(amp3), amplag3);
			hz3_ = Lag.ar(K2A.ar(hz3), hzlag3);
			// Create the third sine oscillator
			sine3 = SinOsc.ar(hz3_) * amp3_;

			// Sum the three sine waves and output as stereo
			Out.ar(out, (sine1 + sine2 + sine3).dup);
		// Send the synth function to the engine as a UGen graph.
		// It seems like when an Engine is loaded it is passed an AudioContext
		// that is used to define audio routing stuff (Busses and Groups in SC parlance)
		// These methods are defined in
		// https://github.github.com/monome/norns/blob/master/sc/core/CroneAudioContext.sc
		// pass the CroneAudioContext method "out_b" as the value to the \out argument
		// pass the CroneAudioContext method "xg" as the value to the target.
		}.play(args: [\out, context.out_b], target: context.xg);

		// Export argument symbols as modulatable parameters for each sine wave
		// This could be extended to control the Lag time as additional params
		this.addCommand("hz1", "f", { arg msg;
			synth.set(\hz1, msg[1]);
		});
		this.addCommand("amp1", "f", { arg msg;
			synth.set(\amp1, msg[1]);
		});

		this.addCommand("hz2", "f", { arg msg;
			synth.set(\hz2, msg[1]);
		});
		this.addCommand("amp2", "f", { arg msg;
			synth.set(\amp2, msg[1]);
		});

		this.addCommand("hz3", "f", { arg msg;
			synth.set(\hz3, msg[1]);
		});
		this.addCommand("amp3", "f", { arg msg;
			synth.set(\amp3, msg[1]);
		});
	}
	// define a function that is called when the synth is shut down
	free {
		synth.free;
	}
}