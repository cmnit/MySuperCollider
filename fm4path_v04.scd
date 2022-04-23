//
// FM Path on a 24-Cell
// v0.4
// cmn 2022-04-23
//

s = Server.local;
s.boot;

s.plotTree;

s.scope;

// it does not work anymore...
//~freqscope1 = FreqScope.new(busNum:0);
//~freqscope2 = FreqScope.new(busNum:1);

~meter = ServerMeter.new(s, 4, 2);


// Busses

~fxBus     = Bus.audio(s, 2);
~masterBus = Bus.audio(s, 2);

//FreqScope.new(busNum:~masterBus);

// Groups

~sources = Group.new;
~effects = Group.new(~sources, \addAfter);
~master  = Group.new(~effects, \addAfter);

// Master control

(
SynthDef(\masterOut, { arg
	amp=1;
	var signal;
	signal = In.ar(~masterBus,2) * Lag.kr(amp,0.3);
//	signal = In.ar(~masterBus,2) * amp;  // it works
	Out.ar(0, signal);
}).add;
)

// FX

(
SynthDef(\fx, { arg
	lc=20, hc=5000;
	var signal;
	signal = HPF.ar(HPF.ar(LPF.ar(In.ar(~fxBus,2),hc),lc),lc);
	signal = FreeVerb.ar(signal, mix:0.4, room:0.6, damp:0.3);
	Out.ar(~masterBus,signal);

}).add;
)

// Sources

// FM2 granular
(
SynthDef(\fm2grain, { arg
	freq1=72, freq2=216, pan0=1.0, amp=1.0, dur=10.0,
	m1r=6/5, m2r=8/5,
	ampgr1=0.25, ampgr2=0.12,
	carRatio=1, idx1m=3.832, idx2m=3.832,
	grdur=0.10, grdens=25;

	var mix, mix1, env, envp, envd, envt;
	var p1, p2;
	var detune = 1.006; // = 10.4 cents ( => pan0 = 1.0)
	var decay = 2.0;

	env  = EnvGen.kr(Env.new(levels:[amp/2,amp,amp/2,0.1],times:[dur/2,dur/2,decay],curve:\exp),doneAction:2);
	envd = EnvGen.kr(Env.new(levels:[2,grdens,2,0.1],times:[dur/2,dur/2,decay],curve:\exp));
	envt = EnvGen.kr(Env.new(levels:[3*grdur,grdur,3*grdur,3*grdur],times:[dur/2,dur/2,decay],curve:\exp));
	envp = 1;

	p1 = freq1;
	p2 = freq2;
	mix = Mix.ar([
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1, modfreq:p1*m1r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1, modfreq:p1*m2r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1*m1r, modfreq:p1*m1r*m1r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1*m1r, modfreq:p1*m1r*m2r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1*m2r, modfreq:p1*m2r*m1r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1*m2r, modfreq:p1*m2r*m2r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2, modfreq:p2*m1r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2, modfreq:p2*m2r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2*m1r, modfreq:p2*m1r*m1r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2*m1r, modfreq:p2*m1r*m2r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2*m2r, modfreq:p2*m2r*m1r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2*m2r, modfreq:p2*m2r*m2r, index:idx2m, mul:ampgr2)]
	);
	mix = mix*env;

	p1 = freq1*(1+((detune-1)*pan0*envp));
	p2 = freq2*(1+((detune-1)*pan0*envp));
	mix1 = Mix.ar([
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1, modfreq:p1*m1r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1, modfreq:p1*m2r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1*m1r, modfreq:p1*m1r*m1r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1*m1r, modfreq:p1*m1r*m2r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1*m2r, modfreq:p1*m2r*m1r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p1*m2r, modfreq:p1*m2r*m2r, index:idx1m, mul:ampgr1),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2, modfreq:p2*m1r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2, modfreq:p2*m2r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2*m1r, modfreq:p2*m1r*m1r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2*m1r, modfreq:p2*m1r*m2r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2*m2r, modfreq:p2*m2r*m1r, index:idx2m, mul:ampgr2),
		GrainFM.ar(trigger:Dust.kr(envd), dur:LFNoise0.kr(100,envt/2,envt), carfreq:p2*m2r, modfreq:p2*m2r*m2r, index:idx2m, mul:ampgr2)]
	);
	mix1 = mix1*env;

	Out.ar(~fxBus,[mix,mix1]);

}).add;
)

// obsolete FM2 if granular is used
(
SynthDef(\fm2env, { arg
	freq=240, pan0=1.0,
	carRatio=1, m1r=2, m2r=0.5, idx1m=3.832, idx2m=3.832,
	atk  = 0.20, rel  = 0.50,
	atkm = 0.01, susm = 0.05,
	amp=0.5;

	var mod1, mod2, car, env, envm, relm, dur;

	var pitch, car1;
	var detune = 1.006; // = 10.4 cents ( => pan0 = 1.0)

	dur = atk+rel;
	relm = dur-(atkm+susm); // NO control of relm > 0

	env  = EnvGen.kr(Env.perc(atk,rel,curve:-4),doneAction:2);

	envm = EnvGen.kr(Env.new(levels:[0,1,1,0],times:[atkm,susm,relm],curve:\lin));

	pitch = freq;
	mod1 = SinOsc.ar(pitch*m1r, mul:pitch*m1r*idx1m*envm);
	mod2 = SinOsc.ar(pitch*m2r, mul:pitch*m2r*idx2m*envm);
	car  = SinOsc.ar(pitch*carRatio + mod1 + mod2, mul:amp*env);

	pitch = freq*(1+((detune-1)*pan0));
	mod1 = SinOsc.ar(pitch*m1r, mul:pitch*m1r*idx1m*envm);
	mod2 = SinOsc.ar(pitch*m2r, mul:pitch*m2r*idx2m*envm);
	car1 = SinOsc.ar(pitch*carRatio + mod1 + mod2, mul:amp*env);

	Out.ar(~fxBus,[car,car1]);

}).add;
)

//
// FM 4-mods with fade in/out
// Modulation index fine control for zero Bessel (harmonics suppression)
// simple stereo detune
//
(
SynthDef(\fm4env, { arg
	freq=110, pan0=1.0,
	carRatio=1,
	m1r=2, m2r=3, m3r=5, m4r=7,
	idx1m=3.832, idx2m=3.832, idx3m=3.832, idx4m=3.832,
	l1s=1, l1e=1, l2s=1, l2e=0, l3s=0, l3e=1, l4s=0, l4e=0,
	atk=2, sus=8, rel=2,
	amp=0.5;

	var mod1, mod2, mod3, mod4, car, env, envm1, envm2, envm3, envm4, dur;
	var atkm,susm1,rampm,susm2,relm;

	var pitch, car1, pan, envp;
	var detune = 1.006; // = 10.4 cents ( => pan0 = 1.0)

	dur = atk+sus+rel;
	atkm  =   dur/11;
	susm1 = 2*dur/11;
	rampm = 5*dur/11;
	susm2 = 2*dur/11;
	relm  =   dur/11;

	env  = EnvGen.kr(Env.new(levels:[0.01,1,1,0.01],times:[atk,sus,rel],curve:\exp),doneAction:2);

	envm1 = EnvGen.kr(Env.new(levels:[0,l1s,l1s,l1e,l1e,0],times:[atkm,susm1,rampm,susm2,relm],curve:\lin));
	envm2 = EnvGen.kr(Env.new(levels:[0,l2s,l2s,l2e,l2e,0],times:[atkm,susm1,rampm,susm2,relm],curve:\lin));
	envm3 = EnvGen.kr(Env.new(levels:[0,l3s,l3s,l3e,l3e,0],times:[atkm,susm1,rampm,susm2,relm],curve:\lin));
	envm4 = EnvGen.kr(Env.new(levels:[0,l4s,l4s,l4e,l4e,0],times:[atkm,susm1,rampm,susm2,relm],curve:\lin));

	envp  = EnvGen.kr(Env.new(levels:[0,1,0.3,1,0.3,1,0],times:[atkm,susm1,rampm/2,rampm/2,susm2,relm],curve:\lin));

	mod1 = SinOsc.ar(freq*m1r, mul:freq*m1r*idx1m*envm1);
	mod2 = SinOsc.ar(freq*m2r, mul:freq*m2r*idx2m*envm2);
	mod3 = SinOsc.ar(freq*m3r, mul:freq*m3r*idx3m*envm3);
	mod4 = SinOsc.ar(freq*m4r, mul:freq*m4r*idx4m*envm4);
	car  = SinOsc.ar(freq*carRatio + mod1 + mod2 + mod3 + mod4, mul:amp*env);

	pitch = freq*(1+((detune-1)*pan0*envp));
	mod1 = SinOsc.ar(pitch*m1r, mul:pitch*m1r*idx1m*envm1);
	mod2 = SinOsc.ar(pitch*m2r, mul:pitch*m2r*idx2m*envm2);
	mod3 = SinOsc.ar(pitch*m3r, mul:pitch*m3r*idx3m*envm3);
	mod4 = SinOsc.ar(pitch*m4r, mul:pitch*m4r*idx4m*envm4);
	car1 = SinOsc.ar(pitch*carRatio + mod1 + mod2 + mod3 + mod4, mul:amp*env);

	Out.ar(~fxBus,[car,car1]);

}).add;
)

//
// Execution
//

// activate Master, FX
(
m = Synth.new(\masterOut, target: ~master);
f = Synth.new(\fx,        target: ~effects);
)

m.set(\amp, 0.5);
f.set(\hc, 5000, \lc, 20);
f.set(\mix, 0.2, \room, 0.7, \damp, 0.4);

m.free; f.free;

//
// play Sources
//

//
// Score as Task
//

(
t = Task{

	var j0z1 = 2.405, j0z2 = 5.520, j0z3 =  8.654;
	var j1z1 = 3.832, j1z2 = 7.016, j1z3 = 10.173;
	var j2z1 = 5.136, j2z2 = 8.417, j2z3 = 11.620;

	var f1 = 72, f2 = 216, f3 = 648; // A4 = 432 Hz

    var a1 = 6/5, a2 = 5/6;
	var b1 = 7/5, b2 = 5/7; // tritone
	var c1 = 8/5, c2 = 5/8;
	var d1 = 9/5, d2 = 5/9;

	var ampmix = 0.2;
	var ampgr1 = 0.25, ampgr2 = 0.12, ampgr3 = 0.08;

	var tr_atk = 2.5, tr_sus = 10.0, tr_rel = 2.5;
	var trwtime = tr_atk + tr_sus + tr_rel - 2.5;
	var vx_dur  = 10.0;
	var vxwtime = vx_dur - 2.5;

	var ch, n;

	"start".postln;

	"vertex  1: ++00 RG".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, a1, \m2r, b1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition  1-> 2 G: ++00 -> +0+0".postln;
	ch = [f2, f2*a1]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
			\freq, ch[i], \m1r, a1, \m2r, b1, \m3r, c1, \m4r, d1,
			              \l1s,  1, \l2s,  1, \l3s,  0, \l4s,  0,
			              \l1e,  1, \l2e,  0, \l3e,  1, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex  2: +0+0 GB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f2, \freq2, f3, \m1r, a1, \m2r, c1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition  2-> 3 B: +0+0 -> +00+".postln;
	ch = [f3, f3*a1]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b1, \m3r, c1, \m4r, d1,
			              \l1s,  1, \l2s,  0, \l3s,  1, \l4s,  0,
		                  \l1e,  1, \l2e,  0, \l3e,  0, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex  3: +00+ RB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f3, \m1r, a1, \m2r, d1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition  3-> 4 B: +00+ -> 0+0+".postln;
	ch = [f3, f3*d1]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b1, \m3r, c1, \m4r, d1,
		 	              \l1s,  1, \l2s,  0, \l3s,  0, \l4s,  1,
  		                  \l1e,  0, \l2e,  1, \l3e,  0, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex  4: 0+0+ GB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f2, \freq2, f3, \m1r, b1, \m2r, d1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr2, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition  4-> 5 G: 0+0+ -> 00++".postln;
	ch = [f2, f2*d1]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b1, \m3r, c1, \m4r, d1,
			              \l1s,  0, \l2s,  1, \l3s,  0, \l4s,  1,
		                  \l1e,  0, \l2e,  0, \l3e,  1, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex  5: 00++ RG".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, c1, \m2r, d1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition  5-> 6 R: 00++ -> 0++0".postln;
	ch = [f1, f1*c1]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b1, \m3r, c1, \m4r, d1,
			              \l1s,  0, \l2s,  0, \l3s,  1, \l4s,  1,
		                  \l1e,  0, \l2e,  1, \l3e,  1, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex  6: 0++0 RB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, b1, \m2r, c1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition  6-> 7 R: 0++0 -> -+00".postln;
	ch = [f1, f1*b1]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b1, \m3r, c1, \m4r, d1,
			              \l1s,  0, \l2s,  1, \l3s,  1, \l4s,  0,
	                      \l1e,  1, \l2e,  1, \l3e,  0, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex  7: -+00 RG".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, a2, \m2r, b1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition  7-> 8 G: -+00 -> -0+0".postln;
	ch = [f2, f2*a2]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b1, \m3r, c1, \m4r, d1,
			              \l1s,  1, \l2s,  1, \l3s,  0, \l4s,  0,
			              \l1e,  1, \l2e,  0, \l3e,  1, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex  8: -0+0 GB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f2, \freq2, f3, \m1r, a2, \m2r, c1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr2, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition  8-> 9 B: -0+0 -> -00+".postln;
	ch = [f3, f3*a2]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b1, \m3r, c1, \m4r, d1,
			              \l1s,  1, \l2s,  0, \l3s,  1, \l4s,  0,
			              \l1e,  1, \l2e,  0, \l3e,  0, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex  9: -00+ RB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, a2, \m2r, d1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition  9->10 B: -00+ -> 0-0+".postln;
	ch = [f3, f3*d1]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b2, \m3r, c1, \m4r, d1,
			              \l1s,  1, \l2s,  0, \l3s,  0, \l4s,  1,
			              \l1e,  0, \l2e,  1, \l3e,  0, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex 10: 0-0+ GB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f2, \freq2, f3, \m1r, b2, \m2r, d1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr2, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 10->11 G: 0-0+ -> 00-+".postln;
	ch = [f2, f2*d1]; n = ch.size;
	n.do{ |i|
	Synth.head(~sources,\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j2z1, \idx4m, j1z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b2, \m3r, c2, \m4r, d1,
			              \l1s,  0, \l2s,  1, \l3s,  0, \l4s,  1,
			              \l1e,  0, \l2e,  0, \l3e,  1, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex 11: 00-+ RG".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, c2, \m2r, d1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition 11->12 R: 00-+ -> 0--0".postln;
	ch = [f1, f1*c2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z3, \idx2m, j1z3, \idx3m, j2z3, \idx4m, j1z3,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b2, \m3r, c2, \m4r, d1,
			              \l1s,  0, \l2s,  0, \l3s,  1, \l4s,  1,
			              \l1e,  0, \l2e,  1, \l3e,  1, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex 12: 0--0 RB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f3, \m1r, b2, \m2r, c2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 12->13 R: 0--0 -> --00".postln;
	ch = [f1, f1*b2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z3, \idx2m, j1z3, \idx3m, j2z3, \idx4m, j1z3,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b2, \m3r, c2, \m4r, d1,
			              \l1s,  0, \l2s,  1, \l3s,  1, \l4s,  0,
			              \l1e,  1, \l2e,  1, \l3e,  0, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex 13: --00 RG".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, a2, \m2r, b2, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition 13->14 G: --00 -> -0-0".postln;
	ch = [f2, f2*a2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z2, \idx2m, j1z2, \idx3m, j2z2, \idx4m, j1z2,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b2, \m3r, c2, \m4r, d1,
			              \l1s,  1, \l2s,  1, \l3s,  0, \l4s,  0,
			              \l1e,  1, \l2e,  0, \l3e,  1, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex 14: -0-0 GB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f2, \freq2, f3, \m1r, a2, \m2r, c2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr2, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 14->15 B: -0-0 -> -00-".postln;
	ch = [f3, f3*a2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j2z1, \idx4m, j2z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b2, \m3r, c2, \m4r, d2,
			              \l1s,  1, \l2s,  0, \l3s,  1, \l4s,  0,
			              \l1e,  1, \l2e,  0, \l3e,  0, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex 15: -00- RB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f3, \m1r, a2, \m2r, d2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 15->16 B: -00- -> 0-0-".postln;
	ch = [f3, f3*d2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j2z1, \idx4m, j2z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b2, \m3r, c2, \m4r, d2,
			              \l1s,  1, \l2s,  0, \l3s,  0, \l4s,  1,
			              \l1e,  0, \l2e,  1, \l3e,  0, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex 16: 0-0- GB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f2, \freq2, f3, \m1r, b2, \m2r, d2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr2, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 16->17 G: 0-0- -> 00--".postln;
	ch = [f2, f2*d2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z2, \idx2m, j1z2, \idx3m, j2z2, \idx4m, j2z2,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b2, \m3r, c2, \m4r, d2,
			              \l1s,  0, \l2s,  1, \l3s,  0, \l4s,  1,
			              \l1e,  0, \l2e,  0, \l3e,  1, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex 17: 00-- RG".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, c2, \m2r, d2, \idx1m, j2z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition 17->18 G: 00-- -> +0-0".postln;
	ch = [f2, f2*c2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z2, \idx2m, j1z2, \idx3m, j2z2, \idx4m, j2z2,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b2, \m3r, c2, \m4r, d2,
			              \l1s,  0, \l2s,  0, \l3s,  1, \l4s,  1,
			              \l1e,  1, \l2e,  0, \l3e,  1, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex 18: +0-0 GB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f2, \freq2, f3, \m1r, a1, \m2r, c2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr2, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 18->19 G: +0-0 -> +-00".postln;
	ch = [f2, f2*a1]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z2, \idx2m, j1z2, \idx3m, j2z2, \idx4m, j2z2,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b2, \m3r, c2, \m4r, d2,
			              \l1s,  1, \l2s,  0, \l3s,  1, \l4s,  0,
			              \l1e,  1, \l2e,  1, \l3e,  0, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex 19: +-00 RG".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, a1, \m2r, b2, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition 19->20 R: +-00 -> 0-+0".postln;
	ch = [f1, f1*b2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z3, \idx2m, j1z3, \idx3m, j1z3, \idx4m, j2z3,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b2, \m3r, c1, \m4r, d2,
			              \l1s,  1, \l2s,  1, \l3s,  0, \l4s,  0,
			              \l1e,  0, \l2e,  1, \l3e,  1, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex 20: 0-+0 RB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f3, \m1r, b2, \m2r, c1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 20->21 R: 0-+0 -> 00+-".postln;
	ch = [f1, f1*c1]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z3, \idx2m, j1z3, \idx3m, j1z3, \idx4m, j2z3,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b2, \m3r, c1, \m4r, d2,
			              \l1s,  0, \l2s,  1, \l3s,  1, \l4s,  0,
			              \l1e,  0, \l2e,  0, \l3e,  1, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex 21: 00+- RG".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, c1, \m2r, d2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;
	"transition 21->22 R: 00+- -> +00-".postln;
	ch = [f1, f1*d2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z3, \idx2m, j1z3, \idx3m, j1z3, \idx4m, j2z3,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a1, \m2r, b2, \m3r, c1, \m4r, d2,
			              \l1s,  0, \l2s,  0, \l3s,  1, \l4s,  1,
			              \l1e,  1, \l2e,  0, \l3e,  0, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex 22: +00- RB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f3, \m1r, a1, \m2r, d2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 22->23 B: +00- -> 0+0-".postln;
	ch = [f3, f3*d2]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j1z1, \idx4m, j2z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
			\freq, ch[i], \m1r, a1, \m2r, b1, \m3r, c2, \m4r, d2,
			              \l1s,  1, \l2s,  0, \l3s,  0, \l4s,  1,
			              \l1e,  0, \l2e,  1, \l3e,  0, \l4e,  1]
	);};
	trwtime.wait;
//
	"vertex 23: 0+0- GB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f2, \freq2, f3, \m1r, b1, \m2r, d2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr2, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 23->24 B: 0+0- -> 0+-0".postln;
	ch = [f3, f3*b1]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z1, \idx2m, j1z1, \idx3m, j2z1, \idx4m, j2z1,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
		    \freq, ch[i], \m1r, a2, \m2r, b1, \m3r, c2, \m4r, d2,
			              \l1s,  0, \l2s,  1, \l3s,  0, \l4s,  1,
			              \l1e,  0, \l2e,  1, \l3e,  1, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex 24: 0+-0 RB".postln;
	Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f3, \m1r, b1, \m2r, c2, \idx1m, j1z1, \idx2m, j2z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr3
	]);
	vxwtime.wait;
	"transition 24->1 R: 0+-0 -> ++00".postln;
	ch = [f1, f1*b1]; n = ch.size;
	n.do{ |i|
	Synth.new(\fm4env, [\idx1m, j1z3, \idx2m, j1z3, \idx3m, j2z3, \idx4m, j2z3,
			\amp, ampmix, \atk, tr_atk, \sus, tr_sus, \rel, tr_rel,
			\freq, ch[i], \m1r, a1, \m2r, b1, \m3r, c1, \m4r, d1,
			              \l1s,  0, \l2s,  1, \l3s,  1, \l4s,  0,
			              \l1e,  1, \l2e,  1, \l3e,  0, \l4e,  0]
	);};
	trwtime.wait;
//
	"vertex  1: ++00 RG".postln;
		Synth.head(~sources,\fm2grain, [
		\freq1, f1, \freq2, f2, \m1r, a1, \m2r, b1, \idx1m, j1z1, \idx2m, j1z1, \dur, vx_dur,
		\ampgr1, ampgr1, \ampgr2, ampgr2
	]);
	vxwtime.wait;


	"end".postln

};
)

// end Score as Task

t.start;

t.stop;

t.resume;

t.reset;

// ////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////////////////////////////


//
// 24-cell path
//
// ++00 | +0+0 | +00+ | 0+0+ | 00++ | 0++0 | -+00 | -0+0
// -00+ | 0-0+ | 00-+ | 0--0 | --00 | -0-0 | -00- | 0-0-
// 00-- | +0-0 | +-00 | 0-+0 | 00+- | +00- | 0+0- | 0+-0 | ++00
//

// void reference
(
	"vertex  1: ++00 RG".postln;
	"transition  1-> 2 G: ++00 -> +0+0".postln;
	"vertex  2: +0+0 GB".postln;
	"transition  2-> 3 B: +0+0 -> +00+".postln;
	"vertex  3: +00+ RB".postln;
	"transition  3-> 4 B: +00+ -> 0+0+".postln;
	"vertex  4: 0+0+ GB".postln;
	"transition  4-> 5 G: 0+0+ -> 00++".postln;
	"vertex  5: 00++ RG".postln;
	"transition  5-> 6 R: 00++ -> 0++0".postln;
	"vertex  6: 0++0 RB".postln;
	"transition  6-> 7 R: 0++0 -> -+00".postln;
	"vertex  7: -+00 RG".postln;
	"transition  7-> 8 G: -+00 -> -0+0".postln;
	"vertex  8: -0+0 GB".postln;
	"transition  8-> 9 B: -0+0 -> -00+".postln;
	"vertex  9: -00+ RB".postln;
	"transition  9->10 B: -00+ -> 0-0+".postln;
	"vertex 10: 0-0+ GB".postln;
	"transition 10->11 G: 0-0+ -> 00-+".postln;
	"vertex 11: 00-+ RG".postln;
	"transition 11->12 R: 00-+ -> 0--0".postln;
	"vertex 12: 0--0 RB".postln;
	"transition 12->13 R: 0--0 -> --00".postln;
	"vertex 13: --00 RG".postln;
	"transition 13->14 G: --00 -> -0-0".postln;
	"vertex 14: -0-0 GB".postln;
	"transition 14->15 B: -0-0 -> -00-".postln;
	"vertex 15: -00- RB".postln;
	"transition 15->16 B: -00- -> 0-0-".postln;
	"vertex 16: 0-0- GB".postln;
	"transition 16->17 G: 0-0- -> 00--".postln;
	"vertex 17: 00-- RG".postln;
	"transition 17->18 G: 00-- -> +0-0".postln;
	"vertex 18: +0-0 GB".postln;
	"transition 18->19 G: +0-0 -> +-00".postln;
	"vertex 19: +-00 RG".postln;
	"transition 19->20 R: +-00 -> 0-+0".postln;
	"vertex 20: 0-+0 RB".postln;
	"transition 20->21 R: 0-+0 -> 00+-".postln;
	"vertex 21: 00+- RG".postln;
	"transition 21->22 R: 00+- -> +00-".postln;
	"vertex 22: +00- RB".postln;
	"transition 22->23 B: +00- -> 0+0-".postln;
	"vertex 23: 0+0- GB".postln;
	"transition 23->24 B: 0+0- -> 0+-0".postln;
	"vertex 24: 0+-0 RB".postln;
	"transition 24->1 R: 0+-0 -> ++00".postln;
	"vertex  1: ++00 RG".postln;
)




