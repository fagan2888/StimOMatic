%
function pluginData = pContinuous_processData( newDataReceived, newTimestampsReceived, pluginData, CSCBufferData, CSCTimestampData )
%disp('pSpikes_processedData called');

% TODO: remove this temp fix - make sure *_processData only receives the
% correct data. see also "pCtrlLFP_processData.m'
switch pluginData.channelInfo_caller.channelStr
    case {'VT1', 'VT2'}
        
    otherwise

        framesize=512;
        nrOverlapLFP = 4*framesize;
        nrOverlapSpikes = 4*framesize;


        % update filter buffers before raw buffers!
        pluginData.filteredDataLFP = filterSignal_appendBlock( pluginData.StimOMaticConstants.filters.HdLFP, CSCBufferData, pluginData.filteredDataLFP, newDataReceived', nrOverlapLFP, framesize );
        pluginData.filteredDataSpikes = filterSignal_appendBlock( pluginData.StimOMaticConstants.filters.HdSpikes, CSCBufferData, pluginData.filteredDataSpikes, newDataReceived', nrOverlapSpikes, framesize );

        %plotState [lengthNewData, totReceived]
        pluginData.plotState = [length(newDataReceived) pluginData.plotState(2)+length(newDataReceived)];

        % update channel-stats
        %pluginData.spikesSd = std(pluginData.filteredDataSpikes);
        
end