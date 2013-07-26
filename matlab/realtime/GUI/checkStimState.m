function checkStimState(object, eventdata, handles)
% Check current state of the StimState variable and end stimulation if an
% end-signal has been received from the StimPC

switch handles.StimState.data(end)
    case 0 % running
        return
    case 1 % stimulation finished
        addEntryToStatusListbox(handles.ListboxStatus, ['Stop signal received from PTB system.'])          
        % Stop acquisition / recording
        if get(handles.StartACQButton, 'Value') == get(handles.StartACQButton, 'Max')
            [~, ~] = NlxSendCommand('-StopAcquisition');
            set(handles.StartACQButton, 'String', 'Start ACQ', 'BackgroundColor', [0.831 0.816 0.784]);
            set(handles.StartACQButton, 'Value', get(handles.StartACQButton, 'Min'));
        end;
        if get(handles.StartRECButton, 'Value') == get(handles.StartRECButton, 'Max')
            [~, ~] = NlxSendCommand('-StopRecording');
            set(handles.StartRECButton, 'String', 'Start REC', 'BackgroundColor', [0.831 0.816 0.784]);
            set(handles.StartRECButton, 'Value', get(handles.StartRECButton, 'Min'));
        end;
        
        % Reset trigger variable on StimPC
        tcpClientMat('0',get(handles.inputfieldPsychServer, 'String'), 9997, 0);
        
        % Stop the timer object, but don't delete!
        stop(handles.tmr2);
end;