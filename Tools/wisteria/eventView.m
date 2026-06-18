function varargout = eventView(varargin)
% EVENTVIEW MATLAB code for eventView.fig
%      EVENTVIEW, by itself, creates a new EVENTVIEW or raises the existing
%      singleton*.
%
%      H = EVENTVIEW returns the handle to a new EVENTVIEW or the handle to
%      the existing singleton*.
%
%      EVENTVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVENTVIEW.M with the given input arguments.
%
%      EVENTVIEW('Property','Value',...) creates a new EVENTVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eventView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eventView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eventView

% Last Modified by GUIDE v2.5 18-Jun-2013 14:17:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eventView_OpeningFcn, ...
                   'gui_OutputFcn',  @eventView_OutputFcn, ...
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


% --- Executes just before eventView is made visible.
function eventView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eventView (see VARARGIN)

% Choose default command line output for eventView
handles.output = hObject;

maxRead = 500;

wisteria_input = find(strcmp(varargin, 'wisteria'));
if (isempty(wisteria_input) ...
    || (length(varargin) <= wisteria_input) ...
    || (~ishandle(varargin{wisteria_input+1})) ...
    || nargin < wisteria_input+2)
    dontOpen = true;
    return;
else
    % Remember the handle, and adjust our position
    handles.wisteria = varargin{wisteria_input+1};
    % Obtain handles using GUIDATA with the caller's handle 
    handles.chanIndex = varargin{wisteria_input+2};
    main_handles = guidata(handles.wisteria);
end
set(handles.tblEventData, 'Data', {});
% 
set(main_handles.figure1, 'pointer', 'watch');
drawnow;
entityID = main_handles.channels(handles.chanIndex).entityID;
[rc, info] = ns_GetEntityInfo(main_handles.hFile, entityID);
xlimits = get(main_handles.drawnChannels(1).ax, 'xlim');

[~, startIndex] = ns_GetIndexByTime(main_handles.hFile, entityID, ...
    xlimits(1), 0);
[~, endIndex] = ns_GetIndexByTime(main_handles.hFile, entityID, ...
  xlimits(2), 0);
cellSize = min(maxRead, endIndex-startIndex+1);
data = cell(cellSize, 4);
nData = 1;
for index=startIndex:endIndex
  if nData > maxRead
    warning('eventView: Reached max number of events read (%d)', maxRead)
    break
  end
  [rc, ts, eventData, dataSize] = ns_GetEventData(main_handles.hFile, entityID, ...
    index);
  if ts < xlimits(1) || ts > xlimits(2) 
      continue;
  end
  data{nData, 1} = sprintf('%d', index);
  data{nData, 2} = sprintf('%4.2f', ts * 1000);
  data{nData, 3} = sprintf('%d', uint32(ts * 30000));
  data{nData, 4} = sprintf('%d', eventData);
  data{nData, 5} = sprintf('0x%x', eventData);
  
  nData = nData + 1;
end
set(handles.tblEventData, 'Data', data);

set(main_handles.figure1, 'pointer', 'arrow');
drawnow;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eventView wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eventView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
