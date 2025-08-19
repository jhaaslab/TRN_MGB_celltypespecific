classdef simParams
    % Parameters passed to a dsim function
    % 'default' values:
    properties
        g_ca_lts = 0.75;     %gca of .75 with leak of .1 is good;
        g_nat = 60.5;
        g_kd = 60;
        g_nap = 0;
        g_kt = 5;
        g_k2 = .5;
        g_ar = 0.025;
        g_L = 0.1;
        g_GtACR = 10;
        E_na = 50;
        E_k = -100;
        E_ca = 125;
        E_ar = -40;
        E_L = -75;
        E_GtACR = -70;
        E_AMPA = 0;
        E_GABA = -100;
        C = 1;       % membrance capacitance  uF/cm^2
        Ti1 = 5;     %Inh rise time constant  %1e-4/5e-4 is good for b-let.
        Ti2 = 35;       %fall time constant  %5e-3 / 20e-3 ?? ~50 ms rise.
        Te1 = 5;     %Exc
        Te2 = 35;
        GtACR_on = {};
        GtACR_off = {};

        n 
        names
        per_neuron
        s0
        Rin
        vm_rest
        
        %DC pulses
        bias
        iDC          % uA/cm2;  DC  .25 is ~TR for burst
        istart={};
        %istop={};
        
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
    end
    
    methods
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
                
                sp.A(1:sp.n) = 0;
                sp.tA(1:sp.n) = {0};
                
                sp.AI(1:sp.n) = 0;
                sp.tAI(1:sp.n) = {0};
                
                sp.GtACR_on(1:sp.n) = {0};
                sp.GtACR_off(1:sp.n) = {0};

                sp.gj=zeros(sum(startsWith(namesOfNeurons,'TRN')));
            end
        end
    end
end