%
% schneideri/apr2013 - Recieve new data from VT stream
%
function [dataArray, timeStampArray, timeStampArrayConv, numValidSamplesArray,numRecordsReturned,samplingFreqArray,stepsize] = Netcom_pollVT( VTStream, verbose, Fs, dataArrayPreAlloc, dataArrayPtr )

% Call un-optimized NetCom function
[succeeded,  timeStampArray, dataArray, ~, numRecordsReturned, numRecordsDropped ] = NlxGetNewVTData(VTStream);

% Do we need this doubling for downstream processing?
numValidSamplesArray = numRecordsReturned;
timeStampArrayConv = timeStampArray;

if numRecordsReturned==0 && verbose
    disp([num2str(labindex) ' ' VTStream ' success ' num2str(succeeded) ' received ' num2str(numRecordsReturned) ' dropped=' num2str(numRecordsDropped) ]);
end    

if numRecordsReturned>0    
    if verbose && ( numRecordsReturned || numRecordsDropped)        
        disp([num2str(labindex) ' ' VTStream ' success ' num2str(succeeded) ' received ' num2str(numRecordsReturned) ' dropped=' num2str(numRecordsDropped) ]);
    end
    
    if numRecordsDropped
        disp(['warning records dropped ' num2str(numRecordsDropped)]);
    end        
        
    % Check if time stamps and samples are consistent
    nTimes = length(timeStampArray);
    nData = size(dataArray,2)/2;
    
    if nData ~= nTimes
        % Streaming problem
        disp(['length missmatch ' num2str([ nTimes nData])]);          
    end;
end;