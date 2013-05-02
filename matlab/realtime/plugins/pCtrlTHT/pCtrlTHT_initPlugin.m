%
% schneideri/apr13 - initialize the head tracker realtime control plugin
%
function handlesGUI = pCtrlTHT_initPlugin(  )

%% open the GUI
handlesGUI.figHandle = pCtrlTHT_GUI;    % open the GUI
set(handlesGUI.figHandle, 'CloseRequestFcn', '');
