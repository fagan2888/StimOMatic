function varargout = pCtrlTHT_GUI(varargin)
% pCtrlTHT_GUI MATLAB code for pCtrlTHT_GUI.fig
%      pCtrlTHT_GUI, by itself, creates a new pCtrlTHT_GUI or raises the existing
%      singleton*.
%
%      H = pCtrlTHT_GUI returns the handle to a new pCtrlTHT_GUI or the handle to
%      the existing singleton*.
%
%      pCtrlTHT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in pCtrlTHT_GUI.M with the given input arguments.
%
%      pCtrlTHT_GUI('Property','Value',...) creates a new pCtrlTHT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pCtrlTHT_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pCtrlTHT_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% --------------------
% WRITE DOCUMENTATION FOR THE TURTLE HEAD TRACKER SOFTWARE DESCRIBING
% FEATURES AND REQUIREMENTS.
%
% Implemented features:
%   1. Connect to cheetah (either directly or via NLXRouter)  - done
%   2. Subscribe to both video tracker streams                - done
%   3. Constant while loop using timer object                 - done
%   4. Check fiducial position on VT1 and VT2                 - done
%       - Define VT1 as azimuth and VT2 as elevation          - done
%   5. Send event
%       5.a Initially send event to cheetah                   - done
%   6. Disconnect properly                                    - done
%   7. Graphical user interface with fields                   - done
%   8. Dynamic plotting of the position information           - done
%   9. Plotting of ROI and VOI in 2d and 3d                   - done
%
% Features to be implemented:
%   - Adapt for usage as StimOMatic plugin
% --------------------

% Edit the above text to modify the response to help pCtrlTHT_GUI

% Last Modified by GUIDE v2.5 25-Apr-2013 14:37:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pCtrlTHT_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @pCtrlTHT_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before pCtrlTHT_GUI is made visible.
function pCtrlTHT_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pCtrlTHT_GUI (see VARARGIN)

% Choose default command line output for pCtrlTHT_GUI
handles.output = hObject;

%On startup initialize ROIdefined field and set it to 0
% handles.ROIdefined = 0;

% Create timer object here which works as pacemaker of the tracker
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', 0.020, ...                     % Initial period
    'TimerFcn', {@update_THTdisplay, handles}); % Specify callback function

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pCtrlTHT_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = pCtrlTHT_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Update the timer handles
guidata(hObject, handles);

function inputfieldROIy_Callback(hObject, eventdata, handles)
% hObject    handle to inputfieldROIy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputfieldROIy as text
%        str2double(get(hObject,'String')) returns contents of inputfieldROIy as a double

% --- Executes during object creation, after setting all properties.
function inputfieldROIy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputfieldROIy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function inputfieldROIz_Callback(hObject, eventdata, handles)
% hObject    handle to inputfieldROIz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputfieldROIz as text
%        str2double(get(hObject,'String')) returns contents of inputfieldROIz as a double

% --- Executes during object creation, after setting all properties.
function inputfieldROIz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputfieldROIz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function inputfieldROIx_Callback(hObject, eventdata, handles)
% hObject    handle to inputfieldROIx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputfieldROIx as text
%        str2double(get(hObject,'String')) returns contents of inputfieldROIx as a double

% --- Executes during object creation, after setting all properties.
function inputfieldROIx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputfieldROIx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupVTStreams1.
function popupVTStreams1_Callback(hObject, eventdata, handles)
% hObject    handle to popupVTStreams1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupVTStreams1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupVTStreams1


% --- Executes during object creation, after setting all properties.
function popupVTStreams1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupVTStreams1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupVTStreams2.
function popupVTStreams2_Callback(hObject, eventdata, handles)
% hObject    handle to popupVTStreams2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupVTStreams2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupVTStreams2


% --- Executes during object creation, after setting all properties.
function popupVTStreams2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupVTStreams2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonUpdateVTs.
function pushbuttonUpdateVTs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUpdateVTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get app data from parents
appDataParent = getappdata(handles.parentFigHandle);

% Populate info into VT selection popups
set([handles.popupVTStreams1, handles.popupVTStreams2] ,  'String', {'none',appDataParent.UsedByGUIData_m.StimOMaticConstants.VTStreams{:}} );
