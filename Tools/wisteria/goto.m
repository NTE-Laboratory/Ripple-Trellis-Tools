function varargout = goto(varargin)
% GOTO MATLAB code for goto.fig
%      GOTO, by itself, creates a new GOTO or raises the existing
%      singleton*.
%
%      H = GOTO returns the handle to a new GOTO or the handle to
%      the existing singleton*.
%
%      GOTO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GOTO.M with the given input arguments.
%
%      GOTO('Property','Value',...) creates a new GOTO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before goto_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to goto_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help goto

% Last Modified by GUIDE v2.5 08-Jul-2013 16:15:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @goto_OpeningFcn, ...
                   'gui_OutputFcn',  @goto_OutputFcn, ...
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


% --- Executes just before goto is made visible.
function goto_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to goto (see VARARGIN)

% Choose default command line output for goto
handles.output = hObject;

wisteria_input = find(strcmp(varargin, 'wisteria'));

if (isempty(wisteria_input) ...
    || (length(varargin) <= wisteria_input) ...
    || (~ishandle(varargin{wisteria_input+1})))
    dontOpen = true;
    return;
else
    % Remember the handle, and adjust our position
    handles.wisteria = varargin{wisteria_input+1};
    % Obtain handles using GUIDATA with the caller's handle 
    main_handles = guidata(handles.wisteria);
end

set(handles.edtStartTime, 'String', ...
  sprintf('%4.2f', get(main_handles.sldTimeAxis, 'value')));
set(handles.edtLength, 'String', ...
  sprintf('%4.2f', main_handles.fileInfo.TimeSpan));
set(handles.edtDuration, 'String', sprintf('%4.2f', main_handles.range));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes goto wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = goto_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function edtStartTime_Callback(hObject, eventdata, handles)
% hObject    handle to edtStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main_handles = guidata(handles.wisteria);

startTime = str2double(get(hObject, 'String'));
if startTime ~= startTime
  startTime = get(main_handles.sldTimeAxis, 'Value');
elseif startTime < 0
  startTime = 0;
elseif startTime > main_handles.fileInfo.TimeSpan
  startTime = main_handles.fileInfo.TimeSpan;
end
set(handles.edtStartTime, 'string', sprintf('%4.2f', startTime));
    
guidata(hObject, handles);
  

% --- Executes during object creation, after setting all properties.
function edtStartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edtDuration_Callback(hObject, eventdata, handles)
% hObject    handle to edtDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main_handles = guidata(handles.wisteria);

durTime = str2double(get(hObject, 'String'));
startTime = str2double(get(handles.edtStartTime, 'String'));

if durTime ~= durTime
  durTime = main_handles.range;
elseif durTime < 0
  durTime = 0;
elseif durTime > main_handles.maxDisplayTime
  durTime = main_handles.maxDisplayTime;
end
endTime = startTime + durTime;
if endTime > main_handles.fileInfo.TimeSpan
  endTime = main_handles.fileInfo.TimeSpan;
end
durTime = endTime - startTime;

set(hObject, 'string', sprintf('%4.3f', durTime));
    
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edtDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnGo.
function btnGo_Callback(hObject, eventdata, handles)
% hObject    handle to btnGo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startTime = str2double(get(handles.edtStartTime, 'string'));
duration = str2double(get(handles.edtDuration, 'string'));
main_handles = guidata(handles.wisteria);
if duration + startTime > main_handles.fileInfo.TimeSpan
    duration = main_handles.fileInfo.TimeSpan - startTime;
end
wisteria('gotocall', startTime, duration);



function edtLength_Callback(hObject, eventdata, handles)
% hObject    handle to edtLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtLength as text
%        str2double(get(hObject,'String')) returns contents of edtLength as a double


% --- Executes during object creation, after setting all properties.
function edtLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
