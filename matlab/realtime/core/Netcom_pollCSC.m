%
%receive CSC stream
%
%urut/oct11
function [dataArray, timeStampArray, timeStampArrayConv, numValidSamplesArray,numRecordsReturned,samplingFreqArray,stepsize] = Netcom_pollCSC( CSCStream, verbose, Fs, dataArrayPreAlloc, dataArrayPtr )

BLOCKSIZE = 512;
stepsize=1e6/Fs;

timeStampArrayConv=[];
bufferSizeForNetcom=1000;

%dataArrayPreAlloc = nan(1,(BLOCKSIZE * bufferSizeForNetcom) );  %faster

%% get CSCData

[succeeded,dataArray, timeStampArray, ~, samplingFreqArray, numValidSamplesArray, numRecordsReturned, ...
    numRecordsDropped ] = NlxGetNewCSCData_optimized(CSCStream,bufferSizeForNetcom, BLOCKSIZE,dataArrayPtr);

%% no data received - return.
if numRecordsReturned==0
    if verbose
        disp([num2str(labindex) ' ' CSCStream ' success ' num2str(succeeded) ' received ' num2str(numRecordsReturned) ' dropped=' num2str(numRecordsDropped) ]);
    end
    return;
end

%% new data received - process.
if numRecordsReturned > 0
    
    if verbose && ( numRecordsReturned || numRecordsDropped)
        disp([num2str(labindex) ' ' CSCStream ' success ' num2str(succeeded) ' received ' num2str(numRecordsReturned) ' dropped=' num2str(numRecordsDropped) ]);
    end
    
    if numRecordsDropped
        disp(['warning records dropped ' num2str(numRecordsDropped)]);
    end
    
    %% get timestamp for each data block
    if numRecordsReturned>0
        
        nTimes=length(timeStampArray)*BLOCKSIZE;
        nData=length(dataArray);
        %disp(['length  ' num2str([ nTimes nData])]);
        
        if nData==nTimes & nData>BLOCKSIZE
            [timeStampArrayConv] = interpolateTimestamps_optimized( double(timeStampArray),Fs );
        else if nData==BLOCKSIZE
                
                %only 1 block
                T=double(timeStampArray(1));
                timeStampArrayConv = [T:stepsize:T+BLOCKSIZE*stepsize]';
            else
                %problem
                disp(['length missmatch ' num2str([ nTimes nData])]);
            end
        end
    end
end

end