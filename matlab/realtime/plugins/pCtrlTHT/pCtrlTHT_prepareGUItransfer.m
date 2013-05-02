%
% schneideri/apr13 - Run on worker, prepare data to be transfered to client 
% for plotting (as little as possible). This will be called once per channel 
% that this GUI is processing
%
%
function pluginDataToTransfer = pCtrlTHT_prepareGUItransfer( pluginData )

pluginDataToTransfer=[];

switch pluginData.channelInfo_caller.channelStr
    case {'VT1', 'VT2'}
        pluginDataToTransfer.dataBuffer = pluginData.dataBuffer;
        pluginDataToTransfer.posCol = pluginData.posCol;
        pluginDataToTransfer.ChanStr = pluginData.channelInfo_caller.channelStr;
        pluginDataToTransfer.azimuthTracker = pluginData.azimuthTracker;
        pluginDataToTransfer.elevationTracker = pluginData.elevationTracker;
    otherwise
        pluginDataToTransfer.ChanStr = 'XYZ';
end