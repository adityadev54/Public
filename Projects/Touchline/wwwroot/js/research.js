// Compare both pipelines on exactly the same human-labeled sightings.
export function evaluate(experiment) {
    const tracks = experiment?.tracking?.tracks || [];
    const stats = { labels: 0, local: { correct: 0, wrong: 0, abstained: 0 }, assisted: { correct: 0, wrong: 0, abstained: 0 }, switches: 0, transitions: 0 };
    const previous = new Map();
    for (const frame of (experiment?.frames || []).slice().sort((a,b)=>a.timestamp-b.timestamp)) {
        const identities = frame.people.map(person=>person.referenceId?.trim()).filter(Boolean);
        for (const person of frame.people) {
            const track = tracks.find(track=>track.observations.some(o=>o.timestamp===frame.timestamp && o.personId===person.id));
            if (!track) continue;
            if (/^\d{1,2}$/.test(person.annotation || '')) {
                stats.labels++;
                for (const [name, value] of [['local', track.number], ['assisted', track.number ?? (track.aiReview?.status==='reviewed' && track.aiReview.isPlayer===true ? track.aiReview.number : null)]]) {
                    if (value == null) stats[name].abstained++;
                    else if (value === Number(person.annotation)) stats[name].correct++;
                    else stats[name].wrong++;
                }
            }
            const identity = person.referenceId?.trim();
            // Duplicate reference IDs within one frame are invalid for identity evaluation.
            if (identity && identities.filter(id=>id===identity).length===1) {
                if (previous.has(identity)) { stats.transitions++; if (previous.get(identity)!==track.id) stats.switches++; }
                previous.set(identity, track.id);
            }
        }
    }
    return stats;
}

const ns = 'http://www.w3.org/2000/svg';
function element(tag, attrs = {}, text) {
    const node = document.createElementNS(ns, tag);
    for (const [key, value] of Object.entries(attrs)) node.setAttribute(key, value);
    if (text !== undefined) node.textContent = text;
    return node;
}
function plot(container, title) {
    container.replaceChildren();
    const svg = element('svg', { viewBox:'0 0 500 240', role:'group', 'aria-label':title, class:'data-chart' });
    const readout=document.createElement('div'); readout.className='chart-readout'; readout.setAttribute('aria-live','polite'); readout.textContent='Hover, tap, or focus a data mark for details.'; container.append(svg,readout); return svg;
}
// Shared pointer and keyboard interaction, with a persistent readable detail panel.
function interactive(node, svg, label, action) {
    node.setAttribute('tabindex','0'); node.setAttribute('role',action ? 'button' : 'img'); node.setAttribute('aria-label',label);
    node.classList.add('chart-mark');
    function reveal() {
        svg.querySelectorAll('.selected-mark').forEach(mark=>mark.classList.remove('selected-mark'));
        node.classList.add('selected-mark'); svg.parentElement.querySelector('.chart-readout').textContent=label;
    }
    node.addEventListener('pointerenter',reveal); node.addEventListener('focus',reveal);
    node.addEventListener('click',()=>{reveal(); action?.();});
    node.addEventListener('keydown',event=>{if(event.key==='Enter'||event.key===' '){event.preventDefault();reveal();action?.();}});
}
function empty(id, text) { const node=document.getElementById(id); node.replaceChildren(); node.textContent=text; }
function groupedChart(stats) {
    if (!stats.labels) { empty('researchChart','Verify numbers in Frame review to compare outcomes.'); return; }
    const svg=plot(document.getElementById('researchChart'),`Outcomes across ${stats.labels} labeled sightings`);
    const top=22, bottom=185, left=45, max=stats.labels;
    for (let i=0;i<=4;i++) {
        const y=bottom-(bottom-top)*i/4;
        svg.append(element('line',{x1:left,y1:y,x2:482,y2:y,stroke:'#333'}),element('text',{x:36,y:y+4,'text-anchor':'end'},Number((max*i/4).toFixed(2))));
    }
    ['correct','wrong','abstained'].forEach((key,i)=>{
        const x=85+i*142;
        for(const [method,offset,color] of [['local',0,'#aaa'],['assisted',40,'#bba6ee']]) {
            const value=stats[method][key],height=(bottom-top)*value/max;
            const bar=element('rect',{x:x+offset,y:bottom-height,width:30,height:Math.max(height,1),rx:3,fill:color});
            interactive(bar,svg,`${method==='local'?'Local OCR':'Local + AI'}: ${key}, ${value} of ${stats.labels} labeled sightings (${Math.round(value/stats.labels*100)}%).`);
            svg.append(bar,element('text',{x:x+offset+15,y:bottom-height-7,'text-anchor':'middle'},value));
        }
        svg.append(element('text',{x:x+35,y:209,'text-anchor':'middle'},key[0].toUpperCase()+key.slice(1)));
    });
}
function timeline(experiment) {
    const frames=experiment?.frames || [];
    if(!frames.length) { empty('researchTimeline','Analyze a video to plot detected sightings.'); return; }
    const svg=plot(document.getElementById('researchTimeline'),'Person sightings at each sampled timestamp');
    const max=Math.max(1,...frames.map(f=>f.people.length)),duration=Math.max(1,experiment.duration);
    for(let i=0;i<=4;i++) {
        const y=185-155*i/4;
        svg.append(element('line',{x1:45,y1:y,x2:480,y2:y,stroke:'#333'}),element('text',{x:36,y:y+4,'text-anchor':'end'},Number((max*i/4).toFixed(1))));
        svg.append(element('text',{x:45+435*i/4,y:212,'text-anchor':'middle'},`${(duration*i/4).toFixed(1)}s`));
    }
    const points=frames.map(f=>[45+435*f.timestamp/duration,185-155*f.people.length/max]);
    svg.append(element('polyline',{points:points.map(p=>p.join(',')).join(' '),fill:'none',stroke:'#8bc7b0','stroke-width':2}));
    points.forEach(([x,y],i)=>{
        const group=element('g');
        const dot=element('circle',{cx:x,cy:y,r:4,fill:'#8bc7b0'});
        const hit=element('circle',{cx:x,cy:y,r:14,fill:'transparent'});group.append(dot,hit);
        interactive(group,svg,`${frames[i].timestamp.toFixed(2)}s: ${frames[i].people.length} sightings. Activate to review this frame.`,()=>document.dispatchEvent(new CustomEvent('research-frame',{detail:i})));
        svg.append(group);
    });
}
function outcomes(experiment) {
    const answers=experiment?.ai?.answers || [];
    if(!answers.length) { empty('researchAiChart','No AI review outcomes in this run.'); return; }
    const values=[answers.filter(a=>a.status==='reviewed' && a.isPlayer===true && a.number!==null).length,answers.filter(a=>a.status==='reviewed' && (a.isPlayer!==true || a.number===null)).length,answers.filter(a=>a.status==='error').length];
    const svg=plot(document.getElementById('researchAiChart'),'AI review outcomes: suggestions, abstentions, failures');
    ['Suggestion','Abstained','Failed'].forEach((label,i)=>{
        const y=40+i*58,width=280*values[i]/answers.length;
        const group=element('g');
        group.append(element('text',{x:10,y:y+16},label),element('rect',{x:110,y,width:280,height:26,rx:4,fill:'#292929'}),element('rect',{x:110,y,width,height:26,rx:4,fill:['#bba6ee','#888','#d39292'][i]}),element('text',{x:408,y:y+18},values[i]));
        interactive(group,svg,`${label}: ${values[i]} of ${answers.length} reviewed tracks.`);svg.append(group);
    });
}
export function renderResearch(experiment) {
    const stats=evaluate(experiment);
    document.getElementById('researchRun').textContent=experiment ? `${experiment.fileName} · ${experiment.frames.length} sampled frames` : 'No experiment selected';
    document.getElementById('researchUsage').textContent=experiment?.ai?.calls!=null ? `${experiment.ai.calls} AI calls · ${experiment.ai.inputTokens+experiment.ai.outputTokens} tokens` : 'No AI usage recorded';
    document.getElementById('researchLabels').textContent=`${stats.labels} labeled sightings · ${stats.transitions} identity transitions · ${stats.switches} ID changes`;
    document.getElementById('sampleNote').textContent=stats.labels<20 ? `Small sample: ${stats.labels} labeled sightings. These counts do not establish general accuracy.` : 'Same labeled sightings for both methods; repeated sightings are correlated.';
    groupedChart(stats); timeline(experiment); outcomes(experiment);
}
