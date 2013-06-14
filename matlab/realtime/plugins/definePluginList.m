function [pList, pListStrs] = definePluginList( onlyType )
% returns a list (struct) of available plugins.

% return all plugins by default
pListAll = definePluginListAll();
pList = pListAll;

% filter by trial type
if nargin > 0
    plugin_to_keep = zeros(1, numel(pList));
    for j=1:length(pListAll)
        if pListAll(j).trial_type == onlyType
            plugin_to_keep(j) = 1;
        end
    end
    pList(~plugin_to_keep) = [];
end

pListStrs = cell(1, numel(pList));
for j=1:length(pList)
    pListStrs{j} = pList(j).displayName;
end

%%
function pList_allocated = pListDefault()

    % pre-allocate 'pList' - these are all fields that are available.
    pList_allocated = struct( 'ID', [], ...
        'name', [], ...             % Plugin name.
        'displayName', [], ...      % String to show in GUI.
        'trial_type', [], ...       % Plugin must have unique trial type.
        'data_types', [], ...       % Data type(s) the plugin does operate on.
        'needs_matlab_gui', [], ... % Does Plugin come with a matlab GUI that needs to be updated?
        'initFunc', [], ...
        'initGUIFunc', [], ...
        'initWorker', [], ...
        'processDataFunc', [], ...
        'transferGUIFunc', [], ...
        'updateGUIFunc', [], ...
        'resetGUIFunc', [], ...
        'dependsOn', [], ...
        'shutdownWorkerFunc', []);
    
end


function pList = definePluginListAll()

% Trial types. Each plugin can only belong to one trial type.
TRIAL_TYPE_CONTINUOUS = 1;   % is called for every new datapoint that comes in
TRIAL_TYPE_SINGLE_TRIAL = 2; % is called for every new trial

% Does the plugin come with a matlab gui that needs updating?
NEEDS_MATLAB_GUI_TRUE = 1;
NEEDS_MATLAB_GUI_FALSE = 0;

% data types that plugins might be expecting.
% TODO: assign data types to each plugin.
DATA_TYPE_CONTINUOUS = 1;
DATA_TYPE_EVENT = 2;
DATA_TYPE_VT = 3;

% preallocate struct
pList = pListDefault();


%% ====== pSpikes plugin
i=1;
pList(i).ID=i;
pList(i).name='pSpikes';   %prefix
pList(i).displayName='Spikes and Waveforms (StimOMatic)';
pList(i).trial_type = TRIAL_TYPE_CONTINUOUS;
pList(i).needs_matlab_gui = NEEDS_MATLAB_GUI_TRUE;

%these function pointers define the function of the plugin
pList(i).initFunc = @pSpikes_initPlugin;
pList(i).initGUIFunc = @pSpikes_initGUI;
pList(i).initWorker = @pSpikes_initWorker;
pList(i).processDataFunc = @pSpikes_processData;
pList(i).transferGUIFunc = @pSpikes_prepareGUItransfer;
pList(i).updateGUIFunc = @pSpikes_updateGUI;
pList(i).resetGUIFunc = @pSpikes_resetGUI;

%% ========= pContinuous plugin
i=i+1;
pList(i).ID=i;
pList(i).name='pContinuous';   %prefix
pList(i).displayName='Continuous LFP/Spikes plot';
pList(i).trial_type = TRIAL_TYPE_CONTINUOUS;
pList(i).needs_matlab_gui = NEEDS_MATLAB_GUI_TRUE;

%these function pointers define the function of the plugin
pList(i).initFunc = @pContinuous_initPlugin;
pList(i).initGUIFunc = @pContinuous_initGUI;
pList(i).initWorker = @pContinuous_initWorker;
pList(i).processDataFunc = @pContinuous_processData;
pList(i).transferGUIFunc = @pContinuous_prepareGUItransfer;
pList(i).updateGUIFunc = @pContinuous_updateGUI;

%% ========= pContinuousOpenGL plugin
i=i+1;
pList(i).ID=i;
pList(i).name='pContinuousOpenGL';   %prefix
pList(i).displayName='Continuous LFP/Spikes plot (OpenGL)';
pList(i).trial_type = TRIAL_TYPE_CONTINUOUS;
pList(i).needs_matlab_gui = NEEDS_MATLAB_GUI_FALSE;

%these function pointers define the function of the plugin
pList(i).initFunc = @pContinuousOpenGL_initPlugin;
pList(i).initGUIFunc = @pContinuousOpenGL_initGUI;
pList(i).initWorker = @pContinuousOpenGL_initWorker;
pList(i).processDataFunc = @pContinuousOpenGL_processData;
pList(i).transferGUIFunc = @pContinuousOpenGL_prepareGUItransfer;
pList(i).updateGUIFunc = @pContinuousOpenGL_updateGUI;
pList(i).shutdownWorkerFunc = @pContinuousOpenGL_shutdownWorker;

%% ========== pLFPAverage plugin (trial-by-trial)
i=i+1;
pList(i).ID=i;
pList(i).name='pLFPAv';   %prefix
pList(i).displayName='LFP Average per Trial';
pList(i).trial_type = TRIAL_TYPE_SINGLE_TRIAL;
pList(i).needs_matlab_gui = NEEDS_MATLAB_GUI_TRUE;

%these function pointers define the function of the plugin
pList(i).initFunc = @pLFPAv_initPlugin;
pList(i).initGUIFunc = @pLFPAv_initGUI;
pList(i).initWorker = @pLFPAv_initWorker;
pList(i).processDataFunc = @pLFPAv_processData;
pList(i).transferGUIFunc = @pLFPAv_prepareGUItransfer;
pList(i).updateGUIFunc = @pLFPAv_updateGUI;

%% ========== pRaster plugin (trial-by-trial)
i=i+1;
pList(i).ID=i;
pList(i).name='pRaster';   %prefix
pList(i).displayName='Raster/PSTH (StimOMatic) - req pSpikes; ';
pList(i).trial_type = TRIAL_TYPE_SINGLE_TRIAL;
pList(i).needs_matlab_gui = NEEDS_MATLAB_GUI_TRUE;
pList(i).dependsOn=1; %depends on plugin with this ID to get data (add it afterwards,so a link can be added)

%these function pointers define the function of the plugin
pList(i).initFunc = @pRaster_initPlugin;
pList(i).initGUIFunc = @pRaster_initGUI;
pList(i).initWorker = @pRaster_initWorker;
pList(i).processDataFunc = @pRaster_processData;
pList(i).transferGUIFunc = @pRaster_prepareGUItransfer;
pList(i).updateGUIFunc = @pRaster_updateGUI;

%% ========= pCtrlLFP plug (realtime control plugin)
i=i+1;
pList(i).ID=i;
pList(i).name='pCtrlLFP';   %prefix
pList(i).displayName='Realtime control LFP';
pList(i).trial_type = TRIAL_TYPE_CONTINUOUS;
pList(i).needs_matlab_gui = NEEDS_MATLAB_GUI_TRUE;
%pList(i).dependsOn=2; %depends on plugin with this ID to get data (add it afterwards,so a link can be added)

%these function pointers define the function of the plugin
pList(i).initFunc = @pCtrlLFP_initPlugin;
pList(i).initGUIFunc = @pCtrlLFP_initGUI;
pList(i).initWorker = @pCtrlLFP_initWorker;
pList(i).processDataFunc = @pCtrlLFP_processData;
pList(i).transferGUIFunc = @pCtrlLFP_prepareGUItransfer;
pList(i).updateGUIFunc = @pCtrlLFP_updateGUI;
pList(i).shutdownWorkerFunc = @pCtrlLFP_shutdownWorker;

end

end
