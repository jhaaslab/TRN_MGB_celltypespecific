function [tspks] = poissonP(r,T)
%POISSONP Poisson process for generating stochastic spike trains
%   Computes spike times for given rate(r) in Hz over total time(T) in ms
dt = 0.0001; % .1 ms precision
spks=zeros(1,T*(1/dt));
R=rand(size(spks));
tspks=find(R<r*dt)/10;
end