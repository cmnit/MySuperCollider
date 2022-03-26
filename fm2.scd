//
s = Server.local;
s.boot;
s.scope;
FreqScope.new;

m = ServerMeter.new(s, 4, 2);

//

(
SynthDef(\fm3env, { arg
	freq=110,
	carRatio=1,
	mod1Ratio=2, mod2Ratio=3, mod3Ratio=5,
	idx1Mod=5, idx2Mod=5, idx3Mod=5,
	atk=4, sus=12, rel=4,
	amp=1, pan=0;

	var mod1, mod2, mod3, car, env, envm1, envm2, envm3, dur;
	dur = atk+sus+rel;
	env  = EnvGen.kr(Env.new(levels:[0.01,1,1,0.01],times:[atk,sus,rel],curve:\exp),doneAction:2);
	// fades out
	envm1 = EnvGen.kr(Env.new(levels:[0,1,0,0],times:[atk,sus,rel],curve:\lin));
	// fades in
	envm2 = EnvGen.kr(Env.new(levels:[0,0,1,0],times:[atk,sus,rel],curve:\lin));
	// stays stable
	envm3 = EnvGen.kr(Env.new(levels:[0,1,1,0],times:[atk+sus/3,sus/3,sus/3+rel],curve:\lin));
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
Synth.new(\fm3env, [\freq, 55, \carRatio, 1, \mod1Ratio, 3, \mod2Ratio, 0.2, \mod3Ratio, 7, \idx1Mod, 10, \idx2Mod, 10, \idx3Mod, 10, \sus, 15]);
)

//

// Score test
// SynthDef includes done action (no gate) => no need to \n_free


(
var score;

score = Score.new([
	[0.0,
		[\g_new, 1000],
		[\s_new, \fm3env, 1001, 0, 1000, \freq, 110, \mod1Ratio, 3, \mod2Ratio, 5, \mod3Ratio, 7]
	],
	[20.0,
		[\s_new, \fm3env, 1002, 0, 1000, \freq, 55, \mod1Ratio, 7, \mod2Ratio, 0.618, \mod3Ratio, 5]
	],
	[40.0,
		[\s_new, \fm3env, 1003, 0, 1000, \freq, 220, \mod1Ratio, 5, \mod2Ratio, 0.143, \mod3Ratio, 0.618]
	],
	[60.0,
		[\n_free, 1000]
	],
	[60.00001, [0]]
]);

score.play(s);
)




