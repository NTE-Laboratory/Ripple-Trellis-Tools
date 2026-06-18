function varargout = wisteria(varargin)
% WISTERIA MATLAB code for wisteria.fig
%      WISTERIA, by itself, creates a new WISTERIA or raises the existing
%      singleton*.
%
%      H = WISTERIA returns the handle to a new WISTERIA or the handle to
%      the existing singleton*.
%
%      WISTERIA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WISTERIA.M with the given input arguments.
%
%      WISTERIA('Property','Value',...) creates a new WISTERIA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wisteria_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wisteria_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wisteria

% Last Modified by GUIDE v2.5 20-Feb-2014 15:26:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wisteria_OpeningFcn, ...
                   'gui_OutputFcn',  @wisteria_OutputFcn, ...
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


% --- Executes just before wisteria is made visible.
function wisteria_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for wisteria
handles.output = hObject;
% in the case that wisteria is called from signal selection dialog or
% goto dialog.  In this case we don't want to re-initialize all the
% handle variables.
if isfield(handles, 'isopen')
  % Handle input from the goto dialog
  if find(strcmp(varargin, 'gotocall'), 1) 
    if nargin < 3
       error('invalid goto update');
    end
    handles = guidata(handles.figure1);
    % retrieve start time and duration
    startTime = varargin{2};
    duration = varargin{3};
    % pack the variables in the handles
    handles.range = duration;
    guidata(handles.figure1, handles);
    % update axes and time slider.
    updateAxes([startTime startTime+duration], handles.figure1);
    updateTimeAxisSlider(handles, startTime);
    updateRect(handles);
  % Handle inputs from the signal selection dialog
  elseif find(strcmp(varargin, 'signal'), 1)
    % ensure that we have the needed data from the signal dialog
    if nargin < 2 || ~isstruct(varargin{2})
      error('invalid signal update');
    else
      % Get the signals struct.  For more details see signalSelection.m
      signals = varargin{2};
      for i=1:length(handles.channels)
        % go through each field in the signals struct and set the
        % corresponding channels.selected field (0, or 1).
        if strcmp(handles.channels(i).label, 'raw')
          if find(handles.channels(i).elec == signals.raw, 1)
            handles.channels(i).selected = 1;
          else
            handles.channels(i).selected = 0;
          end
        elseif strcmp(handles.channels(i).label, 'lfp')
          if find(handles.channels(i).elec == signals.lfp, 1)
            handles.channels(i).selected = 1;
          else
            handles.channels(i).selected = 0;
          end
        elseif strcmp(handles.channels(i).label, 'spike')
          if find(handles.channels(i).elec == signals.spike, 1)
            handles.channels(i).selected = 1;
          else
            handles.channels(i).selected = 0;
          end         
        elseif strcmp(handles.channels(i).label, 'stim')
          if find((handles.channels(i).elec - 5120) == signals.stim, 1)
            handles.channels(i).selected = 1;
          else
            handles.channels(i).selected = 0;
          end   
        elseif strcmp(handles.channels(i).label, 'hires')
          if find(handles.channels(i).elec == signals.hires, 1)
            handles.channels(i).selected = 1;
          else
            handles.channels(i).selected = 0;
          end
        end          
      end
      % update gui data and redraw
      guidata(hObject, handles);
      updateSlider(handles);
      % Since we've changed all the selected streams just scroll up to the
      % top of the plot.
      set(handles.sldAxes, 'value', get(handles.sldAxes, 'max'));
      updatePlots(handles.figure1);
      handles = guidata(handles.figure1);
      updateAxes([0, handles.range], handles.figure1);
      return;
    end
  end
else
  handles.fail = 0; % space to record whether we have opened successfully
  handles.lastOpenDir = []; % remember the last opened directory
  handles.PIXELS_PER_CHAN = 30; % depreacated
  % Initialize default parameters.  
  % TODO: allow these to be put in a file for user customizable default options.
  % Default amount in pixels to grow or shrink axes.
  handles.axesGrowIncrement = 10;
  % [min, default, max] pixel ranges for continuous channels
  handles.contPixelRange = [20 40 1000];
  % [min, default, max] pixel ranges for spike channels
  handles.spikePixelRange = [20 20 40];
  % max time range to plot
  handles.maxDisplayTime = 120;
  % A event loop is used to handle resize events.  This parameter
  % determines the rate of checks for resize events in seconds.
  handles.resizeCheckTime = 1.0; % seconds
  % time of last resize event.  Using by resize event loop.
  handles.lastResizeEvent = [];
  % save current figure position for resizing checks
  handles.figPosition = getpixelposition(handles.figure1);
  % timer handle for resize events.  For more details see the callback
  % ReszeTime_CallbackFcn
  handles.redrawTimer = timer('period', 0.5, ...
    'timerfcn', @(j,k)ResizeTimer_CallBackFcn(handles.figure1, eventdata, handles), ...
    'executionmode', 'fixedSpacing', 'BusyMode', 'drop');
  % set(handles.figure1, 'Interruptible', 'off');
  % set(handles.figure1, 'BusyAction', 'cancel');
    
  % Neuroshare constants used in this source.  
  handles.nsTypes = [];
  handles.nsTypes.ANALOG_TYPE = 2;
  handles.nsTypes.SEGMENT_TYPE = 3;
  handles.nsTypes.EVENT_TYPE = 1;
  % debug field for to determine whether to display debugging statements.
  % handles.debug = 1;
  handles.debug = 0;
  % List of sub-dialogs so that they may be closed if the main window is
  % closed.
  handles.dialogs = [];
  % Record the default positions for the basic UI components so that we may
  % more reasonably handle resize events.  These are using in the resize
  % callback.  This is painful, but the Matlab generally handles resizing
  % is terrible
  handles.uicomp = [];
  set(handles.sldAxes, 'units', 'pixels');
  set(handles.sldTimeAxis, 'units', 'pixels');
  handles.uicomp.axesSliderPos = get(handles.sldAxes, 'position');
  handles.uicomp.timeSliderPos = get(handles.sldTimeAxis, 'position');
  % TODO: Is this still used?
  sliderPosPixels = getpixelposition(handles.sldAxes);
  handles.uicomp.sliderWidthPixels = sliderPosPixels(3);
  % set all units to normalized.
  set(findall(handles.figure1, 'type', 'uipanel'), 'units', 'normalized');
  set(findall(handles.figure1, 'type', 'uicontrol'), 'units', 'normalized');
  % Are this still used?
  handles.margins = [];
  handles.margins.bottom = 90; % currently, pixels but should be in characters
  handles.margins.top = 10;
  handles.margins.left = 20;
  handles.margins.right = 10;
  % Setup zoom handles so that we may make use of the Matlab figure zoom and
  % panning functions.
  handles.zoom = zoom(handles.figure1);
  handles.pan = pan(handles.figure1);
  set(handles.zoom, 'ActionPostCallback', @zoomCallback);
  set(handles.pan, 'ActionPostCallback', @zoomCallback);
  % Color map will be useful if displaying spike rates with a single
  % dimension.  This is not really useful currently.
  colormap(flipud(gray));
  % Initialize handles to empty.
  handles.hFile = []; % holds neuroshare data
  handles.drawnChannels = []; % holds info about drawn axes
  handles.channels = []; % holds useful data by entity
  % set handle so that we know that this wisteria has been opened
  handles.isopen = 1;
  
  handles.updatePlotsMutex = 0;
  
  % Update handles structure
  guidata(hObject, handles);
  % Check that neuroshare libraries are in the current path
  if ~exist('ns_CloseFile.m', 'file')
    tryDir = strcat(fileparts(which('wisteria')), '\..\neuroshare\');
    if exist(strcat(tryDir, 'ns_CloseFile.m'), 'file')
      warning('neuroshare sources not in path. Found them in %s.  Adding to path.', tryDir);
      addpath(tryDir);
    else
      str = 'Cannot find neuroshare sources.  Add them to MATLAB path before using Wisteria.  ';
      str = strcat(str, 'The neuroshare sources should be found in <Trellis_Install_Dir>/Tools directory');
      uiwait(msgbox(str, 'Neuroshare Error', 'error'));
      % set fail to 1 in this case. The actual exitting takes place in
      % wisteria_OutputFcn
      handles.fail = 1;
    end
  end
end

guidata(hObject, handles);

      
% --- Outputs from this function are returned to the command line.
function varargout = wisteria_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

guidata(hObject, handles);
% this is seemingly the earliest place on the call stack that I can put
% this function without causeing an error.
if handles.fail
  figure1_CloseRequestFcn(hObject, eventdata, handles);
end


% --------------------------------------------------------------------
function ResizeTimer_CallBackFcn(hObject, evt, handles)

handles = guidata(handles.figure1);
% if this is still on the stack, bail
if isMultipleCall; return; end;

% ensure that wisteria has ever been resized and that we have drawn
% something.
% Note: Matlab GUI always call 'ResizeFcn' on initialization.
if isempty(handles.lastResizeEvent) || isempty(handles.drawnChannels)
    return;
end
% if a resize event has occured in the last second redraw axes
if etime(clock, handles.lastResizeEvent) < 1.0
   % This may not be a good idea, but I don't want the timer to stop
   % working.  Perhaps I have some kind of retry?
   try
      update(handles.figure1);
   end
end

% guidata(handles.figure1, handles);


% --------------------------------------------------------------------
function mnuFile_Callback(hObject, eventdata, handles)
% hObject    handle to mnuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuOpen_Callback(hObject, eventdata, handles)
% Call when open is selected from menu.  Opens new file.
lastOpenDir = [];
if ~isempty(handles.hFile)
  lastOpenDir = handles.hFile.FilePath;
  try
    ns_CloseFile(handles.hFile);
  end
  handles.hFile = [];
  stop(handles.redrawTimer);
end
if ~isempty(lastOpenDir)
  backDir = pwd;
  cd(lastOpenDir);
end
[rc, handles.hFile] = ns_OpenFile;
if ~isempty(lastOpenDir)
  cd(backDir);
end
if ~strcmp(rc, 'ns_OK')
  % TODO: handle this failure properly...
end
guidata(hObject, handles);
% Load Neuroshare data
importNevFile(handles);
% start resize timer
start(handles.redrawTimer)


% --------------------------------------------------------------------
function importNevFile(handles)
% IMPORTNEVFILE extract general data from opened NEV files.
% This function finds all the recorded streams in the nev file and sets up 
% the channels struct.

% close and delete drawn axes if there are any.  With luck try / catch will
% allow us to recover if somehow these axes have been deleted.
try
    if ~isempty(handles.drawnChannels)
        delete([handles.drawnChannels(:).ax]);
    end
catch
  warning('updatePlots: objects for delete are invalid');
end
% reset drawnChannels to NULL
handles.drawnChannels = [];
% To start use maxDisplayTime as the default time
handles.range = handles.maxDisplayTime;
% Grab the file info struct and store it in the handles.
[rc, handles.fileInfo] = ns_GetFileInfo(handles.hFile);
% find all the channels and store the data in the in a struct.  The struct
% will consist of entityID, itemCount, elec (electrode ID), cacheFile,
% type (stream type).
handles.channels = [];
entityCount = 0;
for entityID=1:length(handles.hFile.Entity(:))
  % EntityInfo and AnalogInfo structures are used to retrieve some
  % important pieces of informationt, namely, SampleRate and ItemCounts.
  [rc, entityInfo] = ns_GetEntityInfo(handles.hFile, entityID);
  % Skip any non neural data.  
  % TODO: Add digital events in here.
  if entityInfo.EntityType ~= handles.nsTypes.ANALOG_TYPE && ...
      entityInfo.EntityType ~= handles.nsTypes.SEGMENT_TYPE && ...
      entityInfo.EntityType ~= handles.nsTypes.EVENT_TYPE
    continue;
  end
  entityCount = entityCount + 1;
  % a selected field will allow for vectorized searches to find selected
  % streams.  Start will all selected.  
  handles.channels(entityCount).selected = 1;
  handles.channels(entityCount).selectedForMod = 0;
  % In this case, entityID is simply the index.  Perhaps this isn't needed,
  % but it will stay for now.
  handles.channels(entityCount).entityID = entityID;
  % item count will be an important quantity for binning data
  handles.channels(entityCount).itemCount = entityInfo.ItemCount;
  % store electrode IDs
  elec = handles.hFile.Entity(entityCount).ElectrodeID;
  handles.channels(entityCount).elec = elec;
  % place to set time, x-axis range
  handles.channels(entityCount).range = [];
  % place to set y limits
  handles.channels(entityCount).ylim = [];
  % store the entity type as an integer so that we may easily search and
  % sort by entity type
  handles.channels(entityCount).type = entityInfo.EntityType;
  % For continuous channels, the sample rate found in ns_AnalogInfo struct
  % will be useful to sort raw from LFP.
  if entityInfo.EntityType == handles.nsTypes.ANALOG_TYPE
    [~, analogInfo] = ns_GetAnalogInfo(handles.hFile, entityID);
    % sample rate will be needed for gettting x-axis right.
    handles.channels(entityCount).sampleRate = analogInfo.SampleRate;
    % Labels will be useful for plotting the data.  These don't really need
    % to be stored here since the sample rate is also stored.
    
    % IJM - Added elec number check to make a distinction between AIO
    % and "analog" data from other FEs
    if handles.channels(entityCount).elec > 10240
        if analogInfo.SampleRate == 30000
          handles.channels(entityCount).label = '30 kS/s';
        else
          handles.channels(entityCount).label = '1 kS/s';
        end
    else
        if analogInfo.SampleRate == 30000
          handles.channels(entityCount).label = 'raw';
        elseif analogInfo.SampleRate == 2000
          handles.channels(entityCount).label = 'hires';
        else
          handles.channels(entityCount).label = 'lfp';
        end
    end
    
    % Keep two fields to decide the range to show for a given plot and how
    % many pixels to use for its axes.
    handles.channels(entityCount).pixels = handles.contPixelRange(2);
    % setup labels for spike and stim channels and set pixel ranges
  elseif entityInfo.EntityType == handles.nsTypes.SEGMENT_TYPE
    if handles.channels(entityCount).elec > 5120
      handles.channels(entityCount).label = 'stim';
    else
      handles.channels(entityCount).label = 'spike';
    end
    handles.channels(entityCount).sampleRate = 0;
    handles.channels(entityCount).pixels = handles.spikePixelRange(2);
  elseif entityInfo.EntityType == handles.nsTypes.EVENT_TYPE
    handles.channels(entityCount).elec = 0;
    % IJM
%     if strcmp(entityInfo.EntityLabel, 'Digital Input')
%       handles.channels(entityCount).label = 'digin';
%     else
%       handles.channels(entityCount).label = ['sma', entityInfo.EntityLabel(end)];
%     end
    if strcmp(entityInfo.EntityLabel, 'Parallel Input')
        handles.channels(entityCount).label = 'DIGPAR';
    elseif strcmp(entityInfo.EntityLabel, 'SMA 1')
        handles.channels(entityCount).label = 'DIGIN 1';
    elseif strcmp(entityInfo.EntityLabel, 'SMA 2')
        handles.channels(entityCount).label = 'DIGIN 2';
    elseif strcmp(entityInfo.EntityLabel, 'SMA 3')
        handles.channels(entityCount).label = 'DIGIN 3';
    elseif strcmp(entityInfo.EntityLabel, 'SMA 4')
        handles.channels(entityCount).label = 'DIGIN 4';
    else
        handles.channels(entityCount).label = 'DIGOUT';
    end
    handles.channels(entityCount).sampleRate = 0;
    handles.channels(entityCount).pixels = handles.spikePixelRange(2);
  end
end
% setup time axis slider to reflect current recording period
set(handles.sldTimeAxis, 'min', 0);
set(handles.sldTimeAxis, 'max', handles.fileInfo.TimeSpan);
%
handles.range = min(handles.range, handles.fileInfo.TimeSpan);
updateTimeAxisSlider(handles, 0);
% setup the up/down slider to account for the number of plots.
updateSlider(handles);
guidata(handles.figure1, handles);
% draw axes.
updatePlots(handles.figure1);
% Because these worker function make modifications to handles, we must
% update handles to the modified version.  Hopefully, guidata should be called 
% in all the worker functions.
handles = guidata(handles.figure1);
% retrieve and plot data.
updateAxes([0, handles.range], handles.figure1);
handles = guidata(handles.figure1);

guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function update(hObject)
% this sequence of functions is commonly called in wisteria.  Makes sense
% to put it in a common place.
if isMultipleCall; return; end;

handles = guidata(hObject);

updatePlots(handles.figure1);
sldValue = get(handles.sldTimeAxis, 'value');
updateAxes([sldValue sldValue + handles.range], handles.figure1);

% --------------------------------------------------------------------
function updatePlots(hObject)
% chooses data streams to draw on the current page.
%
% From the selected data streams and where the axesSlider is positioned, choose 
% which plots and how many channels to draw.  Setup all needed axes and create 
% the line or bar instances for each plot.  This function down not retrieve
% data and plot it (only draws the axes).

if isMultipleCall(); return; end;

handles = guidata(hObject);

% get the figure size in pixels so the number of drawn plots can be chosen
% based on pixels.
figPosPixel = getpixelposition(handles.figure1);

selectedIndex = find([handles.channels(:).selected]==1);
selectedChan = handles.channels(selectedIndex);

sliderValue = get(handles.sldAxes, 'value');
% startIndex is simply the slider value, flipped.  This must be done
% because the larger values of the slider point to the upper plot.
if get(handles.sldAxes, 'min') == 0
  startIndex = 1;
  % startIndex = find([handles.channels(:).selected]==1, 1, 'first');
else
  startIndex = get(handles.sldAxes, 'max') - get(handles.sldAxes, 'Value') ...
    + get(handles.sldAxes, 'min');
end
% Find all the plots that we will put in this page.  This must start with
% top plot and include selected plots until we run out of pixels.  Each
% plot may have it's own number of pixels.

% It's possible if the windows are being resized a bunch, then the sldAxes
% is click rapidly that the 'startIndex' (which is read directly from from
% the slider) can be non-integer.
startIndex = floor(startIndex);   

plotsIndex = selectedIndex((startIndex - 1) + find(cumsum([selectedChan(startIndex:end).pixels]) < ...
  figPosPixel(4) - handles.margins.bottom - handles.margins.top));
if isempty(plotsIndex)
  warning('pixels allocated for axes are larger than figure size');
  return;
end
set(handles.figure1, 'units', 'characters');
figurePosChar = get(handles.figure1, 'position');
set(handles.figure1, 'units', 'normalized');
figPosNorm = get(handles.figure1, 'pos');

leftEdge = handles.margins.left / figurePosChar(3);
plotWidth = 1.0 - 5 / figurePosChar(3) - leftEdge;
plotWidth = max(0.1, plotWidth);

if ~isempty(handles.drawnChannels)
    delete([handles.drawnChannels(:).ax]);
    handles.drawnChannels = [];
    guidata(handles.figure1, handles);
end
allEntityIDs = [handles.channels(:).entityID];

bottomEdge = 1.0 - handles.margins.top * figPosNorm(4) / figPosPixel(4);

for index=1:length(handles.channels)
  handles.channels(index).selectedForMod = 0;
end

% This loop essentially creates plotting objects for plotting all the channels on the 
% current page.  This includes axes aranged so that they are very close and
% use a minimal amount of space and graphic elements to plot the actual
% data.  These will be 'line's created with the function 'plot' in the case of continuous 
% data and 'image's created with the function 'imagesc' in the case of spike, stim, or
% digital events
for index=1:length(plotsIndex)
  % In this list, index will index handles.drawnChannels.  chanIndex will
  % index the list selectedChan.  The orginal, handles.channels
  % should not play a role in this list.
  chanIndex = plotsIndex(index);
  % chanIndex = drawnChan(index);
  % This entityID here should be the same as chanIndex
  handles.drawnChannels(index).entityID = handles.channels(chanIndex).entityID;
  % handles.drawnChannels(index).chanIndex = ...
  %   find(allEntityIDs == selectedChan(index).entityID, 1);
  handles.drawnChannels(index).chanIndex = chanIndex;
  plotHeight = handles.channels(chanIndex).pixels / figPosPixel(4);
  bottomEdge = bottomEdge - plotHeight;
  handles.drawnChannels(index).ax = axes('units', 'normalized', ...
    'position', [leftEdge, bottomEdge, plotWidth, plotHeight], ...
    'xtick', [], 'ytick', [], 'parent', handles.figure1);
  % 
  set(handles.drawnChannels(index).ax, 'units', 'characters');
  pos = get(handles.drawnChannels(index).ax, 'position');
  % in the case of continuous data create line objects
  if handles.channels(chanIndex).type == handles.nsTypes.ANALOG_TYPE
    handles.drawnChannels(index).line = ...
    plot(handles.drawnChannels(index).ax, NaN, NaN);
  % in the case of spike and event data create the image objects
  elseif handles.channels(chanIndex).type == handles.nsTypes.SEGMENT_TYPE ...
      || handles.channels(chanIndex).type == handles.nsTypes.EVENT_TYPE
    handles.drawnChannels(index).line = ...
      imagesc(NaN, 'parent', handles.drawnChannels(index).ax);
    
    set(handles.drawnChannels(index).ax, 'clim', [0, 1]);
    set(handles.drawnChannels(index).ax, 'ytick', []);
  end
  % line may of type bar or line, but both should have this function.
  % If we don't add it to the callback it will these objects will block
  % the selection of the axes that we'd like.
  set(handles.drawnChannels(index).line, 'buttondownfcn', @axesCallback);

  label_elec = handles.channels(chanIndex).elec;
  if label_elec > 5120 && label_elec < 10240
    label_elec = label_elec - 5120;
  end
  if handles.channels(chanIndex).elec == 0
    % In the case of digital input the electrode ID has no meaning so we
    % don't display this.  Also with digital, we don't need two line labels.
    handles.drawnChannels(index).text = ...
      ylabel(handles.drawnChannels(index).ax, ...
      handles.channels(chanIndex).label, ...
      'rotation', 0, 'horizontalalignment', 'right', ...
      'verticalalignment', 'middle', 'fontsize', 8);
  else
    if pos(4) <= 2
      % In the axes height is short, just write a one line label with the
      % electrode ID.
      handles.drawnChannels(index).text = ...
        ylabel(handles.drawnChannels(index).ax, ...
        sprintf('elec %03d', label_elec), ...
        'rotation', 0, 'horizontalalignment', 'right', ...
        'verticalalignment', 'middle', 'fontsize', 8);
    else
      % If we have a bit of space, write the label as well, ie., 'spike',
      % 'lfp', etc.
      handles.drawnChannels(index).text = ...
        ylabel(handles.drawnChannels(index).ax, ...
        {sprintf('elec %03d', label_elec); ...
        handles.channels(chanIndex).label}, 'rotation', 0, ...
        'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
        'fontsize', 8);
    end
  end
  set(handles.drawnChannels(index).ax, {'xtick', 'ytick'}, {[], []});
  % since these axes are deleted we need to reset the callbacks.  
  set(handles.drawnChannels(index).ax, 'buttondownfcn', @axesCallback);
  handles.drawnChannels(index).rect = 0;
end

guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function axesCallback(hObject, eventdata)
% This function is triggered any time that any of the plot axes or the
% children of an axis is clicked.  This will select or de-select the
% channel.
handles = guidata(hObject);

ax = hObject;
% Triggered object may be a line, image, rect, or axes.  If this is a line 
% or bar get the axis.  This had better be it's parent.
if ~strcmp(get(hObject, 'type'), 'axes')
  ax = get(hObject, 'parent');
end
% find the index in drawnChannels of this axes.
index = find([handles.drawnChannels(:).ax] == ax);
selectionType = get(handles.figure1, 'SelectionType');
if strcmp(selectionType, 'normal')
  % In normal case (single click) toggle the selection of the the axes
  if handles.drawnChannels(index).rect ~= 0
    delete(handles.drawnChannels(index).rect);
    handles.drawnChannels(index).rect = 0;
    handles.channels(handles.drawnChannels(index).chanIndex).selectedForMod = 0;
  else
    xl = get(ax, 'xlim');
    yl = get(ax, 'ylim');
    handles.channels(handles.drawnChannels(index).chanIndex).selectedForMod = 1;
    handles.drawnChannels(index).rect = rectangle('parent', ax, 'position', ...
      [xl(1), yl(1), xl(2) - xl(1), yl(2) - yl(1)], 'linewidth', 3, ...
      'edgecolor', 'green');
  end
elseif strcmp(selectionType, 'open')
  % In open case (double click) open the correct dialog (either spike view
  % or event view).  We do nothing with continuous channels.
  chanIndex = handles.drawnChannels(index).chanIndex;
  if strcmp(handles.channels(chanIndex).label, 'spike')
    spikeView('wisteria', hObject, chanIndex);
  elseif handles.channels(chanIndex).type == handles.nsTypes.EVENT_TYPE
    eventView('wisteria', hObject, chanIndex);
  end
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function updateAxes(range, hObject)
% update the current set of axes with a new range of x values, but not
% change the drawn channels.

if isMultipleCall(); return; end;

handles = guidata(hObject);

if isempty(handles.drawnChannels)
  return;
end
set(handles.figure1, 'pointer', 'watch');
drawnow;

range(1) = max(1 / 30000, range(1));
range(2) = min(handles.fileInfo.TimeSpan, range(2));

if ishandle(handles.drawnChannels(1).ax)
    pos = getpixelposition(handles.drawnChannels(1).ax);
else
    warning('cannot find axes handle');
    return;
end
% floor because I thought pixel could sometimes be non-integer (though it
% is always of class double).  This may not be true.
pixelWidth = floor(pos(3));
% if the frame is so small that we can't draw anything just bail
if pixelWidth < 5
    return;
end
binWidth = 1;
spikeBins = linspace(range(1), range(2), floor(pixelWidth / binWidth));
% FIXME: In the case of binning we will have the inaccurate time axes.
% Need to ensure that we use the correct time points here.
MAX_POINTS = 10000;
drawnRange = range;
xticks = linspace(range(1), range(2), 10);
% xticks = xticks(2:end-1);
% get data and buffer it.
% separate entities based on NSx files
hFile = handles.hFile;
fileTypes = ...
  unique([hFile.Entity([handles.drawnChannels(:).entityID]).FileType]);
fileTypes = ...
  fileTypes(~strcmp({hFile.FileInfo(fileTypes).FileTypeID}, 'NEURALEV'));
% Create place for data pulled from files and indices.  Indices are important
% to count due to potential pausing in NSx files.
bufferedData = cell(size(handles.drawnChannels));
% one set of indices for each kind of NSx file.
bufferedIndices = cell(size(fileTypes, 1));

for fileType=fileTypes
  fileInfo = hFile.FileInfo(fileType);
  % 
  entitiesFromType = ...
    [handles.drawnChannels([hFile.Entity([handles.drawnChannels.entityID]).FileType] == fileType).entityID];  
  points = zeros(1, 2);
  [rc, index] = ns_GetIndexByTime(hFile, entitiesFromType(1), range(1), 1);
  points(1) = index;
  [rc, index] = ns_GetIndexByTime(hFile, entitiesFromType(1), range(2), -1);
  points(2) = index;
  % points(1) = max(1, points(1));
  npoints = points(2) - points(1) + 1;
  % 
  drawnIndex = find([hFile.Entity([handles.drawnChannels.entityID]).FileType] == fileType);  
  % find pauses
  packetCum = cumsum(fileInfo.TimeStamps(2,:));
  StartPacket = find(points(1)<=packetCum, 1, 'first');
  EndPacket = find(points(2)<=packetCum, 1, 'first');  
  nPacket = length(StartPacket:EndPacket);
  
  % IJM - commented out the warnings/errors because I've implemented
  % support for pausing around line 751, currently broken.
  if nPacket > 1
    % warn user that this won't work
    uiwait(msgbox('MATLAB wisteria does not currently support pausing in NSx 2.2 files.'));
    % may as well reset the pointer
    set(handles.figure1, 'pointer', 'arrow');
    error('MATLAB wisteria does not currently support pausing in NSx 2.2 files.');
  end
  % Get block of analog data.  'unscale' implies that this stays as
  % integers.  This allows us to gather more data with running into
  % memory limits.  We turn this to double after binning.
  [rc, data] = ns_GetAnalogDataBlock(hFile, entitiesFromType, points(1), ...
    npoints, 'unscale');
  % An older version of ns_GetAnalogDataBlock returned the transpose of
  % data, rather than rewrite all of this, simply apply the transpose.
  % However, if speed is an issue we may have to fix this directly.
  data = data';
  
  % IJM - Fill paused portions of data with zeros
  % This could be done more effeciently using Matlab list comp functions
  % and removing for loops.
%   if nPacket > 1
%       % debugging
%       fprintf('range = [%f, %f], points = (%d, %d), start/end pkt = [%d, %d], size data = %d\n', ...
%         range(1), range(2), points(1), points(2), StartPacket, EndPacket, size(data, 2));
%       
%       % Note: TimeStamps are in spaced by "period"
%       period = fileInfo.Period / 30000.; % period in units of clock cycles
%       ts = fileInfo.TimeStamps(1,:)
%       packetCount = fileInfo.TimeStamps(2,:)
%       nChan = size(data, 1);
%       lastPacketTime = sum(fileInfo.TimeStamps)
%       nzeroBefore = 0;
%       if StartPacket > 1
%         for packet=StartPacket:EndPacket
%             if ts(packet)>floor(range(1)/period) && lastPacketTime(packet-1)<floor(range(1)/period)
%                 nzeroBefore = ts(packet) - floor(range(1)/period);
%             end
%         end
%       end
%       
%        nzeroAfter = 0;
%       for packet=StartPacket:EndPacket-1
%         if ceil(range(2)/period)>lastPacketTime(packet) && ceil(range(2)/period)<ts(packet+1)
%             nzeroAfter = ceil(range(2)/period) - lastPacketTime(packet)
%         end
%       end
%       fprintf('per = %f, nzerobefore/after = %d/%d\n', period, nzeroBefore, nzeroAfter);
%       
%       % Create data start and stop indices relevant to the desired data
%       % range given in 'points'
%       startInd = zeros(1, nPacket);
%       stopInd = zeros(1, nPacket);
%       
%       c = 1;
%       for packet=StartPacket:EndPacket
%           if c == 1
%             startInd(c) = 1;
%             if points(2) > packetCum(packet)
%               stopInd(c) = startInd(c) + packetCum(packet) - points(1);
%             else
%               stopInd(c) = npoints;
%             end
%           else
%             startInd(c) = stopInd(c-1) + 1;
%             if points(2) > packetCum(packet)
%               stopInd(c) = startInd(c) + packetCount(packet) - 1;
%             else
%               stopInd(c) = npoints;
%             end
%           end
%          
%           c = c + 1;
%       end
%       
%       % Create start and stop indices in the expanded data set
%       % which includes zeroed data during pauses.
%       allStartInd = zeros(1, nPacket);
%       allStopInd = zeros(1, nPacket);
% 
%       c = 1;
%       nzeros = 0;
%       for packet=StartPacket:EndPacket
%           if c == 1
%               nzeros = nzeros + nzeroBefore;
%               allStartInd(c) = startInd(c) + nzeros;
%               allStopInd(c) = stopInd(c) + nzeros;
%           else
%               nzeros = nzeros + ts(packet) - (ts(packet-1) + packetCount(packet-1));
%               allStartInd(c) = startInd(c) + nzeros;
%               allStopInd(c) = stopInd(c) + nzeros;
%           end
%           c = c + 1;
%       end
%       
%       % Pre-allocate an array to hold all of the data points plus 
%       % region padded with zeroes. 
%       % Logic: total data points w/ zeros is the last packet time,
%       % which counts from zero starting at the beginning of the file,
%       % divided by the period in the same clock units + the number
%       % of data points in the last packet. 
%       % TODO: This may sometimes be too big! Do some size check. 
%       alldata = zeros(nChan, allStopInd(end)+nzeroAfter);
%       
%       % Loop over each of the packets in the file and put data in place
%       % of zeroes.
%       for packet=1:nPacket
%           fprintf('pkt = %d, all=(%d, %d), data=(%d, %d)\n', ...
%                 packet, allStartInd(packet), allStopInd(packet), ...
%                 startInd(packet), stopInd(packet));
%           for chan=1:nChan
%             alldata(chan, allStartInd(packet):allStopInd(packet)) = ...
%                 data(chan, startInd(packet):stopInd(packet));
%           end
%       end
%       data = alldata;
%       clear alldata;
%   end
  npoints = size(data, 2);
  % set bad data to NaN so that it doesn't show up in plots
  data(data==-hex2dec('8000') | data > 1e33) = NaN;
  if npoints > MAX_POINTS && npoints > 2 * pixelWidth
    binSize = floor(npoints / pixelWidth);
    remain = floor(rem(npoints, binSize));

    shapedData = reshape(data(:, 1:end-remain), size(data, 1), binSize, []);
    % Get min / max by bins.
    mins = min(shapedData, [], 2);
    mins = double(mins);
    maxes = max(shapedData, [], 2);
    maxes = double(maxes);
    % add all the data to the data buffer cell arrays and apply scaling.
    % The buffered data will consist of min/max pairs for each bin.
    for i=1:length(drawnIndex)
      cellIndex = drawnIndex(i);
      entity = entitiesFromType(i);
      bufferedData{cellIndex} = zeros(2 * size(mins(:, :), 2), 1);
      bufferedData{cellIndex}(1:2:end) = mins(i, :) * hFile.Entity(entity).Scale;
      bufferedData{cellIndex}(2:2:end) = maxes(i, :) * hFile.Entity(entity).Scale;
    end
  % case where data is small enough that we don't apply any binning.
  else
    % set bad data to NaN so that it doesn't show up in plots
    data(data==-hex2dec('8000') | data > 1e33) = NaN;
    for i=1:length(drawnIndex)
      cellIndex = drawnIndex(i);
      entity = entitiesFromType(i);
      bufferedData{cellIndex} = double(data(i, :)) * hFile.Entity(entity).Scale;
    end
  end
end
drawnChanIndex = [handles.drawnChannels(:).chanIndex];
autoYLimChan = cellfun(@isempty, {handles.channels(drawnChanIndex).ylim});
autoYLimChan = autoYLimChan & ...
  [handles.channels(drawnChanIndex).type] == handles.nsTypes.ANALOG_TYPE;
% points = cellfun(@(x) find(x==x), bufferedData, 'UniformOutput', false);
bounds = cell2mat(cellfun(@(x) max(abs(x)), bufferedData(autoYLimChan), ...
  'UniformOutput', false));
for index=1:length(bounds)
  bound = bounds(index);
  wantedChans = drawnChanIndex(autoYLimChan);
  chanIndex = wantedChans(index); 
  handles.channels(chanIndex).ylim = bound;
end
% timestamp look ups based on electrodes are much faster if only search the 
% the time regions of interest.
if ~isempty(find([handles.channels([handles.drawnChannels.chanIndex]).type] == ...
    handles.nsTypes.SEGMENT_TYPE, 1)) ...
    || ~isempty(find([handles.channels([handles.drawnChannels.chanIndex]).type] == ...
    handles.nsTypes.EVENT_TYPE, 1))
  points = floor(range * 30000);
  % IJM
  % handle nev files with no spikes.  In these case we don't end up with
  % map file.
  if isempty(handles.hFile.FileInfo(1).MemoryMap)
    allSpikeIndex = [];
    allSpikeTimes = [];
    allSpikeElec = [];
  else
    allSpikeIndex = ...
      [handles.hFile.FileInfo(1).MemoryMap.Data.TimeStamp] > points(1) & ...
      [handles.hFile.FileInfo(1).MemoryMap.Data.TimeStamp] < points(2);
    allSpikeTimes = handles.hFile.FileInfo(1).MemoryMap.Data.TimeStamp(allSpikeIndex);
    allSpikeElec = handles.hFile.FileInfo(1).MemoryMap.Data.PacketID(allSpikeIndex);
    allReasons = ...
      handles.hFile.FileInfo(1).MemoryMap.Data.Class(allSpikeIndex);
  end
  % For the sake of speed, the ns_GetEntityData function is skipped here.
  % As such, we'll have to replace some of that code here.
  % IJM The reasons have changed in a recent version of Trellis/nipexec.
  % The first siex reasons are the most recent assigned versions. The
  % reason bit value must be adjusted if an index higher than six is
  % matched. 
%   packetReason = {'Digital Input', 'Input Ch 1', 'Input Ch 2', ...
%                   'Input Ch 3', 'Input Ch 4', 'Input Ch 5'};  
    packetReason = {'Parallel Input', 'SMA 1', 'SMA 2', 'SMA 3', ...
                    'SMA 4', 'Output Echo', 'Digital Input', ...
                    'Input Ch 1', 'Input Ch 2', 'Input Ch 3', ...
                    'Input Ch 4', 'Input Ch 5'};
end
% loop over each drawn electrode and either plot the continious data or
% find the spikes and draw them.
for elecIndex=1:length(handles.drawnChannels)
  
  chanIndex = handles.drawnChannels(elecIndex).chanIndex;
  entity = handles.channels(chanIndex).entityID;
  if handles.channels(chanIndex).type == handles.nsTypes.ANALOG_TYPE
    y = bufferedData{elecIndex};
    %fprintf('length y = %d\n', length(y));
    t = linspace(range(1), range(2), length(y));
    
    set(handles.drawnChannels(elecIndex).line, 'xdata', t(y==y), ...
      'ydata', y(y==y));
    
    if isempty(handles.channels(chanIndex).ylim)
      ylimits = [-bounds bounds];
    else
      ylimits = [-handles.channels(chanIndex).ylim handles.channels(chanIndex).ylim];
    end
    if diff(ylimits) == 0
        ylimits = [-1.0, 1.0];
    end
    set(handles.drawnChannels(elecIndex).ax, 'ylim', ylimits);
    set(handles.drawnChannels(elecIndex).ax, 'xtick', xticks);
    set(handles.drawnChannels(elecIndex).ax, 'ticklength', [0, 0]);
    set(handles.drawnChannels(elecIndex).ax, 'xgrid', 'on');
    set(handles.drawnChannels(elecIndex).ax, 'xticklabel', []);
    pos = get(handles.drawnChannels(elecIndex).ax, 'position');
    if pos(4) > 4
      set(handles.drawnChannels(elecIndex).ax, ...
        'ytick', 0.8*[ylimits(1), ylimits(2)]);
    
      newLabels = arrayfun(@(value)(sprintf('%.1f',value)), ...
        get(handles.drawnChannels(elecIndex).ax, 'ytick'), ...
        'UniformOutput', false);
      set(handles.drawnChannels(elecIndex).ax, 'yticklabel', newLabels);
      
      units = get(handles.drawnChannels(elecIndex).ax, 'units');
      set(handles.drawnChannels(elecIndex).ax, 'units', 'character');
      pos = get(handles.drawnChannels(elecIndex).ax, 'position');
      label = get(handles.drawnChannels(elecIndex).ax, 'ylabel');
      
      set(handles.drawnChannels(elecIndex).ax, 'fontsize', ...
        get(label, 'fontsize') - 1);
      
      set(label, 'units', 'character');
      label_pos = get(label, 'position');
      
      label_pos(1) = -1.0;
      set(label, 'pos', label_pos);
    end    
  % handle spikes and digital event channels
  % IJM - Added '&& size(allSpike ...' to account for empty nev files
  elseif handles.channels(chanIndex).type == handles.nsTypes.SEGMENT_TYPE ...
      || handles.channels(chanIndex).type == handles.nsTypes.EVENT_TYPE ...
      && size(allSpikeElec, 1) > 0
    elecID = handles.channels(chanIndex).elec;
    % To speed this up.  First find all the spikes in the correct window.  
    % Then, sort by channel.
    spikeTimes = allSpikeTimes(allSpikeElec == elecID);
    % in the case of digital events, we need to filter out the ones that
    % aren't relavent to this channel.
    if elecID == 0
      % get all the digital reasons.  This array should contain all the
      % same events as those currently held in "spikeTimes"
      reasons = allReasons(allSpikeElec == elecID);

      % Find what bit pertains to this entities digital events.
      idx = find(strcmp(packetReason, handles.hFile.Entity(entity).Reason));
      % IJM - Adjust index for the old packet reasons.
      if idx > 6
          idx = idx - 6;
      end
      spikeTimes = spikeTimes(bitget(reasons, idx) == 1);
    end
    % convert spike times to seconds
    spikeTimes = double(spikeTimes) / 30000;
    % create one bin per pixel
    % binWidth = 10*pixelWidth;
    % bins = range(1):binWidth:range(2)
    spikeHist = hist(spikeTimes, spikeBins);
    spikeHist(spikeHist >= 1) = 1;
    % spikeHist = ones(length(spikeBins), 1);
    x = spikeBins(spikeHist > 0);
    y = ones(1, length(x));
   
    set(handles.drawnChannels(elecIndex).line, 'cdata', spikeHist, ...
       'xdata', range, 'ydata', [0 0.9]);
    try
      set(handles.drawnChannels(elecIndex).ax, 'xtick', xticks);
    catch
      warning('invalid range');
    end
    set(handles.drawnChannels(elecIndex).ax, 'xticklabel', []);
    set(handles.drawnChannels(elecIndex).ax, 'ticklength', [0, 0]);
    set(handles.drawnChannels(elecIndex).ax, 'xgrid', 'on');
    set(handles.drawnChannels(elecIndex).ax, 'box', 'on');
  end
end
   
set([handles.drawnChannels(:).ax], 'xlim', drawnRange);
% setting parameters for the last of the drawn axes.  The current elecIndex
% ends up being this value, but 'end' would be just as good.
if handles.range > 0.5
  newLabels = arrayfun(@(value)(sprintf('%.1f', value)), xticks, ...
    'UniformOutput', false);
  set(handles.drawnChannels(end).ax, 'xticklabel', newLabels);
  xlabel(handles.drawnChannels(end).ax, '[s]');
else 
  xticks = (xticks - drawnRange(1))*1000;
  newLabels = arrayfun(@(value)(sprintf('%.1f', value)), xticks, ...
    'UniformOutput', false);
  set(handles.drawnChannels(elecIndex).ax, 'xticklabel', newLabels);
  xlabel(handles.drawnChannels(elecIndex).ax, ...
    sprintf('[ms] + %.2f seconds', drawnRange(1)));
end
set(handles.figure1, 'pointer', 'arrow');


% --------------------------------------------------------------------
function sldAxes_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function sldAxes_Callback(hObject, eventdata, handles)
% hObject    handle to sldAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isMultipleCall(); return; end;

set(hObject, 'value', round(get(hObject, 'value')));

if handles.debug
  tic;
end
if ~isempty(handles.drawnChannels)
  xlimits = get(handles.drawnChannels(1).ax, 'xlim');
  range = xlimits;
else
  % FIXME: This will never work!
  warning('sldAxes_Callback: drawnChannels is empty');
  range = 120;
end

% guidata(handles.figure1, handles);
update(handles.figure1);
% updatePlots(handles.figure1);
% handles = guidata(hObject);
% updateAxes(range, handles.figure1);
if handles.debug
  t = toc;
  fprintf('updated plots in %.6f sec\n', t);
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This is an outragous hack.  If a Wisteria session is closed, then 
% opened again, strangly "figure1_ResizeFcn" is called before 
% "figure1_OpeningFcn" so the uicomp structure which should hold all the
% parameters for resizing doesn't get created.  When this is the case, we
% just skip it.  Then, somewhere the initialization codes gets run.  Why
% Matlab Gui's have to be such a mystery, I'll never know.
if ~isfield(handles, 'uicomp')
    return;
end

handles = guidata(handles.figure1);
figPos = getpixelposition(handles.figure1);
% record the slider units so that we may set this back to their original
% values when we are done.
sliderUnits = get(handles.sldAxes, 'units');
axesSliderPos = get(handles.sldAxes, 'pos');
% set position to pixels for resize calculations.
set(handles.sldAxes, 'units', 'pixels');
set(handles.sldTimeAxis, 'units', 'pixels');
% re-align the slider to the sizes setup in the opening function
axesSliderPos(1) = handles.uicomp.axesSliderPos(1);
axesSliderPos(2) = handles.uicomp.axesSliderPos(2);
axesSliderPos(3) = handles.uicomp.axesSliderPos(3);
% ensure that the slider height matches the space allocated for the axes's
axesSliderPos(4) = figPos(4) - handles.margins.top - axesSliderPos(2);
% ensure that the margin is never bigger than the height of the figure
axesSliderPos(4) = max(axesSliderPos(4), 5);
% FIXME: ensure axesSliderPos is all positive
set(handles.sldAxes, 'pos', axesSliderPos);
timeSliderPos = get(handles.sldTimeAxis, 'pos');
timeSliderPos(1) = axesSliderPos(1) + axesSliderPos(3);
timeSliderPos(3) = figPos(3) - timeSliderPos(1) - handles.margins.right;

timeSliderPos(4) = handles.uicomp.timeSliderPos(4);
set(handles.sldTimeAxis, 'pos', timeSliderPos);    
set(handles.sldAxes, 'units', sliderUnits);
% Set the clock time so that the redraw timer can check see that there was
handles.lastResizeEvent = clock;
% Sadly, none of these methods work to handle how this function gets
% clobbered by consecutive calls.  As of 2014/02/20, I'm still handling 
% this with a timer.  Both these work great in all callbacks except for
% 'resize'.  It seems as though figure 'resizefcn' callbacks have a special
% place among callback functions.
% Method 1.
% if isMultipleCall() return; end;
%
% Method 2.  Note method 2 has a second piece at the end of this function
% global returnFlag;
% if ~isempty(returnFlag); return; end;
% returnFlag = 1;

% if ~isempty(handles.drawnChannels)
%    updatePlots(handles.figure1);
%    sldValue = get(handles.sldTimeAxis, 'value');
%    updateAxes([sldValue sldValue+handles.range], handles.figure1);
% end     

guidata(hObject, handles);
% second piece of method 2.
% returnFlag=[];


% --------------------------------------------------------------------
function updateSlider(handles)
% Update slider range and possible distance movement based on the number of
% selected signals and the number of pixels availabe in the axesPanel.
% This number will change on resize events and when the signals are
% updated.
%
% The basic prinicipal for the slider is that the value is in units of
% channel and refers to the upper most plot.  Thus, the min value will be
% 1 and the max value will refer to the upper most plot on the last page,
% given that all channels are displayed.
totalSelected = sum([handles.channels(:).selected]);
pos = getpixelposition(handles.figure1);
% Need the total available pixels for on the figure
availablePixels = pos(4) - handles.margins.bottom - handles.margins.top;
% If we don't have enough pixels left over for a single plot, bail.
if availablePixels < 10
  return
end
% collect all the selected plots
selectedChan = handles.channels([handles.channels(:).selected] == 1);
% If the pixels needed to plot all axes is less than the figure window
% (i.e., all the plots fit on a single page), setup the slider so that it
% cannot be moved.
totalPixels = sum([selectedChan(:).pixels]);

if totalPixels < availablePixels
  % Special case where the selected channels do consitute less pixels than a
  % single page.  Make the slider unmovable
  set(handles.sldAxes, 'min', 0, 'max', 1, 'value', 0, ...
    'sliderstep', [1.0, 1.e9]);
else  
  % Normal case.
  % Find all the plots on the final page so that we can properly set the slider
  % maxSlider value.  maxSlider should be refer to the top 
  plotsIndex = find(cumsum(fliplr([selectedChan(:).pixels])) < ...
    availablePixels, 1, 'last');
  
  if isempty(plotsIndex)
    % case where the figure is too small for a single axes.  This may not
    % be handled well.
    warning('pixels allocated for axes are larger than figure size');
  else
    % The maxslider becomes the total plots minus the number of plots in
    % the last page.
    maxSlider = totalSelected - plotsIndex + 1;
    % set all the values.  Here 'value' is set so that we avoid warnings,
    % but it will be reset below.
    set(handles.sldAxes, 'min', 1, 'max', maxSlider, 'value', maxSlider, ...
      'sliderstep', [1 / maxSlider, min(1.0, handles.PIXELS_PER_CHAN / maxSlider)]);
    if ~isempty(handles.drawnChannels)
      % If axes are already drawn, we'll try to keep the upper most plot as
      % the upper most plot.  This may not work exactly, but is pretty
      % close.
      value = maxSlider + 1 - handles.drawnChannels(1).chanIndex;
      % if value is 0 or less, just set this to the end.  This case occurs
      % when the current upper plot is on the last page and the figure window 
      % grows 
      value = max(value, 1);
      set(handles.sldAxes, 'value', value);
    end
  end
end

guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function zoomCallback(hObject, eventdata)
% zoom in / out callback.  When zoom is selected from toolbar.  New 
% x-limits come from the zoom object.  
% Note: This function is no
% long in use as I pulled the zoom and pan toolbar items out.

handles = guidata(hObject);
% if this is still on the stack, bail
% Wow this can get Matlab to segfault!
% if isMultipleCall; return; end;

switch get(handles.figure1, 'SelectionType')
  case {'normal', 'alt'}
    % get the limits from the event data
    xlimits = xlim(eventdata.Axes);
    % calculate  range.
    handles.range = xlimits(2) - xlimits(1);
    % refresh the axes
    updateAxes(xlimits, handles.figure1);
    updateTimeAxisSlider(handles, xlimits(1));
end
% If plot were selected redraw the rectangles.
updateRect(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function tlbOpenFile_ClickedCallback(hObject, eventdata, handles)
% Called when open is selected from toolbar.  Opens new file.
%
% hObject    handle to tlbOpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% close the current file if opened.
lastOpenDir = [];
if ~isempty(handles.hFile)
  lastOpenDir = handles.hFile.FilePath;
  ns_CloseFile(handles.hFile);
  % stop timer
  stop(handles.redrawTimer);
  handles.hFile = [];
end
% if we have already opened a neuroshare file, use the old path as the
% starting point of opening the new file. 
if ~isempty(lastOpenDir)
  backDir = pwd; % save the current directory so that we may return to it.
  cd(lastOpenDir)
end
[rc, handles.hFile] = ns_OpenFile;
% move back to the old directory
if ~isempty(lastOpenDir)
  cd(backDir);
end
% TODO: Should this failure be handled better?
if ~strcmp(rc, 'ns_OK')
  return;
end

guidata(hObject, handles);
% reimport data.  Plotting calls are handled by importNevFile.
importNevFile(handles);
% (re)start timer
start(handles.redrawTimer);


% --------------------------------------------------------------------
function tlbChannelSelect_ClickedCallback(hObject, eventdata, handles)
% 'signal select' toolbar button clicked.  Open 'signalSelection' figure
% window.
% add dialog handle to the list of handles.
handles.dialogs = [handles.dialogs signalSelection('wisteria', hObject)];
% if this is called more than once only include it once...
handles.dialogs = unique(handles.dialogs);
guidata(hObject, handles);


% --------------------------------------------------------------------
function tlbGrow_ClickedCallback(hObject, eventdata, handles)
% Increase the number of vertical pixels for each plot

selectedIndices = find([handles.channels(:).selectedForMod]==1);
% bail if nothing is selected
if isempty(selectedIndices)
  return;
end
figPos = getpixelposition(handles.figure1);
% get current range
range = get(handles.drawnChannels(end).ax, 'xlim');

for index=selectedIndices
  newPixels = handles.channels(index).pixels + handles.axesGrowIncrement;
  if handles.channels(index).type == handles.nsTypes.SEGMENT_TYPE
    if newPixels < handles.spikePixelRange(3);
      handles.channels(index).pixels = newPixels;
    end
  else
    if newPixels < handles.contPixelRange(3)
      handles.channels(index).pixels = newPixels;
    end
  end
end

updateSlider(handles);

guidata(handles.figure1, handles);
updatePlots(handles.figure1);
handles = guidata(hObject);
updateAxes(range, handles.figure1);
% update handles as it is modified in updatePlots.
handles = guidata(hObject);
% If a rectangle is still on the page redraw the rectangle.
drawnEntities = [handles.drawnChannels(:).chanIndex];

for entity=selectedIndices
  % if this entity is still drawn, re-draw it's rectangle.
  handles.channels(entity).selectedForMod = 1;
  index = find(drawnEntities == entity);
  if ~isempty(index)
    ax = handles.drawnChannels(index).ax;
    xl = get(ax, 'xlim');
    yl = get(ax, 'ylim');

    handles.drawnChannels(index).rect = rectangle('parent', ax, 'position', ...
      [xl(1), yl(1), xl(2) - xl(1), yl(2) - yl(1)], 'linewidth', 2, ...
      'edgecolor', 'green');
  end
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function tlbShrink_ClickedCallback(hObject, eventdata, handles)
% decrease the height or number of pixels for each plot

selectedIndices = find([handles.channels(:).selectedForMod]==1);
% bail if nothing is selected
if isempty(selectedIndices)
  return;
end
% get current range
range = get(handles.drawnChannels(end).ax, 'xlim');
% TODO: This needs to be updated to the parameters in the gui handles.
for index=selectedIndices
  handles.channels(index).pixels = max(handles.channels(index).pixels - 20, 20);
end 
% value = get(handles.sldAxes, 'value');
updateSlider(handles);
% if get(handles.sldAxes, 'value') ~= 0
%   set(handles.sldAxes, 'value', value);
% end

% update handles and redraw axes.
guidata(handles.figure1, handles);
updatePlots(handles.figure1);
handles = guidata(hObject);
updateAxes(range, handles.figure1);
% update handles as it is modified in updatePlots.
handles = guidata(hObject);
% Find the axes that are still drawn and then redraw the rectangles if
% needed.
drawnEntities = [handles.drawnChannels(:).chanIndex];
for entity=selectedIndices
  % if this entity is still drawn, re-draw it's rectangle.
  handles.channels(entity).selectedForMod = 1;
  index = find(drawnEntities == entity);
  if ~isempty(index)
    ax = handles.drawnChannels(index).ax;
    xl = get(ax, 'xlim');
    yl = get(ax, 'ylim');

    handles.drawnChannels(index).rect = rectangle('parent', ax, 'position', ...
      [xl(1), yl(1), xl(2) - xl(1), yl(2) - yl(1)], 'linewidth', 2, ...
      'edgecolor', 'green');
  end
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function sldTimeAxis_Callback(hObject, eventdata, handles)
% executes on x-axis slider movement.  Selected a new time range to plot

% When time axis slider to triggered redraw the data and rectangles with
% new bounds.
updateAxes([get(hObject, 'value') get(hObject, 'value')+handles.range], ...
  handles.figure1);
updateRect(handles);

guidata(hObject, handles);


% --------------------------------------------------------------------
function updateTimeAxisSlider(handles, t0)
% update time axis slider when zooming in and out in time.  t0 refers to
% the smallest time value drawn.
if handles.fileInfo.TimeSpan > handles.range
  set(handles.sldTimeAxis, 'max', handles.fileInfo.TimeSpan-handles.range);
  set(handles.sldTimeAxis, 'value', t0);
  % Set the major shift to be 1 full screen's worth and the minor shift to
  % be 10%
  minor = 0.1*handles.range / handles.fileInfo.TimeSpan;
  major = handles.range / handles.fileInfo.TimeSpan;
  set(handles.sldTimeAxis, 'sliderstep', [minor, major]);
else
  set(handles.sldTimeAxis, 'value', 0, 'max', handles.fileInfo.TimeSpan, ...
    'sliderstep', [1.0, 1.e9]);
end

% --------------------------------------------------------------------
function sldTimeAxis_CreateFcn(hObject, eventdata, handles)
% Executes during object creation, after setting all properties.
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function tlbZoomInTime_ClickedCallback(hObject, eventdata, handles)
% callback for zoom in function.  Reduce the time drawn by 50%.

if isempty(handles.drawnChannels)
  return;
end
zoom = 0.5; % draw 50% less time
% stop zoom when we get to 1.5 milli-sec.  It makes little sense to zoom
% further and this algorithm will break at some point.
if handles.range < 0.0015
  return;
end
newRange = zoom * handles.range;
% calculate how much to remove from either end (half)
shift = handles.range * zoom * 0.5;

xlimits = get(handles.drawnChannels(end).ax, 'xlim');
% calculate new boundaries
xlimits(1) = xlimits(1) + shift;
xlimits(2) = xlimits(2) - shift;
% if somehow we've removed too much, throw an error.
if xlimits(2) < xlimits(1)
  warning('tlbZoomInTime: Invalid x limits');
end
handles.range = newRange;
guidata(hObject, handles);
% redraw
updateAxes(xlimits, handles.figure1);
updateTimeAxisSlider(handles, xlimits(1));
updateRect(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function tlbZoomOutTime_ClickedCallback(hObject, eventdata, handles)
% callback for zoom out button.  Increase the drawn range by 50%.

if isempty(handles.drawnChannels) || handles.range >= 120 ...
    || handles.range > handles.fileInfo.TimeSpan
  return;
end
newRange = 1.50 * handles.range;
% difficult to support displays of data file larger than 120 minutes.
maxRange = min(handles.maxDisplayTime, handles.fileInfo.TimeSpan);
if newRange > maxRange
  newRange = maxRange;
end

shift = (newRange - handles.range) / 2;
handles.range = newRange;

xlimits = get(handles.drawnChannels(end).ax, 'xlim');

xlimits(1) = xlimits(1) - shift;
xlimits(2) = xlimits(2) + shift;
if xlimits(1) < 0
  xlimits(1) = 0;
  if xlimits(2) >  handles.fileInfo.TimeSpan
    xlimits(2) = handles.fileInfo.TimeSpan;
  else
    xlimits(2) = handles.range;
  end
  handles.range = xlimits(2) - xlimits(1);
elseif xlimits(2) > handles.fileInfo.TimeSpan  
  xlimits(2) = handles.fileInfo.TimeSpan;
  xlimits(1) = xlimits(2) - handles.range;
  handles.range = handles.fileInfo.TimeSpan - xlimits(1);
end

updateAxes(xlimits, handles.figure1);
updateTimeAxisSlider(handles, xlimits(1));
updateRect(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function updateRect(handles)
% with the resizing of of figure windows, update all the rectangles so that they
% still cover the axes.  The options are this or just delete the rectangles.
for selected=find([handles.drawnChannels.rect]~=0)
  % Get the limits for each drawn axes that has a rectangle
  ax = handles.drawnChannels(selected).ax;
  xl = get(ax, 'xlim');
  yl = get(ax, 'ylim');
  % Adjust rectangles
  set(handles.drawnChannels(selected).rect, 'position', ...
    [xl(1), yl(1), xl(2) - xl(1), yl(2) - yl(1)], 'linewidth', 2, ...
    'edgecolor', 'green');
end
guidata(handles.figure1, handles);


% --------------------------------------------------------------------
function tlbDecrease_ClickedCallback(hObject, eventdata, handles)
% callback for decrease y scale.  I.e., make plots bigger by 50%.

selectedIndices = find([handles.drawnChannels(:).rect]~=0);
% bail if nothing is selected
if isempty(selectedIndices)
  return;
end
% get current range
range = get(handles.drawnChannels(end).ax, 'xlim');

for index=selectedIndices
  ylim = get(handles.drawnChannels(index).ax, 'ylim');
  handles.channels(handles.drawnChannels(index).chanIndex).ylim = max(ylim) * 0.5;
end
guidata(hObject, handles);

updatePlots(handles.figure1);

updateAxes(range, handles.figure1);
% update handles as it is modified in updatePlots.
handles = guidata(hObject);
% If a rectangle is still on the page redraw the rectangle.
drawnEntities = [handles.drawnChannels(:).chanIndex];

for entity=[handles.drawnChannels(selectedIndices).chanIndex]
  % if this entity is still drawn, re-draw it's rectangle.
  index = find(drawnEntities == entity);
  if ~isempty(index)
    ax = handles.drawnChannels(index).ax;
    xl = get(ax, 'xlim');
    yl = get(ax, 'ylim');

    handles.drawnChannels(index).rect = rectangle('parent', ax, 'position', ...
      [xl(1), yl(1), xl(2) - xl(1), yl(2) - yl(1)], 'linewidth', 2, ...
      'edgecolor', 'green');
  end
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function tlbIncrease_ClickedCallback(hObject, eventdata, handles)
% callback for increase y scale.  I.e., make plots smaller by 50%
selectedIndices = find([handles.drawnChannels(:).rect]~=0);
% bail if nothing is selected
if isempty(selectedIndices)
  return;
end
% get current range
range = get(handles.drawnChannels(end).ax, 'xlim');

for index=selectedIndices
  ylim = get(handles.drawnChannels(index).ax, 'ylim');
  handles.channels(handles.drawnChannels(index).chanIndex).ylim = max(ylim) * 1.50;
end

guidata(hObject, handles);

updatePlots(handles.figure1);
% guidata(hObject, handles);

updateAxes(range, handles.figure1);
% update handles as it is modified in updatePlots.
handles = guidata(hObject);
% If a rectangle is still on the page redraw the rectangle.
drawnEntities = [handles.drawnChannels(:).chanIndex];

for entity=[handles.drawnChannels(selectedIndices).chanIndex]
  % if this entity is still drawn, re-draw it's rectangle.
  index = find(drawnEntities == entity);
  if ~isempty(index)
    ax = handles.drawnChannels(index).ax;
    xl = get(ax, 'xlim');
    yl = get(ax, 'ylim');

    handles.drawnChannels(index).rect = rectangle('parent', ax, 'position', ...
      [xl(1), yl(1), xl(2) - xl(1), yl(2) - yl(1)], 'linewidth', 2, ...
      'edgecolor', 'green');
  end
end
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function tlbSelectAll_ClickedCallback(hObject, eventdata, handles)
% 'select all' toolbar button callback.  Highlights all visable plots, plus
% applies any changes to all selected signals

drawnEntities = [handles.drawnChannels(:).chanIndex];
for index=1:length(handles.channels)
  handles.channels(index).selectedForMod = 1;
  drawnIndex = find(drawnEntities == handles.channels(index).entityID);
    if ~isempty(drawnIndex)
      if handles.drawnChannels(drawnIndex).rect
        continue;
      end
      ax = handles.drawnChannels(drawnIndex).ax;
      xl = get(ax, 'xlim');
      yl = get(ax, 'ylim');

      handles.drawnChannels(drawnIndex).rect = rectangle('parent', ax, 'position', ...
        [xl(1), yl(1), xl(2) - xl(1), yl(2) - yl(1)], 'linewidth', 2, ...
        'edgecolor', 'green');
  end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function tlbDeselectAll_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tlbDeselectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
drawnEntities = [handles.drawnChannels(:).chanIndex];
for index=1:length(handles.channels)
  handles.channels(index).selectedForMod = 0;
  drawnIndex = find(drawnEntities == handles.channels(index).entityID);
  if ~isempty(drawnIndex) && handles.drawnChannels(drawnIndex).rect ~= 0
    delete(handles.drawnChannels(drawnIndex).rect);
    handles.drawnChannels(drawnIndex).rect = 0;
  end
end
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

% if timer is still running stop it.
if isfield(handles, 'redrawTimer') && ...
    strcmp(get(handles.redrawTimer, 'running'), 'on')
  stop(handles.redrawTimer);
end
% close any current Neuroshare files
if isfield(handles, 'hFile') && ~isempty(handles.hFile)
  try
    ns_CloseFile(handles.hFile);
  end
  handles.hFile = [];
end
% wrap this in a try in case one of the existing dialogs somehow got closed
% on its own.
try
  close(handles.dialogs);
end

delete(hObject);


% --------------------------------------------------------------------
function mnuEdit_Callback(hObject, eventdata, handles)
% hObject    handle to mnuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuGoto_Callback(hObject, eventdata, handles)
% hObject    handle to mnuGoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Open goto dialog

% add dialog handle to the list of handles.
handles.dialogs = [handles.dialogs goto('wisteria', hObject)];
% if this is called more than once only include it once...
handles.dialogs = unique(handles.dialogs);
guidata(hObject, handles);


% --------------------------------------------------------------------
function mnuFileInfo_Callback(hObject, eventdata, handles)
% hObject    handle to mnuFileInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% open FileInfo callback
handles.dialogs = [handles.dialogs fileInfo('wisteria', hObject)];
handles.dialogs = unique(handles.dialogs);
guidata(hObject, handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% [ELB-2014/02/20] One would hope this could be a way to handle the 
% clobbering of the resize function, but this doesn't get executed 
% unless the mouse inside the figure.  The 'resize' locatation doesn't 
% seem to count.


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
