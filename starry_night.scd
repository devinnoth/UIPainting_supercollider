s.makeWindow.boot;
/*
Devin Noth's final project

This final is an interactive art piece.
I designed different synths to act with Vincent Van Gogh's "Starry Night".

I decided to do this project based on wanting to work more with GUI's as they are something
I can use in other coding classes outside of this one. Being able to strengthen my knowledge while
testing myself on Supercollider was my intial goal.

Try to make your way through the painting and find out which objects are connected to synths by clicking around! I encourge you not to look at the code for the answers of where hidden buttons until you feel you've explored the project enough.

To run, follow instructions below.
*/

// First, run this to create all our synthesizers.
(
SynthDef( 'Town', {
	arg out = 0;
	var nse, env, kic;
	kic = tanh(
		Ringz.ar( LPF.ar( Trig.ar( Impulse.ar(2.0), SampleDur.ir ), 1000 ), 30, 0.25, 7
	).sin*2);
	env = Env.perc(0.05, 1, 1, -4);
	nse = BrownNoise.ar(2) + PinkNoise.ar(0.5)  * EnvGen.kr(env,Impulse.kr(1), doneAction: 2);

	nse = Mix.ar(BPF.ar(nse,[100,1200,80,40,20],0.5,[1,0.2,1,1,1]));
	Out.ar(out, LPF.ar(nse + kic, 100)! 2);
}).add;

SynthDef( 'Church', {
	arg out = 0;
	var bells = LPF.ar(
		DynKlank.ar(
			`[[900, 971, 1153, 1823, 1401], nil, [
				SinOsc.kr(0.2).range(0.1,1),
				SinOsc.kr(0.6).range(0.1,1),
				SinOsc.kr(0.8).range(0.1,1),
				SinOsc.kr(1.2).range(0.1,1),
				SinOsc.kr(2).range(0.1,1)]
			],
			Limiter.ar(Dust.ar(2, 0.65) + Impulse.ar(1,0,0.9))
		)
	)!2;
	Out.ar(out, FreeVerb.ar(bells, 0.8, 0.8));
}).add;

SynthDef( 'Clouds', {
	arg midinote = 60, gate = 1, amp = 0.25;
	var env = EnvGen.kr(Env.asr(0.1, 1, 0.1), gate, doneAction:2);
	var sig = VarSaw.ar(
		midinote.midicps,
		width:LFNoise2.kr(1).range(0.2, 0.8)*SinOsc.kr(5, Rand(0.0, 1.0)).range(0.7,0.8))*0.25;
	sig = sig * env * amp;
	Out.ar(0, sig!2);
}).add;

SynthDef( 'Trees', {
	arg freq = 50, frate = 0.5, mul = 0.3, out = 0;
	var sigA, sigB, sigC, sig, fmod;
	fmod = SinOsc.kr(frate, mul:0.5, add:0.5) * Line.kr(0, 1, 7);
	sigA = Pulse.ar(freq + fmod, LFNoise2.kr(1).range(0.2, 0.8) );
	sigB = VarSaw.ar(freq + fmod);
	sigC = WhiteNoise.ar() * 0.125;
	sig = SelectX.ar(LFNoise2.kr(2).range(0, 2), [sigA, sigB, sigC]);
	sig = LPF.ar(sig, freq*4 );
	sig = FreeVerb.ar((sig * 0.25).round(2**(-10)), 1, 0.8, 0.5, 4.0);
	Out.ar(out, Pan2.ar(sig, SinOsc.kr(frate, 0.0, mul)));
}).add;

// Star synth, each star passes in different args for variations
SynthDef( 'Stars', {
	arg speed = 5.0, trans = 1.0, pan = 0.0;
	var output, out = 0, pitchArray;
	pitchArray = [38, 40, 42, 43, 45, 47, 49, 50];
	// pitch shift based on input
	pitchArray = (pitchArray + (12 * trans).midicps);
	// For some reason errors when calling scramble alone, so wrapped in a choose
	pitchArray = [
		pitchArray.scramble.midicps
	].choose;
	output = FreeVerb.ar(SinOsc.ar(
		Select.kr(
			Stepper.kr(Impulse.kr(speed), pitchArray.size-1),
			pitchArray),
		mul: 0.5
	).round(2**(-7)), 0.7, 0.7, 0.7);
	Out.ar(out, Pan2.ar(output, pan));
}
).add;
)


// Next, run this to create our painting GUI

(
i = Image.new( thisProcess.nowExecutingPath.dirname +/+ "images/starry_night.jpg" );

    w = Window.new("Image", Rect(120, 400, i.width, i.height)).front;
    w.onClose_({ i.free }); // free the image when the window is closed
    w.drawFunc_({
        i.tileInRect(w.view.bounds, nil, 2, 1.0); // all image contents
    });
)

// Finally, run this to add all the hidden buttons. Go try it out!
(
var town, church, t1, t2, t3, c1, c2, s1, s2, s3, s4, s5, s6, s7;

town = Button(w, Rect(840, 670, 355, 112));
town.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
town.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Town", 9981, 0, 0);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9981);
		};
};

church = Button(w, Rect(660, 605, 40, 180));
church.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
church.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Church", 9982, 0, 0);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9982);
		};
};

t1 = Button(w, Rect(180, 370, 130, 410));
t1.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
t1.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Trees", 9983, 0, 0, "freq", 50, "frate", 0.25, "mul", 0.2);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9983);
		};
};

t2 = Button(w, Rect(205, 55, 53, 315));
t2.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
t2.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Trees", 9984, 0, 0, "freq", 300, "frate", 10, "mul", 0.5);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9984);
		};
};

t3 = Button(w, Rect(330, 577, 130, 203));
t3.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
t3.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Trees", 9985, 0, 0, "freq", 100, "frate", 5, "mul", 0.4);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9985);
		};
};

c1 = Button(w, Rect(760, 345, 150, 170));
c1.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
c1.action = {|view|
	if (view.value == 1) {
		s.sendMsg("/s_new", "Clouds", 9986, 0, 0, "midinote", 67);
	};
	if (view.value == 0) {
		s.sendMsg("/n_free", 9986);
	}
};

c2 = Button(w, Rect(440, 150, 320, 310));
c2.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
c2.action = {|view|
	if (view.value == 1) {
		s.sendMsg("/s_new", "Clouds", 9987, 0, 0, "midinote", 62);
	};
	if (view.value == 0) {
		s.sendMsg("/n_free", 9987);
	}
};

s1 = Button(w, Rect(30, 405, 55, 55));
s1.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
s1.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Stars", 9988, 0, 0, "speed", 3.0, "trans", 0.0, "pan", -0.9);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9988);
		};
};

s2 = Button(w, Rect(342, 430, 158, 150));
s2.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
s2.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Stars", 9993, 0, 0, "speed", 1.0, "trans", 1.0, "pan", -0.2);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9993);
		};
};

s3 = Button(w, Rect(373, 5, 81, 73));
s3.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
s3.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Stars", 9995, 0, 0, "speed", 2.5, "trans", 1.5, "pan", -0.1);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9995);
		};
};

s4 = Button(w, Rect(465, 40, 60, 55));
s4.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
s4.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Stars", 9996, 0, 0, "speed", 7.0, "trans", 2.0, "pan", -0.1);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9996);
		};
};

s5 = Button(w, Rect(670, 35, 120, 110));
s5.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
s5.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Stars", 9997, 0, 0, "speed", 2.0, "trans", 0.0, "pan", 0.6);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9997);
		};
};

s6 = Button(w, Rect(795, 170, 105, 95));
s6.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
s6.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Stars", 9998, 0, 0, "speed", 4.0, "trans", 1.0, "pan", 0.7);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9998);
		};
};

s7 = Button(w, Rect(960, 50, 230, 230));
s7.states = [["", Color.clear, Color.clear],["", Color.clear, Color.clear]];
s7.action = {|view|
		if (view.value == 1) {
		s.sendMsg("/s_new", "Stars", 9999, 0, 0, "speed", 6.0, "trans", 0.5, "pan", 0.9);
		};
		if (view.value == 0) {
			s.sendMsg("/n_free", 9999);
		};
};
)
