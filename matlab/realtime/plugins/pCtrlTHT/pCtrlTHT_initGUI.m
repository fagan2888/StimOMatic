%
% Plot pCtrlTHT GUI
% handlesParent - handles from StimOMatic function
% handlesGUI - handles of active GUIs written into handles.activeplugins.handlesGUI
%
function handlesGUI = pCtrlTHT_initGUI( handlesGUI, handlesParent )

% Get the application data
appdata = getappdata(handlesGUI.figHandle);
handles = appdata.UsedByGUIData_m; % 

% Clear axes
cla(handles.azimuthCam)
cla(handles.elevationCam)
cla(handles.volumeView)

% Check if there are previously defined ROIs and clear them
if isfield(handlesGUI, 'ROIhandles')
    disp('Clearing old ROIs')
    if ishandle(handlesGUI.ROIhandles.aziROI); delete(handlesGUI.ROIhandles.aziROI); end;
    if ishandle(handlesGUI.ROIhandles.eleROI); delete(handlesGUI.ROIhandles.eleROI); end;
    for j = [handlesGUI.ROIhandles.vertex1 handlesGUI.ROIhandles.vertex2 handlesGUI.ROIhandles.vertex3 handlesGUI.ROIhandles.vertex4 handlesGUI.ROIhandles.vertex5 handlesGUI.ROIhandles.vertex6]
        if ishandle(j)
            delete(j)
        end
    end
end;

% Initializing the axes limits according to the camera resolution stored in handles.StimOMaticConstants
set(handles.azimuthCam,'ylim',[0 handlesParent.StimOMaticConstants.heightVT],'xlim',[0 handlesParent.StimOMaticConstants.widthVT]); 
set(handles.elevationCam,'ylim',[0 handlesParent.StimOMaticConstants.heightVT],'xlim',[0 handlesParent.StimOMaticConstants.widthVT]);
set(handles.volumeView,'zlim', [0 handlesParent.StimOMaticConstants.widthVT],'zTick', [0:100:handlesParent.StimOMaticConstants.widthVT],...
    'ylim',[0 handlesParent.StimOMaticConstants.widthVT],'yTick', [0:100:handlesParent.StimOMaticConstants.widthVT],...
    'xlim',[0 handlesParent.StimOMaticConstants.heightVT],'xTick', [0:100:handlesParent.StimOMaticConstants.heightVT]); 

% Get ROIs
handlesGUI.ROIx = str2double(get(handles.inputfieldROIx,'String'));
handlesGUI.ROIy = str2double(get(handles.inputfieldROIy,'String'));
handlesGUI.ROIz = str2double(get(handles.inputfieldROIz,'String'));

halfHeight = handlesParent.StimOMaticConstants.heightVT/2;
halfWidth = handlesParent.StimOMaticConstants.widthVT/2;

% Check if any of the ROIs is NaN and set trackMode accordingly
if all([isnan(handlesGUI.ROIx) isnan(handlesGUI.ROIy) isnan(handlesGUI.ROIz)])
    disp('No ROIs defined - Entering free tracking mode')   
elseif any([isnan(handlesGUI.ROIx) isnan(handlesGUI.ROIy) isnan(handlesGUI.ROIz)])
    error('ROIs need to be defined in each dimension')
else
    disp('ROIs defined - Setting ROIs and entering tracking mode with feedback')     
    
    % Plot ROIs into 2d plots
    ROIhandles.aziROI = rectangle('Parent', handles.azimuthCam ,'Position',[halfWidth-handlesGUI.ROIy/2 halfHeight-handlesGUI.ROIx/2 handlesGUI.ROIy handlesGUI.ROIx], 'LineWidth', 2, 'EdgeColor', 'r', 'HandleVisibility', 'off');
    ROIhandles.eleROI = rectangle('Parent', handles.elevationCam ,'Position',[halfWidth-handlesGUI.ROIz/2 halfHeight-handlesGUI.ROIx/2 handlesGUI.ROIz handlesGUI.ROIx], 'LineWidth', 2, 'EdgeColor', 'r', 'HandleVisibility', 'off');
        
    % Plot ROI into 3d plot
    x=([0 1 1 0 0 0;1 1 0 0 1 1;1 1 0 0 1 1;0 1 1 0 0 0]-0.5)*handlesGUI.ROIx+(halfHeight-handlesGUI.ROIx/2)+handlesGUI.ROIx/2;
    y=([0 0 1 1 0 0;0 1 1 0 0 0;0 1 1 0 1 1;0 0 1 1 1 1]-0.5)*handlesGUI.ROIy+(halfWidth-handlesGUI.ROIy/2)+handlesGUI.ROIy/2;
    z=([0 0 0 0 0 1;0 0 0 0 0 1;1 1 1 1 0 1;1 1 1 1 0 1]-0.5)*handlesGUI.ROIz+(halfWidth-handlesGUI.ROIz/2)+handlesGUI.ROIz/2;
    ROIhandles.vertex1 =patch(x(:,1),y(:,1),z(:,1),'r', 'FaceColor', 'none', 'EdgeColor','r', 'LineWidth', 2, 'HandleVisibility', 'off', 'Parent', handles.volumeView);
    ROIhandles.vertex2 =patch(x(:,2),y(:,2),z(:,2),'r', 'FaceColor', 'none', 'EdgeColor','r', 'LineWidth', 2, 'HandleVisibility', 'off', 'Parent', handles.volumeView);
    ROIhandles.vertex3 =patch(x(:,3),y(:,3),z(:,3),'r', 'FaceColor', 'none', 'EdgeColor','r', 'LineWidth', 2, 'HandleVisibility', 'off', 'Parent', handles.volumeView);
    ROIhandles.vertex4 =patch(x(:,4),y(:,4),z(:,4),'r', 'FaceColor', 'none', 'EdgeColor','r', 'LineWidth', 2, 'HandleVisibility', 'off', 'Parent', handles.volumeView);
    ROIhandles.vertex5 =patch(x(:,5),y(:,5),z(:,5),'r', 'FaceColor', 'none', 'EdgeColor','r', 'LineWidth', 2, 'HandleVisibility', 'off', 'Parent', handles.volumeView);
    ROIhandles.vertex6 =patch(x(:,6),y(:,6),z(:,6),'r', 'FaceColor', 'none', 'EdgeColor','r', 'LineWidth', 2, 'HandleVisibility', 'off', 'Parent', handles.volumeView);
    
    %Write handles into handlesGUI structure
    handlesGUI.ROIhandles = ROIhandles;
end

% Initialize plot handles in GUI
handlesGUI.azimuthCam = handles.azimuthCam;
handlesGUI.elevationCam = handles.elevationCam;
handlesGUI.volumeView = handles.volumeView;

% Initialize line handles for faster plotting
lineHandles.azimuthCam = scatter(handlesGUI.azimuthCam, halfWidth, halfHeight,'+k', 'LineWidth', 2);
lineHandles.elevationCam = scatter(handlesGUI.elevationCam, halfWidth, halfHeight,'+k', 'LineWidth', 2);
lineHandles.volumeView =  plot3(handlesGUI.volumeView, halfHeight, halfWidth, halfWidth, '+k', 'LineWidth', 2);

handlesGUI.lineHandles = lineHandles;