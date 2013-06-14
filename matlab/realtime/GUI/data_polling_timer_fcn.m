% Main function called by the timer callback (in StimOMatic). 
% This function runs on the master and will distribute data onto the
% workers.
% main logic:
% A) handle events
% B) handle data (all non-events)
% C) update GUI.
%
function data_polling_timer_fcn( obj, event, timerCallNr, guihandles ) %#ok<INUSL>

handles = guidata(guihandles); % get data from GUI
% not pretty,but fast; avoid call to setappdata every iteration, which is very slow.
global customData;   

nrWorkersToPoll = handles.nrWorkersInUse;
customData.iterationCounter = customData.iterationCounter+1;
RTModeOn = handles.RTModeOn;

%% A - HANDLE EVENTS.
% 1) prepare event queue.
% 2) poll incoming events. 
% 3) schedule future averaging update.

updateAv = false; % update plugin average based on new incoming events?
tOff = [];

% 1) prepare event queue; pre-allocate
if customData.iterationCounter == 1
    %from NlxGetNewEventData
    bufferSizeEvents=1000;
    maxEventStringLength=128;
    customData.eventStringArray = cell(1,bufferSizeEvents);
    for index = 1:bufferSizeEvents
        customData.eventStringArray{1,index} = blanks(maxEventStringLength);
    end
    customData.eventStringArrayPtr = libpointer('stringPtrPtr', customData.eventStringArray);
end

% TODO: I removed the realtime check since events might always be of interest.
% 2) poll the events for incoming events and update 'handles.storedEvents'
[handles.storedEvents,updateAv,tOff] = Netcom_processEventsIteration(handles.StimOMaticConstants.TTLStream, RTModeOn, handles.storedEvents, updateAv, tOff,customData.eventStringArrayPtr);

% 3) schedule new event for future averaging
% TODO: I believe that this code should be moved into the respective plugin.
if updateAv == true
    % Based on the last OFF event ('tOff'), schedule and update that
    % will occur in the future.
    tSchedule = tOff + handles.StimOMaticConstants.LFPAverageAfterOffset*1000;
    
    % schedule a future update event
    eventToSchedule = [tSchedule handles.StimOMaticConstants.LFPAverageLength];
    customData.labRefs.scheduledEventsStack = scheduleEventOnWorkers( customData.labRefs.scheduledEventsStack, eventToSchedule, nrWorkersToPoll );
end

%% B - HANDLE DATA (non events) and RUN PLUGIN FUNCTIONS (process data).
updateEach = 100;
updateNow = mod(customData.iterationCounter, updateEach) == 0;
sysStatus = [0 0 0];

t2 = tic();
customData.labRefs = pollDataParallel(nrWorkersToPoll, customData.labRefs, RTModeOn );

if updateNow
    sysStatus(1) = tocWithMsg(['C:' num2str(customData.iterationCounter) ' data_polling_timer_fcn - data processing'], t2, 1);
end

%% C - UPDATE THE GUI.

t3 = tic();
% Do not process events in RT Mode, or if only matlab GUI independent plugins
% are found.
% TODO: add check for non RT mode, so that 'updateGUI_realtimeStreams' is
% only called for workers that depend on matlab GUI.
if ~RTModeOn && sum(cellfun(@(x) x.pluginDef.needs_matlab_gui, handles.activePlugins)) > 0
    customData.labRefs = updateGUI_realtimeStreams( handles, nrWorkersToPoll, customData.labRefs, handles.activePlugins, customData.iterationCounter );
end

if updateNow
    sysStatus(2) = tocWithMsg(['C:' num2str(customData.iterationCounter) ' data_polling_timer_fcn - plotting(prepare)'],t3, 1);
end

t1 = tic();
drawnow();

if updateNow
    sysStatus(3) = tocWithMsg(['C:' num2str(customData.iterationCounter) ' data_polling_timer_fcn - plotting(drawnow)'],t1,1);
end

if updateNow
    set( handles.labelStatusDelays, 'String', ['[ms] Data=' num2str(sysStatus(1)*1000) ' Plot=' num2str(sum(sysStatus(2:3))*1000)] );
end

end
