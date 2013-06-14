%
%a special version of interpolateTimestamps.m, speed optimized.
%
%urut/feb12
function [yi] = interpolateTimestamps_optimized( timestamps, Fs)

BLOCKSIZE = 512;
BLOCKSIZE_MINUS_ONE = BLOCKSIZE - 1;
STEPSIZE = 1e6/Fs;

yi=nan(1,BLOCKSIZE*length(timestamps));

for j=1:length(timestamps)
    yi(1+(j-1)*BLOCKSIZE:BLOCKSIZE*j) =  [timestamps(j):STEPSIZE:(timestamps(j)+STEPSIZE*BLOCKSIZE_MINUS_ONE)] ;
end

%timestamps = [ timestamps timestamps(end)+512*Fs/1e6 ]; % need to add one timepoint

%x = 0:blockSize:length(dataSamples);
%xi = 1:length(dataSamples);
%yi = interp1q(x',timestamps', xi' );
end