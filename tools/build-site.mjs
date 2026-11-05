import {mkdir,copyFile,readFile,writeFile} from 'node:fs/promises';
import {gunzipSync} from 'node:zlib';
await mkdir('public/downloads',{recursive:true});
for(const file of ['uart-cpb32','uart-cpb8'])await writeFile(`public/downloads/${file}.vcd`,gunzipSync(await readFile(`results/${file}.vcd.gz`)));
await copyFile('results/test-log.txt','public/downloads/test-log.txt');
console.log('Prepared public simulation evidence downloads.');
