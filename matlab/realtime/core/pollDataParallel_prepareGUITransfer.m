function [dataTransferGUI] = pollDataParallel_prepareGUITransfer(chanID, processedData,trialData, activePlugins)

    %% check if any active plugins are present, otherwise this function will crash.
    if isempty(activePlugins)
        dataTransferGUI = {};
        return;
    end
    
    %% preallocate.
    dataTransferGUIOfChannel = [];
    
    %% initialize in case there is no data
    for k=1:length(activePlugins)
        dataTransferGUIOfChannel{k}=[];
    end
    
    %% call prepareGUItransfer in each continuous plugin
    for k=processedData{chanID}.activePluginsCont
        dataTransferGUIOfChannel{k} = activePlugins{k}.pluginDef.transferGUIFunc( processedData{chanID}.pluginData{k} );
    end
    
    %% Check if trial-by-trial plugin needs to be updated.
    % 'updatePlotPending' is set in 'pollDataParallel_processTrialbyTrialPlugins.m'
    if trialData{chanID}.updatePlotPending
        % call prepareGUItransfer in each TT plugin
        for k=processedData{chanID}.activePluginsTrial
            dataTransferGUIOfChannel{k} = activePlugins{k}.pluginDef.transferGUIFunc( processedData{chanID}.pluginData{k} );
        end
    end
    
    %%
    dataTransferGUI{chanID} = dataTransferGUIOfChannel;

end
