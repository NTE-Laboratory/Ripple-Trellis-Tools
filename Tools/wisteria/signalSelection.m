function varargout = signalSelection(varargin)
% SIGNALSELECTION MATLAB code for signalSelection.fig
%      SIGNALSELECTION, by itself, creates a new SIGNALSELECTION or raises the existing
%      singleton*.
%
%      H = SIGNALSELECTION returns the handle to a new SIGNALSELECTION or the handle to
%      the existing singleton*.
%
%      SIGNALSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIGNALSELECTION.M with the given input arguments.
%
%      SIGNALSELECTION('Property','Value',...) creates a new SIGNALSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before signalSelection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to signalSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help signalSelection

% Last Modified by GUIDE v2.5 19-Feb-2014 18:00:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @signalSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @signalSelection_OutputFcn, ...
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


% --- Executes just before signalSelection is made visible.
function signalSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to signalSelection (see VARARGIN)

% Choose default command line output for signalSelection
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

nChannels = length(main_handles.channels);
spikeLabels = {};
stimLabels = {};
lfpLabels = {};
rawLabels = {};
hiresLabels = {};
rawSelected = zeros(nChannels, 1);
for i=1:nChannels
  chan = main_handles.channels(i);
  if chan.type == main_handles.nsTypes.SEGMENT_TYPE
    if chan.elec < 5120
      spikeLabels = [spikeLabels sprintf('%03d', chan.elec)];
    else
      stimLabels = [stimLabels sprintf('%03d', chan.elec - 5120)];
    end
  elseif chan.type == main_handles.nsTypes.ANALOG_TYPE
    if chan.sampleRate == 30000
      rawLabels = [rawLabels sprintf('%03d', chan.elec)];
      rawSelected(i) = i;
    elseif chan.sampleRate == 2000
      hiresLabels = [hiresLabels sprintf('%03d', chan.elec)];
    else
      lfpLabels = [lfpLabels sprintf('%03d', chan.elec)];
    end
  end
end
stimNodes = main_handles.channels([main_handles.channels(:).type] == ...
  main_handles.nsTypes.SEGMENT_TYPE & [main_handles.channels(:).elec] > 5120);
spikeNodes = main_handles.channels([main_handles.channels(:).type] == ...
  main_handles.nsTypes.SEGMENT_TYPE & [main_handles.channels(:).elec] < 5120);
stimSelected = find([stimNodes(:).selected] == 1);
spikeSelected = find([spikeNodes(:).selected] == 1);
lfpNodes = main_handles.channels([main_handles.channels(:).sampleRate] == 1000);
lfpSelected = find([lfpNodes(:).selected] == 1);
rawNodes = main_handles.channels([main_handles.channels(:).sampleRate] == 30000);
rawSelected = find([rawNodes(:).selected] == 1);
hiresNodes = main_handles.channels([main_handles.channels(:).sampleRate] == 2000);
hiresSelected = find([hiresNodes(:).selected] == 1);

set(handles.lstSpike, 'String', spikeLabels);
set(handles.lstSpike, 'Value', spikeSelected);
set(handles.lstSpike, 'ListBoxTop', 1);
set(handles.lstStim, 'String', stimLabels);
set(handles.lstStim, 'Value', stimSelected);
set(handles.lstStim, 'ListBoxTop', 1);
set(handles.lstRaw, 'String', rawLabels);
set(handles.lstRaw, 'Value', rawSelected);
set(handles.lstRaw, 'ListBoxTop', 1);
set(handles.lstLFP, 'String', lfpLabels);
set(handles.lstLFP, 'Value', lfpSelected);
set(handles.lstLFP, 'ListBoxTop', 1);
set(handles.lstHires, 'String', hiresLabels);
set(handles.lstHires, 'Value', hiresSelected);
set(handles.lstHires, 'ListBoxTop', 1);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = signalSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnUpdate.
function btnUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to btnUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signals = [];
rawString = get(handles.lstRaw, 'String');
lfpString = get(handles.lstLFP, 'String');
stimString = get(handles.lstStim, 'String');
spikeString = get(handles.lstSpike, 'String');
hiresString = get(handles.lstHires, 'String');

if isempty(rawString)
  signals.raw = [];
else
  signals.raw = str2double(rawString(get(handles.lstRaw, 'Value')));
end
if isempty(lfpString)
  signals.lfp = [];
else
  signals.lfp = str2double(lfpString(get(handles.lstLFP, 'Value')));
end
if isempty(stimString)
  signals.stim = [];
else
  signals.stim = str2double(stimString(get(handles.lstStim, 'Value')));
end
if isempty(spikeString)
  signals.spike = [];
else
  signals.spike = str2double(spikeString(get(handles.lstSpike, 'Value')));
end
if isempty(hiresString)
  signals.hires = [];
else
  signals.hires = str2double(hiresString(get(handles.lstHires, 'Value')));
end
wisteria('signal', signals);

% --- Executes on button press in btnClear.
function btnClear_Callback(hObject, eventdata, handles)
% clears all signal lists

% simply set all 'Value's to empty.
set(handles.lstSpike, 'Value', []);
set(handles.lstStim, 'Value', []);
set(handles.lstLFP, 'Value', []);
set(handles.lstRaw, 'Value', []);
set(handles.lstHires, 'Value', []);

% --- Executes on button press in btnClose.
function btnClose_Callback(hObject, eventdata, handles)
% hObject    handle to btnClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes on selection change in lstSpike.
function lstSpike_Callback(hObject, eventdata, handles)
% hObject    handle to lstSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstSpike contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstSpike


% --- Executes during object creation, after setting all properties.
function lstSpike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lstStim.
function lstStim_Callback(hObject, eventdata, handles)
% hObject    handle to lstStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstStim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstStim


% --- Executes during object creation, after setting all properties.
function lstStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lstLFP.
function lstLFP_Callback(hObject, eventdata, handles)
% hObject    handle to lstLFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstLFP contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstLFP


% --- Executes during object creation, after setting all properties.
function lstLFP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstLFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lstRaw.
function lstRaw_Callback(hObject, eventdata, handles)
% hObject    handle to lstRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstRaw contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstRaw


% --- Executes during object creation, after setting all properties.
function lstRaw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lstHires.
function lstHires_Callback(hObject, eventdata, handles)
% hObject    handle to lstHires (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstHires contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstHires


% --- Executes during object creation, after setting all properties.
function lstHires_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstHires (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
