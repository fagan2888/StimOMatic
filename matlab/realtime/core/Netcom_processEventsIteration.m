function [storedEvents,updateAv,tOff] = Netcom_processEventsIteration(TTLStream, RTModeOn, storedEvents, updateAv, tOff, eventStringArrayPtr)
% Polls new events and processes them.
% Called by "data_polling_timer_fcn.m".
%
% returns:
% - storedEvents: vector containing timestamp and event value
% - updateAv: boolean indicating whether to update the plugin average.
% - tOff: timestamp of last "OFF" event.
%

%% set verbose level depending on whether we are in Realtime mode or not.

verbose = 1;
% TODO: I'm assuming that RTModeOn has the value '1' if Realtime is 'on'.
if RTModeOn == 1
    verbose = 0;
end

%% Get new events.

[eventsReceived, nrReceived] = Netcom_pollEvents( TTLStream, verbose, eventStringArrayPtr );

%% Process events.
% TODO: this code should most probably be moved into the processing
% function of the corresponding trial by trial plugin.

if nrReceived > 0
    
    % TODO: these are hard coded event IDs. Make this a plugin config option.
    ON_EVENT = 1;
    OFF_EVENT = 2;
    
    tOff = [];
    ind = find( eventsReceived(:,2) == ON_EVENT | eventsReceived(:,2) == OFF_EVENT ) ;   %stim ON/OFF events
    
    if ~isempty( ind )
        
        if verbose
            disp( [ 'Stim on/off detected at ' num2str(eventsReceived(ind(1),1)) ] );
        end
        
        % append new events.
        storedEvents = [ storedEvents; eventsReceived(ind,:)];
        newOffsetInd = find( eventsReceived(:,2) == OFF_EVENT );
        
        if ~isempty(newOffsetInd)
            
            if verbose
                disp('Stim offset detected, update the average ');
            end
            
            newOffsetInd = newOffsetInd(end); %only consider one trial
            
            %get the last X samples before this
            tOff = eventsReceived(newOffsetInd,1);
            updateAv = true;
        end
    end
    
end

end