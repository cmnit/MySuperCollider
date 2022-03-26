//
s = Server.local;
s.boot;
s.scope;
FreqScope.new;

m = ServerMeter.new(s, 4, 2);

//

(
SynthDef(\fm3, { arg
	freq=55,
	carRatio=1, car1Ratio=1, car2Ratio=11,
	mod1Ratio=2, mod2Ratio=3, mod3Ratio=5,
	idx1Mod=5, idx2Mod=5, idx3Mod=5,
	amp=1, pan=0, dur=10;

	var mod1, mod2, mod3, car, envc1;

	envc1 = EnvGen.kr(Env.new(levels:[car1Ratio,car2Ratio],times:[dur],curve:\lin));

	mod1 = SinOsc.ar(freq*mod1Ratio, mul:freq*mod1Ratio*idx1Mod);
	mod2 = SinOsc.ar(freq*mod2Ratio, mul:freq*mod2Ratio*idx2Mod);
	mod3 = SinOsc.ar(freq*mod3Ratio, mul:freq*mod3Ratio*idx3Mod);
	car  = SinOsc.ar(freq*carRatio*envc1 + mod1 + mod2 + mod3, mul:amp);
	Out.ar([0,1], Pan2.ar(car, pan));

}).add;
)

//

(
Synth.new(\fm3, [\freq, 55, \car1Ratio, 0.25, \car2Ratio, 8, \mod1Ratio, 3, \mod2Ratio, 5, \mod3Ratio, 7, \idx1Mod, 7, \idx2Mod, 4, \idx3Mod, 0, \dur, 12]);
)


//

(
SynthDef(\fm3env, { arg
	freq=110,
	carRatio=1,
	mod1Ratio=2, mod2Ratio=3, mod3Ratio=5,
	idx1Mod=5, idx2Mod=5, idx3Mod=5,
	atk=3, sus=9, rel=3,
	amp=1, pan=0;

	var mod1, mod2, mod3, car, env, envm1, envm2, envm3, dur;
	dur = atk+sus+rel;
	env  = EnvGen.kr(Env.new(levels:[0.01,1,1,0.01],times:[atk,sus,rel],curve:\exp),doneAction:2);
	// fades out
	envm1 = EnvGen.kr(Env.new(levels:[0,1,0,0],times:[atk,sus,rel],curve:\lin));
	// fades in
	envm2 = EnvGen.kr(Env.new(levels:[0,0,1,0],times:[atk,sus,rel],curve:\lin));
	// stays stable
	envm3 = EnvGen.kr(Env.new(levels:[0,1,1,0],times:[atk+sus/4,sus/2,sus/4+rel],curve:\lin));
	mod1 = SinOsc.ar(freq*mod1Ratio, mul:freq*mod1Ratio*idx1Mod*envm1);
	mod2 = SinOsc.ar(freq*mod2Ratio, mul:freq*mod2Ratio*idx2Mod*envm2);
	mod3 = SinOsc.ar(freq*mod3Ratio, mul:freq*mod3Ratio*idx3Mod*envm3);
	car  = SinOsc.ar(freq*carRatio + mod1 + mod2 + mod3, mul:amp*env);
	Out.ar([0,1], Pan2.ar(car, pan));
//	Out.ar(0, car);
//	Pan2.ar(car, pan, 1);

}).add;
)

//

Synth.new(\fm3env);

(
Synth.new(\fm3env, [\freq, 40, \carRatio, 1, \mod1Ratio, 5, \mod2Ratio, 0.33, \mod3Ratio, 7, \idx1Mod, 10, \idx2Mod, 10, \idx3Mod, 10, \sus, 9]);
)

//


//

(
SynthDef(\fm2env, { arg
	freq=110,
	carRatio=1,
	mod1Ratio=2, mod2Ratio=3,
	idx1Mod=8, idx2Mod=8,
	atk=2, sus=2, rel=2,
	amp=1, pan=0;

	var mod1, mod2, car, env, envm, dur;
	dur = atk+sus+rel;
	env  = EnvGen.kr(Env.new(levels:[0.01,1,1,0.01],times:[atk,sus,rel],curve:\exp),doneAction:2);
	envm = EnvGen.kr(Env.new(levels:[0,1,1,0],times:[atk,sus,rel],curve:\lin));
	mod1 = SinOsc.ar(freq*mod1Ratio, mul:freq*mod1Ratio*idx1Mod*envm);
	mod2 = SinOsc.ar(freq*mod2Ratio, mul:freq*mod2Ratio*idx2Mod*envm);
	car  = SinOsc.ar(freq*carRatio + mod1 + mod2, mul:amp*env);
	Out.ar([0,1], Pan2.ar(car, pan));
//	Out.ar(0, car);
//	Pan2.ar(car, pan, 1);

}).add;
)

//

(
Synth.new(\fm2env, [\freq, 40, \carRatio, 1, \mod1Ratio, 2, \mod2Ratio, 0.2, \idx1Mod, 10, \idx2Mod, 10]);
)

//
(
var score;

score = Score.new([
	[0.0,
		[\g_new, 1000],
		[\s_new, \fm2env, 1101, 0, 1000,
			\freq,  40, \mod1Ratio, 2, \mod2Ratio, 3]
	],
	[0.1,
		[\s_new, \fm2env, 1102, 0, 1000,
			\freq,  80, \mod1Ratio, 2, \mod2Ratio, 3]
	],
	[10.0,
		[\n_free, 1000]
	],
	[10.00001, [0]]
]);

score.play(s);
)

//

// Score
// SynthDef includes done action (no gate) => no need to \n_free
// 1: fades out
// 2: fades in
// 3: stays active

(
var score;

score = Score.new([
	[0.0,
		[\g_new, 1000],
		[\s_new, \fm2env, 1101, 0, 1000,
			\freq,  40, \mod1Ratio, 2, \mod2Ratio, 3]
	],
	[0.01,
		[\s_new, \fm2env, 1102, 0, 1000,
			\freq, 120, \mod1Ratio, 2, \mod2Ratio, 3]
	],
	[0.02,
		[\s_new, \fm3env, 1001, 0, 1000,
			\freq,  40, \mod1Ratio, 2, \mod2Ratio, 5, \mod3Ratio, 3]
	],
	[12.0,
		[\s_new, \fm2env, 1103, 0, 1000,
			\freq,  40, \mod1Ratio, 3, \mod2Ratio, 5]
	],
	[12.01,
		[\s_new, \fm2env, 1104, 0, 1000,
			\freq,  80, \mod1Ratio, 3, \mod2Ratio, 5]
	],
	[15.0,
		[\s_new, \fm3env, 1002, 0, 1000,
			\freq,  80, \mod1Ratio, 3, \mod2Ratio, 2, \mod3Ratio, 5]
	],
	[27.0,
		[\s_new, \fm2env, 1105, 0, 1000,
			\freq,  80, \mod1Ratio, 2, \mod2Ratio, 5]
	],
	[27.01,
		[\s_new, \fm2env, 1106, 0, 1000,
			\freq, 120, \mod1Ratio, 2, \mod2Ratio, 5]
	],
	[30.0,
		[\s_new, \fm3env, 1003, 0, 1000,
			\freq, 160, \mod1Ratio, 2, \mod2Ratio, 0.143, \mod3Ratio, 5]
	],
	[42.0,
		[\s_new, \fm2env, 1107, 0, 1000,
			\freq,  40, \mod1Ratio, 5, \mod2Ratio, 0.143]
	],
	[42.01,
		[\s_new, \fm2env, 1108, 0, 1000,
			\freq, 120, \mod1Ratio, 5, \mod2Ratio, 0.143]
	],
	[45.0,
		[\s_new, \fm3env, 1004, 0, 1000,
			\freq, 40, \mod1Ratio, 5, \mod2Ratio, 2, \mod3Ratio, 0.143]
	],
	[57.0,
		[\s_new, \fm2env, 1109, 0, 1000,
			\freq,  40, \mod1Ratio, 2, \mod2Ratio, 0.143]
	],
	[57.01,
		[\s_new, \fm2env, 1110, 0, 1000,
			\freq,  80, \mod1Ratio, 2, \mod2Ratio, 0.143]
	],
	[60.0,
		[\s_new, \fm3env, 1005, 0, 1000,
			\freq, 80, \mod1Ratio, 2, \mod2Ratio, 3, \mod3Ratio, 0.143]
	],
	[75.0,
		[\s_new, \fm3env, 1006, 0, 1000,
			\freq, 160, \mod1Ratio, 3, \mod2Ratio, 0.2, \mod3Ratio, 0.143]
	],
	[90.0,
		[\s_new, \fm3env, 1007, 0, 1000,
			\freq, 40, \mod1Ratio, 0.143, \mod2Ratio, 3, \mod3Ratio, 0.2]
	],
	[105.0,
		[\s_new, \fm3env, 1008, 0, 1000,
			\freq, 80, \mod1Ratio, 0.2, \mod2Ratio, 7, \mod3Ratio, 3]
	],
	[120.0,
		[\s_new, \fm3env, 1009, 0, 1000,
			\freq, 160, \mod1Ratio, 7, \mod2Ratio, 0.5, \mod3Ratio, 3]
	],
	[135.0,
		[\s_new, \fm3env, 1010, 0, 1000,
			\freq, 40, \mod1Ratio, 3, \mod2Ratio, 0.143, \mod3Ratio, 0.5]
	],
	[150.0,
		[\s_new, \fm3env, 1011, 0, 1000,
			\freq, 80, \mod1Ratio, 0.143, \mod2Ratio, 5, \mod3Ratio, 0.5]
	],
	[165.0,
		[\s_new, \fm3env, 1012, 0, 1000,
			\freq, 160, \mod1Ratio, 0.5, \mod2Ratio, 7, \mod3Ratio, 5]
	],
	[180.0,
		[\n_free, 1000]
	],
	[60.00001, [0]]
]);

score.play(s);
)




