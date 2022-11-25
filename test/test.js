const chai = require("chai");
const path = require("path");


const assert = chai.assert;

const wasm_tester = require("circom_tester").wasm;

function perm(h, a) {
    h = (h & (1n << 250n) -1n)
    for (let i = a.length; i>0; i--) {
        const r = h % BigInt(i);
        [a[ i-1 ], a[r] ] = [a[ r ], a[ i-1 ] ];
        h = (h -r) / BigInt(i);
    }
    return a;
}

describe("Random permutation check", function () {
    let circuit;

    this.timeout(100000);

    before( async() => {
        circuit = await wasm_tester(path.join(__dirname, "circuits", "main3.test.circom"), {verbose: true});
    });

    it("Should add point (0,1) and (0,1)", async () => {

        const N = 2;


        const input={
            hash: 21888242871839275222246405745257275088548364400416034343698204186575808495616n,
            in: []
        };

        for (let i=0; i<N; i++) input.in[i] = i;

        const w = await circuit.calculateWitness(input, true);

        await circuit.assertOut(w, {out: perm(input.hash, input.in)});
    });
});