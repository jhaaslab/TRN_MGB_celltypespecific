% Connecting parallel pool 
c = parcluster; 
parpool(c, 14); 

if not(isfolder('init_data'))
%
% Create a unique RNG stream if using poissonP or constructConnections/GJ
sc = parallel.pool.Constant(RandStream('Threefry','seed','shuffle'));
seed = sc.Value.Seed;
%}
%Sim variables
var_rep = 1:150;
var_recip_prob = 0:0.2:1;
var_div_prob = 0:0.2:1;
var_cell_inh = 0:2;

all_vars    = { var_rep,        'replication';
                var_recip_prob, 'recip_prob';
                var_div_prob,   'div_prob';
                var_cell_inh,   'cell_inh'};
            
var_vectors = all_vars(:, 1)';
var_names   = all_vars(:, 2)';
var_combos  = all_combos(var_vectors{:});

mkdir init_data 
save([pwd '/init_data/var_vectors.mat'], 'var_vectors');
save([pwd '/init_data/var_combos.mat'], 'var_combos', 'var_names');
save([pwd '/init_data/RNG_seed.mat'], 'seed');
mkdir result

else 
load([pwd '/init_data/var_vectors.mat']);
load([pwd '/init_data/var_combos.mat']);
load([pwd '/init_data/RNG_seed.mat']);    
sc = parallel.pool.Constant(RandStream('Threefry','seed',seed));
end

%Simulation//Run variables
namesOfNeurons = {'TRN_PV','TRN_SOM',...
                  'TC_MGB','TC_HO'};
load('s_init.mat','s_init')
s0 = s_init;
per_neuron = 20;

startTime  = 0;
endTime    = 1000;
tspan = [startTime endTime];
tmax = abs(endTime - startTime);
options=odeset('InitialStep',10^(-3),'MaxStep',10^(-2));
skip_time = 1/10; % ms

nameOfSavedVar     = 'Sim_results'; 
maxNumIter         = 1000; 
[lpp, ~]           = size(var_combos); 
maxNumBlocks       = ceil(lpp/maxNumIter);
allblocks = vec2mat(1 : lpp, maxNumIter);

finalblock = allblocks(maxNumBlocks, :);
finalblock = finalblock(finalblock ~= 0);

% Start running
for TMPBLOCK = 1:maxNumBlocks
    
    if TMPBLOCK == maxNumBlocks
        block2run = finalblock;
    else
        block2run = allblocks(TMPBLOCK, :);
    end
    
var_combos_2run = var_combos(block2run, :);    
sim_result = struct('file', [], 'vars', [], 'data', [], 'analysis', []);

tic
parfor i = 1:numel(block2run)
    %
    stream = sc.Value;        % Extract the stream from the Constant
    stream.Substream = block2run(i);
    RandStream.setGlobalStream(stream);
    %}
    tmpStruct = struct('file', block2run(i));
    selected = num2cell(var_combos_2run(i,:),1);
    
    % Get out the 'location' of which values to pick from 'selected'
    [rep,recip_prob,div_prob,cell_inh] = selected{:};
    
    sim = simParams(namesOfNeurons,per_neuron,s0); % initialize simParams object
    % change simParams vars to selected vars
    % Synapses
    sim.A_TC_MGB = 1;
    sim.A_TC_HO = 1;
    sim.gj(1,2) = 0.03;
    sim.gj(2,1) = 0.03;

    if rand<recip_prob
    sim.AI_TRN_PV = 3;
    end
    if rand<recip_prob
    sim.AI_TRN_SOM = 3;
    end
    if rand<div_prob
    sim.AI_TRNx_PV = 3;
    end
    if rand<div_prob
    sim.AI_TRNx_SOM = 3;
    end

    % Inputs
    for ii=1:sim.n
        %bias current
        sim.bias(ii)=0.3;
        %noise
        sim.A(ii) = 0.2;
        sim.tA{ii} = poissonP(80,endTime/1000);
        sim.AI(ii) = 0.2;
        sim.tAI{ii} = poissonP(20,endTime/1000);
    end
    
    %tone -> TCs
    sim.iDC(3) = 2.7;
    sim.istart{3}= 500;
    sim.iDC(4) = 2.7;
    sim.istart{4}= 500;

    %silencing -| TRNs
    switch cell_inh
        case 0 %no silencing
        case 1
        sim.GtACR_on{1} = 500;
        sim.GtACR_off{1} = 600;
        case 2 
        sim.GtACR_on{2} = 500;
        sim.GtACR_off{2} = 600; 
    end

    varCellTmpStruct = cell(1, 2*length(var_names));
    varCellTmpStruct(1 : 2 : end-1) = var_names;
    varCellTmpStruct(2 : 2 : end)   = num2cell(selected, 1);
    tmpStruct.vars = struct(varCellTmpStruct{:});
    
    % Start stimualtion
    [t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options);
    
    % Saving Vm data (sampled)
    tot_skip_points = ceil( skip_time * length(t) / tmax );
    kept_idx = 1 : tot_skip_points : length(t);
    
    tmpS_struct = struct('time', t(kept_idx)); 
    idx = 1;
    for ii = 1 : sim.n
       tmpS_struct.(sim.names{ii}) = s(kept_idx, idx);
       idx = idx+sim.per_neuron;
    end
    % Saving network parameters
    %tmpS_struct.A_TC = sim.A_TC;
    %tmpS_struct.AI_TRN = sim.AI_TRN;
    %tmpS_struct.Gc = sim.gj;
    %tmpS_struct.cc = sim.cc;
    tmpStruct.data = tmpS_struct;
    
    % Analysis       
    % General analysis : NumSpk, SpkTime
    tmpAnly_struct = struct('numspk', [], 'spktime', [], 'lat', []);
    tmpNSpk_struct = struct();
    tmpSpkT_struct = struct(); 
    tmpLat_struct  = struct(); 
    for ii = 1 : sim.n
        [~, loc] = findpeaks(s(:, (ii-1) * sim.per_neuron + 1), t, 'MinPeakProminence', 50);
        % number of spikes 
        tmpNSpk_struct.(sim.names{ii}) = length(loc);
        % latency of spikinh, NaN if none 
        latency = NaN; 
        if ~isempty(loc) 
            latency = loc(1);
        end
        tmpLat_struct.(sim.names{ii}) = latency;
        % spike timings 
        tmpSpkT_struct.(sim.names{ii}) = loc;        
    end
    tmpAnly_struct.numspk   = tmpNSpk_struct; 
    tmpAnly_struct.lat      = tmpLat_struct; 
    tmpAnly_struct.spktime  = tmpSpkT_struct;
    
    
    tmpStruct.analysis = tmpAnly_struct;
    
    sim_result(i) = tmpStruct;
    tmpStruct = [];
end
eval([nameOfSavedVar ' = sim_result;']);
toc

save([pwd '/result/' nameOfSavedVar num2str(TMPBLOCK) '.mat'], nameOfSavedVar);
end

delete(gcp('nocreate')) %shutdown parallel pool