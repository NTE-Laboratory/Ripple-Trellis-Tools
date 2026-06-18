function varargout = spikeView(varargin)
% SPIKEVIEW MATLAB code for spikeView.fig
%      SPIKEVIEW, by itself, creates a new SPIKEVIEW or raises the existing
%      singleton*.
%
%      H = SPIKEVIEW returns the handle to a new SPIKEVIEW or the handle to
%      the existing singleton*.
%
%      SPIKEVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKEVIEW.M with the given input arguments.
%
%      SPIKEVIEW('Property','Value',...) creates a new SPIKEVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spikeView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spikeView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spikeView

% Last Modified by GUIDE v2.5 17-Jun-2013 13:39:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spikeView_OpeningFcn, ...
                   'gui_OutputFcn',  @spikeView_OutputFcn, ...
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


% --- Executes just before spikeView is made visible.
function spikeView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spikeView (see VARARGIN)

% Choose default command line output for spikeView
handles.output = hObject;

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

set(main_handles.figure1, 'pointer', 'watch');
drawnow;
entityID = main_handles.channels(handles.chanIndex).entityID;
% [ELB-2014/02/19] info does not seem to be used.  Get ride of this?
% [rc, info] = ns_GetEntityInfo(main_handles.hFile, entityID);
xlimits = get(main_handles.drawnChannels(1).ax, 'xlim');

[~, startIndex] = ns_GetIndexByTime(main_handles.hFile, entityID, xlimits(1), 0);
[~, endIndex] = ns_GetIndexByTime(main_handles.hFile, entityID, ...
  xlimits(2), 0);
cla(handles.axeSpike);

hold on;
nSpikes = 0;
for index=startIndex:endIndex
  if nSpikes > 500
    warning('spikeView: Reached max spikes');
    break;
  end
  [rc, ts, wf, count, unit] = ns_GetSegmentData(main_handles.hFile, entityID, ...
    index);
  if index == startIndex
    t = (1:double(count)) / 30;
  end
  if ts < xlimits(1) || ts > xlimits(2)
    continue;
  end
  % putting this in mV mostly because I can't Matlab to realibly produce a
  % \mu and can't deal with using a 'u' for a '\mu'.  If YOU can get Matlab
  % to produce greek letters on all systems, by all means change this.
  plot(handles.axeSpike, t, wf * 1.0e-3);
  nSpikes = nSpikes + 1;
end
hold off;
set(handles.axeSpike, 'XLim', [min(t) max(t)]);

% This produces an actual \mu on some systems, but not all.  I suppose mV
% will have to work.
% set(get(handles.axeSpike, 'XLabel'), 'String', '[$$\muV$$]', 'Interpreter', 'latex');
ylabel(handles.axeSpike, '[mV]');
xlabel(handles.axeSpike, '[ms]');
title(handles.axeSpike, sprintf('channel: %d, %d spikes', ...
  main_handles.channels(handles.chanIndex).elec, nSpikes));
set(main_handles.figure1, 'pointer', 'arrow');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spikeView wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spikeView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
