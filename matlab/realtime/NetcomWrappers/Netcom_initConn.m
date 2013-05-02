%
% initialize netcom connection, get list of available objects
%
function [success, eventStr, allCSCs,allSEs,allTTs, allVTs] = Netcom_initConn( serverName, appName)

    if nargin < 2
        appName = 'StimOMatic realtime';
    end

    [cheetahObjects,cheetahTypes,success] = initializeNetcomclient( serverName, appName );


    %% parse the list of returned objects
    %
    eventStr = '';

    allCSCs = [];
    allSEs = [];
    allTTs = [];
    allVTs = [];
    
    for k=1:length(cheetahTypes)
        
        switch cheetahTypes{k}
            case 'CscAcqEnt'
                allCSCs{ length(allCSCs)+1 } = cheetahObjects{k};
                
            case 'SEScAcqEnt'
                allSEs{ length(allSEs)+1 } = cheetahObjects{k};
                
            case 'TTScAcqEnt'
                allTTs{ length(allTTs)+1 } = cheetahObjects{k};
                
            case 'EventAcqEnt'
                eventStr = cheetahObjects{k};
                
            case 'VTAcqEnt'
                allVTs{ length(allVTs)+1 } = cheetahObjects{k};
        end
    end
    
end
%% EOF