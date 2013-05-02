%
% schneideri/apr13 - Data structures to be transfered to each worker where this plugin should be running
% NOTE: Settings/parameters can't be changed after starting the data feed! 
%
function pluginData = pCtrlTHT_initWorker(handlesParent, handlesPlugin )

%% Get the application data
appdata = getappdata(handlesPlugin.figHandle);
handles = appdata.UsedByGUIData_m;

%% Get abs_ID and set status
abs_ID = handlesParent.abs_ID_in_parent;
 
statusStr=['PluginID=' num2str(abs_ID)];
handles.pluginStatus = statusStr; % Modified. Does that work and if yes what is it good for?

%% Get settings from the GUI and generate pluginData structure

% Determine which tracker captures azimuth and which elevation
trackerList = get(handles.popupVTStreams1,'String');
aziSel = get(handles.popupVTStreams1, 'Value');
eleSel = get(handles.popupVTStreams2, 'Value');
if aziSel ==1 && eleSel ==1
    error('No tracker streams selected!')    
end;

pluginData.VideoTracker = 1;

% Store the IDs
pluginData.azimuthTracker = trackerList{aziSel}; %VT1
pluginData.elevationTracker = trackerList{eleSel}; %VT2

% Get ROIs
pluginData.ROIx = str2double(get(handles.inputfieldROIx,'String'));
pluginData.ROIy = str2double(get(handles.inputfieldROIy,'String'));
pluginData.ROIz = str2double(get(handles.inputfieldROIz,'String'));

% Check if any of the ROIs is NaN and set trackMode accordingly
switch all([isnan(pluginData.ROIx) isnan(pluginData.ROIy) isnan(pluginData.ROIz)])
    case true
        disp('No ROIs defined - Entering free tracking mode')
        pluginData.trackMode = 0;
        closedLoopSettings = [];
    case false
        disp('ROIs defined - Setting ROIs and entering tracking mode with feedback')
        pluginData.trackMode = 1;                
        % We will need the IP of the stimulation PC        
        pluginData.hostname = get(handlesParent.inputfieldPsychServer,'String');
        pluginData.previousCmdSent = 0;
        % Implement initialization of tcp exchange
end

pluginData.StimOMaticConstants = handlesParent.StimOMaticConstants;