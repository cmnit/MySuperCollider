//
s = Server.local;
s.boot;
s.scope;
FreqScope.new;

m = ServerMeter.new(s, 4, 2);

//


(
SynthDef(\fmsound, { arg pitch=40, carRatio=1, modRatio=2, idxMod=5, amp=1, atk=0.05, sus=0.8, rel=0.15;

	var mod, car, env, envm, baseHz;

	baseHz = pitch;
//	baseHz = midicps(pitch);
	//env = EnvGen.kr(Env.new(levels:[0,1,1,0],times:[atk,sus,rel]),doneAction:2);
	env  = EnvGen.kr(Env.new(levels:[0.01,1,1,0.01],times:[atk,sus,rel],curve:\exp),doneAction:2);
	envm = EnvGen.kr(Env.new(levels:[0,1,1,0],times:[atk+sus/4,sus/2,sus/4+rel],curve:\lin));
	mod = SinOsc.ar(baseHz*modRatio, mul:baseHz*modRatio*idxMod*envm);
	car = SinOsc.ar(baseHz*carRatio + mod, mul:amp*env);
	Out.ar(0, car);

}).add;
)

//

(
Synth(\fmsound, [\pitch, 110, \amp, 1, \modRatio, 4, \idxMod, 3]);
)

//

// MIDI 40 = E2
// Major scale
p = Pbind(
	\instrument, \fmsound,
	\dur, 1.0, \amp, 1.0,
	\pitch, Pseq([40,42,44,45,47,49,51,52,51,49,47,45,44,42,40])
);

// MIDI 45 = A2
// Minor scale
p = Pbind(
	\instrument, \fmsound,
	\dur, 1.0, \amp, 1.0,
	\pitch, Pseq([45,47,48,50,52,53,55,57,55,53,52,50,48,47,45])
);

// MIDI 45 = A2
// quarter-tone scale
(
b = 45;
p = Pbind(
	\instrument, \fmsound,
	\dur, 1.0, \amp, 1.0,
	\pitch, Pseq(([0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12]+b).midicps)
);
)

// MIDI 48 = C3
// Major scale
(
p = Pbind(
	\instrument, \fmsound,
	\dur, 1.0, \amp, 1.0,
	\pitch, Pseq(([0,2,4,5,7,9,11,12]+48).midicps)
);
)

// 12 note in "geometrical" intonation (harmonics up to 21th)

(
f = 110; // A2 Hz
p = Pbind(
	\instrument, \fmsound,
	\dur, 1.0, \amp, 1.0,
	\pitch, Pseq([1,17/16,9/8,19/16,5/4,21/16,11/8,3/2,13/8,7/4,15/8,2]*f)
);
)


// 7 note in Pythagorical intonation

(
f = 110; // A2 Hz
p = Pbind(
	\instrument, \fmsound,
	\dur, 1.0, \amp, 1.0,
	\pitch, Pseq([1,9/8,81/64,4/3,3/2,27/16,243/128,2]*f)
);
)


p.play;


midicps(69)

