%
% ischneider/apr13 - Processing of video tracker data for pCtrlTHT
% This happens in parallel and thus defining the state (in/out of ROI) is
% shaky
% Can we highjack the CSCBufferData variable as Cache?
%
function pluginData = pCtrlTHT_processData( newDataReceived, newTimestampsReceived, pluginData, CSCBufferData, CSCTimestampData )

switch pluginData.channelInfo_caller.channelStr
    case {'VT1', 'VT2'}
        %% Reshape the coordinate array     
        dataArray = reshape(newDataReceived',2,size(newDataReceived',2)/2);
        xData = mean(dataArray(1,:)); % -> 1st row is x-coordinates
        yData = mean(dataArray(2,:)); % -> 2nd row is y-coordinates
        
        % Determine which ROI values are to be used              
        if strcmp(pluginData.azimuthTracker, pluginData.channelInfo_caller.channelStr) == 1
            % Use azimuth ROIs
            xComp = pluginData.ROIy;
            yComp = pluginData.ROIx;
        elseif strcmp(pluginData.elevationTracker, pluginData.channelInfo_caller.channelStr) == 1
            % Use elevation ROIs
            xComp = pluginData.ROIz;
            yComp = pluginData.ROIx;
        end;
        
        %% Check whether we run in closed-loop mode
        switch pluginData.trackMode
            case true
                % Closed-loop mode
                % Check if the head is in the defined volume
                if xData < (pluginData.StimOMaticConstants.widthVT/2 - xComp/2) || xData > (pluginData.StimOMaticConstants.widthVT/2 + xComp/2) || yData < (pluginData.StimOMaticConstants.heightVT/2 - yComp/2) || yData > (pluginData.StimOMaticConstants.heightVT/2 + yComp/2)
                    disp(['Control plugin action: ROI left']);               
                    cmdToSend=1;
                    pluginData.posCol = 'r';
                else                    
                    cmdToSend=0;                    
                    pluginData.posCol = 'b';
                end;
                pCtrlTHT_sendCommand( pluginData.hostname, cmdToSend, pluginData.previousCmdSent);
                pluginData.previousCmdSent = cmdToSend;
            case false
                % Open-loop mode                
                pluginData.posCol = 'b';
        end;

% Take average position for every iteration (3 samples) as approximation
pluginData.dataBuffer = mean(dataArray,2);

% Respond by writing to shared variable on PTB PC
otherwise
    % Generate empty output if channel is not a VT to avoid downstream errors
    pluginData.dataBuffer = [];
end;

    function pCtrlTHT_sendCommand(hostname, Cmd, previousCmdSet,currTimestamp)
        if previousCmdSet~=Cmd
            if tcpClientMat(num2str(Cmd), hostname, 9999, 0)==-1
                warning('could not send RT cmd');
                warning(['Cmd = ' num2str(Cmd)]);
                warning(['previousCmdSet = ' num2str(previousCmdSet)]);
            end
            
            if nargin==4
                NlxSendCommand(['-PostEvent "pCtrTHT Trigger at t=' num2str(currTimestamp) '" 2000 2000']);   %also send to the event log
            else
                NlxSendCommand('-PostEvent "pCtrTHT Trigger" 2000 2000');   %also send to the event log
            end
        end
        
        function pCtrlTHT_sendCommand_noTTL(hostname, Cmd, previousCmdSet)
            if previousCmdSet~=Cmd
                if tcpClientMat(num2str(Cmd), hostname, 9999, 0)==-1
                    warning('could not send RT cmd (noTTL)');
                    disp(['Cmd = ' num2str(Cmd)]);
                    disp(['previousCmdSet = ' num2str(previousCmdSet)]);
                end
            end;