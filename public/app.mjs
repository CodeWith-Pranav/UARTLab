import {frameBits,baudInfo,fifoStep} from './logic.mjs';
const $=id=>document.getElementById(id);
let bits=frameBits(165),byte=165,position=-1,playing=null,queue=[];
const hex=n=>n.toString(16).toUpperCase().padStart(2,'0');
function parseByte(id){const value=$(id).value.trim();if(!/^[0-9a-fA-F]{1,2}$/.test(value))throw new Error('Enter one or two hex digits (00–FF).');return parseInt(value,16);}
function stop(){clearInterval(playing);playing=null;$('play').textContent='▶ Play';}
function draw(){
 $('trace').innerHTML=bits.map((b,i)=>`<div class="bit ${i===position?'active':''}"><span>${i===0?'START':i===9?'STOP':`DATA ${i-1}`}</span><strong>${b}</strong></div>`).join('');
 let d='M 0 55';bits.forEach((b,i)=>{const y=b?8:55;d+=` L ${i*100} ${y} L ${(i+1)*100} ${y}`;});
 $('trace').insertAdjacentHTML('beforeend',`<svg viewBox="0 0 1000 65" preserveAspectRatio="none" aria-hidden="true"><path d="${d}" stroke="#7bf0c7" fill="none" stroke-width="2.5" vector-effect="non-scaling-stroke"/></svg>`);
 $('bit-status').textContent=position<0?'Idle → ready':`Bit ${position+1} / 10 · line ${bits[position]}`;
 $('explain').textContent=position<0?`0x${hex(byte)} = ${byte} decimal. The frame sends one start bit, eight data bits, then one stop bit.`:position===0?'Start: the line goes low to announce a new frame.':position===9?'Stop: the line returns high. A low stop sample would reject this frame and set a framing error.':`Data bit ${position-1}: ${(byte>>(position-1))&1}. Bits travel least significant first.`;
}
function update(){try{const candidate=parseByte('byte'),info=baudInfo(Number($('clock').value)*1e6,Number($('baud').value));byte=candidate;bits=frameBits(byte);position=-1;stop();$('byte-error').textContent='';$('metrics').innerHTML=`<span>DIVIDER <strong>${info.divider}</strong></span><span>ACTUAL <strong>${info.actual.toFixed(2)} baud</strong></span><span>ERROR <strong>${info.error.toFixed(4)}%</strong></span><span>BIT TIME <strong>${info.bitUs.toFixed(3)} µs</strong></span>`;draw();}catch(e){$('byte-error').textContent=e.message;}}
function step(){position=(position+1)%10;draw();if(position===9)stop();}
$('apply').addEventListener('click',update);
for(const id of ['byte','clock','baud'])$(id).addEventListener('keydown',e=>{if(e.key==='Enter')update();});
$('play').addEventListener('click',()=>{if(playing)return stop();if(position===9)position=-1;step();if(position===9)return;playing=setInterval(step,650);$('play').textContent='Ⅱ Pause';});
$('step').addEventListener('click',()=>{stop();step();});$('reset').addEventListener('click',()=>{stop();position=-1;draw();});
function renderQueue(){ $('occupancy').textContent=`${queue.length} / 4${queue.length===4?' · FULL':queue.length===0?' · EMPTY':''}`;$('slots').innerHTML=Array.from({length:4},(_,i)=>`<div class="slot ${i<queue.length?'filled':''}"><strong>${i<queue.length?'0x'+hex(queue[i]):'—'}</strong><span>${i===0&&queue.length?'HEAD':`SLOT ${i}`}</span></div>`).join('');}
function tick(push,pop){try{const value=push?parseByte('fifo-byte'):0;const result=fifoStep(queue,4,push,pop,value);queue=result.queue;renderQueue();$('queue-status').textContent=[result.take?`Consumed 0x${hex(result.value)}.`:pop?'Empty: nothing to consume.':'',result.put?`Queued 0x${hex(value)}.`:'',result.dropped?'Full: new byte rejected.':''].filter(Boolean).join(' ');}catch(e){$('queue-status').textContent=e.message;}}
$('push').addEventListener('click',()=>tick(true,false));$('pop').addEventListener('click',()=>tick(false,true));$('both').addEventListener('click',()=>tick(true,true));$('clear-queue').addEventListener('click',()=>{queue=[];renderQueue();$('queue-status').textContent='Queue cleared.';});
update();renderQueue();
