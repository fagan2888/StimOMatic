%
% schneideri/apr13 - Update the GUI with new information. 
% Called once for each channel. Code only executed for VT streams
%
%
function pCtrlTHT_updateGUI( CSCChanNr, transferedGUIData, handlesPlugin, handlesParent )

switch transferedGUIData.ChanStr    
    case {'VT1'; 'VT2'}        
        if strcmp(transferedGUIData.azimuthTracker, transferedGUIData.ChanStr) == 1
            hCam = handlesPlugin.lineHandles.azimuthCam;
            volData = 'ydata';
        elseif strcmp(transferedGUIData.elevationTracker, transferedGUIData.ChanStr) == 1
            hCam = handlesPlugin.lineHandles.elevationCam;
            volData = 'zdata';
        end;    
        % Update 2d plots
        set(hCam, 'xdata', transferedGUIData.dataBuffer(1,:), 'MarkerEdgeColor', transferedGUIData.posCol);
        set(hCam, 'ydata', transferedGUIData.dataBuffer(2,:), 'MarkerEdgeColor', transferedGUIData.posCol );
        
        % Update data in 3d plot
        set(handlesPlugin.lineHandles.volumeView, 'xdata', transferedGUIData.dataBuffer(1,:), 'MarkerEdgeColor', transferedGUIData.posCol)
        set(handlesPlugin.lineHandles.volumeView, volData, transferedGUIData.dataBuffer(2,:), 'MarkerEdgeColor', transferedGUIData.posCol)
end;