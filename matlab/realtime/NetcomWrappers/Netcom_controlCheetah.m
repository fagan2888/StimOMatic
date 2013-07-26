function Netcom_controlCheetah(hObject, handles, mode)
% Function handling the ACQ and REC buttons in the StimOMatic GUI and
% sending out the appropriate commands

% Prepare the commands depending on the mode
switch mode
    case 'ACQ'
        logTag = 'Acquisition';
        NetcomCommands = {'-StartAcquisition'; '-StopAcquisition'};
        buttonColor = [0 1 0];
    case 'REC'
        logTag = 'Recording';
        NetcomCommands = {'-StartRecording'; '-StopRecording'};
        buttonColor = [0.48 0.06 0.89];
end;

% Get current button state
button_state = get(hObject, 'Value');
button_max = get(hObject, 'Max');
button_min = get(hObject, 'Min');

%% Start/Stop
if button_state == button_max
    [succeeded, cheetahReply] = NlxSendCommand(NetcomCommands{1});
    if succeeded == 1
        addEntryToStatusListbox(handles.ListboxStatus, ['Starting: ', logTag]);
        set(hObject, 'String', ['Stop ', mode], 'BackgroundColor', buttonColor);
               
        if strcmp(mode, 'REC')
            % Toggle ACQ button too, since stopping the REC will not stop ACQ.
            if get(handles.StartACQButton, 'Value') == button_min
                disp('setting ACQ too!');
                set(handles.StartACQButton, 'Enable', 'off', 'String', 'Stop ACQ', 'BackgroundColor', [0 1 0], 'Value', button_max);
            end
        end;
        
        % Send event (experimentID) to Cheetah
        ExpID = strcat(get(handles.inputfieldSubjectID, 'String'),'_',get(handles.inputfieldExpTag,'String'));
        NlxSendCommand(strcat('-PostEvent "',ExpID,'" 9999 9999'));
        addEntryToStatusListbox(handles.ListboxStatus, ['Sent event: ', ExpID])
        
        % Send GO to StimPC if specified
        if get(handles.checkTriggerStim, 'Value') == 1
            addEntryToStatusListbox(handles.ListboxStatus, ['Sending trigger to ',get(handles.inputfieldPsychServer, 'String')])                    
            switch tcpClientMat('1',get(handles.inputfieldPsychServer, 'String'), 9997, 0)
                case true
                    addEntryToStatusListbox(handles.ListboxStatus, ['Sent trigger to PTB system.'])                    
                otherwise
                    addEntryToStatusListbox(handles.ListboxStatus, ['Could not trigger PTB system!'])                    
            end
        end;
        
        % Start timer and regularly check state of StimState variable
        if get(handles.checkAutoStop, 'Value') == 1 
            % Open handle to shared variable
            handles.StimState = initMemSharedVariable('C:/temp/StimLib.dat', 100, 0, true);
            
            if ~isfield(handles, 'tmr2')
                % Create timer object in order to regularly check the state of the StimState variable
                handles.tmr2 = timer;
                set(handles.tmr2, 'ExecutionMode', 'fixedRate','Period', 1.0,'TimerFcn', {@checkStimState, handles});
            end;
            
            if strcmp(get(handles.tmr2, 'Running'), 'off')
                % Start timer if not already running
                start(handles.tmr2);
            end;            
        end;
        
    else
        set(hObject, 'Value', button_min);
    end
    
elseif button_state == button_min
    [succeeded, cheetahReply] = NlxSendCommand(NetcomCommands{2});
    if succeeded == 1
        addEntryToStatusListbox(handles.ListboxStatus, ['Stopping: ', logTag]);
        set(hObject, 'String', ['Start ', mode], 'BackgroundColor', [0.831 0.816 0.784]);
        set(handles.StartACQButton, 'Enable', 'on');        
    else
        set(hObject, 'Value', button_max);
    end
    
end