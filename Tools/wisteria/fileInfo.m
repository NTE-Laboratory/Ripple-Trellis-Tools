function varargout = fileInfo(varargin)
% FILEINFO MATLAB code for fileInfo.fig
%      FILEINFO, by itself, creates a new FILEINFO or raises the existing
%      singleton*.
%
%      H = FILEINFO returns the handle to a new FILEINFO or the handle to
%      the existing singleton*.
%
%      FILEINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILEINFO.M with the given input arguments.
%
%      FILEINFO('Property','Value',...) creates a new FILEINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fileInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fileInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fileInfo

% Last Modified by GUIDE v2.5 17-Jun-2013 12:40:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fileInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @fileInfo_OutputFcn, ...
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


% --- Executes just before fileInfo is made visible.
function fileInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fileInfo (see VARARGIN)

% Choose default command line output for fileInfo
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
% sum the file sizes of all nev, ns? files.  Put this in Mbytes.
totalFileSize = sum([main_handles.hFile.FileInfo.FileSize]) / 2^20;
% Load all info fields
set(handles.edtFileName, 'String', sprintf('%s', main_handles.hFile.Name));
set(handles.edtFilePath, 'String', sprintf('%s', main_handles.hFile.FilePath));
set(handles.edtAppName, 'String', sprintf('%s', main_handles.fileInfo.AppName));
set(handles.edtNChannels, 'String', sprintf('%d', length(main_handles.channels)));
set(handles.edtDataSize, 'String', sprintf('%4.2f', totalFileSize));
set(handles.edtTimeSpan, 'String', ...
  sprintf('%4.2f', main_handles.fileInfo.TimeSpan));
labels = {main_handles.channels(:).label};
nSpike = length(find(strcmp(labels, 'spike')));
nStim = length(find(strcmp(labels, 'spike')));
nLFP = length(find(strcmp(labels, 'lfp')));
nRaw = length(find(strcmp(labels, 'raw')));
set(handles.edtNSpike, 'String', sprintf('%d', nSpike));
set(handles.edtNStim, 'String', sprintf('%d', nStim));
set(handles.edtNRaw, 'String', sprintf('%d', nRaw));
set(handles.edtNLFP, 'String', sprintf('%d', nLFP));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fileInfo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fileInfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edtFileName_Callback(hObject, eventdata, handles)
% hObject    handle to edtFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtFileName as text
%        str2double(get(hObject,'String')) returns contents of edtFileName as a double


% --- Executes during object creation, after setting all properties.
function edtFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to edtFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtFilePath as text
%        str2double(get(hObject,'String')) returns contents of edtFilePath as a double


% --- Executes during object creation, after setting all properties.
function edtFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtNChannels_Callback(hObject, eventdata, handles)
% hObject    handle to edtNChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNChannels as text
%        str2double(get(hObject,'String')) returns contents of edtNChannels as a double


% --- Executes during object creation, after setting all properties.
function edtNChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtDataSize_Callback(hObject, eventdata, handles)
% hObject    handle to edtDataSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtDataSize as text
%        str2double(get(hObject,'String')) returns contents of edtDataSize as a double


% --- Executes during object creation, after setting all properties.
function edtDataSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtDataSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtTimeSpan_Callback(hObject, eventdata, handles)
% hObject    handle to edtTimeSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtTimeSpan as text
%        str2double(get(hObject,'String')) returns contents of edtTimeSpan as a double


% --- Executes during object creation, after setting all properties.
function edtTimeSpan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtTimeSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtNLFP_Callback(hObject, eventdata, handles)
% hObject    handle to edtNLFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNLFP as text
%        str2double(get(hObject,'String')) returns contents of edtNLFP as a double


% --- Executes during object creation, after setting all properties.
function edtNLFP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNLFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtNRaw_Callback(hObject, eventdata, handles)
% hObject    handle to edtNRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNRaw as text
%        str2double(get(hObject,'String')) returns contents of edtNRaw as a double


% --- Executes during object creation, after setting all properties.
function edtNRaw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtNSpike_Callback(hObject, eventdata, handles)
% hObject    handle to edtNSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNSpike as text
%        str2double(get(hObject,'String')) returns contents of edtNSpike as a double


% --- Executes during object creation, after setting all properties.
function edtNSpike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtNStim_Callback(hObject, eventdata, handles)
% hObject    handle to edtNStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNStim as text
%        str2double(get(hObject,'String')) returns contents of edtNStim as a double


% --- Executes during object creation, after setting all properties.
function edtNStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtAppName_Callback(hObject, eventdata, handles)
% hObject    handle to edtAppName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtAppName as text
%        str2double(get(hObject,'String')) returns contents of edtAppName as a double


% --- Executes during object creation, after setting all properties.
function edtAppName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtAppName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
