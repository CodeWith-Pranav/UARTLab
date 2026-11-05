import assert from 'node:assert/strict';
import {frameBits,baudInfo,fifoStep} from '../public/logic.mjs';
for(let b=0;b<256;b++){const f=frameBits(b);assert.equal(f.length,10);assert.equal(f[0],0);assert.equal(f[9],1);assert.equal(f.slice(1,9).reduce((s,v,i)=>s+(v<<i),0),b);}
assert.throws(()=>frameBits(256));assert.throws(()=>frameBits(-1));assert.throws(()=>baudInfo(1,115200));
assert.equal(baudInfo(50e6,115200).divider,434);
assert.deepEqual(fifoStep([1,2,3,4],4,true,true,5),{queue:[2,3,4,5],take:true,put:true,value:1,dropped:false});
assert.deepEqual(fifoStep([],4,true,true,5).queue,[5]);assert.equal(fifoStep([1,2,3,4],4,true,false,5).dropped,true);
console.log('PASS browser model: 256 frame round-trips, invalid inputs, baud divisor, full and empty FIFO boundaries');
