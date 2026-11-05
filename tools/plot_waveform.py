"""Plot the first transmitted frame from the actual Icarus VCD; no synthetic trace."""
from pathlib import Path
import json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
root=Path(__file__).resolve().parents[1]
text=(root/'results/uart-cpb32.vcd').read_text().splitlines()
codes={}; scope=[]; changes={}; timestamp=0; definitions=True
for line in text:
    fields=line.split()
    if not fields: continue
    if definitions:
        if fields[0]=='$scope': scope.append(fields[2])
        elif fields[0]=='$upscope': scope.pop()
        elif fields[0]=='$var' and scope==['tb_uart']:
            codes[fields[4]]=fields[3];changes[fields[3]]=[]
        elif fields[0]=='$enddefinitions': definitions=False
    elif line.startswith('#'): timestamp=int(line[1:])
    elif line[0] in '01xz' and line[1:] in changes:
        changes[line[1:]].append((timestamp,line[0]))
trace=changes[codes['serial_tx']]
start=next(t for t,v in trace if t>0 and v=='0')
bit_ps=32*10000
fig,ax=plt.subplots(figsize=(12,3.6),layout='constrained')
xs=[];ys=[]
for t,v in trace:
    if t>start+11*bit_ps: break
    if v in '01':xs.append((t-start)/bit_ps);ys.append(int(v))
ax.step(xs,ys,where='post',color='#175cd3',linewidth=2.5)
labels=['START','D0 = 1','D1 = 0','D2 = 1','D3 = 0','D4 = 0','D5 = 1','D6 = 0','D7 = 1','STOP']
for i,label in enumerate(labels):
    ax.axvspan(i,i+1,color=('#e6f0ff' if i%2==0 else '#f5f7fa'),zorder=-1)
    ax.text(i+.5,1.2,label,ha='center',fontsize=9)
ax.set(xlim=(-.5,10.5),ylim=(-.2,1.45),yticks=[0,1],xlabel='Bit periods after first falling edge (320 ns / bit)',ylabel='serial_tx',title='UARTLab · Actual RTL simulation · 0xA5, 8N1, least significant bit first')
fig.savefig(root/'results/tx-waveform.png',dpi=170)
(root/'results/waveform-metadata.json').write_text(json.dumps({'source':'uart-cpb32.vcd','timescale':'1ps','first_start_ps':start,'clock_period_ps':10000,'clocks_per_bit':32,'byte':'0xA5','frame':'start, 1,0,1,0,0,1,0,1, stop'},indent=2)+'\n')
print('Saved results/tx-waveform.png from real VCD')
