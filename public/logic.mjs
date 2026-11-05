export function frameBits(byte){
 if(!Number.isInteger(byte)||byte<0||byte>255)throw new RangeError('Enter a byte from 0 to 255.');
 return [0,...Array.from({length:8},(_,i)=>(byte>>i)&1),1];
}
export function baudInfo(clock,baud){
 if(!Number.isFinite(clock)||!Number.isFinite(baud)||clock<=0||baud<=0)throw new RangeError('Clock and baud must be positive.');
 const divider=Math.round(clock/baud);
 if(divider<8)throw new RangeError('This RTL requires at least 8 clocks per bit.');
 const actual=clock/divider;
 return {divider,actual,error:100*(actual-baud)/baud,bitUs:1e6/actual,payload:clock/(divider*10+1)};
}
export function fifoStep(queue,depth,push,pop,byte){
 if(queue.length>depth||depth<2)throw new RangeError('Invalid FIFO configuration.');
 const next=[...queue],take=pop&&next.length>0;
 const value=take?next.shift():null;
 const put=push&&next.length<depth;
 if(put)next.push(byte);
 return {queue:next,take,put,value,dropped:push&&!put};
}
