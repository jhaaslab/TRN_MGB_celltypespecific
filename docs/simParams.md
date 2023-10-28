[simParams.m](../src/simParams.m)

This class controls the variables that will be set for every simulation run.

The first block of values are channel conductance and reversal potentials, which were constant for all cells unless specified in the text.

```matlab
    % mS/cm^2
    g_caT   = 0.75;     %gca of .75 with leak of .1 is good;
    g_nat   = 60.5;
    g_kd    = 60;
    g_nap   = 0;
    g_kt    = 5;
    g_k2    = .5;
    g_ar    = 0.025;
    g_L     = 0.1;
    g_GtACR = 10; 

    % mV
    E_na    = 50;
    E_k     = -100;
    E_ca    = 125;
    E_ar    = -40;
    E_L     = -75;
    E_GtACR = -70;
    E_AMPA  = 0;
    E_GABA  = -100;

    C = 1;       % membrance capacitance  uF/cm^2
```

Next, we have cell labels, num cells, and num ODEs per cell (perNeuron), initial conditions (s0). We can store input resistance (Rin) and vm_rest for reference later, but these are not needed to be set for the model to run.

``` matlab
    names
    n
    per_neuron
    s0
    Rin
    vm_rest
```

# Inputs

DC pulse amplitude and start/end times or GtACR channel activation/inactivation times sepcified here:

```matlab
        % DC pulses, uA/cm2
        bias
        iDC          % DC  .25 is ~TR for burst
        istart = {};
        istop  = {};

        % Silencing 
        GtACR_on  = {};
        GtACR_off = {};

```

# Synapses

Amplitudes and arrival times for external synapses

All possible synapses within the network are also initialized, these amplitude values will be modified if testing that synapse. These do not have arrival times as they will be activated by the source cell.

```matlab
    %Alpha/Beta Synapses
    A            %amplitude of AMPAergic input to cell 1. (0.2)
    tA={};           %arrival time of AMPAergic input to cell 1.
    
    AI           %amplitude of GABAergic input to cell 1.
    tAI={};          %arrival time of GABAergic input to cell 1.

    A_TC_MGB   =0;     %amplitude of AMPAergic TC synapses
    A_TC_HO    =0;
    A_TCx_MGB  =0;     %TC cross-exc MGB->SOM
    A_TCx_HO   =0;     % HO->PV
    AI_TRN_PV  =0;     %amplitude of GABAergic TRN synapses
    AI_TRN_SOM =0;
    AI_TRNx_PV =0;     %TRN cross-inh PV-|HO
    AI_TRNx_SOM=0;     % SOM-|MGB
    AI_TRNi_PV =0;     %intra-TRN inh PV-|SOM
    AI_TRNi_SOM=0;     % SOM-|PV 
    
    %Electrical Synapses
    Gc_total
    gj
    cc
```

# Initialization

Calling the inner construction method will produce an 'empty' network with default cell parameters and inputs//synapses set to zero

```matlab
function sp = simParams(namesOfNeurons,per_neuron,s0)
    if nargin > 0
        sp.names = namesOfNeurons;
        sp.n = length(namesOfNeurons);
        sp.per_neuron = per_neuron;
        sp.s0 = s0;

        sp.g_L(1:sp.n) = 0.1;

        sp.bias(1:sp.n) = 0;

        sp.iDC(1:sp.n) = 0;
        sp.istart(1:sp.n) = {0};
        sp.istop(1:sp.n)  = {0};

        sp.A(1:sp.n)  = 0;
        sp.tA(1:sp.n) = {0};

        sp.AI(1:sp.n)  = 0;
        sp.tAI(1:sp.n) = {0};

        sp.GtACR_on(1:sp.n)  = {0};
        sp.GtACR_off(1:sp.n) = {0};

        sp.gj = zeros(sum(startsWith(sp.names,'TRN')));
    end
end
```

