%% Test framework of pCtrlTHT plugin
%
% ToDo:
% - Split the original THT script into subfunctions 'corresponding' to the
% StimOMatic subfunction framework                          - done
%   1. pCtrlTHT_initPlugin              - done
%   2. pCtrlTHT_GUI                     - done
%   3. pCtrlTHT_initGUI                 - done
%   4. pCtrlTHT_initWorker              - done
%   5. pCtrlTHT_processData             - done
%   6. pCtrlTHT_prepareGUItransfer      - done
%   7. pCtrlTHT_updateGUI               
%       > 2d plots                      - done
%       > 3d plot                       - done
%
% - Adapt previously existing StimOMatic functions
%   - Implement proper usage of handles into pCtrlTHT_GUI   - done
%   - Make StimOMatic aware of the pCtrlTHT plugin          
%       > Modified definePluginList.m                       - done
%   - Make StimOMatic aware of the VT data streams          
%       > Modified NetCom_initConn.m                        - done
%   - Make StimOMatic workers subscribe to the VTs
%       > initializeParallelProcessing.m                    - done
%       > dristributeChannels_toWorkers.m                   - done
%   - Make the StimOMatic workers process the VT data
%       > pollDataParallel.m
%           > pollDataParallel_spmd_main.m                  - done
%           > pollDataParallel_processNewDataBlock.m        - done
%       > NetCom_pollVT.m                                   - done
%   - Make StimOmatic work without active CSCs
%       > StimOMatic.m                                      - done
%       > initializeParallelProcessing.m                    - done
%   - Close the loop using the tcp-shared variable
%       > call to setup_mmap_infrastructure.m <- Required?
%       > tcpClientMat                                      - done
%           > parallel streams or other option to combine streams?
%           > Creating two shared variables
%   - Resolve issues with remaining plugins.
%       > Other plugins should ignore VT streams
%       > Maybe add datatype field in definePluginList {'CSC','VT'}
%   - Implement PTB side functionality
%       > defineSharedVarName(default)
%       > initMemSharedVariable                             - done
%           > memFileHandle.Data =  100 point vector on StimPC
%       > checkIfStopped_conditional 
%           < Work out if more complex situations are necessary
%       > Only stimulate if head is in ROIs                 - done 
