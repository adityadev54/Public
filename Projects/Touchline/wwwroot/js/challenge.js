import { setAction, setIconAction } from './icons.js?v=toolbar-1';
import { readFrame } from './api.js';
import { jerseyReading, matchingPlayer } from './challenge-rules.js';
const el = id => document.getElementById('challenge' + id);
export class ChallengeWorkspace {
    constructor(getExperiment) {
        this.getExperiment = getExperiment;
        this.canvas = el('Canvas'); this.context = this.canvas.getContext('2d');
        for (const [id,icon,label] of [['Zoom','magnifying-glass-plus','Zoom to jersey'],['Next','arrow-right','Next player'],['Original','eye','Hold to see original'],['Reset','arrow-path','Reset patch'],['Review','clipboard-document-list','Verify in frame review'],['Analyze','video-camera','Open video analysis']]) setIconAction(el(id),icon,label);
        setAction(el('Run'),'play','Challenge Touchline');
        this.wins = 0; this.attempts = 0; this.best = null; this.zoom = false; this.image = null; this.version = 0; this.patch = {x:0,y:0};
        el('Zoom').addEventListener('click',()=>{this.zoom=!this.zoom;el('Zoom').setAttribute('aria-pressed',String(this.zoom));setIconAction(el('Zoom'),this.zoom?'photo':'magnifying-glass-plus',this.zoom?'See full frame':'Zoom to jersey');this.draw();});
        el('Next').addEventListener('click',()=>{if(!this.frame?.people.length)return;el('Person').value=String((Number(el('Person').value)+1)%this.frame.people.length);this.resetPatch();});
        el('Frame').addEventListener('change', () => this.loadFrame());
        el('Person').addEventListener('change', () => this.resetPatch());
        for (const id of ['Mode','Size','Decoy']) el(id).addEventListener('input', () => {
            el('DecoyGroup').hidden = el('Mode').value !== 'decoy'; this.draw(); this.clearResult();
        });
        el('Truth').addEventListener('input',()=>this.clearResult());
        el('Reset').addEventListener('click',()=>this.resetPatch());
        el('Run').addEventListener('click',()=>this.run());
        // Visitor reactions describe the experience, not recognition accuracy.
        this.feedback = [];
        el('Feedback').addEventListener('click',event=>{
            const button=event.target.closest('[data-feedback]');
            if(!button||this.feedbackIndex===undefined)return;
            this.feedback[this.feedbackIndex].reaction=button.dataset.feedback;
            el('Feedback').querySelectorAll('[data-feedback]').forEach(choice=>choice.setAttribute('aria-pressed',String(choice===button)));
            el('FeedbackStatus').textContent=button.dataset.feedback==='skip'?'No answer selected.':'Thanks! Feedback kept for this session.';
        });
        el('Review').addEventListener('click',()=> {
            if (this.frame) document.dispatchEvent(new CustomEvent('research-frame',{detail:Number(el('Frame').value)}));
        });
        el('Original').addEventListener('pointerdown',event=>{
            el('Original').setPointerCapture(event.pointerId); this.draw(true);
        });
        for(const name of ['pointerup','pointercancel','lostpointercapture']) el('Original').addEventListener(name,()=>this.draw());
        el('Original').addEventListener('keydown',event=>{if(event.key===' '||event.key==='Enter'){event.preventDefault();this.draw(true);}});
        el('Original').addEventListener('keyup',()=>this.draw());
        el('Original').addEventListener('blur',()=>this.draw());
        // Both views edit the same full-resolution frame; zoom is only a display aid.
        for(const canvas of [this.canvas,el('Focus')]) {
            canvas.addEventListener('pointerdown',event=> {
                if (!this.target || this.busy) return;
                this.dragging=true;canvas.setPointerCapture(event.pointerId);this.move(event);
            });
            canvas.addEventListener('pointermove',event=>{if(this.dragging)this.move(event);});
            for(const name of ['pointerup','pointercancel'])canvas.addEventListener(name,()=>this.dragging=false);
            canvas.addEventListener('keydown',event=>{
                if(this.busy||!this.target)return;
                const moves={ArrowLeft:[-1,0],ArrowRight:[1,0],ArrowUp:[0,-1],ArrowDown:[0,1]};
                if(!moves[event.key])return;event.preventDefault();const [x,y]=moves[event.key];
                this.patch.x=Math.max(0,Math.min(1,this.patch.x+x*this.target.width*.05));
                this.patch.y=Math.max(0,Math.min(1,this.patch.y+y*this.target.height*.05));
                this.draw();this.clearResult();
            });
        }
    }
    render() {
        const run = this.getExperiment(); const previous = el('Frame').value;
        el('Frame').replaceChildren();
        (run?.frames || []).forEach((frame,index)=>el('Frame').add(new Option(`Frame ${index+1} · ${frame.timestamp.toFixed(2)}s`,String(index))));
        if([...el('Frame').options].some(option=>option.value===previous))el('Frame').value=previous;
        el('Status').textContent=run?.frames.length ? `${run.fileName} · Changes stay in this challenge; your analysis is preserved.` : 'Analyze a video first, then return here to challenge its jersey reading.';
        this.loadFrame();
    }
    async loadFrame() {
        const version=++this.version;
        this.frame=this.getExperiment()?.frames[Number(el('Frame').value)];
        this.image=null; this.target=null; el('Person').replaceChildren(); this.draw(); this.lock();
        if(!this.frame)return;
        this.frame.people.forEach((person,index)=>el('Person').add(new Option(`Player ${person.id}`,String(index))));
        const image=new Image();image.src=this.frame.image;
        try { await image.decode(); if(version!==this.version)return;
            this.image=image; this.canvas.width=image.naturalWidth;this.canvas.height=image.naturalHeight;this.resetPatch();
        } catch {el('Evidence').textContent='Could not load frame. Choose another moment.';}
    }
    resetPatch() {
        this.target=this.frame?.people[Number(el('Person').value)];
        if(this.target){this.patch={x:this.target.x+this.target.width/2,y:this.target.y+this.target.height*.3};el('Truth').value=this.target.annotation||'';}
        else el('Truth').value='';
        this.lock();this.draw();this.clearResult();
    }
    lock() {
        for(const id of ['Frame','Person','Truth','Mode','Size','Decoy','Run','Reset','Review','Zoom','Next','Original'])el(id).disabled=Boolean(this.busy)||!this.image||!this.target;
    }
    clearResult() { el('Feedback').hidden=true; this.feedbackIndex=undefined; this.scored=false; el('Evidence').dataset.outcome=''; el('Evidence').textContent=this.target?'Make your edit, then run the real detector and OCR.':'No player detected in this frame. Choose another frame.'; }
    move(event) {
        let bounds=event.currentTarget.getBoundingClientRect();
        if(this.zoom){
            // Account for letterboxing when the close-up is constrained by card height.
            const view=event.currentTarget,scale=Math.min(bounds.width/view.width,bounds.height/view.height);
            const width=view.width*scale,height=view.height*scale;
            bounds={left:bounds.left+(bounds.width-width)/2,top:bounds.top+(bounds.height-height)/2,width,height};
        }
        const area=this.zoom?this.focusArea():{x:0,y:0,width:1,height:1};
        this.patch={x:Math.max(0,Math.min(1,area.x+(event.clientX-bounds.left)/bounds.width*area.width)),y:Math.max(0,Math.min(1,area.y+(event.clientY-bounds.top)/bounds.height*area.height))};
        this.draw();this.clearResult();
    }
    focusArea() {
        const width=Math.min(1,this.target.width*3),height=Math.min(1,this.target.height*1.4);
        return {x:Math.max(0,Math.min(1-width,this.target.x+this.target.width/2-width/2)),y:Math.max(0,Math.min(1-height,this.target.y+this.target.height/2-height/2)),width,height};
    }
    drawFocus() {
        this.canvas.hidden=this.zoom&&Boolean(this.target);
        const focus=el('Focus');focus.hidden=!this.zoom||!this.target;
        if(focus.hidden)return;
        const area=this.focusArea();focus.width=600;focus.height=Math.round(600*area.height*this.canvas.height/(area.width*this.canvas.width));
        focus.getContext('2d').drawImage(this.canvas,area.x*this.canvas.width,area.y*this.canvas.height,area.width*this.canvas.width,area.height*this.canvas.height,0,0,focus.width,focus.height);
    }
    draw(original=false) {
        const ctx=this.context;ctx.clearRect(0,0,this.canvas.width,this.canvas.height);
        if(!this.image){el('Focus').hidden=true;this.canvas.hidden=false;return;}
        ctx.drawImage(this.image,0,0);
        if(original||!this.target){this.drawFocus();return;}
        const size=Number(el('Size').value)/100;
        const width=this.target.width*this.canvas.width*size;
        const height=this.target.height*this.canvas.height*size*.45;
        const x=this.patch.x*this.canvas.width,y=this.patch.y*this.canvas.height;
        ctx.fillStyle='#eeeeea';ctx.fillRect(x-width/2,y-height/2,width,height);
        if(el('Mode').value==='decoy'){
            ctx.fillStyle='#141414';ctx.font=`bold ${height*.85}px Arial`;ctx.textAlign='center';ctx.textBaseline='middle';ctx.fillText(el('Decoy').value,x,y,width*.9);
        }
        this.drawFocus();
    }
    async run() {
        if(this.busy||!this.target)return;
        if(!/^\d{1,2}$/.test(el('Truth').value.trim())){el('Evidence').textContent='Enter the independently verified jersey number first.';return;}
        if(el('Mode').value==='decoy'&&!/^\d{1,2}$/.test(el('Decoy').value.trim())){el('Evidence').textContent='Use a one- or two-digit decoy.';return;}
        const truth=Number(el('Truth').value);const version=this.version;
        el('Feedback').hidden=true; this.feedbackIndex=undefined;
        this.busy=true;this.lock();setAction(el('Run'),'eye','Inspecting edit…');el('Evidence').textContent='Running person detection and OCR on the edited video frame.';
        try {
            this.draw();
            // Submit the complete edited video frame. The truth never goes to the server.
            const result=await readFrame(this.canvas.toDataURL('image/jpeg',.92),new AbortController().signal);
            if(version!==this.version)return;
            const person=matchingPlayer(this.target,result.people||[]);
            const before=jerseyReading(this.target),after=jerseyReading(person);
            this.attempts++;el('Attempts').textContent=`${this.attempts} completed attempts`;
            let verdict=!person?'Target could not be matched reliably. No score.':after===null?'Touchline abstained. No successful trick.':after===truth?'Touchline held on. Try a smaller, sneakier change.':before!==truth?'Original OCR was already wrong or unreadable. No edit-induced trick established.':'You changed a correct reading into a wrong one!';
            if(person&&after!==null&&after!==truth&&before===truth&&!this.scored){this.wins++;this.scored=true;this.best=Math.min(this.best??100,Number(el('Size').value));}
            el('Best').textContent=`Smallest winning patch: ${this.best===null?'—':this.best+'% of player width'}`;
            el('Evidence').dataset.outcome=person&&after!==null&&after!==truth&&before===truth?'win':after===truth?'held':'neutral';
            el('Round').textContent=`${this.wins} successful tricks`;
            el('Evidence').textContent=`${verdict} Original: ${before===null?'unreadable':'#'+before}. Edited: ${!person?'unmatched':after===null?'unreadable':'#'+after}. Verified: #${truth}.`;
            this.feedbackIndex=this.feedback.push({attempt:this.attempts,outcome:el('Evidence').dataset.outcome,reaction:null})-1;
            el('Feedback').querySelectorAll('[data-feedback]').forEach(choice=>choice.setAttribute('aria-pressed','false'));
            el('FeedbackStatus').textContent='Optional · stays in this session.';
            el('Feedback').hidden=false;
        } catch(error) {if(version===this.version)el('Evidence').textContent=`Processing failed; no score. ${error.message}`;}
        finally {this.busy=false;this.lock();setAction(el('Run'),'play','Challenge Touchline');}
    }
}
