pragma circom 2.1.0;

include "../node_modules/circomlib/circuits/bitify.circom";

function getNBits(a) {
    var b = 0;
    while(a) {
        a = a >> 1;
        b++;
    }
    return b;
}

template RandomPermutate(n) {
    signal input hash;
    signal input in[n];
    signal output out[n];

    assert(n<=50);  // 50! < 2^215  << 2^250

    signal selectors[(1+n)*n/2];
    signal vals[(1+n)*n/2];
    signal valns[(1+n)*n/2];
    signal randStep[n];

    component n2b = Num2Bits_strict();
    n2b.in <== hash;
    component b2n = Bits2Num(250);
    for (var i=0; i<250; i++) {
        b2n.in[i] <== n2b.out[i];
    }

    signal r <== b2n.out;

    var rr = r;
    var radix = 1;
    var o = 0;
    var accRndStep = 0;
    for (var i=n; i>0; i--) {
        var a = rr % i;
        var selsSum = 0;
        for (var j=0; j<i; j++) {
            selectors[o+j] <-- a == j;
            selectors[o+j]*(selectors[o+j] - 1) === 0;
            selsSum += selectors[o+j];
            accRndStep += radix*j*selectors[o+j];
        }
        selsSum === 1;
        radix = radix*i;
        rr = rr \ i;
        o = o + i;
    }

    var bitsRadix = getNBits(radix);

    signal rem <-- rr;
    component n2bR = Num2Bits(250-bitsRadix +1);
    n2bR.in <== rem;

    rem*radix + accRndStep === b2n.out;

    for (var i=0; i<n; i++) {
        vals[i] <== in[i];
    }

    o=0;
    for (var i=n; i>0; i--) {
        var accOut = 0;
        for (var j=0; j<i; j++) {
            if (j<i-1) {
                vals[o+i+j] <== selectors[o+j] * ( vals[o+i-1] - vals[o+j] )    + vals[o+j];
            }
            valns[o+j] <== vals[o+j] * selectors[o+j];
            accOut += valns[o+j];
        }
        out[i-1] <== accOut;
        o = o + i;
    }
}