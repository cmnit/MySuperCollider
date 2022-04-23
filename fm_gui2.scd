//
s = Server.local;
s.boot;
s.scope;
FreqScope.new;

m = ServerMeter.new(s, 4, 2);

//

(
SynthDef(\fm2, { arg
	freq=80.0, amp=1.0, mypan=0, freqcut = 5000.0,
	car0phase = 0.0, mod1phase0 = 0.0, mod2phase0 = 0.0,
	carRatio=1.0, mod1Ratio=1.0, mod2Ratio=2.0,
	idx1Mod=2.0, idx2Mod=2.0;

	var car, mod1, mod2;

	mod1 = SinOsc.ar(freq*mod1Ratio, phase:mod1phase0, mul:freq*mod1Ratio*idx1Mod);
	mod2 = SinOsc.ar(freq*mod2Ratio, phase:mod2phase0, mul:freq*mod2Ratio*idx2Mod);
	car  = LPF.ar(SinOsc.ar(freq*carRatio + mod1 + mod2, phase:car0phase, mul:amp), freqcut);

//	Out.ar([0,1], Pan2.ar(car, mypan));
	Out.ar(0, Pan2.ar(car, mypan));

}).add;
)

//

x = Synth.new(\fm2, [mod1phase0:2*pi*0]);
x.set(\freq, 50, \mod1phase0, 2*pi*0, \mod2phase0, 2*pi*0, \mod1Ratio, 2, \mod2Ratio, 3, \idx1Mod, 5, \idx2Mod, 9);
x.set(\mypan, 1);
x.scope;
x.free();

{ PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.scope;

{ LinPan2.ar(SinOsc.ar(440), Line.kr(1, -1, 10)) }.play
{ Pan2.ar(SinOsc.ar(440), Line.kr(1, -1, 10)) }.play
{ Pan2.ar(SinOsc.ar(440), Line.kr(-1, 1, 10)) }.play

//

(
var aSynth, window, knob1, knob1a, knob2, knob2a, knob3, knob4, slider1, slider2, button;
var text1s, text2s, v1s, v2s;
var txt1, txt2, txt3, v1, v2, v3;

aSynth = Synth.new(\fm2);

// GUI setup

window = Window.new("FM2 console", Rect(300,300,240,350));
window.front;

text1s = StaticText(window,Rect(22,10,40,10));
text1s.string_("idxm1");

slider1 = Slider.new(window, Rect(20,30,50,150));
slider1.valueAction_(0.0);

text2s = StaticText(window,Rect(82,10,40,10));
text2s.string_("idxm2");

slider2 = Slider.new(window, Rect(80,30,50,150));
slider2.valueAction_(0.0);

knob1 = Knob.new(window, Rect(20,190,50,50));
knob1.valueAction_(0.0);

txt1 = StaticText(window,Rect(22,250,40,10));
txt1.string_("m1r");

knob1a = Knob.new(window, Rect(20,270,50,50));
knob1a.valueAction_(0.0);

knob2 = Knob.new(window, Rect(80,190,50,50));
knob2.valueAction_(0.0);

txt2 = StaticText(window,Rect(82,250,40,10));
txt2.string_("m2r");

knob2a = Knob.new(window, Rect(80,270,50,50));
knob2a.valueAction_(0.0);

button = Button.new(window, Rect(160,20,50,50));
button.states = [ ["stop", Color.black], ["start", Color.red] ];

knob3 = Knob.new(window, Rect(160,80,50,50));
knob3.valueAction_(0.5);

txt3 = StaticText(window,Rect(162,140,40,10));
txt3.string_("freq");

knob4 = Knob.new(window, Rect(160,170,50,50));
knob4.valueAction_(0.5);

// StaticText(window,Rect(160,200,50,50)).string_("Test");

// GUI audio control

slider1.action_({arg me; var v1s; v1s = me.value.linlin(0,1,0,10); aSynth.set(\idx1Mod, v1s); text1s.string_(v1s); v1s.postln});
slider2.action_({arg me; var v2s; v2s = me.value.linlin(0,1,0,10); aSynth.set(\idx2Mod, v2s); text2s.string_(v2s); v2s.postln});

knob1.action_({arg me; var v1; v1 = me.value.linexp(0,1,0.2,3); aSynth.set(\mod1Ratio, v1); txt1.string_(v1); });
knob2.action_({arg me; var v2; v2 = me.value.linexp(0,1,0.2,3); aSynth.set(\mod2Ratio, v2); txt2.string_(v2); });

knob1a.action_({arg me; aSynth.set(\mod1phase0, me.value.linlin(0,1,0,2*pi)) });
knob2a.action_({arg me; aSynth.set(\mod2phase0, me.value.linlin(0,1,0,2*pi)) });

knob3.action_({arg me; var v3; v3 = me.value.linexp(0,1,20,500); aSynth.set(\freq, v3); txt3.string_(v3); });
knob4.action_({arg me; var pan; pan = me.value.linlin(0,1,-1,1); aSynth.set(\pan, pan); pan.postln });

button.action = ({ arg me;
		var val = me.value.postln;
		if (val == 1) { aSynth.run(false) } { aSynth.run }
	});

window.onClose_({aSynth.free});
)

//
pi;

window.free;