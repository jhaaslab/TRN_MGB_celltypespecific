Template: [Run_dsim.m](../src/Run_dsim.m)

This is the main script controlling execution of the model, most of the work will be done within this script. Here I will show how to build this file for a simulation run.


>[!info]
>Variables that will depend on your sim will be indicated by `<*VAR*>`, this is a placeholder and will need to be replaced

# Sim run setup

Use `parpool('Processes')` or `parpool('Threads')` to set your desired pool type with default number of workers//threads, or designate those for your cluster environment.
```matlab
% Connecting parallel pool
c = parcluster;
parpool(c, 14);
```


We also need to initialize some general run variables, most important here is to specify the length of the sim runs with 'startTime' and 'endTime', and specify cells that will be simulated. neuron naming should start with the cell type TRN or TC, a pair number, followed by an optional subtype identifier if used (ie. TRN1_PV, TRN2_SOM, TC1_MGB, TC2_HO ).

- var_vectors: the lists of separated variable values defined for the runs
- var_names: list of string vectors for names of variables
- var_combos: all combinations of all variable values listed down the matrix rows, with each variable defined in 'var_names' listed across the columns 

ode solver options here control just control step size, ensuring a minimum resolution of 0.1 ms
skip time determines how much the raw data is subsampled to save space storing results.

We break the simulation runs into block of size 'maxNumIter' to protect from crashes as only the currently running block would be lost.

```matlab
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
options=odeset('InitialStep',10^(-2),'MaxStep',10^(-1));
skip_time = 1/10; % ms

% parameters
var_rep = 1:150;
var_<*VAR*>

var_vectors = {var_rep, var_<*VAR*>};
var_names   = {'rep', '<*VAR*>'};
var_combos  = all_combos(var_vectors{:});

% Run//save vars
nameOfSavedVar     = 'Sim_results'; 
maxNumIter         = 1000; 
[lpp, ~]           = size(var_combos); 
maxNumBlocks       = ceil(lpp/maxNumIter);
allblocks = vec2mat(1 : lpp, maxNumIter);

finalblock = allblocks(maxNumBlocks, :);
finalblock = finalblock(finalblock ~= 0);
```

Next, we will check if the sim had started previously (useful for resuming after a crash or splitting a sim run)
We will also set run specific variables and save to 'init_data' directory:
- RNG stream with random 'shuffled' seed, is needed when calling rand(). Threefry algorithm used since it supports parallel processing and substreams.

>[!warning]
>matlab reverts to a default random stream at startup for more info on RNG in matlab refer to [documentation here](https://www.mathworks.com/help/matlab/math/creating-and-controlling-a-random-number-stream.html)

```matlab
if ~isfolder('init_data')
tmpBlock = 1;
% Create a unique RNG stream if using poissonP
sc = parallel.pool.Constant(RandStream('Threefry','seed','shuffle'));
seed = sc.Value.Seed;

mkdir init_data 
save([pwd '/init_data/sim_vars.mat'],  'namesOfNeurons', 'tspan');
save([pwd '/init_data/var_combos.mat'], 'var_combos','var_vectors','var_names','maxNumBlocks');
save([pwd '/init_data/tmpBlock.mat'],  'tmpBlock');
save([pwd '/init_data/RNG_seed.mat'],  'seed');
mkdir result

else 
load([pwd '/init_data/tmpBlock.mat']);
load([pwd '/init_data/RNG_seed.mat']);
sc = parallel.pool.Constant(RandStream('Threefry','seed',seed));
end
```

# Begin iterating sim blocks

Now we will start running the simulations in blocks:

```matlab
% Start running
while tmpBlock <= maxNumBlocks
block2run = allblocks(tmpBlock, :);

if tmpBlock == maxNumBlocks
    block2run = block2run(block2run ~= 0);
end

var_combos_2run = var_combos(block2run, :);  
```

# Begin individual sim runs in parallel

```matlab
Sim_results = struct('file', [], 'vars', [], 'data', [], 'analysis', []);

tic
parfor i = 1:numel(block2run)
    stream = sc.Value;        % Extract the stream from the Constant
    stream.Substream = block2run(i);
    RandStream.setGlobalStream(stream);
    
    tmpStruct = struct('file', block2run(i));
    selected = num2cell(var_combos_2run(i,:),1);
```

Here is where the specific sim run will start, list your variables in an array, in the same order they were added to 'all_vars'.

```matlab
    % Deconstruct vars from selected var_combos
    [rep, <*VAR*> ] = selected{:};
```

# setup parameters for individual sim

We initialize an 'empty' simParam structure

```matlab
	% initialize simParams object
    sim = simParams(namesOfNeurons,per_neuron,s0);
```

The following section will be the most varied.
All synapses, inputs, and changing any values of constants in [simParams](simParams.md) need to be set.

## Inputs

DC inputs defined here:
- bias current
- tone inputs to TCs 

```matlab
% Inputs
    for ii=1:sim.n
        %bias current
        sim.bias(ii)=0.3;

    end

    %tone -> TCs
    sim.iDC(3) = 2.7;
    sim.istart{3}= 500;
    sim.iDC(4) = 2.7;
    sim.istart{4}= 500;

```

To add noise for spontaneous activity give external spike times from poisson process function.

```matlab
    for ii=1:sim.n
    %noise
    sim.A(ii) = 0.2;
    sim.tA{ii} = poissonP(80,endTime/1000);
    sim.AI(ii) = 0.2;
    sim.tAI{ii} = poissonP(20,endTime/1000);
    end

```

Opto silencing can be simulated with the "GtACR" channel activated by on and off times.

```matlab
%silencing -| TRN1_PV

    sim.GtACR_on{1}  = 500;
    sim.GtACR_off{1} = 600;
```

>[!tip]
>when changing properties of specific cell type you can do this within the for loop such as 
>```matlab 
>for ii=1:sim.n 
>	if startsWith(sim.names{ii},'TRN') 
>		sim.<*PROPERTY*> = <*VAR*>
>	else %TC
>	end
>end
>```

## Synapses

Synapses can directly be changed or used with a switch if testing multiple different configurations of connectivity:

```matlab
sim.<*SYNAPSE*> = <*AMPLITUDE*>;

switch
    case 1 
    sim.<*SYN1*> = <*SYN1AMP*>;

    case 2
    sim.<*SYN2*> = <*SYN2AMP*>;
end
```

# Solve ODEs

We call our ode solver with an '@' function handle broadcast over variables (t,s) passed to our [dsim](dsim.md) function, dsim also takes [simParams](simParams.md) input to extract all parameters for the run. t =timepoints of the solution, s = solutions to all differential equations at each value of t

ode function also needs:
- timespan 
- initial conditions, we stored these in sim.s0
- and any optional solver variables, here we changed the max and intial timesteps the solver will take

```matlab
    % Start stimualtion
    [t,s] = ode23(@(t,s) dsim(t,s,sim),tspan,sim.s0,options);
```

# Saving sim results

In most cases we only save voltage data, we will also skip some data points to save space, but not too many as to lose the structure of the data. Sampling ~0.1 ms is ideal but the ode solver steps are adaptive to get optimal solutions. This results in slight clipping of spikes as these are fast events, this will not affect spike detecting as they are still highly prominent in the traces. 

```matlab
    % Saving Vm data (sampled)
    tot_skip_points = ceil(skip_time * length(t) / endTime);
    kept_idx = 1 : tot_skip_points : length(t);
    
    tmpS_struct = struct('time', t(kept_idx)); 
    idx = 1;
    for ii = 1 : sim.n
       tmpS_struct.(sim.names{ii}) = s(kept_idx, idx);
       idx = idx+sim.per_neuron;
    end
    tmpStruct.data = tmpS_struct;
```

We will also extract spike times for later analysis using the [extractData.m](../src/extractData.m) file.

```matlab
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
```

Lastly, store the temp struct in Sim_results. After each block we measure performance, save the results and increment the running block. When all blocks finish we delete the parallel pool to free up system resources.

``` matlab
    sim_result(i) = tmpStruct;
    tmpStruct = [];
end
eval([nameOfSavedVar ' = sim_result;']);
toc

save([pwd '/result/' nameOfSavedVar num2str(tmpBlock) '.mat'], nameOfSavedVar);
end

delete(gcp('nocreate')) %shutdown parallel pool```
