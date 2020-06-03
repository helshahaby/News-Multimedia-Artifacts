function varargout = TextExtractor(varargin)
% TextExtractor MATLAB code for TextExtractor.fig
%      TextExtractor, by itself, creates a new TextExtractor or raises the existing
%      singleton*.
%
%      H = TextExtractor returns the handle to a new TextExtractor or the handle to
%      the existing singleton*.
%
%      TextExtractor('CALLBACK',hObject,~,handles,...) calls the local
%      function named CALLBACK m, in TextExtractor.M with the given input arguments.
%
%      TextExtractor('Property','Value',...) creates a new TextExtractor or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TextExtractor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TextExtractor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TextExtractor

% Last Modified by GUIDE v2.5 14-Aug-2018 22:50:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TextExtractor_OpeningFcn, ...
                   'gui_OutputFcn',  @TextExtractor_OutputFcn, ...
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
% desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% desktop.restoreLayout('Default');
% with GPU using software OpenGL instead of using your graphics hardware to resolve Low-Level Graphics Issues
opengl('save', 'software')



% End initialization code - DO NOT EDIT





% --- Executes just before TextExtractor is made visible.
function TextExtractor_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TextExtractor (see VARARGIN)
% 

%clearvars inputVideoRows_part1  
% % % clearvars videoSizePart1_Flag ;
% % % clearvars inputVideoRows_part2  videoSizePart2_Flag ;
% % % clearvars inputVideoRows_part3  videoSizePart3_Flag ;
% % % clearvars inputVideoRows_part4  videoSizePart4_Flag ;
clearvars corrScore_Right corrScore_Left
clearvars bottomLineNonExistanceFlag 
% clearvars linesErrorFlag ;

clc;


global VideoPath
global OutputPath 
global ChannelName
global ProgramName
global isMergeNewsSelected 
global isNoiseFilterSelected
global isArabicLanguageSelected
global SeparatorPath
global firstTimeToApplyHoughFlag

global TextType
global Classifier
global FeatureExtractor
global MarkedPart
global  EdgeDetector

% VideoPath = get(handles.edit_LoadVideo,'String');

% ChannelName = get(handles.edit_ChannelName,'String');
% 
% ProgramName = get(handles.edit_ProgramName,'String');

% OutputPath = strcat(VideoPath,'_',ChannelName,'_',ProgramName);

% isMergeNewsSelected = get(handles.checkbox_MergeNews,'Value');
% isNoiseFilterSelected = get(handles.checkbox_NoiseFiltering,'Value');
% isArabicLanguageSelected = not(get(handles.togglebutton_Language,'Value'));

firstTimeToApplyHoughFlag = 0;

%Get the Video Path
VideoPath = get(handles.edit_LoadVideo,'String');
ChannelName = get(handles.edit_ChannelName,'String');
ProgramName = get(handles.edit_ProgramName,'String');
SeparatorPath = get(handles.edit_LoadSeparator,'String');

isNoiseFilterSelected = get(handles.checkbox_NoiseFiltering,'Value');
isArabicLanguageSelected = not(get(handles.togglebutton_Language,'Value'));


%Get All pop up menu items for Edge Detector
EdgeDetectorItems = get(handles.popupmenu_EdgeDetector,'String');
%Get the current selected item Index
EdgeDetectorSelectedItem = get(handles.popupmenu_EdgeDetector,'Value');
%Get the name of current selected item
EdgeDetector = EdgeDetectorItems{EdgeDetectorSelectedItem};
% display(EdgeDetector);

%Get All pop up menu items for Text Type ex. Caption(News) or Graphic
%(Films)
TextTypeItems = get(handles.popupmenu_TextType,'String');
%Get the current selected item Index
TextTypeSelectedItem = get(handles.popupmenu_TextType,'Value');
%Get the name of current selected item
TextType = TextTypeItems{TextTypeSelectedItem};
% display(TextType);

%Get All pop up menu items for Marked Part (Top / Bottom / Both)
MarkedPartItems = get(handles.popupmenu_MarkedPart,'String');
%Get the current selected item Index
MarkedPartSelectedItem = get(handles.popupmenu_MarkedPart,'Value');
%Get the name of current selected item
MarkedPart = MarkedPartItems{MarkedPartSelectedItem};
% display(MarkedPart);

%Get All pop up menu items for Feature Extractor
FeatureExtractorItems = get(handles.popupmenu_FeatureExtraction,'String');
%Get the current selected item Index
FeatureExtractorSelectedItem = get(handles.popupmenu_FeatureExtraction,'Value');
%Get the name of current selected item
FeatureExtractor = FeatureExtractorItems{FeatureExtractorSelectedItem};
% display(FeatureExtractor);

%Get All pop up menu items for Classifier
ClassifierItems = get(handles.popupmenu_Classifier,'String');
%Get the current selected item Index
ClassifierSelectedItem = get(handles.popupmenu_Classifier,'Value');
%Get the name of current selected item
Classifier = ClassifierItems{ClassifierSelectedItem};
% display(Classifier);


% Choose default command line output for TextExtractor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TextExtractor wait for user response (see UIRESUME)
% uiwait(handles.figure_TextExtractor);


% Terminate any opened word process
!taskkill  /f  /im WINWORD.EXE


% --- Executes on button press in pushbutton_ .
function pushbutton_Fire_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Fire (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % % global  OutputPath
global  VideoPath
global  ChannelName
global  ProgramName
global  EdgeDetector
global  totalProcessingTime

global isMergeNewsSelected
global isNoiseFilterSelected
global isArabicLanguageSelected

global TextType
global Classifier
global FeatureExtractor
global MarkedPart

%All Algorithim implementation 16 Feb 2019
global Caption_ROI
global vidcap
global NumberOfFrames 
global VideoFrameRate
global typeOfSR

persistent videoSizePart1_Flag
persistent videoSizePart2_Flag
persistent videoSizePart3_Flag
persistent videoSizePart4_Flag

persistent FrameRGB_GetaFrameDozensAhead


% Start Timer
tic

typeOfSR = 'SplineSRInterpolation';

% clear DesiredPartFrameRGB
% clear FrameRGB
%Get the Video Path
VideoPath = get(handles.edit_LoadVideo,'String');
ChannelName = get(handles.edit_ChannelName,'String');
ProgramName = get(handles.edit_ProgramName,'String');


isNoiseFilterSelected = get(handles.checkbox_NoiseFiltering,'Value');
isArabicLanguageSelected = not(get(handles.togglebutton_Language,'Value'));


%Get All pop up menu items for Edge Detector
EdgeDetectorItems = get(handles.popupmenu_EdgeDetector,'String');
%Get the current selected item Index
EdgeDetectorSelectedItem = get(handles.popupmenu_EdgeDetector,'Value');
%Get the name of current selected item
EdgeDetector = EdgeDetectorItems{EdgeDetectorSelectedItem};
% display(EdgeDetector);

%Get All pop up menu items for Text Type ex. Caption(News) or Graphic
%(Films)
TextTypeItems = get(handles.popupmenu_TextType,'String');
%Get the current selected item Index
TextTypeSelectedItem = get(handles.popupmenu_TextType,'Value');
%Get the name of current selected item
TextType = TextTypeItems{TextTypeSelectedItem};
% display(TextType);

%Get All pop up menu items for Marked Part (Top / Bottom / Both)
MarkedPartItems = get(handles.popupmenu_MarkedPart,'String');
%Get the current selected item Index
MarkedPartSelectedItem = get(handles.popupmenu_MarkedPart,'Value');
%Get the name of current selected item
MarkedPart = MarkedPartItems{MarkedPartSelectedItem};
% display(MarkedPart);

%Get All pop up menu items for Feature Extractor
FeatureExtractorItems = get(handles.popupmenu_FeatureExtraction,'String');
%Get the current selected item Index
FeatureExtractorSelectedItem = get(handles.popupmenu_FeatureExtraction,'Value');
%Get the name of current selected item
FeatureExtractor = FeatureExtractorItems{FeatureExtractorSelectedItem};
% display(FeatureExtractor);

%Get All pop up menu items for Classifier
ClassifierItems = get(handles.popupmenu_Classifier,'String');
%Get the current selected item Index
ClassifierSelectedItem = get(handles.popupmenu_Classifier,'Value');
%Get the name of current selected item
Classifier = ClassifierItems{ClassifierSelectedItem};
% display(Classifier);


% Create an output path for processed frames
% [OnlyPath,OnlyName,OnlyExt] = fileparts(VideoPath)
% CurrentPath = pwd;

vidcap = VideoReader(VideoPath);

Frame_ID = 0;
CutFactor = 1.5;
uselessBottomPixelsToRemove=0;

if (  strcmp(TextType , 'Graphic : Song Lyrics' ) == 1 )
    
    OutputFolderSongLyrics = fullfile(strcat(pwd,'\OutputFolderSongLyrics'));
    if ~exist(OutputFolderSongLyrics , 'dir')
        mkdir OutputFolderSongLyrics
    end
    
    SongLyrics = fullfile(strcat(pwd,'\SongLyrics'));
    if ~exist(SongLyrics , 'dir')
        mkdir SongLyrics
    end
    
    cd OutputFolderSongLyrics
    
    %captureFrame = 0;
    LyricsRegionsThreshold = 50;    
    CorrLastFrameThreshold = 0.5;
    CorrBackgroundThreshold = 0.85;
    
elseif (  strcmp(TextType , 'Graphic : Fixed Background' ) == 1 )
    
    OutputFolderFixedBackground = fullfile(strcat(pwd,'\OutputFolderFixedBackground'));
    if ~exist(OutputFolderFixedBackground , 'dir')
        mkdir OutputFolderFixedBackground
    end
    
    FixedBackgroundData = fullfile(strcat(pwd,'\FixedBackgroundData'));
    if ~exist(FixedBackgroundData , 'dir')
        mkdir FixedBackgroundData
    end
    
    cd OutputFolderFixedBackground
    
    FixedBackgroundThreshold = 250;
    FixedBackgroundRelation = 0.87;
    
elseif (  strcmp(TextType , 'Caption : Scrolling/Static' ) == 1 || strcmp(TextType , 'Caption : Scrolling(Horizontal/Vertical) only' ) == 1 || strcmp(TextType , 'Caption : Static only' ) == 1 )
    
    captionPart1_Flag = 0;
    captionPart2_Flag = 0;
    captionPart3_Flag = 0;
    captionPart4_Flag = 0;
    
    OutputFolderNews = fullfile(strcat(pwd,'\OutputFolderNews'));
    if ~exist(OutputFolderNews , 'dir')
        mkdir OutputFolderNews
    end
  
    copyfile TextExtractor.m OutputFolderNews ;
    copyfile AlexNet_News_18a.mat OutputFolderNews ;
    copyfile CNN_FeEx_Le_Net18a.mat OutputFolderNews ;
    copyfile RNN_LSTM_Net18a.mat OutputFolderNews ;
    
    cd OutputFolderNews
    
    if isempty(videoSizePart1_Flag)
        videoSizePart1_Flag = 0;
        captionPart1_Flag = 0;
    end
    
    if isempty(videoSizePart2_Flag)
        videoSizePart2_Flag = 0;
        captionPart2_Flag = 0;        
    end
    
    if isempty(videoSizePart3_Flag)
        videoSizePart3_Flag = 0;
        captionPart3_Flag = 0;        
    end
    
    if isempty(videoSizePart4_Flag)
        videoSizePart4_Flag = 0;
        captionPart4_Flag = 0;        
    end
    
    % mkdir FilmsDataSet
    % mkdir NewsDataSet
    
    % cd NewsDataSet
    
    VideoName_Part1 = strcat(ChannelName,'_',ProgramName,'_Part1.avi');
    v_Part1 = VideoWriter(VideoName_Part1 );
    VideoName_Part2 = strcat(ChannelName,'_',ProgramName,'_Part2.avi');
    v_Part2 = VideoWriter(VideoName_Part2 );
    VideoName_Part3 = strcat(ChannelName,'_',ProgramName,'_Part3.avi');
    v_Part3 = VideoWriter(VideoName_Part3 );
    VideoName_Part4 = strcat(ChannelName,'_',ProgramName,'_Part4.avi');
    v_Part4 = VideoWriter(VideoName_Part4 );
    
    z = 0;
    
    % Get Frame Rate for News Analysis
    VideoFrameRate = floor(vidcap.FrameRate);
    
    while hasFrame(vidcap)
        
        FrameRGB_GetaFrameDozensAhead = readFrame( vidcap  );
        
        if z == VideoFrameRate + 10
            break;
        end
        
        z = z +1;
        
    end
        
    %     Get the Desired part index for the rows
    if strcmp(MarkedPart , 'Bottom' ) == 1
        DesiredAreaIndex_GetaFrameDozensAhead = round( size(FrameRGB_GetaFrameDozensAhead,1) / 1.5);
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndex_GetaFrameDozensAhead:end - uselessBottomPixelsToRemove  , : , :) ;
    elseif strcmp(MarkedPart , 'Top' ) == 1
        DesiredAreaIndex_GetaFrameDozensAhead = round(size(FrameRGB_GetaFrameDozensAhead,1) / 3);
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(1:DesiredAreaIndex_GetaFrameDozensAhead , : , :) ;
    elseif strcmp(MarkedPart , 'Both' ) == 1
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead ;
    elseif strcmp(MarkedPart , 'Middle' ) == 1
        DesiredAreaIndexStart_GetaFrameDozensAhead = round(size(FrameRGB_GetaFrameDozensAhead,1) / 3);
        DesiredAreaIndexEnd_GetaFrameDozensAhead   = round( size(FrameRGB_GetaFrameDozensAhead,1)  / 1.5 );
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndexStart_GetaFrameDozensAhead:DesiredAreaIndexEnd_GetaFrameDozensAhead , : , :) ;
    end
    
    NumberOfFrames = VideoFrameRate * floor(vidcap.Duration);
    
elseif (  strcmp(TextType , 'Graphic : Movie' ) == 1  )
    
    OutputFolderMovies = fullfile(strcat(pwd,'\OutputFolderMovies'));
    if ~exist(OutputFolderMovies , 'dir')
        mkdir OutputFolderMovies
    end
    
    MoviesData = fullfile(strcat(pwd,'\MoviesData'));
    if ~exist(MoviesData , 'dir')
        mkdir MoviesData
    end
    
    copyfile TextExtractor.m OutputFolderMovies ;
    copyfile ZF_NET17b.mat OutputFolderMovies ;
    
    cd OutputFolderMovies
    
    FrameRGB = readFrame(vidcap);
    
    % Get the Desired part index for the rows
    if strcmp(MarkedPart , 'Bottom' ) == 1
        DesiredAreaIndex = round( size(FrameRGB,1) / CutFactor);
        DesiredPartFrameRGB = FrameRGB(DesiredAreaIndex:end , : , :) ;
    elseif strcmp(MarkedPart , 'Top' ) == 1
        DesiredAreaIndex = round(size(FrameRGB,1) / 3);
        DesiredPartFrameRGB = FrameRGB(1:DesiredAreaIndex , : , :) ;
    elseif strcmp(MarkedPart , 'Both' ) == 1
        DesiredPartFrameRGB = FrameRGB ;
    elseif strcmp(MarkedPart , 'Middle' ) == 1
        DesiredAreaIndexStart = round(size(FrameRGB,1) / 3);
        DesiredAreaIndexEnd   = round( size(FrameRGB,1) / 1.5);
        DesiredPartFrameRGB = FrameRGB(DesiredAreaIndexStart:DesiredAreaIndexEnd , : , :) ;
    end
        
    % Convert frame to Gray Scale
    FrameGrayBackground = rgb2gray(DesiredPartFrameRGB);
    
    FrameGrayScalePast = FrameGrayBackground;

end

% While there is a new frame capture it for processing
while hasFrame(vidcap)
    
    FrameRGB = readFrame(vidcap);
    FrameRGB = imadjust(FrameRGB,[],[]);
    
    try
        if (Frame_ID <  NumberOfFrames - VideoFrameRate - 10 - 1)
            
            FrameRGB_GetaFrameDozensAhead = readFrame( vidcap  );
            
            FrameRGB_GetaFrameDozensAhead = imadjust(FrameRGB_GetaFrameDozensAhead,[],[]);
            
        end
    catch
        % Exception occured
        g=0
    end
  
% New News Algorithim Implementation All together 16 Febraury 2019     
% % %     if (  strcmp(TextType , 'Graphic : Movie' ) == 1 )
% % %         
% % %         % TBD
% % %         
% % %     elseif (  strcmp(TextType , 'Caption : Scrolling/Static' ) == 1 || strcmp(TextType , 'Caption : Scrolling(Horizontal/Vertical) only' ) == 1 || strcmp(TextType , 'Caption : Static only' ) == 1 )
% % %            
% % %         if captureFrame > Frame_ID
% % %             Frame_ID = Frame_ID + 1;
% % %             continue;
% % %         end
% % %         
% % %     elseif (  strcmp(TextType , 'Graphic : Song Lyrics' ) == 1 )
% % %         % TBD
% % %     end
    
    
    
    % Get the Desired part index for the rows
    if strcmp(MarkedPart , 'Bottom' ) == 1
        DesiredAreaIndex = round( size(FrameRGB,1) / CutFactor);
        DesiredPartFrameRGB = FrameRGB(DesiredAreaIndex:end - uselessBottomPixelsToRemove  , : , :) ;
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndex_GetaFrameDozensAhead:end - uselessBottomPixelsToRemove  , : , :) ;
    elseif strcmp(MarkedPart , 'Top' ) == 1
        DesiredAreaIndex = round(size(FrameRGB,1) / 3);
        DesiredPartFrameRGB = FrameRGB(1:DesiredAreaIndex , : , :) ;
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(1:DesiredAreaIndex_GetaFrameDozensAhead , : , :) ;
    elseif strcmp(MarkedPart , 'Both' ) == 1
        DesiredPartFrameRGB = FrameRGB ;
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead ;       
    elseif strcmp(MarkedPart , 'Middle' ) == 1
        DesiredAreaIndexStart = round(size(FrameRGB,1) / 3);
        DesiredAreaIndexEnd   = round( size(FrameRGB,1)  / 1.5 );
        DesiredPartFrameRGB = FrameRGB(DesiredAreaIndexStart:DesiredAreaIndexEnd , : , :) ;
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndexStart_GetaFrameDozensAhead:DesiredAreaIndexEnd_GetaFrameDozensAhead , : , :) ;
    end
    
    % Convert frame to Gray Scale
    FrameGrayScale = rgb2gray(DesiredPartFrameRGB);
    FrameGrayScale_GetaFrameDozensAhead = rgb2gray(DesiredPartFrameRGB_GetaFrameDozensAhead);
    % Adjust gray image .
    FrameGrayScale = imadjust(FrameGrayScale);
    FrameGrayScale_GetaFrameDozensAhead = imadjust(FrameGrayScale_GetaFrameDozensAhead);

    
    if (isNoiseFilterSelected)
        h = imgaussfilt(FrameGrayScale);
        
        FrameGrayScale = imfilter(FrameGrayScale , double ( h ) );
        
        FrameGrayScale = filter2(fspecial('average',3),FrameGrayScale)/255;

        % Filter the noisy image using a median filter by applying the medfilt2 function        
        FrameGrayScale = medfilt2(FrameGrayScale);
        
        FrameGrayScale = wiener2(FrameGrayScale);
        
        FrameGrayScalePast = double(FrameGrayScalePast);
        
        FrameGrayBackground = double(FrameGrayBackground);

    end


    if (  strcmp(TextType , 'Caption : Scrolling/Static' ) == 1 || strcmp(TextType , 'Caption : Scrolling(Horizontal/Vertical) only' ) == 1 || strcmp(TextType , 'Caption : Static only' ) == 1 )
        
        % New News Algorithm implemented in 16 Feb 2019
        if mod( Frame_ID , VideoFrameRate) == 0
            
            % Get the ROI
            Caption_ROI_Temp  =  HoughTransform( FrameGrayScale , FrameGrayScale_GetaFrameDozensAhead );
            
            if ~isempty(Caption_ROI_Temp)
                % Caption_ROI = [];
                Caption_ROI = Caption_ROI_Temp;
                Caption_ROI = sortrows(Caption_ROI,2,'descend');
            end
            
        end
        
        % imageOfEdges = bwlabel(FrameGrayScale , 4 ) ;
        % numberOfEdges = max( imageOfEdges(:) ) ;
        
        CaptionNum = size(Caption_ROI,1);
       
        if videoSizePart1_Flag == 0 && ~isempty(v_Part1.Height)
            inputVideoRows_part1 = v_Part1.Height;
            inputVideoColumns_part1 = v_Part1.Width;
            videoSizePart1_Flag = 1;
        end
        if videoSizePart2_Flag == 0 &&  ~isempty(v_Part2.Height)
            inputVideoRows_part2 = v_Part2.Height;
            inputVideoColumns_part2 = v_Part2.Width;
            videoSizePart2_Flag = 1;
        end
        if videoSizePart3_Flag == 0 && ~isempty(v_Part3.Height)
            inputVideoRows_part3 = v_Part3.Height;
            inputVideoColumns_part3 = v_Part3.Width;
            videoSizePart3_Flag = 1;
        end
        if videoSizePart4_Flag == 0 && ~isempty(v_Part4.Height)
            inputVideoRows_part4 = v_Part4.Height;
            inputVideoColumns_part4 = v_Part4.Width;
            videoSizePart4_Flag = 1;
        end
        
        l=1;
        for i = 1 : CaptionNum
            try
                Caption_ROI_AdjustForimcrop = Caption_ROI(i,:) + [0 0 -1 -1];
                % Crop the Frame with existing caption in the video
                CaptionBar  =  imcrop(FrameGrayScale,Caption_ROI_AdjustForimcrop);
                
                compressedframe = imresize(CaptionBar, [ 40 , 200 ] );
            catch
                % Exception occured
                l = 0
            end
            
            if i == 1 && l==1               
                if videoSizePart1_Flag == 1 && (size(CaptionBar , 1) ~=  inputVideoRows_part1 || size(CaptionBar , 2) ~= inputVideoColumns_part1)
                    CaptionBar = imresize(CaptionBar, [inputVideoRows_part1, inputVideoColumns_part1]);
                end
                
                NewsDataP1 = fullfile(strcat(pwd,'\NewsDataP1'));
                if ~exist(NewsDataP1 , 'dir') && captionPart1_Flag == 0
                    mkdir NewsDataP1
                    mkdir NewsDataP1_Normal                    
                    captionPart1_Flag = 1;
                end
                
                cd NewsDataP1
                imwrite(compressedframe, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '.tiff']  , 'tif' );
                cd ..
                cd NewsDataP1_Normal
                imwrite(CaptionBar, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '_Normal','.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );              
                cd ..
                
                open(v_Part1);
                writeVideo(v_Part1 , CaptionBar);
                
                
            elseif i ==  2 && l==1
                if videoSizePart2_Flag == 1 && (size(CaptionBar , 1) ~=  inputVideoRows_part2 || size(CaptionBar , 2) ~= inputVideoColumns_part2)
                    CaptionBar = imresize(CaptionBar, [inputVideoRows_part2, inputVideoColumns_part2]);
                end
                
                NewsDataP2 = fullfile(strcat(pwd,'\NewsDataP2'));
                if ~exist(NewsDataP2 , 'dir') && captionPart2_Flag == 0
                    mkdir NewsDataP2
                    mkdir NewsDataP2_Normal   
                    captionPart2_Flag = 1;
                end
                
                cd NewsDataP2
                imwrite(compressedframe, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '.tiff']  , 'tif' );                
                cd ..                
                cd NewsDataP2_Normal
                imwrite(CaptionBar, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '_Normal','.tiff']  , 'tiff' , 'Resolution' , [500 , 500]);               
                cd ..
                
                open(v_Part2);
                writeVideo(v_Part2 , CaptionBar);

                
            elseif i == 3 && l==1
                if videoSizePart3_Flag == 1 && (size(CaptionBar , 1) ~=  inputVideoRows_part3 || size(CaptionBar , 2) ~= inputVideoColumns_part3)
                    CaptionBar = imresize(CaptionBar, [inputVideoRows_part3, inputVideoColumns_part3]);
                end
                
                NewsDataP3 = fullfile(strcat(pwd,'\NewsDataP3'));
                if ~exist(NewsDataP3 , 'dir') && captionPart3_Flag == 0
                    mkdir NewsDataP3
                    mkdir NewsDataP3_Normal
                    captionPart3_Flag = 1;    
                end
                
                cd(NewsDataP3)
                imwrite(compressedframe, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '.tiff']  , 'tif' );
                cd ..
                cd NewsDataP3_Normal
                imwrite(CaptionBar, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '_Normal','.tiff']  , 'tiff' , 'Resolution' , [500 , 500]);
                cd ..
                
                open(v_Part3);
                writeVideo(v_Part3 , CaptionBar);

                
            elseif i == 4 && l==1
                if videoSizePart4_Flag == 1 && (size(CaptionBar , 1) ~=  inputVideoRows_part4 || size(CaptionBar , 2) ~= inputVideoColumns_part4)
                    CaptionBar = imresize(CaptionBar, [inputVideoRows_part4, inputVideoColumns_part4]);
                end
                
                NewsDataP4 = fullfile(strcat(pwd,'\NewsDataP4'));
                if ~exist(NewsDataP4 , 'dir') && captionPart4_Flag == 0
                    mkdir NewsDataP4
                    mkdir NewsDataP4_Normal
                    captionPart4_Flag = 1;    
                end
                
                cd(NewsDataP4)
                imwrite(compressedframe, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '.tiff']  , 'tif' );
                cd ..
                cd NewsDataP4_Normal
                imwrite(CaptionBar, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '_Normal','.tiff']  , 'tiff' , 'Resolution' , [500 , 500]);
                cd ..
                
                open(v_Part4);
                writeVideo(v_Part4 , CaptionBar);

            end
                       
        end
        
        imwrite(FrameGrayScale , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_All_Captions', '.tiff']  , 'tif' );
        
        Frame_ID = Frame_ID + 1 ;
       
        
        videoSizePart1_Flag = 0;
        videoSizePart2_Flag = 0;
        videoSizePart3_Flag = 0;
        videoSizePart4_Flag = 0;
       
        
    elseif (  strcmp(TextType , 'Graphic : Movie' ) == 1 )
        
        FrameGrayScaleText = FrameGrayScale - FrameGrayScalePast ;
        
        % Detect MSER regions.
        [mserRegions, mserConnComp] = detectMSERFeatures(FrameGrayScaleText, ...
            'RegionAreaRange',[200 1000],'ThresholdDelta', 1 );
        
        % Use regionprops to measure MSER properties
        mserStats = regionprops(mserConnComp, 'BoundingBox' , 'Eccentricity', ...
            'Solidity', 'Extent', 'Euler', 'Image');
        try
            % Compute the aspect ratio using bounding box data.
            bbox = vertcat(mserStats.BoundingBox);
            if ~ isempty(bbox) && ~ isempty(mserStats)
                
                w = bbox(:,3);
                h = bbox(:,4);
                
                aspectRatio = w./h;
                
                % Threshold the data to determine which regions to remove. These thresholds
                % may need to be tuned for other images.
                
                filterIdx = aspectRatio' > 3;
                filterIdx = filterIdx | [mserStats.Eccentricity] > 0.995 ;
                filterIdx = filterIdx | [mserStats.Solidity] < .3;
                filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
                filterIdx = filterIdx | [mserStats.EulerNumber] < -2;
                
                
                % Remove regions
                mserStats(filterIdx) = [];
                mserRegions(filterIdx) = [];
                
                % Get a binary image of the a region, and pad it to avoid boundary effects
                % during the stroke width computation.
                
                regionImage = mserStats(6).Image;
                regionImage = padarray(regionImage, [1 1]);
                
                % Compute the stroke width image.
                distanceImage = bwdist(~regionImage);
                skeletonImage = bwmorph(regionImage, 'thin', inf);
                
                strokeWidthImage = distanceImage;
                strokeWidthImage(~skeletonImage) = 0;
                
                % Compute the stroke width variation metric
                strokeWidthValues = distanceImage(skeletonImage);
                strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
                
                % Threshold the stroke width variation metric
                strokeWidthThreshold = 0.35;
                strokeWidthFilterIdx = strokeWidthMetric > strokeWidthThreshold;
                
                % Process the remaining regions
                for j = 1:numel(mserStats)
                    
                    regionImage = mserStats(j).Image;
                    regionImage = padarray(regionImage, [1 1], 0);
                    
                    distanceImage = bwdist(~regionImage);
                    skeletonImage = bwmorph(regionImage, 'thin', inf);
                    
                    strokeWidthValues = distanceImage(skeletonImage);
                    
                    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
                    
                    strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;
                    
                end
                
                % Remove regions based on the stroke width variation
                mserRegions(strokeWidthFilterIdx) = [];
                mserStats(strokeWidthFilterIdx) = [];
                
                % Get bounding boxes for all the regions
                bboxes = vertcat(mserStats.BoundingBox);
                
                % Convert from the [x y width height] bounding box format to the [xmin ymin
                % xmax ymax] format for convenience.
                xmin = bboxes(:,1);
                ymin = bboxes(:,2);
                xmax = xmin + bboxes(:,3) - 1;
                ymax = ymin + bboxes(:,4) - 1;
                
                % Expand the bounding boxes by a small amount.
                %                 expansionAmount = 0.025;
                expansionAmount = 0.03;
                xmin = (1-expansionAmount) * xmin;
                ymin = (1-expansionAmount) * ymin;
                xmax = (1+expansionAmount) * xmax;
                ymax = (1+expansionAmount) * ymax;
                
                % Clip the bounding boxes to be within the image bounds
                xmin = max(xmin, 1);
                ymin = max(ymin, 1);
                xmax = min(xmax, size( FrameGrayScaleText ,2));
                ymax = min(ymax, size( FrameGrayScaleText ,1));
                
                % Show the expanded bounding boxes
                expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
                IExpandedBBoxes = insertShape(DesiredPartFrameRGB,'Rectangle',expandedBBoxes,'LineWidth',3);
                
                % Compute the overlap ratio
                overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);
                
                % Set the overlap ratio between a bounding box and itself to zero to
                % simplify the graph representation.
                n = size(overlapRatio,1);
                overlapRatio(1:n+1:n^2) = 0;
                
                % Create the graph
                g = graph(overlapRatio);
                
                % Find the connected text regions within the graph
                componentIndices = conncomp(g);
                
                % Merge the boxes based on the minimum and maximum dimensions.
                xmin = accumarray(componentIndices', xmin, [], @min);
                ymin = accumarray(componentIndices', ymin, [], @min);
                xmax = accumarray(componentIndices', xmax, [], @max);
                ymax = accumarray(componentIndices', ymax, [], @max);
                
                % Compose the merged bounding boxes using the [x y width height] format.
                textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
                
                % Remove bounding boxes that only contain one text region
                numRegionsInGroup = histcounts(componentIndices);
                textBBoxes(numRegionsInGroup == 1, :) = [];
                
                % Show the final text detection result.
                ITextRegion = insertShape(DesiredPartFrameRGB, 'Rectangle', textBBoxes,'LineWidth',3);
                
                
            else
                FrameGrayScaleGreat = imbinarize(FrameGrayScale);
                
                imwrite( ~FrameGrayScaleGreat , [ChannelName,'_',ProgramName,'_', num2str(Frame_ID, '%.6d') ,'_Translated_Text_Great' , '.tiff']  , 'tif' , 'Resolution',[500,500]);
                Frame_ID = Frame_ID + 1;
                continue;
                
            end
            %  figure
            %  imshow(ITextRegion)
            %  title('Detected Text')
            
            imwrite( FrameGrayScale , [ChannelName,'_',ProgramName,'_', num2str(Frame_ID, '%.6d') ,'_All' , '.tiff']  , 'tif' , 'Resolution',[500,500]);
            
            FrameGrayScaleText = im2bw(FrameGrayScaleText , 0.03);
            
            FrameGrayScaleText = bwareaopen(FrameGrayScaleText, 5);
            
            %    Input, uint8 GRAY(:,:), the noisy grayscale data.
            %    Output, uint8 GRAY_NEWS(:,:), the grayscale data for the filtered image.
            if (isNoiseFilterSelected)
                [ m, n ] = size ( FrameGrayScaleText );
                FrameGrayScale3d = zeros ( 5, m, n );
                
                %  For pixel (I,J), FrameGrayScale3D(*,I,J) contains the current pixel value
                %  and the four neighboring values.
                
                FrameGrayScale3d(1,:,:) =             FrameGrayScaleText;
                FrameGrayScale3d(2,:,:) = circshift ( FrameGrayScaleText, [  1,  0 ] );
                FrameGrayScale3d(3,:,:) = circshift ( FrameGrayScaleText, [ -1,  0 ] );
                FrameGrayScale3d(4,:,:) = circshift ( FrameGrayScaleText, [  0,  1 ] );
                FrameGrayScale3d(5,:,:) = circshift ( FrameGrayScaleText, [  0, -1 ] );
                
                %  By taking the median of the 5 values, we hope to drop any noisy pixels.
                
                FrameGrayScale3d = median ( FrameGrayScale3d );
                
                %  The MEDIAN command returned a 3D array with a first dimension of 1.
                %  For convenience, we suppress the first dimension.
                
                FrameGrayScale_news(:,:) = FrameGrayScale3d(1,:,:);
                
                %  FrameGrayScale is a UINT8 array.  The MEDIAN operation returned a DOUBLE value.
                %  So we have to convert the array back to UINT8.
                
                FrameGrayScaleText = uint8 ( FrameGrayScale_news );
            end
            
            if ( size(textBBoxes , 1) ==1  )
                % Lucky detected full Text in one box
                
                
                FrameGrayScaleLucky = FrameGrayScaleText;
                
                %invert the image
                [rows, columns] = size(FrameGrayScaleLucky);
                numWhitePixels = sum(FrameGrayScaleLucky);
                numBlackPixels = rows * columns - numWhitePixels;
                if numWhitePixels > numBlackPixels
                    %Background is white.
                    imwrite( FrameGrayScaleLucky , [ChannelName,'_',ProgramName,'_', num2str(Frame_ID, '%.6d') ,'_Lucky_Translated_Text' , '.tiff']  , 'tif' , 'Resolution',[500,500]);
                else
                    imwrite(~FrameGrayScaleLucky , [ChannelName,'_',ProgramName,'_', num2str(Frame_ID, '%.6d') ,'_Lucky_Translated_Text' , '.tiff']  , 'tif' , 'Resolution',[500,500]);
                end
            end
            
        catch
            
            FrameGrayBackground = FrameGrayScale;
            FrameGrayScalePast = FrameGrayScale;
            imwrite(FrameGrayScale , [ChannelName,'_',ProgramName,'_', num2str(Frame_ID, '%.6d'),'_Problem' , '.tiff']  , 'tif' , 'Resolution',[500,500]);
            Frame_ID = Frame_ID + 1;
            continue
        end
        
%         rng('default')
%         
%         load AlexTextNet
%         
%         net = AlexTextNet;
%         
%         [YTestPred,scores] = classify(net,FrameGrayScale);
%         
%         if ( strcmp(YTestPred , 'Text' ) == 1 )
%             
%             objectFrame = step(vidcap);
%             firstFrame = objectFrame;
%             figure;
%             imshow(objectFrame);
%             objectRegion=round(getPosition(imrect));
%             
%             
%             objectFrame = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red');
%             figure;
%             imshow(objectFrame);
%             title('Red box shows object region');
%             
%             points = detectMinEigenFeatures(rgb2gray(objectFrame),'ROI',objectRegion);
%             
%             pointImage = insertMarker(objectFrame,points.Location,'*','Color','green');
%             figure;
%             imshow(pointImage);
%             title('Detected interest points');
%             
%             tracker = vision.PointTracker('MaxBidirectionalError',1);
%             
%             initialize(tracker,points.Location,objectFrame);
%             
%             image_thresholded = ones( 121 , 640 ,3);
%             
%             k=0;
%             N=2;
%             while ~isDone(vidcap)
%                 
%                 secondFrame = step(vidcap);
%                 
%                 [points, validity] = step(tracker,secondFrame);
%                 
%                 Row_min  =  points(1,1);
%                 
%                 Col_min =   min(points(:,2));
%                 
%                 Max =  max(points, [] ,1);
%                 Row_max =  Max(1);
%                 Col_max =  max(points(:,2));
%                 
%                 ROI = [Row_min + N , Col_max + N];
%                 textFrame = imcrop(secondFrame , [Row_min , Col_min , Row_max - Row_min  , Col_max-Col_min ] ) ;
%                 
%                 % perform thresholding by logical indexing
%                 image_thresholded = textFrame;
%                 image_thresholded(textFrame < 0.5) = 1;
%                 image_thresholded(textFrame >= 0.8) = 0;
%                 
%                 image_thresholded_Filt = bwareaopen(image_thresholded, 50);
%                 imwrite(image_thresholded_Filt,['test_16_',int2str(k),'.jpg' ]);
%                 
%                 k=k+1;
%                 
%                 
%                 
%             end
%             
%             release(vidcap);
%             
%             
%         end
        
        
        Frame_ID = Frame_ID + 1;    
        
    elseif (  strcmp(TextType , 'Graphic : Song Lyrics' ) == 1 )
        
        [mserRegions, ~] = detectMSERFeatures(FrameGrayScale);
              
        if mserRegions.Count >= LyricsRegionsThreshold

            
            %  Subtract the background approximation image, |background|, from the
            %  original image ,the resulting image has a uniform background but is now a bit dark for analysis
            CorrBackground = corr2(FrameGrayScale,FrameGrayBackground);
            
            CorrLastFrame =  corr2(FrameGrayScale,FrameGrayScalePast);
            
            if (( CorrBackground >= CorrBackgroundThreshold) && (mserRegions.Count < MSER_Low ))
                
                FrameGrayBackground = FrameGrayScale;
                imwrite(FrameGrayBackground, ['Background_',num2str(Frame_ID, '%.6d') , '.tiff']  , 'tiff' , 'Resolution',[500,500]);
                %  figure , imshow(FrameGrayBackground), hold on
                
            elseif ( CorrLastFrame <= CorrLastFrameThreshold)
                
                MSER_Low = mserRegions.Count;
                
                FrameGrayText = FrameGrayScale - FrameGrayBackground;
                
                FrameGrayText = im2bw(FrameGrayText , 0.05);
                
                FrameGrayTextBinary = bwareaopen(FrameGrayText, 7);
                
                % invert the image
                [rows, columns] = size(FrameGrayTextBinary);
                numWhitePixels = sum(FrameGrayTextBinary);
                numBlackPixels = rows * columns - numWhitePixels;
                if numWhitePixels > numBlackPixels
                    %Background is white.
                    imwrite(FrameGrayTextBinary , ['Translated_Text_',num2str(Frame_ID, '%.6d') , '.tiff']  , 'tiff' , 'Resolution',[500,500]);
                else
                    imwrite(~FrameGrayTextBinary , ['Translated_Text_',num2str(Frame_ID, '%.6d') , '.tiff']  , 'tiff' , 'Resolution',[500,500]);
                end
                
                FrameGrayScalePast = FrameGrayScale;
                
                % captureFrame = -1;
                % figure , imshow(FrameGrayTextBinary), hold on
            end
                                 
        end
        
        Frame_ID = Frame_ID + 1;
        %  figure ,  imshow(DesiredPartFrameRGB) , hold on
        
        
    elseif (  strcmp(TextType , 'Graphic : Fixed Background' ) == 1 )
       

        [mserRegions, mserConnComp] = detectMSERFeatures(FrameGrayScale);
        
    
        if mserRegions.Count >= FixedBackgroundThreshold
            
           if (corr2(FrameGrayScale,FrameGrayScalePast) > FixedBackgroundRelation)
            FrameGrayText = FrameGrayScale  - FrameGrayScalePast;

            % FrameGrayText = imbinarize(FrameGrayText);
            imwrite(FrameGrayText, ['Translated_Text_',num2str(Frame_ID, '%.6d') , '.tiff']  , 'tiff' , 'Resolution',[500,500]);
           end
            
            
            
        else
		
            if (corr2(FrameGrayScale,FrameGrayScalePast) <= FixedBackgroundRelation)
                FrameGrayScalePast =  FrameGrayScale;
                imwrite(FrameGrayScalePast, [' Background_',num2str(Frame_ID, '%.6d'),'.tiff'], 'tiff' , 'Resolution',[500,500]);
            end
        end
        
         Frame_ID = Frame_ID + 1;
    end   
    
end

% Conditions to be done after all frames are written
if (  strcmp(TextType , 'Caption : Scrolling/Static' ) == 1 || strcmp(TextType , 'Caption : Scrolling(Horizontal/Vertical) only' ) == 1 || strcmp(TextType , 'Caption : Static only' ) == 1 )
    
    rng('default')
    
    load AlexNet_News_18a
    
    net = AlexNet_News_18a;
    
    if captionPart1_Flag == 1
        
        P1_FilesPath = 'F:\Total_Code_Final\OutputFolderNews\NewsDataP1';
        P1_FilesPath_Normal = 'F:\Total_Code_Final\OutputFolderNews\NewsDataP1_Normal';
        newsDataImds_P1 = imageDatastore(P1_FilesPath);
        
        YnewsPred_P1 = classify( net , newsDataImds_P1 );
        YnewsPred_P1 = cellstr(YnewsPred_P1);
        save([ChannelName,'_',ProgramName,'_Y_Pred_P1'],'YnewsPred_P1')
        P1_VideoPath = pwd;
        cd NewsDataP1
        
        IndexP1 = 1;
        countP1Text = 0;
        successiveFlag = 1;
        
        
        while ( IndexP1 <= size(YnewsPred_P1,1) )
            
            if ( strcmp(YnewsPred_P1(IndexP1) , 'Caption' ) == 1 )
                if successiveFlag == 1
                    countP1Text = countP1Text + 1;
                else
                    successiveFlag = 0;
                    countP1Text = 0;
                end
            else
                successiveFlag = 0;
            end
            
            if countP1Text == 50
                load CNN_FeEx_Le_Net18a.mat
                CnnNet = CNN_FeEx_Le_Net18a;
                
                featureLayer='Fully_Connected_Layer_1';
                trainingFeatures = activations(CnnNet, newsDataImds_P1, featureLayer, ...
                    'MiniBatchSize', 32, 'OutputAs', 'columns');
                
                FilesP1 = dir(P1_FilesPath);
                fileNumberP1 = 1;
                previousFileIndex = 0;
                diffFileIndex = 0;
                
                for FileIndex = 3 : length(FilesP1)
                    
                    X( 1:4000 , FileIndex-2 ) = trainingFeatures(:,fileNumberP1);
                    
                    filename = fullfile(P1_FilesPath, FilesP1(FileIndex).name);
                    
                    [~,name,~] = fileparts(filename);
                    
                    currentFileIndex = str2double(name(end-12:end-7));
                    
                    diffFileIndex = diffFileIndex + currentFileIndex - previousFileIndex;
                    
                    thisImage = imread(filename);
                    thisImage_Reshapped = reshape(thisImage,[8000,1]);
                    % To be used to determine the direction
                    X_Direction( 1:8000 , FileIndex-2 ) = thisImage_Reshapped;
                    
                    
                    if FileIndex-2 == 1
                        frameGray = thisImage;
                    elseif FileIndex-2 == 50  && diffFileIndex <= 50
                        corrScore = corrMatching(frameGray, thisImage);
                    elseif FileIndex-2 == 10   &&  diffFileIndex > 30
                        corrScore = corrMatching(frameGray, thisImage);
                    end
                    
                    previousFileIndex = currentFileIndex;
                    fileNumberP1 = fileNumberP1 + 1;
                    
                end
                
                load RNN_LSTM_Net18a.mat
                RNNNet = RNN_LSTM_Net18a;
                
                YPred = classify( RNNNet , X , ...
                    'MiniBatchSize',32, ...
                    'SequenceLength','longest' ) ;
                cd ..
                save (strcat(ChannelName,'_',ProgramName,'_RNN_P1') ,  'X' );
                clear X
                break;
                
            end
            
            IndexP1 = IndexP1 + 1;
        end

        % Double check that the classification is correct
        if ( YPred == 'HorizontalMove_1' || corrScore < 0.7 )
            
            load RNN_Direction_Net18a
            RNN_Direction_Net = RNN_Direction_Net18a;
            YPred_Direction = classify( RNN_Direction_Net , X_Direction , ...
                'MiniBatchSize',128, ...
                'SequenceLength','longest' ) ;
            
                    
            getKeyCaption(ChannelName,ProgramName,typeOfSR,P1_FilesPath_Normal,YPred_Direction);
                    
        elseif  (YPred == 'HorizontalMove_2' && corrScore > 0.8 )
            
            newsDataImds_P1 = imageDatastore(P1_FilesPath_Normal);
            
            NewsDataP1_Key = fullfile(strcat(P1_FilesPath_Normal,'NewsDataP1_Key\'));

            if ~exist(NewsDataP1_Key , 'dir')
                mkdir NewsDataP1_Key
            end

            IndexP1_Counter = 1;
            frame_Write = 0;
            
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part1');
                    
            
            while ( IndexP1_Counter <= size(YnewsPred_P1,1) )
                if ( strcmp(YnewsPred_P1(IndexP1_Counter) , 'Caption' ) == 1 && frame_Write == 0 )
                    
                    cd NewsDataP1_Normal
                    for i = 1 : 10
                        RotatingBarBinary = readimage(newsDataImds_P1 , IndexP1_Counter + i);
                        RotatingBarBinary = imbinarize(RotatingBarBinary);
                        gatheredForSR(:,:,i) = RotatingBarBinary;
                        gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                    end
                    
                    cd ..
                    cd NewsDataP1_Key
                    
                    RotatingBarBinary = readimage(newsDataImds_P1,IndexP1_Counter);
                    imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'Key.tiff']);
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter)) ,  'gatheredForSR' );
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter),'_Inverted') ,  'gatheredForSR_inverted');
                    
                    % Apply Super Resolution ( can remove output parameters )
                    [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP1_Counter-1 , typeOfSR);
                    
                    imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    imwrite(HR_Inverted,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    % Save image(s) to word
                    save2word ( ChannelName , ProgramName , IndexP1_Counter-1 , typeOfSR , '_Part1');
                    
                    clearvars gatheredForSR gatheredForSR_inverted

                    cd .. 
                    
                    frame_Write = 1;
                    
                elseif strcmp(YnewsPred_P1(IndexP1_Counter) , 'NoCaption' ) == 1
                    frame_Write = 0;
                end
                
                IndexP1_Counter = IndexP1_Counter +1;
            end
 
            
        elseif  ( ( (YPred == 'VerticalMove_1') || (YPred == 'VerticalMove_2')) && corrScore > 0.8  )

            newsDataImds_P1 = imageDatastore(P1_FilesPath_Normal);
            
            NewsDataP1_Key = fullfile(strcat(P1_FilesPath_Normal,'NewsDataP1_Key'));
            if ~exist(NewsDataP1_Key , 'dir')
                mkdir NewsDataP1_Key
            end
            
            IndexP1_Counter = 1;
            frame_Write = 0;
            
            cd NewsDataP1_Key
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part1');
            cd ..
                    
            while ( IndexP1_Counter <= size(YnewsPred_P1,1) )
                if ( strcmp(YnewsPred_P1(IndexP1_Counter) , 'Caption' ) == 1 && frame_Write == 0 )
                        cd NewsDataP1_Normal
                        for i = 1 : 10
                            RotatingBarBinary = readimage(newsDataImds_P1 , IndexP1_Counter + i);
                            RotatingBarBinary = imbinarize(RotatingBarBinary);
                            gatheredForSR(:,:,i) = RotatingBarBinary;
                            gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                        end

                        cd ..
                        cd NewsDataP1_Key
                        
                        RotatingBarBinary = readimage(newsDataImds_P1,IndexP1_Counter);
                        imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'_Key.tiff']);

                        save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter)) ,  'gatheredForSR' );

                        save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter),'_Inverted') ,  'gatheredForSR_inverted');

                        % Apply Super Resolution ( can remove output parameters )
                        [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP1_Counter-1 , typeOfSR);

                        imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                        
                        imwrite(HR_Inverted,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );

                        % Save image(s) to word
                        save2word ( ChannelName , ProgramName , IndexP1_Counter-1 , typeOfSR , '_Part1');

                        clearvars gatheredForSR gatheredForSR_inverted

                        cd .. 

                        frame_Write = 1;
                elseif strcmp(YnewsPred_P1(IndexP1_Counter) , 'NoCaption' ) == 1
                    frame_Write = 0;
                end
                
                IndexP1_Counter = IndexP1_Counter +1;
            end

        elseif  ( (YPred == 'Static')  && corrScore > 0.8 )

            newsDataImds_P1 = imageDatastore(P1_FilesPath_Normal);
            
            NewsDataP1_Key = fullfile(strcat(P1_FilesPath_Normal,'NewsDataP1_Key'));
            if ~exist(NewsDataP1_Key , 'dir')
                mkdir NewsDataP1_Key
            end
            
            IndexP1_Counter = 1;
            
            cd NewsDataP1_Key
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part1');
            cd ..
                    

            while ( IndexP1_Counter <= size(YnewsPred_P1,1) )
                if ( strcmp(YnewsPred_P1(IndexP1_Counter) , 'Caption' ) == 1 )
                    
                    cd NewsDataP1_Normal
                    for i = 1 : 10
                        RotatingBarBinary = readimage(newsDataImds_P1 , IndexP1_Counter + i);
                        RotatingBarBinary = imbinarize(RotatingBarBinary);
                        gatheredForSR(:,:,i) = RotatingBarBinary;
                        gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                    end
                    
                    cd ..
                    cd NewsDataP1_Key
                    
                    imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'_Key.tiff']);
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter)) ,  'gatheredForSR' );
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter),'_Inverted') ,  'gatheredForSR_inverted');
                    
                    % Apply Super Resolution ( can remove output parameters )
                    [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP1_Counter-1 , typeOfSR);
                    
                    imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    imwrite(HR_Inverted,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP1_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    % Save image(s) to word
                    save2word ( ChannelName , ProgramName , IndexP1_Counter-1 , typeOfSR , '_Part1');
                    
                    clearvars gatheredForSR gatheredForSR_inverted

                    cd .. 

                    break;
                    
                end
                
                IndexP1_Counter = IndexP1_Counter +1;
            end

        end
        
        Footer2word(ChannelName , ProgramName, typeOfSR , toc , '_Part1');
        
        
    end
    
    
    
    if captionPart2_Flag == 1
        
        load AlexNet_News_18a
        net = AlexNet_News_18a;
        
        P2_FilesPath = 'F:\Total_Code_Final\OutputFolderNews\NewsDataP2';
        P2_FilesPath_Normal = 'F:\Total_Code_Final\OutputFolderNews\NewsDataP2_Normal\';
        newsDataImds_P2 = imageDatastore(P2_FilesPath);
        
        YnewsPred_P2 = classify( net , newsDataImds_P2 );
        YnewsPred_P2 = cellstr(YnewsPred_P2);
        save([ChannelName,'_',ProgramName,'_Y_Pred_P2'],'YnewsPred_P2')
        cd(P2_FilesPath)
        
        IndexP2 = 1;
        countP2Text = 0;
        
        while ( IndexP2 <= size(YnewsPred_P2,1) )
            
            if ( strcmp(YnewsPred_P2(IndexP2) , 'Caption' ) == 1 )
                countP2Text = countP2Text + 1;
            else
                countP2Text = 0;
            end
            
            if countP2Text == 20
                load CNN_FeEx_Le_Net18a.mat
                CnnNet = CNN_FeEx_Le_Net18a;
                
                featureLayer='Fully_Connected_Layer_1';
                trainingFeatures = activations(CnnNet, newsDataImds_P2, featureLayer, ...
                    'MiniBatchSize', 32, 'OutputAs', 'columns');
                
                FilesP2 = dir(P2_FilesPath);
                fileNumberP2 = 1;
                previousFileIndex = 0;
                diffFileIndex = 0;
                
                for FileIndex = 3 : length(FilesP2)
                    
                    X( 1:4000 , FileIndex-2 ) = trainingFeatures(:,fileNumberP2);
                    
                    filename = fullfile(P2_FilesPath, FilesP2(FileIndex).name);
                                        
                    [~,name,~] = fileparts(filename);
                    
                    currentFileIndex = str2double(name(end-12:end-7));
                    
                    diffFileIndex = diffFileIndex + currentFileIndex - previousFileIndex;
                    
                    thisImage = imread(filename);
                    
                    if FileIndex-2 == 1
                        frameGray = thisImage;
                    elseif FileIndex-2 == 50 && diffFileIndex <= 50
                        corrScore = corrMatching(frameGray, thisImage);
                    elseif FileIndex-2 == 10 &&  diffFileIndex > 30
                        corrScore = corrMatching(frameGray, thisImage);                        
                    end
                    
                    previousFileIndex = currentFileIndex;
                    fileNumberP2 = fileNumberP2 + 1;
                    
                end
                
                load RNN_LSTM_Net18a.mat
                RNNNet = RNN_LSTM_Net18a;
                
                YPred = classify( RNNNet , X , ...
                    'MiniBatchSize',32, ...
                    'SequenceLength','longest' ) ;
                
                cd ..
                save (strcat(ChannelName,'_',ProgramName,'_RNN_P2') ,  'X' );
                clear X
                break;
                
            end
            
            IndexP2 = IndexP2 + 1;
        end

        
        % Double check that the classification is correct
        if  ( YPred == 'HorizontalMove_1'  && corrScore > 0.95 )
            YPred = categorical({'Static'});
        end
        
        if  ( ( (YPred == 'VerticalMove_1') || (YPred == 'VerticalMove_2') || YPred == 'HorizontalMove_2' ) || corrScore > 0.8  )

            newsDataImds_P2 = imageDatastore(P2_FilesPath_Normal);
            
            NewsDataP2_Key = fullfile(strcat(P2_FilesPath_Normal,'NewsDataP2_Key'));
            if ~exist(NewsDataP2_Key , 'dir')
                mkdir NewsDataP2_Key
            end
            
            IndexP2_Counter = 1;
            frame_Write = 0;
            
            cd NewsDataP2_Key 
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part2');
            cd ..
                    
            while ( IndexP2_Counter <= size(YnewsPred_P2,1) )
                if ( strcmp(YnewsPred_P2(IndexP2_Counter) , 'Caption' ) == 1 && frame_Write == 0 )
                    
                    cd(P2_FilesPath_Normal)
                    for i = 1 : 10
                        RotatingBarBinary = readimage(newsDataImds_P2 , IndexP2_Counter + i);
                        RotatingBarBinary = imbinarize(RotatingBarBinary);
                        gatheredForSR(:,:,i) = RotatingBarBinary;
                        gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                    end
                    
                    cd ..
                    cd NewsDataP2_Key

                    RotatingBarBinary = readimage(newsDataImds_P2,IndexP2_Counter);
                    imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter-1, '%.6d'),'_Key.tiff']);
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter)) ,  'gatheredForSR' );
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter),'_Inverted') ,  'gatheredForSR_inverted');
                    
                    % Apply Super Resolution ( can remove output parameters )
                    [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP2_Counter-1 , typeOfSR);
                    
                   imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );

                   imwrite(HR_Inverted,[pwd,'\' ,ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] ); 
                    
                    % Save image(s) to word
                    save2word ( ChannelName , ProgramName , IndexP2_Counter-1 , typeOfSR , '_Part2');
                    
                    clearvars gatheredForSR gatheredForSR_inverted

                    cd .. 
                    
                    frame_Write = 1;
                    
                elseif strcmp(YnewsPred_P2(IndexP2_Counter) , 'NoCaption' ) == 1
                    frame_Write = 0;
                end
                
                IndexP2_Counter = IndexP2_Counter +1;
            end

            
        elseif  ( (YPred == 'Static')  && corrScore > 0.8 )

            newsDataImds_P2 = imageDatastore(P2_FilesPath_Normal);
            
            NewsDataP2_Key = fullfile(strcat(P2_FilesPath_Normal,'NewsDataP2_Key'));
            if ~exist(NewsDataP2_Key , 'dir')
                mkdir NewsDataP2_Key
            end
            
            IndexP2_Counter = 1;
            
            cd NewsDataP2_Key 
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part2');
            cd ..
                    

            while ( IndexP2_Counter <= size(YnewsPred_P2,1) )
                if ( strcmp(YnewsPred_P2(IndexP2_Counter) , 'Caption' ) == 1  )
                    
                    cd(P2_FilesPath_Normal)
                    for i = 1 : 10
                        RotatingBarBinary = readimage(newsDataImds_P2 , IndexP2_Counter + i);
                        RotatingBarBinary = imbinarize(RotatingBarBinary);
                        gatheredForSR(:,:,i) = RotatingBarBinary;
                        gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                    end
                    
                    cd ..
                    cd NewsDataP2_Key
                    
                    imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter-1, '%.6d'),'_Key.tiff']);
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter)) ,  'gatheredForSR' );
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter),'_Inverted') ,  'gatheredForSR_inverted');
                    
                    % Apply Super Resolution ( can remove output parameters )
                    [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP2_Counter-1 , typeOfSR);
                    
                    imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    imwrite(HR_Inverted,[pwd,'\' ,ChannelName,'_',ProgramName,'_',num2str(IndexP2_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    % Save image(s) to word
                    save2word ( ChannelName , ProgramName , IndexP2_Counter-1 , typeOfSR , '_Part2');
                    
                    clearvars gatheredForSR gatheredForSR_inverted

                    cd .. 
                    
                    break;
                end
                
                IndexP2_Counter = IndexP2_Counter +1;
            end

        end
        
        Footer2word(ChannelName , ProgramName, typeOfSR , toc , '_Part2');
        
    end
    
    
    if captionPart3_Flag == 1
        
        load AlexNet_News_18a
        net = AlexNet_News_18a;
        P3_FilesPath = 'F:\Total_Code_Final\OutputFolderNews\NewsDataP3';
        P3_FilesPath_Normal = 'F:\Total_Code_Final\OutputFolderNews\NewsDataP3_Normal\';
        newsDataImds_P3 = imageDatastore(P3_FilesPath);
        
        YnewsPred_P3 = classify( net , newsDataImds_P3 );
        YnewsPred_P3 = cellstr(YnewsPred_P3);
        save([ChannelName,'_',ProgramName,'_Y_Pred_P3'],'YnewsPred_P3')
        cd(NewsDataP3)
        
        IndexP3 = 1;
        countP3Text = 0;
        
        while ( IndexP3 <= size(YnewsPred_P3,1) )
            
            if ( strcmp(YnewsPred_P3(IndexP3) , 'Caption' ) == 1 )
                
                countP3Text = countP3Text + 1;
            else
                
                countP3Text = 0;
            end

            
            if countP3Text == 50
                load CNN_FeEx_Le_Net18a.mat
                CnnNet = CNN_FeEx_Le_Net18a;
                
                featureLayer='Fully_Connected_Layer_1';
                trainingFeatures = activations(CnnNet, newsDataImds_P3, featureLayer, ...
                    'MiniBatchSize', 32, 'OutputAs', 'columns');
                
                FilesP3 = dir(P3_FilesPath);
                fileNumberP3 = 1;
                previousFileIndex = 0;
                diffFileIndex = 0;
                
                for FileIndex = 3 : length(FilesP3)
                    
                    X( 1:4000 , FileIndex-2 ) = trainingFeatures(:,fileNumberP3);
                    
                    filename = fullfile(P3_FilesPath, FilesP3(FileIndex).name);
                    
                    [~,name,~] = fileparts(filename);
                    
                    currentFileIndex = str2double(name(end-12:end-7));
                    
                    diffFileIndex = diffFileIndex + currentFileIndex - previousFileIndex;
                    
                    thisImage = imread(filename);
                    
                    if FileIndex-2 == 1
                        frameGray = thisImage;
                    elseif FileIndex-2 == 50   && diffFileIndex <= 50
                        corrScore = corrMatching(frameGray, thisImage);
                    elseif FileIndex-2 == 10   &&  diffFileIndex > 30
                        corrScore = corrMatching(frameGray, thisImage);
                    end
                    
                    previousFileIndex = currentFileIndex;
                    fileNumberP3 = fileNumberP3 + 1;
                    
                end
                
                load RNN_LSTM_Net18a.mat
                RNNNet = RNN_LSTM_Net18a;
                
                YPred = classify( RNNNet , X , ...
                    'MiniBatchSize',32, ...
                    'SequenceLength','longest' ) ;
                
                cd ..
                save (strcat(ChannelName,'_',ProgramName,'_RNN_P3') ,  'X' );
                clear X
                break;
                
            end
            
            IndexP3 = IndexP3 + 1;
        end
        

        if  ( YPred == 'HorizontalMove_1'  && corrScore > 0.95 )
            YPred = categorical({'Static'});
        end
        
        % Double check that the classification is correct
        if  ( ( (YPred == 'VerticalMove_1') || (YPred == 'VerticalMove_2') || YPred == 'HorizontalMove_2' ) || corrScore > 0.8  )

            newsDataImds_P3 = imageDatastore(P3_FilesPath_Normal);
            
            NewsDataP3_Key = fullfile(strcat(P3_FilesPath_Normal,'NewsDataP3_Key'));
            if ~exist(NewsDataP3_Key , 'dir')
                mkdir NewsDataP3_Key
            end
            
            IndexP3_Counter = 1;
            frame_Write = 0;
            
            cd NewsDataP3_Key
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part3');
            cd ..
                    
            
            while ( IndexP3_Counter <= size(YnewsPred_P3,1) )
                if ( strcmp(YnewsPred_P3(IndexP3_Counter) , 'Caption' ) == 1 && frame_Write == 0 )
                    
                    cd(P3_FilesPath_Normal)
                    for i = 1 : 10
                        RotatingBarBinary = readimage(newsDataImds_P3 , IndexP3_Counter + i);
                        RotatingBarBinary = imbinarize(RotatingBarBinary);
                        gatheredForSR(:,:,i) = RotatingBarBinary;
                        gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                    end
                    
                    cd ..
                    cd NewsDataP3_Key 

                    RotatingBarBinary = readimage(newsDataImds_P3,IndexP3_Counter);
                    imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter-1, '%.6d'),'_Key.tiff']);
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter)) ,  'gatheredForSR' );
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter),'_Inverted') ,  'gatheredForSR_inverted');
                    
                    % Apply Super Resolution ( can remove output parameters )
                    [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP3_Counter-1 , typeOfSR);
                    
                    imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );

                    imwrite(HR_Inverted,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    % Save image(s) to word
                    save2word ( ChannelName , ProgramName , IndexP3_Counter-1 , typeOfSR , '_Part3');
                    
                    clearvars gatheredForSR gatheredForSR_inverted

                    cd .. 
                    
                    frame_Write = 1;
                    
                elseif strcmp(YnewsPred_P3(IndexP3_Counter) , 'NoCaption' ) == 1
                    frame_Write = 0;
                end
                
                IndexP3_Counter = IndexP3_Counter +1;
            end
            
        elseif  ( (YPred == 'Static')  || corrScore > 0.8 )
            
            cd ..
            cd(P3_FilesPath_Normal)
            newsDataImds_P3 = imageDatastore(P3_FilesPath_Normal);
            
            NewsDataP3_Key = fullfile(strcat(P3_FilesPath_Normal,'NewsDataP3_Key'));
            if ~exist(NewsDataP3_Key , 'dir')
                mkdir NewsDataP3_Key
            end
            
            IndexP3_Counter = 1;
            
            cd ..
            cd NewsDataP3_Key
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part3');
            cd ..
                    
            
            while ( IndexP3_Counter <= size(YnewsPred_P3,1) )
                if ( strcmp(YnewsPred_P3(IndexP3_Counter) , 'Caption' ) == 1  )
                    
                    cd(P3_FilesPath_Normal)
                    for i = 1 : 10
                        RotatingBarBinary = readimage(newsDataImds_P3 , IndexP3_Counter + i);
                        RotatingBarBinary = imbinarize(RotatingBarBinary);
                        gatheredForSR(:,:,i) = RotatingBarBinary;
                        gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                    end
                    
                    cd ..
                    cd NewsDataP3_Key

                    imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter-1, '%.6d'),'_Key.tiff']);
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter)) ,  'gatheredForSR' );
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter),'_Inverted') ,  'gatheredForSR_inverted');
                    
                    % Apply Super Resolution ( can remove output parameters )
                    [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP3_Counter-1 , typeOfSR);
                    
                    imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    imwrite(HR_Inverted,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP3_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    % Save image(s) to word
                    save2word ( ChannelName , ProgramName , IndexP3_Counter-1 , typeOfSR , '_Part3');
                    
                    clearvars gatheredForSR gatheredForSR_inverted

                    cd .. 
                    
                    break;
                end
                
                IndexP3_Counter = IndexP3_Counter +1;
            end
        end
        
        Footer2word(ChannelName , ProgramName, typeOfSR , toc , '_Part3');
        
    end
    
    
    if captionPart4_Flag == 1
        
        load AlexNet_News_18a
        net = AlexNet_News_18a;
        P4_FilesPath = 'F:\Total_Code_Final\OutputFolderNews\NewsDataP4';
        P4_FilesPath_Normal = 'F:\Total_Code_Final\OutputFolderNews\NewsDataP4_Normal\';
        newsDataImds_P4 = imageDatastore(P4_FilesPath);
        
        YnewsPred_P4 = classify( net , newsDataImds_P4 );
        YnewsPred_P4 = cellstr(YnewsPred_P4);
        save([ChannelName,'_',ProgramName,'_Y_Pred_P4'],'YnewsPred_P4')
        cd(NewsDataP4)
        
        IndexP4 = 1;
        countP4Text = 0;
        
        while ( IndexP4 <= size(YnewsPred_P4,1) )
            
            if ( strcmp(YnewsPred_P4(IndexP4) , 'Caption' ) == 1 )
                countP4Text = countP4Text + 1;
            else
                countP4Text = 0;
            end
            
            if countP4Text == 50
                load CNN_FeEx_Le_Net18a.mat
                CnnNet = CNN_FeEx_Le_Net18a;
                
                featureLayer='Fully_Connected_Layer_1';
                trainingFeatures = activations(CnnNet, newsDataImds_P4, featureLayer, ...
                    'MiniBatchSize', 32, 'OutputAs', 'columns');
                
                FilesP4 = dir(P4_FilesPath);
                fileNumberP4 = 1;
                previousFileIndex = 0;
                diffFileIndex = 0;
                for FileIndex = 3 : length(FilesP4)
                    
                    X( 1:4000 , FileIndex-2 ) = trainingFeatures(:,fileNumberP4);
                    
                    filename = fullfile(P4_FilesPath, FilesP4(FileIndex).name);
                                        
                    [~,name,~] = fileparts(filename);
                    
                    currentFileIndex = str2double(name(end-12:end-7));
                    
                    diffFileIndex = diffFileIndex + currentFileIndex - previousFileIndex;
                    
                    thisImage = imread(filename);
                    
                    
                    if FileIndex-2 == 1
                        frameGray = thisImage;
                    elseif FileIndex-2 == 50   && diffFileIndex <= 50
                        corrScore = corrMatching(frameGray, thisImage);
                    elseif FileIndex-2 == 10   &&  diffFileIndex > 30
                        corrScore = corrMatching(frameGray, thisImage);
                    end
                    
                    previousFileIndex = currentFileIndex;
                    fileNumberP4 = fileNumberP4 + 1;
                    
                end
                
                load RNN_LSTM_Net18a.mat
                RNNNet = RNN_LSTM_Net18a;
                
                YPred = classify( RNNNet , X , ...
                    'MiniBatchSize',32, ...
                    'SequenceLength','longest' ) ;
                
                cd ..
                save (strcat(ChannelName,'_',ProgramName,'_RNN_P4') ,  'X' );
                clear X
                break;
                
            end
            
            IndexP4 = IndexP4 + 1;
        end
        
        if  ( YPred == 'HorizontalMove_1'  && corrScore > 0.95 )
            YPred = categorical({'Static'});
        end
        
        % Double check that the classification is correct
        if  ( ( (YPred == 'VerticalMove_1') || (YPred == 'VerticalMove_2') || YPred == 'HorizontalMove_2' ) && corrScore < 0.8  )

            newsDataImds_P4 = imageDatastore(P4_FilesPath_Normal);
            
            NewsDataP4_Key = fullfile(strcat(P4_FilesPath_Normal,'NewsDataP4_Key'));
            if ~exist(NewsDataP4_Key , 'dir')
                mkdir NewsDataP4_Key
            end
            
            IndexP4_Counter = 1;
            frame_Write = 0;

            cd NewsDataP4_Key
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part4');
            cd ..
                    
                        
            while ( IndexP4_Counter <= size(YnewsPred_P4,1) )
                if ( strcmp(YnewsPred_P4(IndexP4_Counter) , 'Caption' ) == 1 && frame_Write == 0 )
                    
                    cd(P4_FilesPath_Normal)
                    for i = 1 : 10
                        RotatingBarBinary = readimage(newsDataImds_P4 , IndexP4_Counter + i);
                        RotatingBarBinary = imbinarize(RotatingBarBinary);
                        gatheredForSR(:,:,i) = RotatingBarBinary;
                        gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                    end
                    
                    cd ..
                    cd NewsDataP4_Key

                    RotatingBarBinary = readimage(newsDataImds_P4,IndexP4_Counter);
                    imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter-1, '%.6d'),'_Key.tiff']);
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter)) ,  'gatheredForSR' );
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter),'_Inverted') ,  'gatheredForSR_inverted');
                    
                    % Apply Super Resolution ( can remove output parameters )
                    [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP4_Counter-1 , typeOfSR);
                    
                    imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    imwrite(HR_Inverted,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    % Save image(s) to word
                    save2word ( ChannelName , ProgramName , IndexP4_Counter-1 , typeOfSR , '_Part4');
                    
                    clearvars gatheredForSR gatheredForSR_inverted

                    cd .. 
                    
                    frame_Write = 1;
                    
                elseif strcmp(YnewsPred_P4(IndexP4_Counter) , 'NoCaption' ) == 1
                    frame_Write = 0;
                end
                
                IndexP4_Counter = IndexP4_Counter +1;
            end
            
        elseif  ( (YPred == 'Static')  && corrScore > 0.8 )
            
            newsDataImds_P4 = imageDatastore(P4_FilesPath_Normal);
            
            NewsDataP4_Key = fullfile(strcat(P4_FilesPath_Normal,'NewsDataP4_Key'));
            if ~exist(NewsDataP4_Key , 'dir')
                mkdir NewsDataP4_Key
            end
            
            IndexP4_Counter = 1;
            
            cd NewsDataP4_Key
            % Create document to save results
            header2word(ChannelName , ProgramName , typeOfSR , '_Part4');
            cd ..
                   
            while ( IndexP4_Counter <= size(YnewsPred_P4,1) )
                if ( strcmp(YnewsPred_P4(IndexP4_Counter) , 'Caption' ) == 1  )
                    
                    cd(P4_FilesPath_Normal)
                    for i = 1 : 10
                        RotatingBarBinary = readimage(newsDataImds_P4 , IndexP4_Counter + i);
                        RotatingBarBinary = imbinarize(RotatingBarBinary);
                        gatheredForSR(:,:,i) = RotatingBarBinary;
                        gatheredForSR_inverted(:,:,i) = ~RotatingBarBinary;
                    end
                    
                    cd ..
                    cd NewsDataP4_Key 

                    imwrite(RotatingBarBinary,[ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter-1, '%.6d'),'._Key.tiff']);
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter)) ,  'gatheredForSR' );
                    
                    save (strcat(ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter),'_Inverted') ,  'gatheredForSR_inverted');
                    
                    % Apply Super Resolution ( can remove output parameters )
                    [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , IndexP4_Counter-1 , typeOfSR);
                    
                    imwrite(HR,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter-1, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    imwrite(HR_Inverted,[pwd,'\',ChannelName,'_',ProgramName,'_',num2str(IndexP4_Counter-1, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                    
                    % Save image(s) to word
                    save2word ( ChannelName , ProgramName , IndexP4_Counter-1 , typeOfSR , '_Part4');
                    
                    clearvars gatheredForSR gatheredForSR_inverted

                    cd .. 
                    
                    break;
                end
                
                IndexP4_Counter = IndexP4_Counter +1;
            end
        end
        
        Footer2word(ChannelName , ProgramName, typeOfSR , toc , '_Part4');
       
    end
    
    close(v_Part1);
    close(v_Part2);
    close(v_Part3);
    close(v_Part4);
end

%%%%%%%%%%%%%%%%%%%%%%            OCR                  %%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------

%Tesseract OCR
if (isArabicLanguageSelected == true)
    ocrtxt = ocr(FrameGrayScale ,'Language' , 'C:\Program Files (x86)\Tesseract-OCR\tessdata\ara.traineddata');
else
    ocrtxt = ocr(FrameGrayScale);
end


%ABBYY OCR
% % % % JavaObject = TestApp;
% % % % if (isArabicLanguageSelected == true)
% % % %     javaMethod('main' , JavaObject , {'recognize' ,  'News.png' , 'Matlab_test2.txt' , '--lang=Arabic'} );
% % % % else
% % % %     javaMethod('main' , JavaObject , {'recognize' ,  'News.png' , 'Matlab_test2.txt' , '--lang=English'} );
% % % % end
% % % % fileID = fopen('Matlab_test2.txt','r');
% % % % fscanf(fileID,'%c')
% % % % fclose(fileID);
% slCharacterEncoding('UTF-8')
% type Matlab_test2.txt

% -------------------------------------------------------------------------



% get prcocessing time and display it
toc
totalProcessingTime = toc;
set(handles.edit_ProcessingTime,'String',num2str(totalProcessingTime));

% Footer2word(ChannelName , ProgramName, typeOfSR , elapsedTime);

% cd(CurrentPath);
vidcap.delete();
cd ..


% --- Outputs from this function are returned to the command line.
function varargout = TextExtractor_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
 varargout{1} = handles.output;



function edit_ProgramName_Callback(hObject, ~, handles)
% hObject    handle to edit_ProgramName (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ProgramName as text
%        str2double(get(hObject,'String')) returns contents of edit_ProgramName as a double
global ProgramName

ProgramName = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function edit_ProgramName_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_ProgramName (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ChannelName_Callback(hObject, ~, handles)
% hObject    handle to edit_ChannelName (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ChannelName as text
%        str2double(get(hObject,'String')) returns contents of edit_ChannelName as a double

global ChannelName
ChannelName = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function edit_ChannelName_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_ChannelName (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_LoadSeparator_Callback(hObject, ~, handles)
% hObject    handle to edit_LoadSeparator (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_LoadSeparator as text
%        str2double(get(hObject,'String')) returns contents of edit_LoadSeparator as a double




% --- Executes during object creation, after setting all properties.
function edit_LoadSeparator_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_LoadSeparator (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_LoadVideo_Callback(hObject, ~, handles)
% hObject    handle to edit_LoadVideo (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_LoadVideo as text
%        str2double(get(hObject,'String')) returns contents of edit_LoadVideo as a double


% --- Executes during object creation, after setting all properties.
function edit_LoadVideo_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_LoadVideo (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_Separator.
function pushbutton_Separator_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Separator (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global SeparatorPath
SeparatorPath = uigetdir(pwd,'MATLAB Root Folder');
set(handles.edit_LoadSeparator,'String', SeparatorPath );


% --- Executes on button press in pushbutton_LoadVideo.
function pushbutton_LoadVideo_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_LoadVideo (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global OutputPath 
global VideoPath
global VideoName
global ChannelName
global ProgramName
global actx
global FramesRate
global VideoDuration
global NumberOfFrames


[VideoName, VideoPath] = uigetfile('*.*','Please select a file');
set(handles.edit_LoadVideo,'String',strcat(VideoPath , VideoName));
VideoPath = strcat(VideoPath , VideoName);
OutputPath = strcat(VideoPath  , '_', ChannelName , '_' , ProgramName);

vidcap = VideoReader(VideoPath);

FramesRate = vidcap.FrameRate;
VideoDuration = vidcap.Duration;
NumberOfFrames = vidcap.NumberOfFrames;

set(handles.edit_VideoDuration,'String',num2str(VideoDuration));
set(handles.edit_totalFrames,'String',num2str(NumberOfFrames));
set(handles.edit_EndFrame,'String',num2str(NumberOfFrames));


% try
%     actx.controls.stop();
% catch
% end
% 
% actx = actxcontrol('WMPlayer.ocx.7',[23 ,23,290,350], TextExtractor ); % Create Controller
% 
% actx.URL = VideoPath; % Create Media object
% actx.controls.play();
% vidcap.delete();

% --- Executes on button press in pushbutton_Show.
function pushbutton_Show_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Show (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global StartFrame
global EndFrame
global VideoPath
global NumberOfFrames
global CurrentFrame
global NumberOfSkippedFrames

VideoPath = get(handles.edit_LoadVideo,'String');
vidcap = VideoReader(VideoPath);

FramesRate = vidcap.FrameRate;
VideoDuration = vidcap.Duration;
NumberOfFrames = ceil(FramesRate * VideoDuration);


StartFrame = str2num(get(handles.edit_StartFrame,'String'));
EndFrame = str2num(get(handles.edit_EndFrame,'String')); 
CurrentFrame = str2num(get(handles.edit_Frame,'String')); 
DisplayFrame = CurrentFrame;
if isempty(EndFrame)
    set(handles.edit_EndFrame,'String',num2str(NumberOfFrames));
    EndFrame = str2num(get(handles.edit_EndFrame,'String')); 
end

if (CurrentFrame < StartFrame) || (CurrentFrame > EndFrame) 
    CurrentFrame = StartFrame ;
    set(handles.edit_Frame,'String',num2str(CurrentFrame));
end

NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
AxesIndex = 1;
vidcap = VideoReader(VideoPath);


for i = 1 : 6
    if DisplayFrame > EndFrame
        break;
    end
    ShowFrame = read(vidcap , DisplayFrame );
    AxesUsed = sprintf('axes%d', AxesIndex);
    EditFieldAxesUsed = sprintf('edit_frame_axes%d', AxesIndex);
    axes(handles.(AxesUsed));
    imshow(ShowFrame);
    set(handles.(EditFieldAxesUsed),'String',num2str(DisplayFrame));
    DisplayFrame = DisplayFrame + NumberOfSkippedFrames;
    AxesIndex = AxesIndex + 1;
end
% set(handles.axes1,'ButtondownFcn',{'@axes1_ButtonDownFcn', handles});
% vidcap.delete();
% guidata(hObject, handles);

function edit_Frame_Callback(hObject, ~, handles)
% hObject    handle to edit_Frame (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Frame as text
%        str2double(get(hObject,'String')) returns contents of edit_Frame as a double


% --- Executes during object creation, after setting all properties.
function edit_Frame_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_Frame (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_VideoDuration_Callback(hObject, ~, handles)
% hObject    handle to edit_VideoDuration (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_VideoDuration as text
%        str2double(get(hObject,'String')) returns contents of edit_VideoDuration as a double


% --- Executes during object creation, after setting all properties.
function edit_VideoDuration_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_VideoDuration (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_SelectStartFrame.
function pushbutton_SelectStartFrame_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_SelectStartFrame (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global  StartFrame

StartFrame = str2num(get(handles.edit_StartFrame,'String')) ;
if StartFrame < 1
    StartFrame = 1;
    set(handles.edit_StartFrame,'String',num2str(StartFrame));
end

% --- Executes on button press in pushbutton_SelectEndFrame.
function pushbutton_SelectEndFrame_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_SelectEndFrame (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global StartFrame
global EndFrame
global NumberOfFrames

EndFrame = str2num(get(handles.edit_EndFrame,'String')); 
if EndFrame < StartFrame
    EndFrame = StartFrame + 10 ;
    set(handles.edit_EndFrame,'String',num2str(EndFrame));
elseif EndFrame > NumberOfFrames
    EndFrame = NumberOfFrames ;
    set(handles.edit_EndFrame,'String',num2str(EndFrame));
end

function edit_StartFrame_Callback(hObject, ~, handles)
% hObject    handle to edit_StartFrame (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StartFrame as text
%        str2double(get(hObject,'String')) returns contents of edit_StartFrame as a double


% --- Executes during object creation, after setting all properties.
function edit_StartFrame_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_StartFrame (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_EndFrame_Callback(hObject, ~, handles)
% hObject    handle to edit_EndFrame (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EndFrame as text
%        str2double(get(hObject,'String')) returns contents of edit_EndFrame as a double



% --- Executes during object creation, after setting all properties.
function edit_EndFrame_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_EndFrame (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_totalFrames_Callback(hObject, ~, handles)
% hObject    handle to edit_totalFrames (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_totalFrames as text
%        str2double(get(hObject,'String')) returns contents of edit_totalFrames as a double


% --- Executes during object creation, after setting all properties.
function edit_totalFrames_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_totalFrames (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_MarkedPart.
function popupmenu_MarkedPart_Callback(hObject, ~, handles)
% hObject    handle to popupmenu_MarkedPart (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_MarkedPart contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_MarkedPart
global MarkedPart
items = get(hObject,'String');
index_selected = get(hObject,'Value');
MarkedPart = items{index_selected};
display(MarkedPart);

% --- Executes during object creation, after setting all properties.
function popupmenu_MarkedPart_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu_MarkedPart (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_TextType.
function popupmenu_TextType_Callback(hObject, ~, handles)
% hObject    handle to popupmenu_TextType (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_TextType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_TextType
global TextType 
items = get(hObject,'String');
index_selected = get(hObject,'Value');
TextType = items{index_selected};
display(TextType);

% --- Executes during object creation, after setting all properties.
function popupmenu_TextType_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu_TextType (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_Classifier.
function popupmenu_Classifier_Callback(hObject, ~, handles)
% hObject    handle to popupmenu_Classifier (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_Classifier contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_Classifier

global Classifier

items = get(hObject,'String');
index_selected = get(hObject,'Value');
Classifier = items{index_selected};
display(Classifier);


% --- Executes during object creation, after setting all properties.
function popupmenu_Classifier_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu_Classifier (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_FeatureExtraction.
function popupmenu_FeatureExtraction_Callback(hObject, ~, handles)
% hObject    handle to popupmenu_FeatureExtraction (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_FeatureExtraction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_FeatureExtraction

global FeatureExtractor

items = get(hObject,'String');
index_selected = get(hObject,'Value');
FeatureExtractor = items{index_selected};
display(FeatureExtractor);


% --- Executes during object creation, after setting all properties.
function popupmenu_FeatureExtraction_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu_FeatureExtraction (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_EdgeDetector.
function popupmenu_EdgeDetector_Callback(hObject, ~, handles)
% hObject    handle to popupmenu_EdgeDetector (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% returns popupmenu_EdgeDetector contents as cell array
% contents = cellstr(get(hObject,'String')); 

global EdgeDetector

items = get(hObject,'String');
% returns selected item from popupmenu_EdgeDetector
index_selected = get(hObject,'Value');
EdgeDetector = items{index_selected};
display(EdgeDetector);


% --- Executes during object creation, after setting all properties.
function popupmenu_EdgeDetector_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu_EdgeDetector (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ProcessingTime_Callback(hObject, ~, handles)
% hObject    handle to edit_ProcessingTime (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ProcessingTime as text
%        str2double(get(hObject,'String')) returns contents of edit_ProcessingTime as a double


% --- Executes during object creation, after setting all properties.
function edit_ProcessingTime_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_ProcessingTime (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton_Language.
function togglebutton_Language_Callback(hObject, ~, handles)
% hObject    handle to togglebutton_Language (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_Language

global isArabicLanguageSelected
button_state = get(hObject,'Value');

if button_state == get(hObject,'Max')
    isArabicLanguageSelected = false;
    set(handles.togglebutton_Language,'value',1); % set to the English language
    set(handles.togglebutton_Language,'String','English'); % set to the English language    

elseif button_state == get(hObject,'Min')
    isArabicLanguageSelected = true;
    set(handles.togglebutton_Language,'value',0);  % set to the Arabic language
    set(handles.togglebutton_Language,'String','Arabic'); % set to the Arabic language    

end


% --- Executes on button press in checkbox_NoiseFiltering.
function checkbox_NoiseFiltering_Callback(hObject, ~, handles)
% hObject    handle to checkbox_NoiseFiltering (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_NoiseFiltering

global isNoiseFilterSelected
if (get(hObject,'Value') == get(hObject,'Max')) 
    isNoiseFilterSelected = true;
    display('Noise Filtering is Selected');
else
    isNoiseFilterSelected = false;
    display('Noise Filtering is NOT Selected');
end

% %For Test Purpose
% JavaObject = TestApp;
% javaMethod('main' , JavaObject , {'recognize' ,  'News.png' , 'Matlab_test2.txt' , '--lang=Arabic'} );


% --------------------------------------------------------------------
function activex1_Click(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
% handles.activex1.URL = 'Sample1SkyNews.avi'
% handles.activex1.controls.play();
% global VideoPath
% global VideoName
% global actx
% 
% global FramesRate
% global NumberOfFrames
% global VideoDuration

% actx = actxcontrol('WMPlayer.ocx.7',[35 ,30,290,360], TextExtractor ); % Create Controller
% 
% actx.URL = VideoPath; % Create Media object
% actx.controls.play();
% 
% vidcap = VideoReader(VideoPath);l
% 
% FramesRate = vidcap.FrameRate;
% VideoDuration = vidcap.Duration;
% NumberOfFrames = ceil(FramesRate * VideoDuration);
% set(handles.edit_VideoDuration,'String',num2str(VideoDuration));
% set(handles.edit_totalFrames,'String',num2str(NumberOfFrames));
% set(handles.edit_EndFrame,'String',num2str(NumberOfFrames));

% --------------------------------------------------------------------
function activex1_OpenStateChange(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_PlayStateChange(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_StatusChange(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_NewStream(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_EndOfStream(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_CurrentPlaylistChange(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_MediaChange(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_CurrentItemChange(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_MediaCollectionAttributeStringChanged(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_PlayerReconnect(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function activex1_KeyDown(hObject, ~, handles)
% hObject    handle to activex1 (see GCBO)
% ~  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frame_axes1_Callback(hObject, ~, handles)
% hObject    handle to edit_frame_axes1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frame_axes1 as text
%        str2double(get(hObject,'String')) returns contents of edit_frame_axes1 as a double


% --- Executes during object creation, after setting all properties.
function edit_frame_axes1_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_frame_axes1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frame_axes2_Callback(hObject, ~, handles)
% hObject    handle to edit_frame_axes2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frame_axes2 as text
%        str2double(get(hObject,'String')) returns contents of edit_frame_axes2 as a double


% --- Executes during object creation, after setting all properties.
function edit_frame_axes2_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_frame_axes2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frame_axes3_Callback(hObject, ~, handles)
% hObject    handle to edit_frame_axes3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frame_axes3 as text
%        str2double(get(hObject,'String')) returns contents of edit_frame_axes3 as a double


% --- Executes during object creation, after setting all properties.
function edit_frame_axes3_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_frame_axes3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frame_axes4_Callback(hObject, ~, handles)
% hObject    handle to edit_frame_axes4 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frame_axes4 as text
%        str2double(get(hObject,'String')) returns contents of edit_frame_axes4 as a double


% --- Executes during object creation, after setting all properties.
function edit_frame_axes4_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_frame_axes4 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frame_axes5_Callback(hObject, ~, handles)
% hObject    handle to edit_frame_axes5 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frame_axes5 as text
%        str2double(get(hObject,'String')) returns contents of edit_frame_axes5 as a double


% --- Executes during object creation, after setting all properties.
function edit_frame_axes5_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_frame_axes5 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frame_axes6_Callback(hObject, ~, handles)
% hObject    handle to edit_frame_axes6 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frame_axes6 as text
%        str2double(get(hObject,'String')) returns contents of edit_frame_axes6 as a double


% --- Executes during object creation, after setting all properties.
function edit_frame_axes6_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_frame_axes6 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, ~, handles)
% hObject    handle to axes1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame

vidcap = VideoReader(VideoPath);
ShowFrame = read(vidcap , CurrentFrame );
axes(handles.axes1);
figure('Name','Axes 1','NumberTitle','off');
imshow(ShowFrame);
guidata(hObject, handles);

vidcap.delete();

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, ~, handles)
% hObject    handle to axes2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
ReadThatFrame = CurrentFrame + NumberOfSkippedFrames;

if ReadThatFrame <  NumberOfFrames
    vidcap = VideoReader(VideoPath);
    ShowFrame = read(vidcap , ReadThatFrame );
    axes(handles.axes2);
    figure('Name','Axes 2','NumberTitle','off');
    imshow(ShowFrame);
    guidata(hObject, handles);
end
 
vidcap.delete();

% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, ~, handles)
% hObject    handle to axes2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
ReadThatFrame = CurrentFrame + NumberOfSkippedFrames * 2;

if ReadThatFrame <  NumberOfFrames
    vidcap = VideoReader(VideoPath);
    ShowFrame = read(vidcap , ReadThatFrame );
    axes(handles.axes3);
    figure('Name','Axes 3','NumberTitle','off');
    imshow(ShowFrame);
    guidata(hObject, handles);
end

vidcap.delete();

% --- Executes on mouse press over axes background.
function axes4_ButtonDownFcn(hObject, ~, handles)
% hObject    handle to axes4 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
ReadThatFrame = CurrentFrame + NumberOfSkippedFrames * 3;

if ReadThatFrame <  NumberOfFrames
    vidcap = VideoReader(VideoPath);
    ShowFrame = read(vidcap , ReadThatFrame );
    axes(handles.axes4);
    figure('Name','Axes 4','NumberTitle','off');
    imshow(ShowFrame);
    guidata(hObject, handles);
end

vidcap.delete();

% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, ~, handles)
% hObject    handle to axes5 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
ReadThatFrame = CurrentFrame + NumberOfSkippedFrames * 4;

if ReadThatFrame <  NumberOfFrames
    vidcap = VideoReader(VideoPath);
    ShowFrame = read(vidcap , ReadThatFrame);
    axes(handles.axes5);
    figure('Name','Axes 5','NumberTitle','off');
    imshow(ShowFrame);
    guidata(hObject, handles);
end

vidcap.delete();

% --- Executes on mouse press over axes background.
function axes6_ButtonDownFcn(hObject, ~, handles)
% hObject    handle to axes6 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
ReadThatFrame = CurrentFrame + NumberOfSkippedFrames * 5;

if ReadThatFrame <  NumberOfFrames
    vidcap = VideoReader(VideoPath);
    ShowFrame = read(vidcap , ReadThatFrame );
    axes(handles.axes6);
    figure('Name','Axes 6','NumberTitle','off');
    imshow(ShowFrame);
    guidata(hObject, handles);
end

vidcap.delete();

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, ~, handles)
% hObject    handle to axes1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on key release with focus on figure_TextExtractor and none of its controls.
function figure_TextExtractor_KeyReleaseFcn(hObject, ~, handles)
% hObject    handle to figure_TextExtractor (see GCBO)
% ~  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure_TextExtractor and none of its controls.
function figure_TextExtractor_KeyPressFcn(hObject, ~, handles)
% hObject    handle to figure_TextExtractor (see GCBO)
% ~  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when figure_TextExtractor is resized.
function figure_TextExtractor_SizeChangedFcn(hObject, ~, handles)
% hObject    handle to figure_TextExtractor (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure KeyPressFcnbackground, over a disabled or
% --- inactive control, or over an axes background.
function figure_TextExtractor_WindowButtonDownFcn(hObject, ~, handles)
% hObject    handle to figure_TextExtractor (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when uipanel11 is resized.
function uipanel11_SizeChangedFcn(hObject, ~, handles)
% hObject    handle to uipanel11 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipanel11_ButtonDownFcn(hObject, ~, handles)
% hObject    handle to uipanel11 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_ClearAxes1.
function pushbutton_ClearAxes1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_ClearAxes1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes1,'reset')
set(handles.axes1,'ButtondownFcn',{@axes1_ButtonDownFcn, handles});



% --- Executes on button press in pushbutton_ClearAxes2.
function pushbutton_ClearAxes2_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_ClearAxes2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes2,'reset')
set(handles.axes2,'ButtondownFcn',{@axes2_ButtonDownFcn, handles});

% --- Executes on button press in pushbutton_ClearAxes3.
function pushbutton_ClearAxes3_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_ClearAxes3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes3,'reset')
set(handles.axes3,'ButtondownFcn',{@axes3_ButtonDownFcn, handles});

% --- Executes on button press in pushbutton_ClearAxes4.
function pushbutton_ClearAxes4_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_ClearAxes4 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes4,'reset')
set(handles.axes4,'ButtondownFcn',{@axes4_ButtonDownFcn, handles});

% --- Executes on button press in pushbutton_ClearAxes5.
function pushbutton_ClearAxes5_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_ClearAxes5 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes5,'reset')
set(handles.axes5,'ButtondownFcn',{@axes5_ButtonDownFcn, handles});

% --- Executes on button press in pushbutton_ClearAxes6.
function pushbutton_ClearAxes6_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_ClearAxes6 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes6,'reset')
set(handles.axes6,'ButtondownFcn',{@axes6_ButtonDownFcn, handles});



function edit_Steps_Callback(hObject, ~, handles)
% hObject    handle to edit_Steps (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Steps as text
%        str2double(get(hObject,'String')) returns contents of edit_Steps as a double


% --- Executes during object creation, after setting all properties.
function edit_Steps_CreateFcn(hObject, ~, handles)
% hObject    handle to edit_Steps (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Minus1.
function pushbutton_Minus1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Minus1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame

AxesIndex = 1;
vidcap = VideoReader(VideoPath);
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
if CurrentFrame > 1
    CurrentFrame = CurrentFrame - 1;
end 
DisplayFrame = CurrentFrame;
for i = 1 : 6
    
    if DisplayFrame < 1 
        break;
    end
    ShowFrame = read(vidcap , DisplayFrame );
    AxesUsed = sprintf('axes%d', AxesIndex);
    EditFieldAxesUsed = sprintf('edit_frame_axes%d', AxesIndex);
    axes(handles.(AxesUsed));
    imshow(ShowFrame);
    set(handles.(EditFieldAxesUsed),'String',num2str(DisplayFrame));
    DisplayFrame = DisplayFrame + NumberOfSkippedFrames;
    AxesIndex = AxesIndex + 1;
end

vidcap.delete();

% --- Executes on button press in pushbutton_Minus6.
function pushbutton_Minus6_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Minus6 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VideoPath
global NumberOfFrames
global CurrentFrame

AxesIndex = 1;
vidcap = VideoReader(VideoPath);
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
if CurrentFrame > 6
    CurrentFrame = CurrentFrame - 6;
end
DisplayFrame = CurrentFrame;

for i = 1 : 6
    
    if  DisplayFrame  < 1 
        break;
    end
    ShowFrame = read(vidcap , DisplayFrame );
    AxesUsed = sprintf('axes%d', AxesIndex);
    EditFieldAxesUsed = sprintf('edit_frame_axes%d', AxesIndex);
    axes(handles.(AxesUsed));
    imshow(ShowFrame);
    set(handles.(EditFieldAxesUsed),'String',num2str(DisplayFrame));
    DisplayFrame = DisplayFrame + NumberOfSkippedFrames;
    AxesIndex = AxesIndex + 1;
end

vidcap.delete();

% --- Executes on button press in pushbutton_Minus12.
function pushbutton_Minus12_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Minus12 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VideoPath
global NumberOfFrames
global CurrentFrame

AxesIndex = 1;
vidcap = VideoReader(VideoPath);
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
if CurrentFrame > 12
    CurrentFrame = CurrentFrame - 12;
end
DisplayFrame = CurrentFrame;
for i = 1 : 6
    
    if  DisplayFrame  < 1 
        break;
    end
    ShowFrame = read(vidcap , DisplayFrame );
    AxesUsed = sprintf('axes%d', AxesIndex);
    EditFieldAxesUsed = sprintf('edit_frame_axes%d', AxesIndex);
    axes(handles.(AxesUsed));
    imshow(ShowFrame);
    set(handles.(EditFieldAxesUsed),'String',num2str(DisplayFrame));
    DisplayFrame = DisplayFrame + NumberOfSkippedFrames;
    AxesIndex = AxesIndex + 1;
end

vidcap.delete();

% --- Executes on button press in pushbutton_Plus1.
function pushbutton_Plus1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Plus1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VideoPath
global NumberOfFrames
global CurrentFrame

AxesIndex = 1;
vidcap = VideoReader(VideoPath);
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
CurrentFrame = CurrentFrame + 1;
DisplayFrame = CurrentFrame;

for i = 1 : 6

    if  DisplayFrame  >   NumberOfFrames
        break;
    end
    ShowFrame = read(vidcap , DisplayFrame );
    AxesUsed = sprintf('axes%d', AxesIndex);
    EditFieldAxesUsed = sprintf('edit_frame_axes%d', AxesIndex);
    axes(handles.(AxesUsed));
    imshow(ShowFrame);
    set(handles.(EditFieldAxesUsed),'String',num2str(DisplayFrame));
    DisplayFrame = DisplayFrame + NumberOfSkippedFrames;
    AxesIndex = AxesIndex + 1;
end

vidcap.delete();
% --- Executes on button press in pushbutton_Plus6.
function pushbutton_Plus6_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Plus6 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame

AxesIndex = 1;
vidcap = VideoReader(VideoPath);
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
CurrentFrame = CurrentFrame + 6 ;
DisplayFrame = CurrentFrame;

for i = 1 : 6
    
    if DisplayFrame   >  NumberOfFrames
        break;
    end
    ShowFrame = read(vidcap , DisplayFrame );
    AxesUsed = sprintf('axes%d', AxesIndex);
    EditFieldAxesUsed = sprintf('edit_frame_axes%d', AxesIndex);
    axes(handles.(AxesUsed));
    imshow(ShowFrame);
    set(handles.(EditFieldAxesUsed),'String',num2str(DisplayFrame));
    DisplayFrame = DisplayFrame + NumberOfSkippedFrames;
    AxesIndex = AxesIndex + 1;
end

vidcap.delete();

% --- Executes on button press in pushbutton_Plus12.
function pushbutton_Plus12_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_Plus12 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VideoPath
global NumberOfFrames
global CurrentFrame

AxesIndex = 1;
vidcap = VideoReader(VideoPath);
NumberOfSkippedFrames =str2num(get(handles.edit_Steps,'String'));
CurrentFrame = CurrentFrame + 12;
DisplayFrame = CurrentFrame;

for i = 1 : 6
    
    if DisplayFrame  > NumberOfFrames
        break;
    end
    ShowFrame = read(vidcap , DisplayFrame );
    AxesUsed = sprintf('axes%d', AxesIndex);
    EditFieldAxesUsed = sprintf('edit_frame_axes%d', AxesIndex);
    axes(handles.(AxesUsed));
    imshow(ShowFrame);
    set(handles.(EditFieldAxesUsed),'String',num2str(DisplayFrame));
    DisplayFrame = DisplayFrame + NumberOfSkippedFrames;
    AxesIndex = AxesIndex + 1;
end

vidcap.delete();


% --- Executes on button press in pushbuttongetAllFrames.
function pushbuttongetAllFrames_Callback(hObject, ~, handles)
% hObject    handle to pushbuttongetAllFrames (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbuttongetAllFrames

tic

global VideoPath
global MarkedPart
global Caption_ROI
global vidcap
global NumberOfFrames 
global VideoFrameRate
global TextType

persistent videoSizePart1_Flag
persistent videoSizePart2_Flag
persistent videoSizePart3_Flag
persistent videoSizePart4_Flag

persistent FrameRGB_GetaFrameDozensAhead


CutFactor = 1.5;
% uselessBottomPixelsToRemove = 20;
uselessBottomPixelsToRemove = 0;

ChannelName = get(handles.edit_ChannelName,'String');
ProgramName = get(handles.edit_ProgramName,'String');
VideoPath = get(handles.edit_LoadVideo,'String');

Frame_ID = 0;

%Get All pop up menu items for Marked Part (Top / Bottom / Both)
MarkedPartItems = get(handles.popupmenu_MarkedPart,'String');
%Get the current selected item Index
MarkedPartSelectedItem = get(handles.popupmenu_MarkedPart,'Value');
%Get the name of current selected item
MarkedPart = MarkedPartItems{MarkedPartSelectedItem};


vidcap = VideoReader(VideoPath);
vidcapNews = VideoReader(VideoPath);
     
if (  strcmp(TextType , 'Caption : Scrolling/Static' ) == 1 || strcmp(TextType , 'Caption : Scrolling(Horizontal/Vertical) only' ) == 1 || strcmp(TextType , 'Caption : Static only' ) == 1 )
    
    if isempty(videoSizePart1_Flag)
        videoSizePart1_Flag = 0;
    end
    
    if isempty(videoSizePart2_Flag)
        videoSizePart2_Flag = 0;
    end
    
    if isempty(videoSizePart3_Flag)
        videoSizePart3_Flag = 0;
    end
    
    if isempty(videoSizePart4_Flag)
        videoSizePart4_Flag = 0;
    end
    
    % mkdir FilmsDataSet
    mkdir NewsDataSet
    
    cd NewsDataSet
    
    VideoName_Part1 = strcat(ChannelName,'_',ProgramName,'_Part1.avi');
    v_Part1 = VideoWriter(VideoName_Part1 );
    VideoName_Part2 = strcat(ChannelName,'_',ProgramName,'_Part2.avi');
    v_Part2 = VideoWriter(VideoName_Part2 );
    VideoName_Part3 = strcat(ChannelName,'_',ProgramName,'_Part3.avi');
    v_Part3 = VideoWriter(VideoName_Part3 );
    VideoName_Part4 = strcat(ChannelName,'_',ProgramName,'_Part4.avi');
    v_Part4 = VideoWriter(VideoName_Part4 );
   
    open(v_Part1);
    open(v_Part2);
    open(v_Part3);
    open(v_Part4);
    
    z = 0;
    
    VideoFrameRate = floor(vidcapNews.FrameRate);
    
    while hasFrame(vidcapNews)
        
        FrameRGB_GetaFrameDozensAhead = readFrame( vidcapNews  );
        
        if z == VideoFrameRate + 10
            break;
        end
        
        z = z +1;
        
    end
    
    %     Get the Desired part index for the rows
    if strcmp(MarkedPart , 'Bottom' ) == 1
        DesiredAreaIndex_GetaFrameDozensAhead = round( size(FrameRGB_GetaFrameDozensAhead,1) / 1.5);
        % You May need to change the factor according to the Film
        %   DesiredWidthIndexStart_GetaFrameDozensAhead = round( size(FrameRGB_GetaFrameDozensAhead,2) / 4);
        %   DesiredWidthIndexEnd_GetaFrameDozensAhead = round( size(FrameRGB_GetaFrameDozensAhead,2) * 3 / 4);
        %   DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB(DesiredAreaIndex_GetaFrameDozensAhead:end , DesiredWidthIndexStart_GetaFrameDozensAhead:DesiredWidthIndexEnd_GetaFrameDozensAhead , :) ;
        %     height = DesiredAreaIndex_GetaFrameDozensAhead:size(FrameRGB_GetaFrameDozensAhead,1)- uselessBottomPixelsToRemove ;
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndex_GetaFrameDozensAhead:end - uselessBottomPixelsToRemove  , : , :) ;
    elseif strcmp(MarkedPart , 'Top' ) == 1
        DesiredAreaIndex_GetaFrameDozensAhead = round(size(FrameRGB_GetaFrameDozensAhead,1) / 3);
        %     height = 1:DesiredAreaIndex_GetaFrameDozensAhead;
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(1:DesiredAreaIndex_GetaFrameDozensAhead , : , :) ;
    elseif strcmp(MarkedPart , 'Both' ) == 1
        %     height = size(FrameRGB_GetaFrameDozensAhead,1);
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead ;
    elseif strcmp(MarkedPart , 'Middle' ) == 1
        DesiredAreaIndexStart_GetaFrameDozensAhead = round(size(FrameRGB_GetaFrameDozensAhead,1) / 3);
        DesiredAreaIndexEnd_GetaFrameDozensAhead   = round( size(FrameRGB_GetaFrameDozensAhead,1)  / 1.5 );
        %     height = DesiredAreaIndexStart_GetaFrameDozensAhead:DesiredAreaIndexEnd_GetaFrameDozensAhead  ;
        DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndexStart_GetaFrameDozensAhead:DesiredAreaIndexEnd_GetaFrameDozensAhead , : , :) ;
    end
    
    %FrameGrayScale_GetaFrameDozensAhead = rgb2gray(DesiredPartFrameRGB_GetaFrameDozensAhead);
    
    NumberOfFrames = VideoFrameRate * floor(vidcapNews.Duration);
    
    while hasFrame(vidcapNews)
        
        FrameRGB = readFrame(vidcapNews);
        FrameRGB = imadjust(FrameRGB,[],[]);
        try
            if (Frame_ID <  NumberOfFrames - VideoFrameRate - 10 - 1)
                
                FrameRGB_GetaFrameDozensAhead = readFrame( vidcapNews  );
                
                FrameRGB_GetaFrameDozensAhead = imadjust(FrameRGB_GetaFrameDozensAhead,[],[]);
                
            end
        catch
            % Exception occured
            g=0
        end
        %     Get the Desired part index for the rows
        if strcmp(MarkedPart , 'Bottom' ) == 1
            DesiredAreaIndex = round( size(FrameRGB,1) / CutFactor);
            % You May need to change the factor according to the Film
            %         DesiredWidthIndexStart = round( size(FrameRGB,2) / 4);
            %         DesiredWidthIndexEnd = round( size(FrameRGB,2) * 3 / 4);
            %         DesiredPartFrameRGB = FrameRGB(DesiredAreaIndex:end , DesiredWidthIndexStart:DesiredWidthIndexEnd , :) ;
            DesiredPartFrameRGB = FrameRGB(DesiredAreaIndex:end - uselessBottomPixelsToRemove  , : , :) ;
            DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndex_GetaFrameDozensAhead:end - uselessBottomPixelsToRemove  , : , :) ;
            
        elseif strcmp(MarkedPart , 'Top' ) == 1
            DesiredAreaIndex = round(size(FrameRGB,1) / 3);
            DesiredPartFrameRGB = FrameRGB(1:DesiredAreaIndex , : , :) ;
            DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(1:DesiredAreaIndex_GetaFrameDozensAhead , : , :) ;
            
        elseif strcmp(MarkedPart , 'Both' ) == 1
            DesiredPartFrameRGB = FrameRGB ;
            DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead ;
            
        elseif strcmp(MarkedPart , 'Middle' ) == 1
            DesiredAreaIndexStart = round(size(FrameRGB,1) / 3);
            DesiredAreaIndexEnd   = round( size(FrameRGB,1)  / 1.5 );
            DesiredPartFrameRGB = FrameRGB(DesiredAreaIndexStart:DesiredAreaIndexEnd , : , :) ;
            DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndexStart_GetaFrameDozensAhead:DesiredAreaIndexEnd_GetaFrameDozensAhead , : , :) ;
            
        end
        
        FrameGrayScale = rgb2gray(DesiredPartFrameRGB);
        FrameGrayScale_GetaFrameDozensAhead = rgb2gray(DesiredPartFrameRGB_GetaFrameDozensAhead);
        
        if mod( Frame_ID , VideoFrameRate) == 0
            
            % Get the ROI
            Caption_ROI_Temp  =  HoughTransform( FrameGrayScale , FrameGrayScale_GetaFrameDozensAhead );
            
            if ~isempty(Caption_ROI_Temp)
                % Caption_ROI = [];
                Caption_ROI = Caption_ROI_Temp;
                Caption_ROI = sortrows(Caption_ROI,2,'descend');
            end
            
        end
        
        % % %     imageOfEdges = bwlabel(FrameGrayScale , 4 ) ;
        % % %     numberOfEdges = max( imageOfEdges(:) ) ;
        
        CaptionNum = size(Caption_ROI,1);
        
        
        if videoSizePart1_Flag == 0 && ~isempty(v_Part1.Height)
            inputVideoRows_part1 = v_Part1.Height;
            inputVideoColumns_part1 = v_Part1.Width;
            videoSizePart1_Flag = 1;
        end
        if videoSizePart2_Flag == 0 &&  ~isempty(v_Part2.Height)
            inputVideoRows_part2 = v_Part2.Height;
            inputVideoColumns_part2 = v_Part2.Width;
            videoSizePart2_Flag = 1;
        end
        if videoSizePart3_Flag == 0 && ~isempty(v_Part3.Height)
            inputVideoRows_part3 = v_Part3.Height;
            inputVideoColumns_part3 = v_Part3.Width;
            videoSizePart3_Flag = 1;
        end
        if videoSizePart4_Flag == 0 && ~isempty(v_Part4.Height)
            inputVideoRows_part4 = v_Part4.Height;
            inputVideoColumns_part4 = v_Part4.Width;
            videoSizePart4_Flag = 1;
        end
        
        l=1;
        for i = 1 : CaptionNum
            try
                Caption_ROI_AdjustForimcrop = Caption_ROI(i,:) + [0 0 -1 -1];
                % Crop the Frame with existing caption in the video
                CaptionBar  =  imcrop(FrameGrayScale,Caption_ROI_AdjustForimcrop);
                
                compressedframe = imresize(CaptionBar, [ 40 , 200 ] );
            catch
                % Exception occured
                l=0
            end
            
            if i == 1 && l==1
                if videoSizePart1_Flag == 1 && (size(CaptionBar , 1) ~=  inputVideoRows_part1 || size(CaptionBar , 2) ~= inputVideoColumns_part1)
                    CaptionBar = imresize(CaptionBar, [inputVideoRows_part1, inputVideoColumns_part1]);
                end
                writeVideo(v_Part1 , CaptionBar);
            elseif i ==  2 && l==1
                if videoSizePart2_Flag == 1 && (size(CaptionBar , 1) ~=  inputVideoRows_part2 || size(CaptionBar , 2) ~= inputVideoColumns_part2)
                    CaptionBar = imresize(CaptionBar, [inputVideoRows_part2, inputVideoColumns_part2]);
                end
                writeVideo(v_Part2 , CaptionBar);
            elseif i == 3 && l==1
                if videoSizePart3_Flag == 1 && (size(CaptionBar , 1) ~=  inputVideoRows_part3 || size(CaptionBar , 2) ~= inputVideoColumns_part3)
                    CaptionBar = imresize(CaptionBar, [inputVideoRows_part3, inputVideoColumns_part3]);
                end
                writeVideo(v_Part3 , CaptionBar);
            elseif i == 4 && l==1
                if videoSizePart4_Flag == 1 && (size(CaptionBar , 1) ~=  inputVideoRows_part4 || size(CaptionBar , 2) ~= inputVideoColumns_part4)
                    CaptionBar = imresize(CaptionBar, [inputVideoRows_part4, inputVideoColumns_part4]);
                end
                writeVideo(v_Part4 , CaptionBar);
            end
            
            imwrite(compressedframe, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i), '.tiff']  , 'tif' );
            if l ==1
                imwrite(CaptionBar , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Part_',num2str(i),'_Normal_size', '.tiff']  , 'tif' );
            end
        end
        
        imwrite(FrameGrayScale , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_All_Captions', '.tiff']  , 'tif' );
        
        Frame_ID = Frame_ID + 1 ;
        
    end
    
    close(v_Part1);
    close(v_Part2);
    close(v_Part3);
    close(v_Part4);
    
    videoSizePart1_Flag = 0;
    videoSizePart2_Flag = 0;
    videoSizePart3_Flag = 0;
    videoSizePart4_Flag = 0;
    
    
    
elseif (  strcmp(TextType , 'Graphic : Movie' ) == 1  )
    

    mkdir FilmManyTranslationDataSet
    
    cd FilmManyTranslationDataSet
    
    while hasFrame(vidcap)
        
        FrameRGB = readFrame(vidcap);
        FrameRGB = imadjust(FrameRGB,[],[]);
        
        %   Get the Desired part index for the rows
        if strcmp(MarkedPart , 'Bottom' ) == 1
            DesiredAreaIndex = round( size(FrameRGB,1) / CutFactor);
            % You May need to change the factor according to the Film
            %         DesiredWidthIndexStart = round( size(FrameRGB,2) / 4);
            %         DesiredWidthIndexEnd = round( size(FrameRGB,2) * 3 / 4);
            %         DesiredPartFrameRGB = FrameRGB(DesiredAreaIndex:end , DesiredWidthIndexStart:DesiredWidthIndexEnd , :) ;
            DesiredPartFrameRGB = FrameRGB(DesiredAreaIndex:end - uselessBottomPixelsToRemove  , : , :) ;
            %DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndex_GetaFrameDozensAhead:end - uselessBottomPixelsToRemove  , : , :) ;
            
        elseif strcmp(MarkedPart , 'Top' ) == 1
            DesiredAreaIndex = round(size(FrameRGB,1) / 3);
            DesiredPartFrameRGB = FrameRGB(1:DesiredAreaIndex , : , :) ;
            %DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(1:DesiredAreaIndex_GetaFrameDozensAhead , : , :) ;
            
        elseif strcmp(MarkedPart , 'Both' ) == 1
            DesiredPartFrameRGB = FrameRGB ;
            %DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead ;
            
        elseif strcmp(MarkedPart , 'Middle' ) == 1
            DesiredAreaIndexStart = round(size(FrameRGB,1) / 3);
            DesiredAreaIndexEnd   = round( size(FrameRGB,1)  / 1.5 );
            DesiredPartFrameRGB = FrameRGB(DesiredAreaIndexStart:DesiredAreaIndexEnd , : , :) ;
            %DesiredPartFrameRGB_GetaFrameDozensAhead = FrameRGB_GetaFrameDozensAhead(DesiredAreaIndexStart_GetaFrameDozensAhead:DesiredAreaIndexEnd_GetaFrameDozensAhead , : , :) ;
            
        end
        
        FrameGrayScale = rgb2gray(DesiredPartFrameRGB);
        %FrameGrayScale_GetaFrameDozensAhead = rgb2gray(DesiredPartFrameRGB_GetaFrameDozensAhead);
        
        compressedframe = imresize(FrameGrayScale, [40, 200]);
        
        imwrite(compressedframe, [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') , '.tiff']  , 'tif' );
        imwrite(FrameGrayScale , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d') ,'_Normal_Size', '.tiff']  , 'tif' );
        
        Frame_ID = Frame_ID + 1 ;
        
        
        
    end

end
    vidcapNews.delete();
    vidcap.delete();
    
toc
totalProcessingTime = toc;
set(handles.edit_ProcessingTime,'String',num2str(totalProcessingTime));

cd ..


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Implements the hough transformation on the video frames
%
% Inputs: FrameGrayScale
%
% Output: ROI coordinates as [xmin ymin width height]

function Caption_ROI  =  HoughTransform( FrameGrayScale , FrameGrayScale_GetaFrameDozensAhead)

    global EdgeDetector
    global FeatureExtractor
    global firstTimeToApplyHoughFlag
    global NumberOfFrames 
    % global VideoFrameRate
    
    % Declare static variables
    persistent StartPt;
    persistent width;
    persistent ConfidenceLevel ;
    persistent width_Prev;
    persistent StartPt_Prev;
    persistent holdFlag;         
    
    persistent bottomLineNonExistanceFlag;

    persistent yDim_Prev;
    persistent LastLine ;
    persistent beforeLastLine ;   
    
    persistent ForceFullCaptionCount;
    
    persistent lastLineConfidence; 
    persistent isBeginVideo;

    
    firstCaptionOrder = 1;
    
    HeightTolerance  =  4;
    PositionTolerance  =  4 ;    
    ForceCaptionsDimensionsFlag = 0;
    ForceCaptionsStartPoint_X = 72 ;
    ForceCaptionsEndPoint_X = 1120 ;
 
    ForceAllCaptionsDimensionsFlag = 1;
    ForceCaptionsStartPoint_X = [4 50 400 400 400 ];
    ForceCaptionsEndPoint_X = [1010 1140 1140  1140 1140 ] ;

    horizontalLinesDistanceTolerance = 4;
    ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
    
    MaxBoundryTolerance = 0;
    ForceFullCaptionAfterThisValue =  NumberOfFrames ;
    %     ForceFullCaptionAfterThisValue =  10  ;
    
    % Confidence for caption width low ex 3 for fast changes
    % but greater for slow changes ex.5
    ConfidenceThreshold = 5; % BBC 1 caption = 7
    
    % In case no bottom line this is the new line distance from image end
    distanceFromImageBottom = 30;
    
    % The flag can have 0 and 1 values
    getExtralinesFlag = 0;
    % The flag can have -1 , 0 and 1 values
    getExtraBottomlinesFlag = -1;
    
    % Lower Limit for distance between the Text line and bottom boundry
    TextLineBottomBoundryLowerLimit = 4;
    % Upper limit <<15>> in normal case 20 in some cases like RT news
    % 35 in case of ON TV news
    % 25 Sky Ramadan
    TextLineBottomBoundryUpperLimit = 30;

% Sky News Ramadan    
% % %     HeightTolerance  =  4;
% % %     PositionTolerance  =  2 ;
% % %     
% % %     
% % %     firstCaptionOrder = 1;
% % %     
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  3 540  784 784  784  784 784  784];
% % %     ForceCaptionsEndPoint_X = [  962 1072 1072 1072 1072 1072 1072 1072] ;
% % %     
% % %     
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance = 10;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     % ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 40;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = -1;
% % %     % The flag can have -1 , 0 and 1 values
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;



%Arabya    
% %     HeightTolerance  =  4 ;
% %     PositionTolerance  =  2 ;
% %     firstCaptionOrder = 1;
% % 
% %     horizontalLinesDistanceTolerance = 25;
% % 
% %     ForceCaptionsDimensionsFlag = 0;
% %     ForceCaptionsStartPoint_X = 72 ;
% %     ForceCaptionsEndPoint_X = 1120 ;
% % 
% %     ForceAllCaptionsDimensionsFlag = 1;
% %     ForceCaptionsStartPoint_X = [  4 4 4 4];
% %     ForceCaptionsEndPoint_X = [  498 490 490 490] ;
% %     
% %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% %     
% %     MaxBoundryTolerance = 0;
% %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% %     ForceFullCaptionAfterThisValue =  10  ;    
% % 
% %     
% %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% %     
% %     % In case no bottom line this is the new line distance from image end
% %     distanceFromImageBottom = 20;
% %     
% %     getExtralinesFlag = 0;
% %     getExtraBottomlinesFlag = -1;
% %     
% %     % Lower Limit for distance between the Text line and bottom boundry
% %     TextLineBottomBoundryLowerLimit = 4;
% %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% %     % 35 in case of ON TV news
% %     % 25 Sky Ramadan
% %     TextLineBottomBoundryUpperLimit = 18;


    
%   Static_Araimi_Boulevard
% % %     HeightTolerance  =  4 ;
% % %     PositionTolerance  =  2 ;
% % %     firstCaptionOrder = 1;
% % % 
% % %     horizontalLinesDistanceTolerance = 25;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % % 
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  277 277 277 277];
% % %     ForceCaptionsEndPoint_X = [  1056 1056 1056 1056] ;
% % %     
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     ForceFullCaptionAfterThisValue =  10  ;    
% % %     ConfidenceThreshold = 3;
% % %     
% % % %     In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 30;
% % %     
% % %     getExtralinesFlag = 6;
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % % %     Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % % %     Upper limit <<15>> in normal case 20 in some cases like RT news
% % % %     35 in case of ON TV news
% % % %     25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;


%%%% Elbalad Static Court%    
% % %     HeightTolerance  =  11 ;
% % %     PositionTolerance  =  1 ;
% % %     firstCaptionOrder = 1;
% % % 
% % %     horizontalLinesDistanceTolerance = 25;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % % 
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  277 277 277 277];
% % %     ForceCaptionsEndPoint_X = [  1056 1056 1056 1056] ;
% % %     
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;    
% % %     ConfidenceThreshold = 3;
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 30;
% % %     
% % %     getExtralinesFlag = 6;
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;

    
    Caption_ROI = [];    
    
    I_NCC_RightMax =[];
    I_NCC_LeftMax = [];
    I_NCC_Mean = [];
    corrScore_Right =[];
    corrScore_Left = [];
    pointX_Long = [];
    [m,n] = size(FrameGrayScale);

    corrDoneFlag = 0;
    
    if isempty(bottomLineNonExistanceFlag)
        bottomLineNonExistanceFlag = 0;
    end
    
    if isempty(firstTimeToApplyHoughFlag)
        firstTimeToApplyHoughFlag = 0;
    end
    
    if isempty(ForceFullCaptionCount)
        ForceFullCaptionCount = 0;
    end
    

    ForceFullCaptionCount = ForceFullCaptionCount + 1 ;
    
    
    BlackWhiteFrame  =   edge(FrameGrayScale, EdgeDetector , 0.7);
    BlackWhiteFrame_a  =   edge(FrameGrayScale, EdgeDetector);
    % figure, imshow(BlackWhiteFrame), hold on
    
    % Apply Hough transformation
    % T: Theta
    % R: Rho
    
    [H,T,R]  =  hough(BlackWhiteFrame,'Theta',-90);
    [H_a,T_a,R_a]  =  hough(BlackWhiteFrame_a,'Theta',-90);
    P   =  houghpeaks( H , 5 , 'threshold' , ceil(0.3 * max(H(:)) ) );
    P_a   =  houghpeaks( H_a , 3 , 'threshold' , ceil(0.5 * max(H_a(:)) ) );
    
    % Get all available lines
    lines  =  houghlines(BlackWhiteFrame , T , R , P , 'FillGap' , 5 , 'MinLength' , 100);
    lines_a  =  houghlines(BlackWhiteFrame_a , T_a , R_a , P_a , 'FillGap' , 5 , 'MinLength' , 100);
    
    lines_b  =  houghlines(BlackWhiteFrame , T , R , P , 'FillGap' , 3 , 'MinLength' , 40);

    BlackWhiteFrame_c  =   edge(FrameGrayScale,'approxcanny' , 0.3 );    
    
    %  figure, imshow(BlackWhiteFrame), hold on
    
    [H_c,T_c,R_c]  =  hough(BlackWhiteFrame_c,'Theta',-90);
    P_c   =  houghpeaks( H_c, 5 , 'threshold' , ceil(0.3 * max(H_c(:)) ) );
    
    
    lines_c =  houghlines(BlackWhiteFrame_c , T_c , R_c , P_c , 'FillGap' , 5 , 'MinLength' , 80);
    lines_d  =  houghlines(BlackWhiteFrame , T , R , P , 'FillGap' , 3 , 'MinLength' , 80);
    lines_e  =  houghlines(BlackWhiteFrame , T , R , P , 'FillGap' , 5 , 'MinLength' , 60);
    lines_f  =  houghlines(BlackWhiteFrame_c , T_c , R_c , P_c , 'FillGap' , 1 , 'MinLength' , 30);
    
    
    BW_g = imbinarize(FrameGrayScale,0.2);
    BW_g  =  edge(BW_g,'canny');
    [H_g,T_g,R_g]  =  hough(BW_g,'Theta',-90);
    P_g   =  houghpeaks( H_g , 5 , 'threshold' , ceil(0.3 * max(H_g(:)) ) );
    lines_g  =  houghlines(BW_g , T_g , R_g , P_g , 'FillGap' , 2 , 'MinLength' , 7);
    
    BW_h = imbinarize(FrameGrayScale,0.4);
    BW_h  =  edge(BW_h,'canny');
    [H_h,T_h,R_h]  =  hough(BW_h,'Theta',-90);
    P_h   =  houghpeaks( H_h , 5 , 'threshold' , ceil(0.3 * max(H_h(:)) ) );
    lines_h  =  houghlines(BW_h , T_h , R_h , P_h , 'FillGap' , 2 , 'MinLength' , 7);
    
    lines_i =  houghlines(BW_h , T_h , R_h , P_h , 'FillGap' , 5 , 'MinLength' , 150);
    
    lines_j =  houghlines(BlackWhiteFrame_c , T_c , R_c , P_c , 'FillGap' , 2 , 'MinLength' , 400);
    
    if getExtralinesFlag == 0
        lines = [lines , lines_a , lines_b  , lines_d , lines_e ];
    elseif getExtralinesFlag == 1
        lines = [lines , lines_a , lines_b , lines_c , lines_d , lines_e , lines_f , lines_g , lines_h];
    elseif getExtralinesFlag == 2
         lines = [lines , lines_a ,  lines_d , lines_e ];
    elseif getExtralinesFlag == 3
        % Default
    elseif getExtralinesFlag == 4
        lines = [lines , lines_a , lines_b  , lines_d , lines_e , lines_i];
    elseif getExtralinesFlag == 5
        lines = [lines , lines_j];
    elseif getExtralinesFlag == 6
        lines = [lines , lines_a , lines_d  , lines_i];
        %lines = [lines , lines_a  , lines_j];
    else 
        lines = [lines , lines_a  , lines_i ];
    end
          
    P_Bottom   =  houghpeaks( H_a , 5 , 'threshold' , ceil(0.05 * max(H_a(:)) ) );    
    BlackWhiteFrame_Bottom2  =  edge(FrameGrayScale,'approxcanny' , 0.7 );
    [H_Bottom2,T_Bottom2,R_Bottom2]  =  hough(BlackWhiteFrame_Bottom2,'Theta',-90);
    P_Bottom2   =  houghpeaks( H_Bottom2 , 5 , 'threshold' , ceil(0.05 * max(H_Bottom2(:)) ) );    
    
    % bottomLines is used mainly to detect start / end points of bottom line
    if getExtraBottomlinesFlag == -1
        
        bottomLines1 = houghlines(BlackWhiteFrame_a , T_a , R_a , P_Bottom , 'FillGap' , 140 , 'MinLength' , 10);
        bottomLines2=[];
        
    elseif getExtraBottomlinesFlag == 0
        
        bottomLines1=[];
        bottomLines2 = houghlines(BlackWhiteFrame_Bottom2 , T_Bottom2 , R_Bottom2 , P_Bottom2 , 'FillGap' , 140 , 'MinLength' , 10);
        
    elseif getExtraBottomlinesFlag == 1
        
        bottomLines1 = houghlines(BlackWhiteFrame_a , T_a , R_a , P_Bottom , 'FillGap' , 140 , 'MinLength' , 10);
        bottomLines2 = houghlines(BlackWhiteFrame_Bottom2 , T_Bottom2 , R_Bottom2 , P_Bottom2 , 'FillGap' , 140 , 'MinLength' , 10);
        
    end
    
    bottomLines  =  [bottomLines1,bottomLines2]; 
    
    if ~isempty(lines) && ~isempty(bottomLines)
        oldLineIndentifier = lines(1).rho;
        oldLineIndentifierB = bottomLines(1).rho;
    else
        return
    end
    
    % Index for normal lines
    lineIndex = 1;
    yDim =[];
    yDimB=[];
    
    % By Default , horizontalLinesDistanceTolerance = 4
    if abs( size(BlackWhiteFrame , 1) - lines(1).point1(2) ) >= horizontalLinesDistanceTolerance
        yDim(1)  =  lines(1).point1(2);
    else
        lineIndex = 0;
    end

    % Algorithm for wrong extra lines detection
    lineIndexB = 1;

    % By Default , horizontalLinesDistanceTolerance = 4
    if abs( size(BlackWhiteFrame , 1) - bottomLines(1).point1(2) ) >= horizontalLinesDistanceTolerance    
        yDimB(1)  =  bottomLines(1).point1(2);
    else
        lineIndexB =0;
    end
    
    % figure;imshow(BlackWhiteFrame);hold on
        
    % Normal lines processing
    for k  =  2:length(lines)
        
        % For debugging purpose
% % %         xy = [lines(k).point1; lines(k).point2];
% % %         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% % %         
% % %         % Plot beginnings and ends of lines
% % %         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
% % %         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        
        newLineIdentifier = lines(k).rho;
        
        isNewLine = newLineIdentifier ~= oldLineIndentifier;
        
        if (isNewLine == 1) && lines(k).point1(2) > horizontalLinesDistanceTolerance   && lines(k).point1(2) < size(FrameGrayScale,1)-horizontalLinesDistanceTolerance
            
            yDim(lineIndex+1)  =  lines(k).point1(2);
            lineIndex = lineIndex + 1;
            
        end
        
        oldLineIndentifier = newLineIdentifier;
        
    end
 
    % increment line counter if bottom line does not exist
    if bottomLineNonExistanceFlag == 1
        
        yDim(end+1)=m-distanceFromImageBottom;
        yDimB(end+1)=m-distanceFromImageBottom;
    end
    
    if   ~isempty (LastLine) && ~isempty(yDim)

        if   isBeginVideo == 0
            
            yDim = sort(yDim , 'descend');
            
            if lastLineConfidence <= 20% 200
                
                if abs( LastLine - yDim(1) ) <= TextLineBottomBoundryLowerLimit
                    lastLineConfidence = lastLineConfidence + 1;
                elseif lastLineConfidence >= 0 % -20
                    lastLineConfidence = lastLineConfidence - 1;
                else
                    LastLine = yDim(1);
                    %  if length(yDim) > 1
                    %  beforeLastLine = yDim(2);
                    %  end
                end
                
            else
                
                LastLine = yDim(1);
                % beforeLastLine = yDim(2);
                isBeginVideo = 1;
            end
        end
    end
    
        
    % Add some lines if missing
    if ~isempty(LastLine) && ~isempty(yDim) 
        yDim = [yDim , beforeLastLine , LastLine]  ;
    elseif isempty(yDim) 
        yDim = [ beforeLastLine , LastLine]  ;
    end
    
    yDim = sort(yDim , 'descend');
      
    for k  =  1:length(bottomLines)
        
% % %         %For debugging purpose
% % %         xy = [bottomLines(k).point1; bottomLines(k).point2];
% % %         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% % %         
% % %         % Plot beginnings and ends of lines
% % %         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
% % %         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
  
        if ( ~isempty(yDim) && yDim(1) - 4 <  bottomLines(k).point1(2) && bottomLines(k).point1(2) <  size(BlackWhiteFrame,1)-horizontalLinesDistanceTolerance)
            
            %linesErrorFlag = 0;
            
            if firstTimeToApplyHoughFlag == 0 %&& abs(yDim(1) -  bottomLines(k).point1(2)) <= 4
                bottomLineNonExistanceFlag = 1 ;
                break
            end
           
        end
        
    end
    
     % [Not Redundant] increment line counter if bottom line does not exist
    if bottomLineNonExistanceFlag == 1
        
        yDim(end+1)=m-distanceFromImageBottom;
        yDimB(end+1)=m-distanceFromImageBottom;
    end   
    
    % Algorithm for wrong extra lines detection
    for k  =  2:length(bottomLines)
        
        % For debugging purpose
        % % %         xy = [lines(k).point1; lines(k).point2];
        % % %         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        % % %
        % % %         % Plot beginnings and ends of lines
        % % %         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        % % %         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        
        newLineIdentifierB = bottomLines(k).rho;
        
        isNewLineB = newLineIdentifierB ~= oldLineIndentifierB;
        
        if (isNewLineB == 1) && bottomLines(k).point1(2) > horizontalLinesDistanceTolerance   && bottomLines(k).point1(2) < size(FrameGrayScale,1)-horizontalLinesDistanceTolerance
            
            yDimB(lineIndexB+1)  =  bottomLines(k).point1(2);
            lineIndexB = lineIndexB + 1;
            
        end
        
        oldLineIndentifierB = newLineIdentifierB;
        
    end

    
    % Algorithm for wrong extra lines detection
    if ~ isempty (beforeLastLine) && ~ isempty (LastLine)
        
        beforeLastLineDiff = any( abs (yDim - beforeLastLine ) <= horizontalLinesDistanceTolerance);
        
        LastLineDiff = any ( abs (yDim - LastLine ) <= horizontalLinesDistanceTolerance ) ;
        
        beforeLastLineFoundIndex = find(beforeLastLineDiff == 1 , 50 );
        
        LastLineDiffFoundIndex = find(LastLineDiff == 1 , 50 );
        
        yDim(beforeLastLineFoundIndex)=[];
        yDim(LastLineDiffFoundIndex)=[];
        
        if ~isempty(beforeLastLineFoundIndex)
            yDim = [yDim , beforeLastLine ]  ;
        end
        
        if ~isempty(LastLineDiffFoundIndex)
            yDim = [yDim LastLine]  ;
        end
        
        % Algorithm for wrong extra lines detection
        try
        yDimB = sort(yDimB , 'descend');
        catch
            if bottomLineNonExistanceFlag == 1
                yDimB(end)=m-distanceFromImageBottom;
            end
        end
    end
    
    firstTimeToApplyHoughFlag = 1;
       
% % %     % increment line counter if bottom line does not exist
% % %     if bottomLineNonExistanceFlag == 1
% % %         
% % %         yDim(end+1)=m-distanceFromImageBottom;
% % %         yDimB(end+1)=m-distanceFromImageBottom;
% % %         
% % %     end
    
    try
        yDim = sort(yDim , 'descend');
        % Algorithm for wrong extra lines detection
        yDimB = sort(yDimB , 'descend');
    catch
    
    end
    
    % Algorithm for wrong extra lines detections
    % remove all lines very close to each other by certain tolerance
    % By Default , horizontalLinesDistanceTolerance = 4
    idsB=[];
    for i = 2 : length(yDimB)
        if  yDimB(i-1) - yDimB(i) <= horizontalLinesDistanceTolerance
            idsB = [idsB , i];
        end
    end
    
    yDimB(idsB)=[];
 
    ids=[];
    for i = 2 : length(yDim)
        if  yDim(i-1) - yDim(i) <= horizontalLinesDistanceTolerance
            ids = [ids , i];
        end
    end
    
    yDim(ids)=[];
    
    ids=[];
    % Algorithm for wrong extra lines detection
    for h = 2:length(yDim)
            if  ( abs(yDim(h-1) - yDim(h)) > TextLineBottomBoundryLowerLimit && abs(yDim(h-1) - yDim(h)) <= TextLineBottomBoundryUpperLimit && isempty(find(ids == h-1)) ) ...
                           ||    (~isempty(find(ids == h-1)) && abs(yDim(h-2) - yDim(h)) > TextLineBottomBoundryLowerLimit && abs(yDim(h-2) - yDim(h)) <= TextLineBottomBoundryUpperLimit )
                ids = [ids , h];
                %lineIndex = lineIndex-1;
            
            end
    end
    
    yDim(ids)=[];
    
% % %     % Auto Correct yDim in case of lines variable extraction mistake 
% % %     % By Default , horizontalLinesDistanceTolerance = 4
% % %     if ~isempty(beforeLastLine) && length(yDim) >= 2 && abs(yDim(1) - LastLine) > horizontalLinesDistanceTolerance  && abs(yDim(1) - beforeLastLine) > horizontalLinesDistanceTolerance 
% % %         % before last line and last line are missing correction
% % %         yDim(end+1) = beforeLastLine;
% % %         yDim(end+1) = LastLine;
% % %         
% % %     elseif ~isempty(beforeLastLine) && abs(yDim(1) - beforeLastLine) <= horizontalLinesDistanceTolerance
% % %         % last line missing correction
% % %         yDim(end+1) = LastLine;
% % % 
% % %     elseif ~isempty(beforeLastLine) && length(yDim) >= 2 && abs(yDim(2) - beforeLastLine) > horizontalLinesDistanceTolerance 
% % %         % before last line missing correction
% % %         yDim(end+1) = beforeLastLine;
% % %         
% % %     end    

    if ~isempty(beforeLastLine)
        yDim(end+1) = beforeLastLine;
        yDim(end+1) = LastLine;
    end

    yDim = sort(yDim , 'descend');
    
    ids=[];
    for i = 2 : length(yDim)
        if  yDim(i-1) - yDim(i) <= horizontalLinesDistanceTolerance
            if yDim(i) == beforeLastLine || yDim(i) == LastLine 
                ids = [ids , i-1];
            else
                ids = [ids , i];
            end
        end
    end
    
    yDim(ids)=[];
    
    yDim = sort(yDim , 'descend');
    
    % Store yDim variable for the next usage 
    if ( length(yDim) == 1 && bottomLineNonExistanceFlag == 0)
        % Make a Correction
        yDim = yDim_Prev;
    else
        yDim_Prev = yDim;
    end
    
    lineIndex = length(yDim);
    if isempty(beforeLastLine) && ~isempty(yDim) %|| yDim(1) > LastLine
        lastLineConfidence = 0;
        isBeginVideo = 0;
        LastLine = yDim(1);
        if length(yDim) > 1
            beforeLastLine = yDim(2);
        end
    end
    if isBeginVideo == 1
        beforeLastLine = yDim(2);
        isBeginVideo=-1;
    end
   
    
    if isempty(ConfidenceLevel)
        ConfidenceLevel = -1;       
    end
    holdFlag(1:length(yDim))=0;
        
    for v  =  1 : length(yDim)-1
        try
        if ForceAllCaptionsDimensionsFlag == 1
            
            StartPt( v ) = ForceCaptionsStartPoint_X(v) ;
            width( v ) = ForceCaptionsWidth(v) ;
            continue
            
        end
        catch
            j=0;
        end
        
        cropPointsX = [];
        
        % Crop the frame and detect the bar 's Region of interest (detected with edge detection technique)
        % rect structure is [xmin ymin width height]
        Vertical_ROI = [1 yDim(v+1) + PositionTolerance n yDim(v)-yDim(v+1)];
        RotatingBarFullWidth = imcrop(FrameGrayScale,Vertical_ROI);
        RotatingBarFullWidth_DozensLaterFrame = imcrop(FrameGrayScale_GetaFrameDozensAhead,Vertical_ROI);
        
        verticalBlackWhiteFrame1  =   edge(RotatingBarFullWidth, 'prewitt' , 0.03 , 'vertical'  );
        [verticalH1,T1,R1]  =  hough(verticalBlackWhiteFrame1,'Theta',0);
        verticalP1   =  houghpeaks( verticalH1 , 5 , 'threshold' , ceil(0.3 * max(verticalH1(:)) ) );
        verticalLines1  =  houghlines(verticalBlackWhiteFrame1 , T1 , R1 , verticalP1 , 'FillGap' , 1 , 'MinLength' , 5);
        
        % Get Vertical lines with big distortion coming from the rotating text
        verticalBlackWhiteFrame2  =   edge(RotatingBarFullWidth, 'sobel' , 0.05 , 'vertical'  );
        [verticalH2,T2,R2]  =  hough(verticalBlackWhiteFrame2,'Theta',0);
        verticalP2   =  houghpeaks( verticalH2 , 5 , 'threshold' , ceil(0.5 * max(verticalH2(:)) ) );
        verticalLines2  =  houghlines(verticalBlackWhiteFrame2 , T2 , R2 , verticalP2 , 'FillGap' , 5 , 'MinLength' , 40);
        
        % Get Vertical lines with moderate distortion coming from the rotating text
        verticalBlackWhiteFrame3  =   edge(RotatingBarFullWidth, 'sobel' , 0.03 , 'vertical'  );
        [verticalH3,T3,R3]  =  hough(verticalBlackWhiteFrame3,'Theta',0);
        verticalP3   =  houghpeaks( verticalH3 , 3 , 'threshold' , ceil(0.3 * max(verticalH3(:)) ) );
        verticalLines3  =  houghlines(verticalBlackWhiteFrame3 , T3 , R3 , verticalP3 , 'FillGap' , 5 , 'MinLength' , 15);
        
        verticalBlackWhiteFrame4  =   edge(RotatingBarFullWidth, 'sobel' , 0.05 , 'vertical'  );
        [verticalH4,T4,R4]  =  hough(verticalBlackWhiteFrame4,'Theta',0);
        verticalP4   =  houghpeaks( verticalH4 , 5 , 'threshold' , ceil(0.3 * max(verticalH4(:)) ) );
        verticalLines4  =  houghlines(verticalBlackWhiteFrame4 , T4 , R4 , verticalP4 , 'FillGap' , 5 , 'MinLength' , 15);
        
        verticalBlackWhiteFrame5  =   edge(RotatingBarFullWidth, 'prewitt' , 0.03 , 'vertical'  );
        [verticalH5,T5,R5]  =  hough(verticalBlackWhiteFrame5,'Theta',0);
        verticalP5   =  houghpeaks( verticalH5 , 5 , 'threshold' , ceil(0.3 * max(verticalH5(:)) ) );
        verticalLines5  =  houghlines(verticalBlackWhiteFrame5 , T5 , R5 , verticalP5 , 'FillGap' , 1 , 'MinLength' , 5);
        
        verticalBlackWhiteFrame6  =   edge(RotatingBarFullWidth, 'sobel' , 0.05 , 'vertical'  );
        [verticalH6,T6,R6]  =  hough(verticalBlackWhiteFrame6,'Theta',0);
        verticalP6   =  houghpeaks( verticalH6 , 5 , 'threshold' , ceil(0.45 * max(verticalH6(:)) ) );
        verticalLines6  =  houghlines(verticalBlackWhiteFrame6 , T6 , R6 , verticalP6 , 'FillGap' , 5 , 'MinLength' , 15);
        
        verticalBlackWhiteFrame7  =   edge(RotatingBarFullWidth, 'sobel' , 0.05 , 'vertical'  );
        [verticalH7,T7,R7]  =  hough(verticalBlackWhiteFrame7,'Theta',0);
        verticalP7   =  houghpeaks( verticalH7 , 5 , 'threshold' , ceil(0.3 * max(verticalH7(:)) ) );
        verticalLines7  =  houghlines(verticalBlackWhiteFrame7 , T7 , R7 , verticalP7 , 'FillGap' , 1 , 'MinLength' , 5);
        
        % Get very small vertical lines
        verticalBlackWhiteFrame8  =   edge(RotatingBarFullWidth, 'sobel' , 0.01 , 'vertical'  );
        [verticalH8,T8,R8]  =  hough(verticalBlackWhiteFrame8,'Theta',0);
        verticalP8   =  houghpeaks( verticalH8 , 2 , 'threshold' , ceil(0.1 * max(verticalH8(:)) ) );
        verticalLines8  =  houghlines(verticalBlackWhiteFrame8 , T8 , R8 , verticalP8 , 'FillGap' , 1 , 'MinLength' , 5);
        
        try
            BW9 = imbinarize(RotatingBarFullWidth,0.2);
            verticalBlackWhiteFrame9  =   edge(BW9, 'sobel' , 0.05 , 'vertical'  );
            [verticalH9,T9,R9]  =  hough(verticalBlackWhiteFrame9,'Theta',0);
            verticalP9   =  houghpeaks( verticalH9 , 5 , 'threshold' , ceil(0.3 * max(verticalH9(:)) ) );
            verticalLines9  =  houghlines(verticalBlackWhiteFrame9 , T9 , R9 , verticalP9 , 'FillGap' , 5 , 'MinLength' , 15);
            
            BW10 = imbinarize(RotatingBarFullWidth,0.2);
            verticalBlackWhiteFrame10  =   edge(BW10, 'sobel' , 0.05 , 'vertical'  );
            [verticalH10,T10,R10]  =  hough(verticalBlackWhiteFrame9,'Theta',0);
            verticalP10   =  houghpeaks( verticalH10 , 5 , 'threshold' , ceil(0.3 * max(verticalH10(:)) ) );
            verticalLines10  =  houghlines(verticalBlackWhiteFrame10 , T10 , R10 , verticalP10 , 'FillGap' , 5 , 'MinLength' , 15);
            
        catch
            verticalLines9 = [];
            verticalLines10 = [];
        end
        
        try
            BW = imbinarize(RotatingBarFullWidth,0.65);
            verticalBlackWhiteFrameLong  =   edge(BW, 'sobel' , 0.05 , 'vertical'  );
            [verticalH_Long,T_Long,R_Long]  =  hough(verticalBlackWhiteFrameLong,'Theta',0);
            verticalP_Long   =  houghpeaks( verticalH_Long , 5 , 'threshold' , ceil(0.3 * max(verticalH_Long(:)) ) );
            verticalLinesLong  =  houghlines(verticalBlackWhiteFrameLong , T_Long , R_Long , verticalP_Long , 'FillGap' , 5 , 'MinLength' , 15);
        catch
            verticalLinesLong = [];
        end
        
        
        % Concatenate both found lines
        verticalLines  =  [ verticalLines1 , verticalLines2 , verticalLines3 , verticalLines4 , verticalLines5 , verticalLines6 , verticalLines7 , verticalLines8 , verticalLines9 , verticalLines10];
        verticalLines_Long  =  verticalLinesLong ;
        
        
        
        for k  =  1 : length(verticalLines)
            
            pointX(v,k) = verticalLines(k).point2(1);
            
            if  v==1 && pointX(v,k) < size(RotatingBarFullWidth,2)-40 && pointX(v,k) > 41
                
                corrDoneFlag = 1 ;
                
                if (  strcmp(FeatureExtractor , 'Template Matching with normal correlation (news)' ) == 1 )
                                        
                    % Get Point of intersection of rotating text with the fixed
                    % text( Clock etc)
                    frameImg = RotatingBarFullWidth( : , pointX(v,k) : pointX(v,k)+40 ) ;
                    templateImg =  RotatingBarFullWidth_DozensLaterFrame( : , pointX(v,k) : pointX(v,k)+40 ) ;
                    corrScore_Right(k)= corr2(frameImg, templateImg);
                    
                    % Get Point of intersection of rotating text with the fixed
                    % text( News Type: Economic , Sports , politics etc)
                    frameImg = RotatingBarFullWidth( : , pointX(v,k)-40 : pointX(v,k) ) ;
                    templateImg =  RotatingBarFullWidth_DozensLaterFrame( : , pointX(v,k)-40 : pointX(v,k) );
                    corrScore_Left(k)= corr2(frameImg, templateImg);
                    
                else
                    
                    [~ , I_NCC_Right]=template_matching(RotatingBarFullWidth( : , pointX(v,k) : pointX(v,k)+40 ) , RotatingBarFullWidth_DozensLaterFrame( : , pointX(v,k) : pointX(v,k)+40 ) );
                    I_NCC_RightMax(k) = mean(I_NCC_Right(:));
                    
                    [~ , I_NCC_Left]=template_matching(RotatingBarFullWidth( : , pointX(v,k)-40 : pointX(v,k) ) , RotatingBarFullWidth_DozensLaterFrame( : , pointX(v,k)-40 : pointX(v,k) ) );
                    I_NCC_LeftMax(k) = mean(I_NCC_Left(:));
                    
                end
            end
        end
        
        
        
        for s  =  1 : length(verticalLines_Long)
            
            pointX_Long(v,s) = verticalLines_Long(s).point2(1);
            
        end
        
        
        if v == firstCaptionOrder && ~isempty(verticalLines) && corrDoneFlag ==1
            
            if (  strcmp(FeatureExtractor , 'Template Matching with normal correlation (news)' ) == 1 )

                I_diff = abs(corrScore_Right - corrScore_Left);

                I_diff_Sort = sort(I_diff, 'descend');
                
                if ~isempty(I_diff_Sort)
                    I_diff_Sort_Max_Correct_Index = find(I_diff_Sort < 1); 
                    I_Corr_Max = I_diff_Sort(I_diff_Sort_Max_Correct_Index(1));
                end
                              
                PointIdx = find(I_diff == I_Corr_Max );
                cropPointsX = pointX(PointIdx(1));
                               
                for I_count = 2: length(I_diff_Sort)

                    anotherPointIdx = find(I_diff == I_diff_Sort(I_count));
                    
                    if ~isempty(anotherPointIdx)
                        newPoint = pointX(anotherPointIdx(1));
                        
                        if  I_diff_Sort(I_count) >= 0.2   && abs(newPoint - cropPointsX) > n/2 %I_diff_Sort(I_count-1) - I_diff_Sort(I_count) >= 0.4 && I_diff_Sort(I_count) >= 0.4 %I_diff_Sort(I_count) >= 0.2 && I_diff_Sort(I_count) ~= I_diff_Sort(I_count-1)
                            
                            cropPointsX = [cropPointsX, newPoint ];
                            cropPointsX = sort(cropPointsX, 'descend');
                            break;
                            
                        end
                    end
                end
                
            else
                
                if pointX(k) < size(RotatingBarFullWidth,2)-40
                    I_diff = abs(I_NCC_RightMax - I_NCC_LeftMax);
                    
                    I_diff_Sort = sort(I_diff, 'descend');
                    
                    if ~isempty(I_diff_Sort)
                        I_NCC_Mean = I_diff_Sort(1);
                    end
                    
                    cropPointsX = [];
                    
                    if I_NCC_Mean >= 0.01
                        PointIdx = find(I_diff == I_NCC_Mean);
                        cropPointsX = pointX(PointIdx(1));
                    end
                    
                    for I_count = 2: length(I_diff_Sort)
                        
                        anotherPointIdx = find(I_diff == I_diff_Sort(I_count));
                        newPoint = pointX(anotherPointIdx(1));
                        
                        if  I_diff_Sort(I_count) >= 0.01  && abs(newPoint - cropPointsX) > 5*n/8 %&&  round(I_diff_Sort(1) - I_diff_Sort(I_count),2) >= 0.01
                                                      
                            cropPointsX = [cropPointsX, newPoint];
                            cropPointsX = sort(cropPointsX, 'descend');
                            break;
                            
                        end
                    end
                end
                
            end
            
        elseif  size(pointX_Long,1) >= v
            
            maxBoundary = max(pointX_Long(v,:)) + MaxBoundryTolerance;
            minBoundary = min(pointX_Long(v,:));
            if  minBoundary *2 < n && maxBoundary * 2 >  n
                cropPointsX = [ maxBoundary, minBoundary ] ;
            end
            
        end
                
        
        % Normal width for all regions except the bottom one
        if length(cropPointsX)==1
            
            if  cropPointsX *2 < n % x < n/2
                width(v) = n-cropPointsX;
                StartPt(v) = cropPointsX;
            else
                width(v) = cropPointsX;
                StartPt(v) = 1;
            end
                        
        elseif length(cropPointsX)==2 && abs(cropPointsX(1)-cropPointsX(2)) < 80 && cropPointsX(1) > n/2
            
            width(v) = min(cropPointsX);
            StartPt(v) = 1;
            
        elseif length(cropPointsX)==2 && abs(cropPointsX(1)-cropPointsX(end)) > n/4 && yDim(v)-yDim(v+1)<=40
            
            width(v) = cropPointsX(1) - cropPointsX(end);
            StartPt(v) = cropPointsX(end);
            
        else
            width(v) = n;
            StartPt(v) = 1;
            
        end
        
        if ForceFullCaptionAfterThisValue < ForceFullCaptionCount 
            width(1) = n;
            StartPt(1) = 1;            
        end
        
        width( length(yDim) : end ) = [];
        StartPt( length(yDim) : end ) = [];

        
        if ~isempty(width_Prev)  && length(width) == length(yDim)-1
            
            subtratcSize = min( length(width_Prev) , length (width) );
            widthDiffOK = all (abs( width_Prev(1:subtratcSize) - width(1:subtratcSize) ) < 15 );
            StartPtDiffOK = all ( abs ( StartPt_Prev(1:subtratcSize) - StartPt(1:subtratcSize) ) < 15 );
            
            
            if  widthDiffOK == 1 && StartPtDiffOK == 1 && ConfidenceLevel < ConfidenceThreshold
                
                ConfidenceLevel = ConfidenceLevel +1;
                holdFlag(v)=0;
                
            elseif  ConfidenceLevel >= ConfidenceThreshold

                if length(width) == length(width_Prev) 
                    width = width_Prev;
                    StartPt = StartPt_Prev;   
                    holdFlag(v)=0;
                    
                elseif length(width) > length(width_Prev) 
                    len = length(width_Prev) ;
                    width(1:len) = width_Prev;
                    StartPt(1:len) = StartPt_Prev;   
                    holdFlag(1:v)=1;
                end
                           
            else
                
                ConfidenceLevel = ConfidenceLevel - 1;
                holdFlag(v)=1;
                if ConfidenceLevel < -3
                    width_Prev = width;
                    StartPt_Prev = StartPt;
                    holdFlag(v)=0;
                    ConfidenceLevel = 0;
                end
                
                width = width_Prev;
                StartPt = StartPt_Prev;
                
            end
            
        elseif ~isempty(width_Prev) && v <= length(width_Prev)
            
            width(v) = width_Prev(v);
            StartPt(v) = StartPt_Prev(v);
%             holdFlag(v) = 1;

        end
        
        if  ConfidenceLevel >= ConfidenceThreshold 
            
            width(1) = width_Prev(1);
            StartPt(1) = StartPt_Prev(1);   
            
        end
        
        if holdFlag(v) == 0 
            
            width_Prev = width;
            StartPt_Prev = StartPt;
            
        end
        
        % keep 3rd and above captions alined with the previous ones
        try
            if v >= 3 && width(v) > width(v-1)
                
                width(v) = width(v-1);
                StartPt(v) = StartPt(v-1);
                
            end
        catch
            % Exception occured
        end
    
    end
    
    % Used for News like DMC Channel
    if ForceCaptionsDimensionsFlag == 1
        
        StartPt( 1 : length(StartPt) ) = ForceCaptionsStartPoint_X ;
        width( 1 :  length(StartPt) ) = ForceCaptionsWidth ;
        
    end
    
    if length(HeightTolerance) == 1
        singleToleranceFlag = 1;
    else
        singleToleranceFlag = 0;
    end
    
    for i  = 1 : lineIndex-1
        
        try
            if singleToleranceFlag == 1
                height(i)  =   yDim(i) - yDim(i+1) -  HeightTolerance;
                
                objectRegion = [StartPt(i) yDim(i+1) + PositionTolerance width(i) height(i)];
            else
                height(i)  =   yDim(i) - yDim(i+1) -  HeightTolerance(i);
                
                objectRegion = [StartPt(i) yDim(i+1) + PositionTolerance(i) width(i) height(i)];
            end
            
        catch
            
            % Exception occured
            r=0
            
        end
        
        % the output of the function used to crop the frames
        Caption_ROI(i,:) = objectRegion;
        
    end
    
    
% % %     Urdu

% % % % horizontalLinesDistanceTolerance = 10;
% % % % 
% % % % HeightTolerance  =  -5;
% % % % PositionTolerance  =  -3 ;
% % % % % In case of curved / inclined captions
% % % % ForceCaptionsDimensionsFlag = 0;
% % % % ForceCaptionsStartPoint_X = 284 ;
% % % % ForceCaptionsEndPoint_X = 1166 ;
% % % % 
% % % % ForceAllCaptionsDimensionsFlag = 1;
% % % %     ForceCaptionsStartPoint_X = [ 77 153 153 153 153 153 ];
% % % %     ForceCaptionsEndPoint_X = [ 682 679 679 679 679 679] ;
% % % % 
% % % % 
% % % % ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % % 
% % % % MaxBoundryTolerance = 0;
% % % % ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % % 
% % % % % Confidence for caption width low ex 3 for fast changes
% % % % % but greater for slow changes ex.5
% % % % ConfidenceThreshold = 5; % BBC 1 caption = 7
% % % % 
% % % % % In case no bottom line this is the new line distance from image end
% % % % distanceFromImageBottom = 4;
% % % % 
% % % % % The flag can have 0 and 1 values
% % % % % 2 : small number of lines (used in case of mis - alignment issue)
% % % % % 3 : medium number of lines
% % % % getExtralinesFlag = 1;
% % % % % The flag can have -1 , 0 and 1 values
% % % % getExtraBottomlinesFlag = 1;
% % % % 
% % % % % Lower Limit for distance between the Text line and bottom boundry
% % % % TextLineBottomBoundryLowerLimit = 4;
% % % % % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % % % 35 in case of ON TV news
% % % % % 25 Sky Ramadan
% % % % % 6 for english/latin text
% % % % TextLineBottomBoundryUpperLimit = 15;

%%% CNN Sleep

% % % % % horizontalLinesDistanceTolerance = 10;
% % % % % 
% % % % % HeightTolerance  =  -3;
% % % % % PositionTolerance  =  2 ;
% % % % % % In case of curved / inclined captions
% % % % % ForceCaptionsDimensionsFlag = 0;
% % % % % ForceCaptionsStartPoint_X = 284 ;
% % % % % ForceCaptionsEndPoint_X = 1166 ;
% % % % % 
% % % % % ForceAllCaptionsDimensionsFlag = 1;
% % % % %     ForceCaptionsStartPoint_X = [ 1 254 254 254 254 254];
% % % % %     ForceCaptionsEndPoint_X = [ 1009 1060 1060 1060 1060 1060] ;
% % % % % 
% % % % % 
% % % % % ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % % % 
% % % % % MaxBoundryTolerance = 0;
% % % % % ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % % % 
% % % % % % Confidence for caption width low ex 3 for fast changes
% % % % % % but greater for slow changes ex.5
% % % % % ConfidenceThreshold = 5; % BBC 1 caption = 7
% % % % % 
% % % % % % In case no bottom line this is the new line distance from image end
% % % % % distanceFromImageBottom = 20;
% % % % % 
% % % % % % The flag can have 0 and 1 values
% % % % % % 2 : small number of lines (used in case of mis - alignment issue)
% % % % % % 3 : medium number of lines
% % % % % getExtralinesFlag = 1;
% % % % % % The flag can have -1 , 0 and 1 values
% % % % % getExtraBottomlinesFlag = 0;
% % % % % 
% % % % % % Lower Limit for distance between the Text line and bottom boundry
% % % % % TextLineBottomBoundryLowerLimit = 4;
% % % % % % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % % % % 35 in case of ON TV news
% % % % % % 25 Sky Ramadan
% % % % % % 6 for english/latin text
% % % % % TextLineBottomBoundryUpperLimit = 15;
% % % % % 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % % CNN TRUMP Problem exist
% % % %     
% % % %     horizontalLinesDistanceTolerance = 2;
% % % %     
% % % %     HeightTolerance  =  -2;
% % % %     PositionTolerance  =  0 ;
% % % %     % In case of curved / inclined captions
% % % %     ForceCaptionsDimensionsFlag = 0;
% % % %     ForceCaptionsStartPoint_X = 1;                                                                                                                                                                                                                                                                                                                                                                                                                                                     oint_X = 284 ;
% % % %     ForceCaptionsEndPoint_X = 1166 ;
% % % %   
% % % %     ForceAllCaptionsDimensionsFlag = 1;
% % % %     ForceCaptionsStartPoint_X = [26 26  30 30 30 30 30 30];
% % % %     ForceCaptionsEndPoint_X = [518 518 547 547 212 212 212 212] ;
% % % %     
% % % %     
% % % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % %     
% % % %     MaxBoundryTolerance = 0;
% % % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % %     
% % % %     % Confidence for caption width low ex 3 for fast changes 
% % % %     % but greater for slow changes ex.5
% % % %     ConfidenceThreshold = 2; % BBC 1 caption = 7
% % % %     
% % % %     % In case no bottom line this is the new line distance from image end
% % % %     distanceFromImageBottom = 40;
% % % %     
% % % %     % The flag can have 0 and 1 values
% % % %     % 2 : small number of lines (used in case of mis - alignment issue)
% % % %     % 3 : medium number of lines
% % % %     getExtralinesFlag = 1;
% % % %     % The flag can have -1 , 0 and 1 values    
% % % %     getExtraBottomlinesFlag = 1;
% % % %     
% % % %     % Lower Limit for distance between the Text line and bottom boundry
% % % %     TextLineBottomBoundryLowerLimit = 4;
% % % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % %     % 35 in case of ON TV news
% % % %     % 25 Sky Ramadan
% % % %     % 6 for english/latin text
% % % %     TextLineBottomBoundryUpperLimit = 15;

    
%%%% TRT world %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % %    firstCaptionOrder = 1;
% % % %     HeightTolerance  =  4;
% % % %     PositionTolerance  =  2 ;
% % % %     
% % % %     horizontalLinesDistanceTolerance = 4;
% % % %     
% % % % %     HeightTolerance  =  4;
% % % % %     PositionTolerance  =  2 ;
% % % %     % In case of curved / inclined captions
% % % %     ForceCaptionsDimensionsFlag = 0;
% % % %     ForceCaptionsStartPoint_X = 284 ;
% % % %     ForceCaptionsEndPoint_X = 1166 ;
% % % %   
% % % %     ForceAllCaptionsDimensionsFlag = 1;
% % % %     ForceCaptionsStartPoint_X = [286  108 108 108 108 108 108];
% % % %     ForceCaptionsEndPoint_X = [1166  1166 618 618 618 618 618] ;
% % % %     
% % % %     
% % % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % %     
% % % %     MaxBoundryTolerance = 0;
% % % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % %     
% % % %     % Confidence for caption width low ex 3 for fast changes 
% % % %     % but greater for slow changes ex.5
% % % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % % %     
% % % %     % In case no bottom line this is the new line distance from image end
% % % %     distanceFromImageBottom = 5;
% % % %     
% % % %     % The flag can have 0 and 1 values
% % % %     % 2 : small number of lines (used in case of mis - alignment issue)
% % % %     % 3 : medium number of lines
% % % %     getExtralinesFlag = 2;
% % % %     % The flag can have -1 , 0 and 1 values    
% % % %     getExtraBottomlinesFlag = 0;
% % % %     
% % % %     % Lower Limit for distance between the Text line and bottom boundry
% % % %     TextLineBottomBoundryLowerLimit = 4;
% % % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % %     % 35 in case of ON TV news
% % % %     % 25 Sky Ramadan
% % % %     % 6 for english/latin text
% % % %     TextLineBottomBoundryUpperLimit = 6;
    
   %%%% TRT world 3rd Part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % %    firstCaptionOrder = 1;
% % %    HeightTolerance  =  4;
% % %    PositionTolerance  =  2 ;
% % %    
% % %    horizontalLinesDistanceTolerance = 4;
% % %    
% % %    %     HeightTolerance  =  4;
% % %    %     PositionTolerance  =  2 ;
% % %    % In case of curved / inclined captions
% % %    ForceCaptionsDimensionsFlag = 0;
% % %    ForceCaptionsStartPoint_X = 284 ;
% % %    ForceCaptionsEndPoint_X = 1166 ;
% % %    
% % %    ForceAllCaptionsDimensionsFlag = 1;
% % %    ForceCaptionsStartPoint_X = [286  108 108 108 108 108 108];
% % %    ForceCaptionsEndPoint_X = [1166  618 618 618 618 618 618] ;
% % %    
% % %    
% % %    ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %    
% % %    MaxBoundryTolerance = 0;
% % %    ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %    %     ForceFullCaptionAfterThisValue =  10  ;
% % %    
% % %    % Confidence for caption width low ex 3 for fast changes
% % %    % but greater for slow changes ex.5
% % %    ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %    
% % %    % In case no bottom line this is the new line distance from image end
% % %    distanceFromImageBottom = 20;
% % %    
% % %    % The flag can have 0 and 1 values
% % %    % 2 : small number of lines (used in case of mis - alignment issue)
% % %    % 3 : medium number of lines
% % %    getExtralinesFlag = 4;
% % %    % The flag can have -1 , 0 and 1 values
% % %    getExtraBottomlinesFlag = 0;
% % %    
% % %    % Lower Limit for distance between the Text line and bottom boundry
% % %    TextLineBottomBoundryLowerLimit = 4;
% % %    % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %    % 35 in case of ON TV news
% % %    % 25 Sky Ramadan
% % %    % 6 for english/latin text
% % %    TextLineBottomBoundryUpperLimit = 6;
    
 %%% France24 AR BnSalman_Mackron   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% % %     HeightTolerance  =  0;
% % %     PositionTolerance  =  4 ;
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = 172 ;
% % %     ForceCaptionsEndPoint_X = 1187 ;
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 5;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 2;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;

    
%%%% RT Arabic Qudus %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % %     HeightTolerance  =  4;
% % % %     PositionTolerance  =  2 ;
% % % %     % In case of curved / inclined captions
% % % %     ForceCaptionsDimensionsFlag = 1;
% % % %     ForceCaptionsStartPoint_X = 1 ;
% % % %     ForceCaptionsEndPoint_X = 503 ;
% % % %   
% % % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % %     
% % % %     MaxBoundryTolerance = 0;
% % % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % %     
% % % %     % Confidence for caption width low ex 3 for fast changes 
% % % %     % but greater for slow changes ex.5
% % % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % % %     
% % % %     % In case no bottom line this is the new line distance from image end
% % % %     distanceFromImageBottom = 30;
% % % %     
% % % %     % The flag can have 0 and 1 values
% % % %     getExtralinesFlag = 2;
% % % %     % The flag can have -1 , 0 and 1 values    
% % % %     getExtraBottomlinesFlag = 1;
% % % %     
% % % %     % Lower Limit for distance between the Text line and bottom boundry
% % % %     TextLineBottomBoundryLowerLimit = 4;
% % % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % %     % 35 in case of ON TV news
% % % %     % 25 Sky Ramadan
% % % %     TextLineBottomBoundryUpperLimit = 15;
    

%%% France24 EN Nobel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     HeightTolerance  =  4;
% % %     PositionTolerance  =  2 ;
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = 99 ;
% % %     ForceCaptionsEndPoint_X = 1180 ;
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 200;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 3; %lines  =  houghlines(BlackWhiteFrame , T , R , P , 'FillGap' , 5 , 'MinLength' , 100)
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;
    

%%% Iran %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    
% % %     ForceCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = 1 ;
% % %     ForceCaptionsEndPoint_X = 520 ;
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 1;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 0;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 0;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;
    
%%Hebrew   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %     firstCaptionOrder = 1;
% % % %     HeightTolerance  =  4;
% % % %     PositionTolerance  =  2 ;
% % % %     horizontalLinesDistanceTolerance = 10;
% % % % 
% % % %     % In case of curved / inclined captions
% % % %     ForceCaptionsDimensionsFlag = 1;
% % % %     ForceCaptionsStartPoint_X = 32 ;
% % % %     ForceCaptionsEndPoint_X = 593 ;
% % % %   
% % % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % %     
% % % %     MaxBoundryTolerance = 0;
% % % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % %     
% % % %     % Confidence for caption width low ex 3 for fast changes 
% % % %     % but greater for slow changes ex.5
% % % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % % %     
% % % %     % In case no bottom line this is the new line distance from image end
% % % %     distanceFromImageBottom = 30;
% % % %     
% % % %     % The flag can have 0 and 1 values
% % % %     getExtralinesFlag = 1;
% % % %     % The flag can have -1 , 0 and 1 values    
% % % %     getExtraBottomlinesFlag = 1;
% % % %     
% % % %     % Lower Limit for distance between the Text line and bottom boundry
% % % %     TextLineBottomBoundryLowerLimit = 4;
% % % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % %     % 35 in case of ON TV news
% % % %     % 25 Sky Ramadan
% % % %     TextLineBottomBoundryUpperLimit = 15;
    
    
  
% % %     CNN Cancer  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%trial 1
% % % % horizontalLinesDistanceTolerance = 10;
% % % % 
% % % % HeightTolerance  =  -2;
% % % % PositionTolerance  =  -1 ;
% % % % % In case of curved / inclined captions
% % % % ForceCaptionsDimensionsFlag = 0;
% % % % ForceCaptionsStartPoint_X = 284 ;
% % % % ForceCaptionsEndPoint_X = 1166 ;
% % % % 
% % % % ForceAllCaptionsDimensionsFlag = 1;
% % % % ForceCaptionsStartPoint_X = [56  127 127 127 127 127 127];
% % % % ForceCaptionsEndPoint_X = [504  532 340 340 532 532 532] ;
% % % % 
% % % % 
% % % % ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % % 
% % % % MaxBoundryTolerance = 0;
% % % % ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % % 
% % % % % Confidence for caption width low ex 3 for fast changes
% % % % % but greater for slow changes ex.5
% % % % ConfidenceThreshold = 5; % BBC 1 caption = 7
% % % % 
% % % % % In case no bottom line this is the new line distance from image end
% % % % distanceFromImageBottom = 10;
% % % % 
% % % % % The flag can have 0 and 1 values
% % % % % 2 : small number of lines (used in case of mis - alignment issue)
% % % % % 3 : medium number of lines
% % % % getExtralinesFlag = 1;
% % % % % The flag can have -1 , 0 and 1 values
% % % % getExtraBottomlinesFlag = 1;
% % % % 
% % % % % Lower Limit for distance between the Text line and bottom boundry
% % % % TextLineBottomBoundryLowerLimit = 4;
% % % % % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % % % 35 in case of ON TV news
% % % % % 25 Sky Ramadan
% % % % % 6 for english/latin text
% % % % TextLineBottomBoundryUpperLimit = 25;
    
    % Trial 2

% % % % %     HeightTolerance  =  -1;
% % % % %     PositionTolerance  =  2 ;
% % % % %     % In case of curved / inclined captions
% % % % %     ForceCaptionsDimensionsFlag = 0;
% % % % %     ForceCaptionsStartPoint_X = 1 ;
% % % % %     ForceCaptionsEndPoint_X = 1000 ;
% % % % %   
% % % % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % % %     
% % % % %     MaxBoundryTolerance = 0;
% % % % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % % %     
% % % % %     % Confidence for caption width low ex 3 for fast changes 
% % % % %     % but greater for slow changes ex.5
% % % % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % % % %     
% % % % %     % In case no bottom line this is the new line distance from image end
% % % % %     distanceFromImageBottom = 15;
% % % % %     
% % % % %     % The flag can have 0 and 1 values
% % % % %     getExtralinesFlag = 1;
% % % % %     % The flag can have -1 , 0 and 1 values    
% % % % %     getExtraBottomlinesFlag = -1;
% % % % %     
% % % % %     % Lower Limit for distance between the Text line and bottom boundry
% % % % %     TextLineBottomBoundryLowerLimit = 4;
% % % % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % % %     % 35 in case of ON TV news
% % % % %     % 25 Sky Ramadan
% % % % %     TextLineBottomBoundryUpperLimit = 15;    

%     CNN Sleep  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % firstCaptionOrder = 2;
% % % HeightTolerance  =  0;
% % % % In case of curved / inclined captions
% % % ForceCaptionsDimensionsFlag = 0;
% % % ForceCaptionsStartPoint_X = 1 ;
% % % ForceCaptionsEndPoint_X = 1000 ;
% % % 
% % % ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % % 
% % % MaxBoundryTolerance = 0;
% % % ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % % 
% % % % Confidence for caption width low ex 3 for fast changes
% % % % but greater for slow changes ex.5
% % % ConfidenceThreshold = 5; % BBC 1 caption = 7
% % % 
% % % % In case no bottom line this is the new line distance from image end
% % % distanceFromImageBottom = 15;
% % % 
% % % % The flag can have 0 and 1 values
% % % getExtralinesFlag = 1;
% % % % The flag can have -1 , 0 and 1 values
% % % getExtraBottomlinesFlag = 1;
% % % 
% % % % Lower Limit for distance between the Text line and bottom boundry
% % % TextLineBottomBoundryLowerLimit = 4;
% % % % Upper limit <<15>> in normal case 20 in some cases like RT news
% % % % 35 in case of ON TV news
% % % % 25 Sky Ramadan
% % % TextLineBottomBoundryUpperLimit = 15;  


% RT Islam English  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     ForceCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = 180 ;
% % %     ForceCaptionsEndPoint_X = 854 ;
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 30;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 0;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;


% Hayat     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 10;
% % %     
% % %     getExtralinesFlag = 1;
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;
% Hayat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
% CBC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     ConfidenceThreshold = 3;
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 10;
% % %     
% % %     getExtralinesFlag = 0;
% % %     getExtraBottomlinesFlag = 0;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 20;
% CBC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% Dream%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     HeightTolerance  =  [ 4 18];
% % %     PositionTolerance  =  [2 0] ;
% % %     firstCaptionOrder = 1;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  1 168  168 168  168  168 168  168];
% % %     ForceCaptionsEndPoint_X = [  783 796 796 796 796 796 796 796] ;
% % % 
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =4;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 10;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 0;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 0;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 35;
% Dream%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Olla Old%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 35;
% % %     
% % %     getExtralinesFlag = 1;
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 20;
%Olla Old%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Olla New%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % 
% % %     firstCaptionOrder = 1;
% % %     HeightTolerance  =  2;
% % %     PositionTolerance  =  1 ;
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  1 103  128 128  128 128  128 128 ];
% % %     ForceCaptionsEndPoint_X = [  500 596 596 596 596 596 596 596] ;
% % % 
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =4;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 35;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 1;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 20;
%Olla New%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
% Sky USA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %    ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 12;
% % %     
% % %     getExtralinesFlag = 1;
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;
% Sky USA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%People%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 20;
% % %     
% % %     getExtralinesFlag = 0;
% % %     getExtraBottomlinesFlag = 0;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 30;
%People%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

% Arabya%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 20;
% % %     
% % %     getExtralinesFlag = 0;
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 18;
    
% Arabya%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Elbalad%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % %    ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 15;
% % %     
% % %     getExtralinesFlag = 1;
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 18;
%Elbalad%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    

%%% Sky Sob7 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
% % %      MaxBoundryTolerance = 10;
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 2; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 15;
% % %     
% % %     getExtralinesFlag = 0;
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;
%%% Sky Sob7 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


% Hayat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 15;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 1;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;
% Hayat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    

%%%% DMC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 15;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 0;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;
   
    
%%%%%%%%%%%%%%%%%%%%%% NEW BEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     firstCaptionOrder = 1;
% % %     
% % %     HeightTolerance  =  2;
% % %     PositionTolerance  =  4 ;
% % %     
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  74 74 215  61 61  61  61 61  61];
% % %     ForceCaptionsEndPoint_X = [  1119 1119 1050 1216 1216 1216 1216 1216 1216] ;    
% % %  
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % %     horizontalLinesDistanceTolerance = 6;
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 15;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 2;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 35;

%%%% DMC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%% ON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 15;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 0;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 30;
    

%%% ON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     firstCaptionOrder = 1;
% % %     
% % %     HeightTolerance  =  2;
% % %     PositionTolerance  =  4 ;    
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % %  
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [4 50 400 400 400 ];
% % %     ForceCaptionsEndPoint_X = [1010 1140 1140  1140 1140 ] ;
% % % 
% % %     horizontalLinesDistanceTolerance = 10;
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 20;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 0;
% % %     % The flag can have -1 , 0 and 1 values
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;
%%% ON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	


% % % RT Vertical  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% %     firstCaptionOrder = 2;
% %     HeightTolerance  =  2;
% %     PositionTolerance  =  1 ;
% %     ForceCaptionsDimensionsFlag = 0;
% %     ForceAllCaptionsDimensionsFlag = 1;
% %     ForceCaptionsStartPoint_X = [  1 1  155 155 155 155 155 155];
% %     ForceCaptionsEndPoint_X = [  566 566 566 566 566 566 566 566] ;
% % 
% %   
% %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% %     horizontalLinesDistanceTolerance =4;
% %     MaxBoundryTolerance = 0;
% %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     ForceFullCaptionAfterThisValue =  10  ;
% %     
% %     % Confidence for caption width low ex 3 for fast changes 
% %     % but greater for slow changes ex.5
% %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% %     
% %     % In case no bottom line this is the new line distance from image end
% %     distanceFromImageBottom = 200;
% %     
% %     % The flag can have 0 and 1 values
% %     getExtralinesFlag = 5;
% %     % The flag can have -1 , 0 and 1 values    
% %     getExtraBottomlinesFlag = -1;
% %     
% %     % Lower Limit for distance between the Text line and bottom boundry
% %     TextLineBottomBoundryLowerLimit = 4;
% %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% %     % 35 in case of ON TV news
% %     % 25 Sky Ramadan
% %     TextLineBottomBoundryUpperLimit = 8;
% % 
% % 
% %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

% % % 	%BBC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % 
% % %     firstCaptionOrder = 1;
% % %     HeightTolerance  =  2;
% % %     PositionTolerance  =  1 ;
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  1 1  1 1  1 1  1 1 ];
% % %     ForceCaptionsEndPoint_X = [  403 532 532 532 532 532 532 532] ;
% % % 
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =4;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 10;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 0;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;
% % % 
% % % 
% % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

% % % 	Sky Ramadan  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     HeightTolerance  =  4;
% % %     PositionTolerance  =  2 ;
% % % 
% % %    
% % %     firstCaptionOrder = 1;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  3 540  784 784  784  784 784  784];
% % %     ForceCaptionsEndPoint_X = [  962 1072 1072 1072 1072 1072 1072 1072] ;
% % % 
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance = 10;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     % ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 40;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 1;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;
   

% % %   Sky Syria %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     HeightTolerance  =  4;
% % %     PositionTolerance  =  2 ;
% % % 
% % %    
% % %     firstCaptionOrder = 1;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  1 319  319 319  319  319 319  319];
% % %     ForceCaptionsEndPoint_X = [  482 537 537 537 537 537 537 537] ;

% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance = 7;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     % ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 20;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 0;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 10;
% % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 

%%% BBC AR H2 Sainai    
% % %     firstCaptionOrder = 1;
% % %     HeightTolerance  =  2;
% % %     PositionTolerance  =  1 ;
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  30 30 30 30  ];
% % %     ForceCaptionsEndPoint_X = [  530 530 530 530] ;
% % % 
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =4;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 10;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 7;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 20;


% % %     Jejera EN H2 Britain
% % %    firstCaptionOrder = 1;
% % %    HeightTolerance  =  2;
% % %    PositionTolerance  =  2 ;
% % %    
% % %    horizontalLinesDistanceTolerance = 20;
% % %    
% % %    %     HeightTolerance  =  4;
% % %    %     PositionTolerance  =  2 ;
% % %    % In case of curved / inclined captions
% % %    ForceCaptionsDimensionsFlag = 0;
% % %    ForceCaptionsStartPoint_X = 284 ;
% % %    ForceCaptionsEndPoint_X = 1166 ;
% % %    
% % %    ForceAllCaptionsDimensionsFlag = 1;
% % %    ForceCaptionsStartPoint_X = [296 296  296 296 296 ];
% % %    ForceCaptionsEndPoint_X = [1086 1086  1086 1086 1086] ;
% % %    
% % %    ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %    
% % %    MaxBoundryTolerance = 0;
% % %    ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %    % ForceFullCaptionAfterThisValue =  10  ;
% % %    
% % %    % Confidence for caption width low ex 3 for fast changes
% % %    % but greater for slow changes ex.5
% % %    ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %    
% % %    % In case no bottom line this is the new line distance from image end
% % %    distanceFromImageBottom = 15;
% % %    
% % %    % The flag can have 0 and 1 values
% % %    % 2 : small number of lines (used in case of mis - alignment issue)
% % %    % 3 : medium number of lines
% % %    getExtralinesFlag = 2;
% % %    % The flag can have -1 , 0 and 1 values
% % %    getExtraBottomlinesFlag = -1;
% % %    
% % %    % Lower Limit for distance between the Text line and bottom boundry
% % %    TextLineBottomBoundryLowerLimit = 4;
% % %    % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %    % 35 in case of ON TV news
% % %    % 25 Sky Ramadan
% % %    % 6 for english/latin text
% % %    TextLineBottomBoundryUpperLimit = 6;
% % %     Jejera EN H2 Britain


% SKY AR H2
% % %     HeightTolerance  =  4;
% % %     PositionTolerance  =  2;
% % %     firstCaptionOrder = 1;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % % % SKY AR H2 Dubai
% % % %     ForceCaptionsStartPoint_X = [  4 94  94 94  94];
% % % %     ForceCaptionsEndPoint_X = [  545 545 545 545 545 ] ;
% % % % SKY AR H2 Women Rights
% % % %     ForceCaptionsStartPoint_X = [  1 70  70 262 ];
% % % %     ForceCaptionsEndPoint_X = [  783 620 620 620 ] ;
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =4;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %       MaxBoundryTolerance = 10;
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 2; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 15;
% % %     
% % %     getExtralinesFlag = 0;
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     TextLineBottomBoundryUpperLimit = 15;

   

% Jejera AR Vert1
% % %     firstCaptionOrder = 1;
% % %     
% % %     HeightTolerance  =  6;
% % %     PositionTolerance  =  6 ;
% % %     
% % %     horizontalLinesDistanceTolerance = 4;
% % %      % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % %   
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [211 211 211 211 211 ];
% % %     ForceCaptionsEndPoint_X = [1062 1062 1062  1062 1062 ] ;
% % % 
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 4;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 7; % may be 2 to be first half of video better
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;
% Jejera AR Vert1    

     % Hora AR Vert2
% % %     firstCaptionOrder = 1;
% % %    HeightTolerance  =  2;
% % %    PositionTolerance  =  -2 ;
% % %    
% % %    horizontalLinesDistanceTolerance = 20;
% % %    % In case of curved / inclined captions
% % %    ForceCaptionsDimensionsFlag = 0;
% % %    ForceCaptionsStartPoint_X = 284 ;
% % %    ForceCaptionsEndPoint_X = 1166 ;
% % %    
% % %    ForceAllCaptionsDimensionsFlag = 1;
% % %    ForceCaptionsStartPoint_X = [40 40  40 40 40 ];
% % %    ForceCaptionsEndPoint_X = [1186 1186  1186 1186 1186] ;
% % %    
% % %    ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %    
% % %    MaxBoundryTolerance = 0;
% % %    ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %    % ForceFullCaptionAfterThisValue =  10  ;
% % %    
% % %    % Confidence for caption width low ex 3 for fast changes
% % %    % but greater for slow changes ex.5
% % %    ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %    
% % %    % In case no bottom line this is the new line distance from image end
% % %    distanceFromImageBottom = 15;
% % %    
% % %    % The flag can have 0 and 1 values
% % %    % 2 : small number of lines (used in case of mis - alignment issue)
% % %    % 3 : medium number of lines
% % %    getExtralinesFlag = 2;
% % %    % The flag can have -1 , 0 and 1 values
% % %    getExtraBottomlinesFlag = -1;
% % %    
% % %    % Lower Limit for distance between the Text line and bottom boundry
% % %    TextLineBottomBoundryLowerLimit = 4;
% % %    % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %    % 35 in case of ON TV news
% % %    % 25 Sky Ramadan
% % %    % 6 for english/latin text
% % %    TextLineBottomBoundryUpperLimit = 6;
     % Hora AR Vert2
     
     % Hayat AR Static
% % %     HeightTolerance  =  4 ;
% % %     PositionTolerance  =  2 ;
% % %     firstCaptionOrder = 1;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [ 285 285  285 285 ];
% % %     ForceCaptionsEndPoint_X = [  1108 1108 1108 1108] ;
% % % 
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =8;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 10;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 2;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;    
    % Hayat AR Static
    
    % TEN AR Static
% % %     HeightTolerance  =  4 ;
% % %     PositionTolerance  =  2 ;
% % %     firstCaptionOrder = 1;
% % % 
% % %     horizontalLinesDistanceTolerance = 80;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % % 
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  295 295  295 295];
% % %     ForceCaptionsEndPoint_X = [  1187 1187 1187 1187] ;
% % %     
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;    
% % %     ConfidenceThreshold = 3;
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 5;
% % %     
% % %     getExtralinesFlag = 2;
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 255;
 % TEN AR Static    

 % CBC AR Static %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     HeightTolerance  =  4 ;
% % %     PositionTolerance  =  2 ;
% % %     firstCaptionOrder = 1;
% % % 
% % %     horizontalLinesDistanceTolerance = 10;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % % 
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  66 66  66 66];
% % %     ForceCaptionsEndPoint_X = [  369 369 369 369] ;
% % %     
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;    
% % %     ConfidenceThreshold = 3;
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 10;
% % %     
% % %     getExtralinesFlag = 0;
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 35;
% CBC AR Static %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ON TV Staic %%%%%%    
% % %     HeightTolerance  =  4 ;
% % %     PositionTolerance  =  2 ;
% % %     firstCaptionOrder = 1;
% % % 
% % %     horizontalLinesDistanceTolerance = 4;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 72 ;
% % %     ForceCaptionsEndPoint_X = 1120 ;
% % % 
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  62 62  62 62];
% % %     ForceCaptionsEndPoint_X = [  1170 1170 1170 1170] ;
% % %     
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 3; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 15;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 1;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 30;
% ON TV Staic %%%%%%     

% Masrya AR Static%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     HeightTolerance  =  4 ;
% % %     PositionTolerance  =  2 ;
% % %     firstCaptionOrder = 1;
% % % 
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [ 178 178  178 178 ];
% % %     ForceCaptionsEndPoint_X = [  550 550 550 550] ;
% % % 
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =8;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 10;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 1;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 25;
% Masrya AR Static%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%RT En Yellow Shirts    
% % %     firstCaptionOrder = 2;
% % %     HeightTolerance  =  2;
% % %     PositionTolerance  =  1 ;
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  277 277  277 277];
% % %     ForceCaptionsEndPoint_X = [  1368 1368 1368 1368] ;
% % %     
% % %     
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =4;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 200;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 2;
% % %     % The flag can have -1 , 0 and 1 values
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 8;
%RT En Yellow Shirts     


    
    % BloomBerg_EN_Static
% % %     firstCaptionOrder = 1;
% % %     
% % %     HeightTolerance  =  4;
% % %     
% % %     PositionTolerance  =  2 ;
% % %     
% % %     horizontalLinesDistanceTolerance = 4;
% % %     
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 1 ;
% % %     ForceCaptionsEndPoint_X = 1000 ;
% % %     
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [281 281 281 281 281 ];
% % %     ForceCaptionsEndPoint_X = [1102 1102 1102  1102 1102 ] ;

% % % % Bloomberg2
% % %     ForceCaptionsStartPoint_X = [284 284 284 284 284 ];
% % %     ForceCaptionsEndPoint_X = [1122 1122 1122  1122 1122 ] ;
% % %     
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     %CNN Most important
% % %     distanceFromImageBottom = 22; 
% % %     % distanceFromImageBottom = 28;% Bloomberg2
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 4;
% % %     % The flag can have -1 , 0 and 1 values
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;
    % BloomBerg_EN_Static

    % CNN EN P1 , P2 , P3 are static 
    % For P1 accurate alone: Put HeightTolerance=12 and PositionTolerance=12 
% % %     firstCaptionOrder = 1;
% % %     
% % %     HeightTolerance  =  6;
% % %     
% % %     PositionTolerance  =  6 ;
% % %     
% % %     horizontalLinesDistanceTolerance = 4;
% % %     
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 1 ;
% % %     ForceCaptionsEndPoint_X = 1000 ;
% % % 
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [1035 66 66  66 66 66 66 66 66];
% % %     ForceCaptionsEndPoint_X = [1226 1088 632  632 632 632 632 632 632] ;
% % % 
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     %CNN Most important
% % %     distanceFromImageBottom = 22;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 5;
% % %     % The flag can have -1 , 0 and 1 values
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;



    % CNN EN P1:Vert1 P2:Static 
% % %     firstCaptionOrder = 1;
% % %     
% % %     HeightTolerance  =  8;
% % %     
% % %     PositionTolerance  =  8 ;
% % %     
% % %     horizontalLinesDistanceTolerance = 4;
% % %     
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 1 ;
% % %     ForceCaptionsEndPoint_X = 1000 ;
% % % 
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [175 66  66 66 66 66 66 66];
% % %     ForceCaptionsEndPoint_X = [1222 1090  1090 1090 1090 1090 1090 1090] ;
% % % 
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     %CNN Most important
% % %     distanceFromImageBottom = 18;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 3;
% % %     % The flag can have -1 , 0 and 1 values
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 15;
 % CNN EN P1:Vert1 P2:Static    


%%% TRT EN Vert2 Khashiggy4 %%%%%%%%%%%%%%%%%%%%     
% % %     firstCaptionOrder = 2;
% % %     HeightTolerance  =  4;
% % %     PositionTolerance  =  2 ;
% % %     
% % %     horizontalLinesDistanceTolerance = 4;
% % %     
% % %     %     HeightTolerance  =  4;
% % %     %     PositionTolerance  =  2 ;
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 284 ;
% % %     ForceCaptionsEndPoint_X = 1166 ;
% % %     
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %   
% % % %     Kashiggy4
% % %     ForceCaptionsStartPoint_X = [282 114  114 114 114 114 114 114];
% % %     ForceCaptionsEndPoint_X = [1165 1165  558 558 558 558 558 558] ;    
% % % 
% % % 
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 30;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     % 2 : small number of lines (used in case of mis - alignment issue)
% % %     % 3 : medium number of lines
% % %     getExtralinesFlag = 2;
% % %     % The flag can have -1 , 0 and 1 values
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     % 6 for english/latin text
% % %     TextLineBottomBoundryUpperLimit = 6;
%%% TRT EN Vert2 Khashiggy4 %%%%%%%%%%%%%%%%%%%% 
  
    
%%% TRT EN Vert2 Khashiggy2 and (Khashiggy3 P 2 / 3) %%%%%%%%%%%%%%%%%%%%     
% % %     firstCaptionOrder = 2;
% % %     HeightTolerance  =  4;
% % %     PositionTolerance  =  2 ;
% % %     
% % %     horizontalLinesDistanceTolerance = 4;
% % %     
% % %     %     HeightTolerance  =  4;
% % %     %     PositionTolerance  =  2 ;
% % %     % In case of curved / inclined captions
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceCaptionsStartPoint_X = 284 ;
% % %     ForceCaptionsEndPoint_X = 1166 ;
% % %     
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     Kashiggy2:
% % %     ForceCaptionsStartPoint_X = [110 110  110 110 110 110 110 110];
% % %     ForceCaptionsEndPoint_X = [1165 1165  417 417 417 417 417 417] ;
% % %     Kashiggy3:
% % %     ForceCaptionsStartPoint_X = [112 112  112 112 112 112 112 112];
% % %     ForceCaptionsEndPoint_X = [1165 1165  614 614 614 614 614 614] ;     
% % %     Kashiggy5:
% % %     ForceCaptionsStartPoint_X = [112 112  112 112 112 112 112 112];
% % %     ForceCaptionsEndPoint_X = [1165 1165  564 564 564 564 564 564] ;  
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %     %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 20;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     % 2 : small number of lines (used in case of mis - alignment issue)
% % %     % 3 : medium number of lines
% % %     getExtralinesFlag = 2;
% % %     % The flag can have -1 , 0 and 1 values
% % %     getExtraBottomlinesFlag = -1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     % 6 for english/latin text
% % %     TextLineBottomBoundryUpperLimit = 6;    
%%% TRT EN Vert2 Khashiggy P 2 / 3 %%%%%%%%%%%%%%%%%%%%    

%%% SKY EN Vert2 Nicolas %%%%%%%%%%%%%%%%%%%%      
% % %    firstCaptionOrder = 1;
% % %    HeightTolerance  =  2;
% % %    PositionTolerance  =  2 ;
% % %    
% % %    horizontalLinesDistanceTolerance = 20;
% % %    
% % %    %     HeightTolerance  =  4;
% % %    %     PositionTolerance  =  2 ;
% % %    % In case of curved / inclined captions
% % %    ForceCaptionsDimensionsFlag = 0;
% % %    ForceCaptionsStartPoint_X = 284 ;
% % %    ForceCaptionsEndPoint_X = 1166 ;
% % %    
% % %    ForceAllCaptionsDimensionsFlag = 1;
% % %    ForceCaptionsStartPoint_X = [40 40  40 40 40 ];
% % %    ForceCaptionsEndPoint_X = [1186 1186  1186 1186 1186] ;
% % %    
% % %    ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %    
% % %    MaxBoundryTolerance = 0;
% % %    ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %    % ForceFullCaptionAfterThisValue =  10  ;
% % %    
% % %    % Confidence for caption width low ex 3 for fast changes
% % %    % but greater for slow changes ex.5
% % %    ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %    
% % %    % In case no bottom line this is the new line distance from image end
% % %    distanceFromImageBottom = 15;
% % %    
% % %    % The flag can have 0 and 1 values
% % %    % 2 : small number of lines (used in case of mis - alignment issue)
% % %    % 3 : medium number of lines
% % %    getExtralinesFlag = 1;
% % %    % The flag can have -1 , 0 and 1 values
% % %    getExtraBottomlinesFlag = 1;
% % %    
% % %    % Lower Limit for distance between the Text line and bottom boundry
% % %    TextLineBottomBoundryLowerLimit = 4;
% % %    % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %    % 35 in case of ON TV news
% % %    % 25 Sky Ramadan
% % %    % 6 for english/latin text
% % %    TextLineBottomBoundryUpperLimit = 6;
%%% SKY EN Vert2 Nicolas %%%%%%%%%%%%%%%%%%%%   


%%% SKY EN Vert2 JOHNSON %%%%%%%%%%%%%%%%%%%%      
% % %    firstCaptionOrder = 1;
% % %    HeightTolerance  =  2;
% % %    PositionTolerance  =  2 ;
% % %    
% % %    horizontalLinesDistanceTolerance = 25;
% % %    
% % %    %     HeightTolerance  =  4;
% % %    %     PositionTolerance  =  2 ;
% % %    % In case of curved / inclined captions
% % %    ForceCaptionsDimensionsFlag = 0;
% % %    ForceCaptionsStartPoint_X = 284 ;
% % %    ForceCaptionsEndPoint_X = 1166 ;
% % %    
% % %    ForceAllCaptionsDimensionsFlag = 1;
% % %    ForceCaptionsStartPoint_X = [40 40  40 40 40 ];
% % %    ForceCaptionsEndPoint_X = [1186 1186  1186 1186 1186] ;
% % %    
% % %    ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %    
% % %    MaxBoundryTolerance = 0;
% % %    ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %    % ForceFullCaptionAfterThisValue =  10  ;
% % %    
% % %    % Confidence for caption width low ex 3 for fast changes
% % %    % but greater for slow changes ex.5
% % %    ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %    
% % %    % In case no bottom line this is the new line distance from image end
% % %    distanceFromImageBottom = 30;
% % %    
% % %    % The flag can have 0 and 1 values
% % %    % 2 : small number of lines (used in case of mis - alignment issue)
% % %    % 3 : medium number of lines
% % %    getExtralinesFlag = 1;
% % %    % The flag can have -1 , 0 and 1 values
% % %    getExtraBottomlinesFlag = 1;
% % %    
% % %    % Lower Limit for distance between the Text line and bottom boundry
% % %    TextLineBottomBoundryLowerLimit = 4;
% % %    % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %    % 35 in case of ON TV news
% % %    % 25 Sky Ramadan
% % %    % 6 for english/latin text
% % %    TextLineBottomBoundryUpperLimit = 6;
%%% SKY EN Vert2 JOHNSON %%%%%%%%%%%%%%%%%%%%   
   
   
%%% TRT EN Vert2 Kill of Khashiggy%%%%%%%%%%%%%%%%%%%%
% Make remove mod in hough transform function%%%%%%
% % %    firstCaptionOrder = 2;
% % %    HeightTolerance  =  4;
% % %    PositionTolerance  =  2 ;
% % %    
% % %    horizontalLinesDistanceTolerance = 4;
% % %    
% % %    %     HeightTolerance  =  4;
% % %    %     PositionTolerance  =  2 ;
% % %    % In case of curved / inclined captions
% % %    ForceCaptionsDimensionsFlag = 0;
% % %    ForceCaptionsStartPoint_X = 284 ;
% % %    ForceCaptionsEndPoint_X = 1166 ;
% % %    
% % %    ForceAllCaptionsDimensionsFlag = 1;
% % %    ForceCaptionsStartPoint_X = [283 283  112 112 112 108 108 108];
% % %    ForceCaptionsEndPoint_X = [1165 1165  1165 557 557 1165 1165 1165] ;
% % %    
% % %    
% % %    ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %    
% % %    MaxBoundryTolerance = 0;
% % %    ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % %    %     ForceFullCaptionAfterThisValue =  10  ;
% % %    
% % %    % Confidence for caption width low ex 3 for fast changes
% % %    % but greater for slow changes ex.5
% % %    ConfidenceThreshold = 5; % BBC 1 caption = 7
% % %    
% % %    % In case no bottom line this is the new line distance from image end
% % %    distanceFromImageBottom = 20;
% % %    
% % %    % The flag can have 0 and 1 values
% % %    % 2 : small number of lines (used in case of mis - alignment issue)
% % %    % 3 : medium number of lines
% % %    getExtralinesFlag = 2;
% % %    % The flag can have -1 , 0 and 1 values
% % %    getExtraBottomlinesFlag = -1;
% % %    
% % %    % Lower Limit for distance between the Text line and bottom boundry
% % %    TextLineBottomBoundryLowerLimit = 4;
% % %    % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %    % 35 in case of ON TV news
% % %    % 25 Sky Ramadan
% % %    % 6 for english/latin text
% % %    TextLineBottomBoundryUpperLimit = 6;
%%% TRT Vert2 Kill of Khashiggy%%%%%%%%%%%%%%%%%%%%    
    
% % % 	%BBC Yaman  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % %     firstCaptionOrder = 2;
% % %     HeightTolerance  =  -5;
% % %     PositionTolerance  =  2 ;
% % %     ForceCaptionsDimensionsFlag = 0;
% % %     ForceAllCaptionsDimensionsFlag = 1;
% % %     ForceCaptionsStartPoint_X = [  15 15 750  750 750  824 824  824 824 ];
% % %     ForceCaptionsEndPoint_X = [  791 791 1079 1079 1079 1079 1079 1079 1079] ;
% % % 
% % %   
% % %     ForceCaptionsWidth = ForceCaptionsEndPoint_X - ForceCaptionsStartPoint_X ;
% % %     horizontalLinesDistanceTolerance =10;
% % %     MaxBoundryTolerance = 0;
% % %     ForceFullCaptionAfterThisValue =  NumberOfFrames ;
% % % %     ForceFullCaptionAfterThisValue =  10  ;
% % %     
% % %     % Confidence for caption width low ex 3 for fast changes 
% % %     % but greater for slow changes ex.5
% % %     ConfidenceThreshold = 1; % BBC 1 caption = 7
% % %     
% % %     % In case no bottom line this is the new line distance from image end
% % %     distanceFromImageBottom = 5;
% % %     
% % %     % The flag can have 0 and 1 values
% % %     getExtralinesFlag = 1;
% % %     % The flag can have -1 , 0 and 1 values    
% % %     getExtraBottomlinesFlag = 1;
% % %     
% % %     % Lower Limit for distance between the Text line and bottom boundry
% % %     TextLineBottomBoundryLowerLimit = 4;
% % %     % Upper limit <<15>> in normal case 20 in some cases like RT news
% % %     % 35 in case of ON TV news
% % %     % 25 Sky Ramadan
% % %     TextLineBottomBoundryUpperLimit = 10;
% % % 	%BBC Yaman  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % For debugging purpose
    % % %         BlackWhiteFrame = insertShape(double(BlackWhiteFrame),'Rectangle',objectRegion,'Color','red');
    % % %         figure;imshow(BlackWhiteFrame);hold on
    % % %         title('Red box shows object region');
    
        

% Implements a new object region detection
%
% Inputs:
% CroppednewFrame  -  Current Frame
% CroppednextFrame  -  New Frame
% points  -  are found using points tracker
%
% Output:
% optimized object Region
function objectRegion  =  Update_ROI(  CroppednewFrame , CroppednextFrame, points )

    global InitialobjectRegion;
    minROIflag  =  0;
    maxROIflag  =  0;
    
    if isempty ( points.Location )
        
        objectRegion  =  InitialobjectRegion;
        
    else
        
        tracker  =  vision.PointTracker('MaxBidirectionalError',1);
        
        initialize( tracker ,  points.Location , CroppednewFrame );
        
        %should be the next frame
        [points, validity]  =  step(tracker , CroppednextFrame);
        
        for i  =  1 : length(points)
            if validity(i)  ==  1
                Row_min   =   points(i,1) ;
                %Col_min  =    points(i,2) ;
                minROIflag  =  1;
                break ;
            end
        end
        
        for i  =  0:length(points) - 1
            
            if validity(end - i)  ==  1
                Row_max  =   points(end - i,1) ;
                %Col_max  =   points(end - i,2) ;
                maxROIflag  =  1;
                break;
            end
        end
        
        %objectRegion  =  [ x , y , width , height ] ;
        if minROIflag  ==  1 && maxROIflag  ==  1
            Col_min  =    min(points(:,2)) ;
            Col_max  =    max(points(:,2)) ;
            objectRegion  =  [  Row_min , Col_min  , Row_max  -  Row_min , abs(Col_max - Col_min ) ];
        else
            objectRegion  =  InitialobjectRegion ;
        end
        
    end






% Implements a simple cubic - spline interpolation of a single image. This
% image is then deblurred using the same method as in the Fast and Robust
% method.
%
% Inputs:
% LR  -  A sequence of low resolution images
%
% Output:
% The estimated HR image
function HR  =  SplineSRInterp( LR  )

    maxIter  =  21;
    P  =  2;
    alpha  =  0.3;
    beta  =  0.0001;
    lambda  =  0.04;
    resFactor  =  1;
    psfKernelSize  =  2;
    psfSigma  =   2;
   
    LR  =  double(LR);

    % Initialize guess as interpolated version of LR
    [X,Y]  =  meshgrid(0:resFactor:(size(LR,2) - 1)*resFactor, 0:resFactor:(size(LR,1) - 1)*resFactor);
    [XI,YI]  =  meshgrid(resFactor + 1:(size(LR,2) - 2)*resFactor - 1, resFactor + 1:(size(LR,1) - 2)*resFactor - 1);
    
    Z = interp2(X, Y, squeeze(LR(:,:,1)), XI, YI, '*spline');
    
    % Deblur the HR image and regulate using bilatural filter
    
    
    HR  =  Z;
    iter  =  1;
    A  =  ones(size(HR));
    
    Hpsf  =  fspecial('gaussian', [psfKernelSize psfKernelSize], psfSigma);
    
    % Loop and improve HR in steepest descent direction
    while iter < maxIter
        
        % Compute gradient of the energy part of the cost function
        Gback  =  FastGradientBackProject(HR, Z, A, Hpsf);
        
        % Compute the gradient of the bilateral filter part of the cost function
        Greg  =  GradientRegulization(HR, P, alpha);
        
        % Perform a single SD step
        HR  =  HR  -  beta.*(Gback  +  lambda.* Greg);
        
        iter  =  iter + 1;
        
    end






% Implements the fast and robust super - resolution method. This funtion
% first compute an estimation of the blurred HR image, using the median and
% shift method. It then uses the bilateral filter as a regulating term
% for the deblurring and interpolation step.
%
% Inputs:
% LR  -  A sequence of low resolution images
%
% Outputs:
% The estimated HR image
function HR  =  FastRobustSR( LR  )

    maxIter  =  21;
    P  =  2;
    alpha  =  0.3;
    beta  =  0.0001;
    lambda  =  0.04;
    resFactor  =  1;
    psfKernelSize  =  2;
    psfSigma  =   2;
    
    % Round translation to nearest neighbor
    D_Registeration  =  RegisterImageSeq(LR) ;
    D_Rounded  =  round( D_Registeration .*resFactor);
    % Shift all images so D is bounded from 0 - resFactor
    Dr = floor( D_Rounded /resFactor);
    D  =  mod(D_Rounded,resFactor) + resFactor;
    
    % Compute initial estimate of blurred HR by the means of MedianAndShift
    [Z, A]  =  MedianAndShift(LR, D, [(size(LR,1) + 1)*resFactor - 1 (size(LR,2) + 1)*resFactor - 1], resFactor);
    
    % Deblur the HR image and regulate using bilatural filter
    
    % Loop and improve HR in steepest descent direction
    HR  =  Z;
    iter  =  1;    

    Hpsf  =  fspecial('gaussian', [psfKernelSize psfKernelSize], psfSigma);
    
    while iter < maxIter
        
        % Compute gradient of the energy part of the cost function
        Gback  =  FastGradientBackProject(HR, Z, A, Hpsf);
        
        % Compute the gradient of the bilateral filter part of the cost function
        Greg  =  GradientRegulization(HR, P, alpha);
        
        % Perform a single SD step
        HR  =  HR  -  beta.*(Gback  +  lambda.* Greg);
        
        iter  =  iter + 1;
        
    end



% Implements the robust super - resolution method. This function uses the
% steepest descent method to minimize the SR cost function which includes
% two terms. The "energy" term, which is the L1 norm of the residual error
% between the HR image and the LR image sequence. The "regularization" term
% which induces piecewise smoothness on the HR image using the bilateral
% filter.
%
% Inputs:
% LR  -  A sequence of low resolution images
% InitialHR  -  InitialHR HR
% Output:
% The estimated HR image
function HR  =  RobustSR( LR , InitialHR )

    % Loop and improve HR in steepest descent direction
    iter  =  1;
    
    maxIter  =  21;
    P  =  2;
    alpha  =  0.7;
    beta  =  0.1;
    lambda  =  0.04;
    resFactor  =  1;
    psfKernelSize  =  3;
    psfSigma  =   1;
    
    Hpsf  =  fspecial('gaussian', [psfKernelSize psfKernelSize], psfSigma);
    
    % Round translation to nearest neighbor
    D_Registeration  =  RegisterImageSeq(LR) ;
    D_Rounded  =  round( D_Registeration .*resFactor);
    % Shift all images so D is bounded from 0 - resFactor
    Dr = floor( D_Rounded /resFactor);
    D  =  mod(D_Rounded,resFactor) + resFactor;
    
    HR  =  InitialHR;
    
    while iter < maxIter
        
        % Compute gradient of the energy part of the cost function
        Gback  =  GradientBackProject(HR, LR, D, Hpsf, resFactor);
        
        % Compute the gradient of the bilateral filter part of the cost function
        Greg  =  GradientRegulization(HR, P, alpha);
        
        % Perform a single SD step
        HR  =  HR  -  beta.*(Gback  +  lambda.* Greg);
        
        iter  =  iter + 1;
        
    end





% Implements a simple cubic - spline interpolation of a single image. This
% image is then deblurred using the same method as in the Fast and Robust
% method.
%
% Inputs:
% LR  -  A sequence of low resolution images
% LR_Inverted  -  LR Inverted
% ChannelName  -  Channel Name
% ProgramName  -  Program Name
% Frame_ID  -  Frame ID
% typeOfSR  -  type Of SR
%
% Output:
% The estimated HR image
function [HR , HR_Inverted]   =  ApplySuperResolution( LR , LR_Inverted , ChannelName , ProgramName , Frame_ID , typeOfSR)


switch typeOfSR
    
    case 'SplineSRInterpolation'
        HR_SplineSRInterp  =  SplineSRInterp( LR );
        HR_SplineSRInterp_Inverted  =  SplineSRInterp( LR_Inverted );
        imwrite(HR_SplineSRInterp , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_HR_SplineSRInterpolation' , '.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );
        imwrite(HR_SplineSRInterp_Inverted , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_HR_SplineSRInterpolation_Inverted' , '.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );
        
        HR  =  HR_SplineSRInterp;
        HR_Inverted  =   HR_SplineSRInterp_Inverted;
        
    case 'FastRobustSR'
        HR_FastRobustSR =  FastRobustSR (LR );
        HR_FastRobustSR_Inverted =  FastRobustSR (LR_Inverted );        
        imwrite(HR_FastRobustSR , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_HR_FastRobustSR' , '.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );
        imwrite(HR_FastRobustSR_Inverted , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_HR_FastRobustSR_Inverted' , '.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );
        
        HR  =  HR_FastRobustSR;
        HR_Inverted  =   HR_FastRobustSR_Inverted;
        
    case 'RobustSR'
        HR_FastRobustSR =  FastRobustSR (LR );
        HR_FastRobustSR_Inverted =  FastRobustSR (LR_Inverted );        
        HR_RobustSR  =  RobustSR ( LR , HR_FastRobustSR);
        HR_RobustSR_Inverted  =  RobustSR ( LR_Inverted , HR_FastRobustSR_Inverted);        
        imwrite(HR_RobustSR , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_HR_RobustSR' , '.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );
        imwrite(HR_RobustSR_Inverted , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_HR_RobustSR_Inverted' , '.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );
        
        HR  =  HR_RobustSR;
        HR_Inverted  =   HR_RobustSR_Inverted;
        
    otherwise
        HR_SplineSRInterp  =  SplineSRInterp( LR );
        HR_SplineSRInterp_Inverted  =  SplineSRInterp( LR_Inverted );
        imwrite(HR_SplineSRInterp , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_HR_SplineSRInterpolation' , '.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );
        imwrite(HR_SplineSRInterp_Inverted , [ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_HR_SplineSRInterpolation_Inverted' , '.tiff']  , 'tiff' , 'Resolution' , [500 , 500] );
        
        HR  =  HR_SplineSRInterp;
        HR_Inverted  =   HR_SplineSRInterp_Inverted;
        
end



% Implements the results header
%
% Inputs:
% ChannelName  -  Channel Name
% ProgramName  -  Program Name
% typeOfSR  -  type Of SR
%
% Output:  - 

function header2word(ChannelName , ProgramName , typeOfSR , PartNum)

global word
global document
global selection

word  =  actxserver('Word.Application');      %start Word
% word.Visible  = 1;                          %make Word Visible
                      %for debugging

document = word.Documents.Add;                %create new Document
selection = word.Selection;                   %set Cursor
selection.Font.Name = 'Courier New';          %set Font
selection.Font.Size = 14;                     %set Size

selection.Pagesetup.RightMargin = 28.34646;   %set right Margin to 1cm
selection.Pagesetup.LeftMargin = 28.34646;    %set left Margin to 1cm
selection.Pagesetup.TopMargin = 28.34646;     %set top Margin to 1cm
selection.Pagesetup.BottomMargin = 28.34646;  %set bottom Margin to 1cm
                                            %1cm is circa 28.34646 points
                                            
selection.Paragraphs.LineUnitAfter = 0.01;    %sets the amount of spacing
                                            %between paragraphs(in gridlines)

selection.ParagraphFormat.Alignment  = 1;     %Center - aligned
selection.TypeText([ChannelName , ' ' , ProgramName] );
selection.TypeParagraph;                    %linebreak
selection.TypeParagraph;                    %linebreak
selection.ParagraphFormat.Alignment  = 0;     %Left - aligned

selection.TypeText(' This document is generated from Matlab for OCR purpose');
selection.TypeParagraph;                    %linebreak
selection.TypeParagraph;                    %linebreak
selection.TypeText([' Super Resolution is done using ' , typeOfSR ,' method']);
selection.TypeParagraph;                    %linebreak
selection.TypeParagraph;                    %linebreak
selection.TypeParagraph;                    %linebreak
selection.TypeParagraph;                    %linebreak

%save Document        
invoke(document,'SaveAs',[pwd , '/',ChannelName ,'_', ProgramName  ,'_', typeOfSR , PartNum ,'.doc'],1);




% Implements the images saving in word
%
% Inputs:
% ChannelName  -  Channel Name
% ProgramName  -  Program Name
% Frame_ID  -  Frame ID
% typeOfSR  -  type Of SR
%
% Output:  - 

function save2word(ChannelName , ProgramName , Frame_ID , typeOfSR, PartNum)

global word
global document
global selection

% Find end of document and make it the insertion point:
end_of_doc  =  get(word.activedocument.content,'end');
set( selection ,'Start',end_of_doc);
set( selection ,'End',end_of_doc);

selection.TypeText( [ 'Frame no. :' , num2str(Frame_ID + 1, '%.6d')]);      %write number
selection.TypeParagraph;                    %linebreak
% selection.MoveUp(5,1,1);                    %5 = row mode

selection.InlineShapes.AddPicture([pwd '/',ChannelName ,'_', ProgramName , '_',num2str(Frame_ID , '%.6d') ,'_HR_', typeOfSR,'.tiff'],0,1);
selection.TypeParagraph;                    %linebreak
%with this command we insert a picture 'picture.png' wich is in the same
%folder as our m - file
selection.MoveDown(5,1);
selection.InlineShapes.AddPicture([pwd '/',ChannelName ,'_', ProgramName , '_', num2str(Frame_ID , '%.6d')  ,'_HR_', typeOfSR,'_Inverted' , '.tiff'],0,1);
selection.TypeParagraph;                    %linebreak
selection.TypeParagraph;                    %linebreak
% selection.InsertNewPage;

%save Document        
invoke(document,'SaveAs',[pwd , '/',ChannelName ,'_', ProgramName  ,'_', typeOfSR , PartNum,'.doc'],1);




% Implements the results footer
%
% Inputs:
% ChannelName  -  Channel Name
% ProgramName  -  Program Name
% typeOfSR  -  type Of SR
% elapsedTime  -  Elapsed Time
%
% Output:  - 

function Footer2word( ChannelName , ProgramName, typeOfSR , elapsedTime, PartNum)

global word
global document
global selection

% Find end of document and make it the insertion point:
end_of_doc  =  get(word.activedocument.content,'end');
set( selection ,'Start',end_of_doc);
set( selection ,'End',end_of_doc);

selection.TypeParagraph;                    %linebreak
selection.TypeParagraph;                    %linebreak
selection.TypeParagraph;                    %linebreak

selection.TypeText([ 'Total Elapsed Time : ' , num2str(elapsedTime)]);   %write number
selection.TypeParagraph;                    %linebreak
selection.MoveUp(5,1,1);                    %5 = row mode

%save Document        
invoke(document,'SaveAs',[pwd , '/',ChannelName ,'_', ProgramName  ,'_', typeOfSR , PartNum ,'.doc'],1);
word.Quit();                                %close Word



function [I_SSD,I_NCC,Idata]=template_matching(T,I,IdataIn)
% TEMPLATE_MATCHING is a cpu efficient function which calculates matching
% score images between template and an (color) 2D or 3D image.
% It calculates:
% - The sum of squared difference (SSD Block Matching), robust template
%   matching.
% - The normalized cross correlation (NCC), independent of illumination,
%   only dependent on texture
% The user can combine the two images, to get template matching which
% works robust with his application.
% Both measures are implemented using FFT based correlation.
%
%   [I_SSD,I_NCC,Idata]=template_matching(T,I,Idata)
%
% inputs,
%   T : Image Template, can be grayscale or color 2D or 3D.
%   I : Color image, can be grayscale or color 2D or 3D.
%  (optional)
%   Idata : Storage of temporary variables from the image I, to allow
%           faster search for multiple templates in the same image.
%
% outputs,
%   I_SSD: The sum of squared difference 2D/3D image. The SSD sign is
%          reversed and normalized to range [0 1]
%   I_NCC: The normalized cross correlation 2D/3D image. The values
%          range between 0 and 1
%   Idata : Storage of temporary variables from the image I, to allow
%           faster search for multiple templates in the same image.
%
% Example 2D,
%   % Find maximum response
%    I = im2double(imread('lena.jpg'));
%   % Template of Eye Lena
%    T=I(124:140,124:140,:);
%   % Calculate SSD and NCC between Template and Image
%    [I_SSD,I_NCC]=template_matching(T,I);
%   % Find maximum correspondence in I_SDD image
%    [x,y]=find(I_SSD==max(I_SSD(:)));
%   % Show result
%    figure,
%    subplot(2,2,1), imshow(I); hold on; plot(y,x,'r*'); title('Result')
%    subplot(2,2,2), imshow(T); title('The eye template');
%    subplot(2,2,3), imshow(I_SSD); title('SSD Matching');
%    subplot(2,2,4), imshow(I_NCC); title('Normalized-CC');



if(nargin<3), IdataIn=[]; end

% Convert images to double
T=double(T); I=double(I);

% Grayscale image
[I_SSD,I_NCC,Idata]=template_matching_gray(T,I,IdataIn);


function [I_SSD,I_NCC,Idata]=template_matching_gray(T,I,IdataIn)
% Calculate correlation output size  = input size + padding template
T_size = size(T); I_size = size(I);
outsize = I_size + T_size-1;

% calculate correlation in frequency domain
if(length(T_size)==2)
    FT = fft2(rot90(T,2),outsize(1),outsize(2));
    if(isempty(IdataIn))
        Idata.FI = fft2(I,outsize(1),outsize(2));
    else
        Idata.FI=IdataIn.FI;
    end
    Icorr = real(ifft2(Idata.FI.* FT));
else
    FT = fftn(rot90_3D(T),outsize);
    FI = fftn(I,outsize);
    Icorr = real(ifftn(FI.* FT));
end

% Calculate Local Quadratic sum of Image and Template
if(isempty(IdataIn))
    Idata.LocalQSumI= local_sum(I.*I,T_size);
else
    Idata.LocalQSumI=IdataIn.LocalQSumI;
end

QSumT = sum(T(:).^2);

% SSD between template and image
I_SSD=Idata.LocalQSumI+QSumT-2*Icorr;

% Normalize to range 0..1
I_SSD=I_SSD-min(I_SSD(:));
I_SSD=1-(I_SSD./max(I_SSD(:)));

% Remove padding
I_SSD=unpadarray(I_SSD,size(I));

if (nargout>1)
    % Normalized cross correlation STD
    if(isempty(IdataIn))
        Idata.LocalSumI= local_sum(I,T_size);
    else
        Idata.LocalSumI=IdataIn.LocalSumI;
    end
    
    % Standard deviation
    if(isempty(IdataIn))
        Idata.stdI=sqrt(max(Idata.LocalQSumI-(Idata.LocalSumI.^2)/numel(T),0) );
    else
        Idata.stdI=IdataIn.stdI;
    end
    stdT=sqrt(numel(T)-1)*std(T(:));
    % Mean compensation
    meanIT=Idata.LocalSumI*sum(T(:))/numel(T);
    I_NCC= 0.5+(Icorr-meanIT)./ (2*stdT*max(Idata.stdI,stdT/1e5));
    
    % Remove padding
    I_NCC=unpadarray(I_NCC,size(I));
end



function T=rot90_3D(T)
    T=flipdim(flipdim(flipdim(T,1),2),3);

    
function B=unpadarray(A,Bsize)
    Bstart=ceil((size(A)-Bsize)/2)+1;
    Bend=Bstart+Bsize-1;
    if(ndims(A)==2)
        B=A(Bstart(1):Bend(1),Bstart(2):Bend(2));
    elseif(ndims(A)==3)
        B=A(Bstart(1):Bend(1),Bstart(2):Bend(2),Bstart(3):Bend(3));
    end

    
function local_sum_I= local_sum(I,T_size)
    % Add padding to the image
    B = padarray(I,T_size);

    % Calculate for each pixel the sum of the region around it,
    % with the region the size of the template.
    if(length(T_size)==2)
        % 2D localsum
        s = cumsum(B,1);
        c = s(1+T_size(1):end-1,:)-s(1:end-T_size(1)-1,:);
        s = cumsum(c,2);
        local_sum_I= s(:,1+T_size(2):end-1)-s(:,1:end-T_size(2)-1);
    else
        % 3D Localsum
        s = cumsum(B,1);
        c = s(1+T_size(1):end-1,:,:)-s(1:end-T_size(1)-1,:,:);
        s = cumsum(c,2);
        c = s(:,1+T_size(2):end-1,:)-s(:,1:end-T_size(2)-1,:);
        s = cumsum(c,3);
        local_sum_I  = s(:,:,1+T_size(3):end-1)-s(:,:,1:end-T_size(3)-1);
    end


function  getKeyCaption(ChannelName,ProgramName,typeOfSR,P1_FilesPath_Normal,YPred_Direction)
% -------------------------------------------------------------------------
% Function templateMatching: Template Matching using normxcorr2
% Inputs: 
%          NewsVideoP1
% Output: 
%          None
% -------------------------------------------------------------------------
global VideoFrameRate
global NewsDataP1_Key
global word_width 
global wordImage % for debugging
NewsDataP1_Key = fullfile(strcat(pwd,'\NewsDataP1_Key\'));
if ~exist(NewsDataP1_Key , 'dir')
    mkdir NewsDataP1_Key
end

cd(P1_FilesPath_Normal);
tiffFiles = dir(fullfile(pwd,'\*.tiff*'));
n = numel(tiffFiles);

% Extract between frames based on the start and end frames
Frame_ID = 0;
% Read first frame
RotatingBar = imread(tiffFiles(Frame_ID + 1).name);

[height, bar_width] = size(RotatingBar); 

% Crop bar and detect the word 's Region of interest (to be detected with edge detection technique)
% word_width=120;%Sky
% JumpFrames = 5 ;% VideoFrameRate; 
word_width = 220;
JumpFrames =  20; 

if YPred_Direction == 'Right'
    word_ROI=[0.5 0.5 word_width height];
else
    word_ROI=[bar_width-word_width-0.5 0.5 word_width height];
end

blankWordCount = 0;

% While there is a new frame capture it for processing
while Frame_ID + 1 < n
    
    % Initial value for write frame flag
    writeFrame_Flag=1;
    
    % update the frame ,bar and sub bar with the selected ROIs
    cd(P1_FilesPath_Normal);
    RotatingBar = imread(tiffFiles(Frame_ID+1).name);
    
    RotatingBarBinary = RotatingBar; %new
    
    if Frame_ID == 0
        

        wordImage = imcrop(RotatingBarBinary,word_ROI);
        
        RotatingBar2 = imread(tiffFiles(Frame_ID+1).name);
        RotatingBarBinary2 = RotatingBar2;
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary2 , YPred_Direction );

        if YPred_Direction == 'Right'
            RotatingBarBinary2(:,1:bar_width-numShiftedPixels) = RotatingBarBinary2(:,numShiftedPixels+1:bar_width);
            RotatingBarBinary2(:,bar_width-numShiftedPixels:bar_width) = RotatingBarBinary(:,bar_width-numShiftedPixels:bar_width);
        else
            RotatingBarBinary2(:,numShiftedPixels+1:bar_width) = RotatingBarBinary2(:,1:bar_width-numShiftedPixels);
            RotatingBarBinary2(:,1 : numShiftedPixels) = RotatingBarBinary(:,1 : numShiftedPixels);                        
        end
        
        
        RotatingBar3 = imread(tiffFiles(Frame_ID+2).name);
        RotatingBarBinary3 = (RotatingBar3);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary3 , YPred_Direction );
        
        if YPred_Direction == 'Right'
            RotatingBarBinary3(:,1:bar_width-numShiftedPixels) = RotatingBarBinary3(:,numShiftedPixels+1:bar_width);
            RotatingBarBinary3(:,bar_width-numShiftedPixels:bar_width) = RotatingBarBinary(:,bar_width-numShiftedPixels:bar_width);
        else
            RotatingBarBinary3(:,numShiftedPixels+1:bar_width) = RotatingBarBinary3(:,1:bar_width-numShiftedPixels);
            RotatingBarBinary3(:,1 : numShiftedPixels) = RotatingBarBinary(:,1 : numShiftedPixels);                        
        end

        
        RotatingBar4 = imread(tiffFiles(Frame_ID+3).name);
        RotatingBarBinary4 = (RotatingBar4);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary4 , YPred_Direction );
        
        if YPred_Direction == 'Right'
            RotatingBarBinary4(:,1:bar_width-numShiftedPixels) = RotatingBarBinary4(:,numShiftedPixels+1:bar_width);
            RotatingBarBinary4(:,bar_width-numShiftedPixels:bar_width) = RotatingBarBinary(:,bar_width-numShiftedPixels:bar_width);
        else
            RotatingBarBinary4(:,numShiftedPixels+1:bar_width) = RotatingBarBinary4(:,1:bar_width-numShiftedPixels);
            RotatingBarBinary4(:,1 : numShiftedPixels) = RotatingBarBinary(:,1 : numShiftedPixels);                        
        end
        
        RotatingBar5 = imread(tiffFiles(Frame_ID+4).name);
        RotatingBarBinary5 = (RotatingBar5);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary5 , YPred_Direction );
        
        
        if YPred_Direction == 'Right'
            RotatingBarBinary5(:,1:bar_width-numShiftedPixels) = RotatingBarBinary5(:,numShiftedPixels+1:bar_width);
            RotatingBarBinary5(:,bar_width-numShiftedPixels:bar_width) = RotatingBarBinary(:,bar_width-numShiftedPixels:bar_width);
        else
            RotatingBarBinary5(:,numShiftedPixels+1:bar_width) = RotatingBarBinary5(:,1:bar_width-numShiftedPixels);
            RotatingBarBinary5(:,1 : numShiftedPixels) = RotatingBarBinary(:,1 : numShiftedPixels);                        
        end

        cd(NewsDataP1_Key);
        
    
        %Create document to save results
        header2word(ChannelName , ProgramName , typeOfSR , '_Part1');
        setBeginEndOfNews( YPred_Direction , typeOfSR, P1_FilesPath_Normal, RotatingBarBinary , RotatingBarBinary2 , RotatingBarBinary3 , RotatingBarBinary4 , RotatingBarBinary5 ,ChannelName ,ProgramName,Frame_ID ,'first');

        Frame_ID = Frame_ID + JumpFrames;

        continue;
        
    end
   
    if Frame_ID + JumpFrames > n-4
         
        RotatingBar = imread(tiffFiles(n-4).name);
        RotatingBarBinary = RotatingBar;
        imwrite(RotatingBarBinary,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_Key.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                
        RotatingBar2 = imread(tiffFiles(n-3).name);

        RotatingBarBinary2 = RotatingBar2;
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary2 , YPred_Direction );
        
        if YPred_Direction == 'Right'
            RotatingBarBinary2(:,1:bar_width-numShiftedPixels) = RotatingBarBinary2(:,numShiftedPixels+1:bar_width);
            RotatingBarBinary2(:,bar_width-numShiftedPixels:bar_width) = RotatingBarBinary(:,bar_width-numShiftedPixels:bar_width);
        else
            RotatingBarBinary2(:,numShiftedPixels+1:bar_width) = RotatingBarBinary2(:,1:bar_width-numShiftedPixels);
            RotatingBarBinary2(:,1 : numShiftedPixels) = RotatingBarBinary(:,1 : numShiftedPixels);                        
        end
        
        
        RotatingBar3 = imread(tiffFiles(n-2).name);
        RotatingBarBinary3 = (RotatingBar3);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary3 , YPred_Direction );

        
        if YPred_Direction == 'Right'
            RotatingBarBinary3(:,1:bar_width-numShiftedPixels) = RotatingBarBinary3(:,numShiftedPixels+1:bar_width);
            RotatingBarBinary3(:,bar_width-numShiftedPixels:bar_width) = RotatingBarBinary(:,bar_width-numShiftedPixels:bar_width);
        else
            RotatingBarBinary3(:,numShiftedPixels+1:bar_width) = RotatingBarBinary3(:,1:bar_width-numShiftedPixels);
            RotatingBarBinary3(:,1 : numShiftedPixels) = RotatingBarBinary(:,1 : numShiftedPixels);                        
        end

        
        RotatingBar4 = imread(tiffFiles(n-1).name);
        RotatingBarBinary4 = (RotatingBar4);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary4 , YPred_Direction );
        
        
        if YPred_Direction == 'Right'
            RotatingBarBinary4(:,1:bar_width-numShiftedPixels) = RotatingBarBinary4(:,numShiftedPixels+1:bar_width);
            RotatingBarBinary4(:,bar_width-numShiftedPixels:bar_width) = RotatingBarBinary(:,bar_width-numShiftedPixels:bar_width);
        else
            RotatingBarBinary4(:,numShiftedPixels+1:bar_width) = RotatingBarBinary4(:,1:bar_width-numShiftedPixels);
            RotatingBarBinary4(:,1 : numShiftedPixels) = RotatingBarBinary(:,1 : numShiftedPixels);                        
        end
        
        RotatingBar5 = imread(tiffFiles(n).name);
        RotatingBarBinary5 = (RotatingBar5);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary5 , YPred_Direction );

        
        if YPred_Direction == 'Right'
            RotatingBarBinary5(:,1:bar_width-numShiftedPixels) = RotatingBarBinary5(:,numShiftedPixels+1:bar_width);
            RotatingBarBinary5(:,bar_width-numShiftedPixels:bar_width) = RotatingBarBinary(:,bar_width-numShiftedPixels:bar_width);
        else
            RotatingBarBinary5(:,numShiftedPixels+1:bar_width) = RotatingBarBinary5(:,1:bar_width-numShiftedPixels);
            RotatingBarBinary5(:,1 : numShiftedPixels) = RotatingBarBinary(:,1 : numShiftedPixels);                        
        end
       
        
        cd ..
        cd NewsDataP1_Key

        setBeginEndOfNews( YPred_Direction , typeOfSR, P1_FilesPath_Normal, RotatingBarBinary , RotatingBarBinary2 , RotatingBarBinary3 , RotatingBarBinary4 , RotatingBarBinary5 ,ChannelName ,ProgramName,Frame_ID ,'last');

        break;
    end
    
    wordImageTemp = imbinarize(wordImage);
    if all(all(wordImageTemp)) == 1
        wordImage(1,1)=0;  % Pre-Requiste : To avoid matlab error
% % %     elseif all(all(wordImage)) == 0
% % %         wordImage(1,1)=1;  % Pre-Requiste : To avoid matlab error
    end
    
    if YPred_Direction == 'Right'
        
        % Arabic
        for i = (bar_width - word_width ):-10:1
            window = RotatingBarBinary( : , i:(i + word_width));
            C2 = normxcorr2(wordImage(:,:),window(:,:));
            if max(abs(C2(:)))>= 0.87
                writeFrame_Flag=0;
                % disp('get next frame:word image found using brute force');
                break;
            end
        end
        
    else
        
        % English
        for i = 1:10:(bar_width - word_width)
            window = RotatingBarBinary( : , i:(i + word_width ));
            C2 = normxcorr2(wordImage(:,:),window(:,:));
            if max(abs(C2(:)))>= 0.87
                writeFrame_Flag=0;
                % disp('get next frame:word image found using brute force');
                break;
            end
        end
        
    end
    
     if writeFrame_Flag == 1

        imwrite(RotatingBarBinary,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_Key.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
        
        RotatingBar2 = imread(tiffFiles(Frame_ID+1).name);
        RotatingBarBinary2 = (RotatingBar2);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary2 , YPred_Direction );        
        
        if YPred_Direction == 'Right'
            RotatingBarBinary2(1:end-numShiftedPixels) = RotatingBarBinary2(numShiftedPixels+1:end);
            RotatingBarBinary2(end-numShiftedPixels:end) = RotatingBarBinary(end-numShiftedPixels:end);
        else
            RotatingBarBinary2(numShiftedPixels+1:end) = RotatingBarBinary2(1:end-numShiftedPixels);
            RotatingBarBinary2(1 : numShiftedPixels) = RotatingBarBinary(1 : numShiftedPixels);                        
        end
        
        RotatingBar3 = imread(tiffFiles(Frame_ID+1).name);
        RotatingBarBinary3 = (RotatingBar3);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary3 , YPred_Direction );
       
        
        if YPred_Direction == 'Right'
            RotatingBarBinary3(1:end-numShiftedPixels) = RotatingBarBinary3(numShiftedPixels+1:end);
            RotatingBarBinary3(end-numShiftedPixels:end) = RotatingBarBinary(end-numShiftedPixels:end);
        else
            RotatingBarBinary3(numShiftedPixels+1:end) = RotatingBarBinary3(1:end-numShiftedPixels);
            RotatingBarBinary3(1 : numShiftedPixels) = RotatingBarBinary(1 : numShiftedPixels);                        
        end
                 
        RotatingBar4 = imread(tiffFiles(Frame_ID+1).name);
        RotatingBarBinary4 = (RotatingBar4);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary4 , YPred_Direction );
        

        if YPred_Direction == 'Right'
            RotatingBarBinary4(1:end-numShiftedPixels) = RotatingBarBinary4(numShiftedPixels+1:end);
            RotatingBarBinary4(end-numShiftedPixels:end) = RotatingBarBinary(end-numShiftedPixels:end);
        else
            RotatingBarBinary4(numShiftedPixels+1:end) = RotatingBarBinary4(1:end-numShiftedPixels);
            RotatingBarBinary4(1 : numShiftedPixels) = RotatingBarBinary(1 : numShiftedPixels);                        
        end
 
        
        RotatingBar5 = imread(tiffFiles(Frame_ID+1).name);
        RotatingBarBinary5 = (RotatingBar5);
        numShiftedPixels = getRotatingShift(RotatingBarBinary, RotatingBarBinary5 , YPred_Direction );
        

        if YPred_Direction == 'Right'
            RotatingBarBinary5(1:end-numShiftedPixels) = RotatingBarBinary5(numShiftedPixels+1:end);
            RotatingBarBinary5(end-numShiftedPixels:end) = RotatingBarBinary(end-numShiftedPixels:end);
        else
            RotatingBarBinary5(numShiftedPixels+1:end) = RotatingBarBinary5(1:end-numShiftedPixels);
            RotatingBarBinary5(1 : numShiftedPixels) = RotatingBarBinary(1 : numShiftedPixels);                        
        end
        
        setBeginEndOfNews( YPred_Direction , typeOfSR , P1_FilesPath_Normal, RotatingBarBinary , RotatingBarBinary2 , RotatingBarBinary3 , RotatingBarBinary4 , RotatingBarBinary5 ,ChannelName ,ProgramName,Frame_ID ,'mid');
        
        wordImage = imcrop(RotatingBarBinary,word_ROI);
        try
            wordImageTemp = imbinarize(wordImageTemp);
            while all(all(wordImageTemp)) == 1 || all(all(~wordImageTemp)) == 1
                if  YPred_Direction == 'Right'
                    wordImage = imcrop(RotatingBarBinary,word_ROI + [50*blankWordCount 0.5 0 0]);
                else
                    wordImage = imcrop(RotatingBarBinary,word_ROI + [bar_width-word_width-50*blankWordCount 0.5 0 0]);
                end
                
                blankWordCount = blankWordCount + 1;
            end
            blankWordCount = 0;
        catch
            %Frame_ID = Frame_ID + VideoFrameRate * 2;
            % Frame_ID = Frame_ID + 10;
            Frame_ID = Frame_ID + 1;
            continue;
        end
      
     end
    
    
    if writeFrame_Flag == 0
        % determine  frame after 1 time to be captured
        Frame_ID = Frame_ID + 1;
    else

        % determine  frame after certain time to be captured
        Frame_ID = Frame_ID + JumpFrames;
    end
    
    
end

cd ..


function   setBeginEndOfNews( YPred_Direction , typeOfSR, P1_FilesPath_Normal, RotatingBarBinary , RotatingBarBinary2 , RotatingBarBinary3 , RotatingBarBinary4 , RotatingBarBinary5 ,ChannelName ,ProgramName,Frame_ID , order)

    global SeparatorPath
    global NewsDataP1_Key
    persistent mergedRotatingBarBinary
    persistent mergedRotatingBarBinary2
    persistent mergedRotatingBarBinary3
    persistent mergedRotatingBarBinary4
    persistent mergedRotatingBarBinary5
    
    
    global wordImage % for debugging
    
    
    %spaceSizeThreshold = 50;% Sky Ramadan
    spaceSizeThreshold = 70;
        
    fullnewsflag = 0;
    spaceFoundflag = 0;

    SeparatorFiles = dir(fullfile(SeparatorPath,'\*.tiff*'));
    numSeparator = numel(SeparatorFiles);

    RotatingBarBinaryTemp = imbinarize(RotatingBarBinary);
    [rows, columns] = size(RotatingBarBinaryTemp);
    numWhitePixels = sum(RotatingBarBinaryTemp(:));
    numBlackPixels = rows * columns - numWhitePixels;
    
    if numWhitePixels > numBlackPixels
        % Background is white.
        BlankColumns = find(all(RotatingBarBinaryTemp==1));
        BlankColumnsShifted = [ BlankColumns(2:end) 0 ];
        whitBackgroundFlag=1;
    else
        % Background is black.
        BlankColumns = find(all(RotatingBarBinaryTemp==0));
        BlankColumnsShifted = [ BlankColumns(2:end) 1 ];
        whitBackgroundFlag=0;
    end
    
    Diff = BlankColumnsShifted - BlankColumns;
    firstIdx = find(Diff == 1, 1, 'first');
    Diff(Diff ~= 1 ) = 0;
    Diff(1:firstIdx-1 ) = 5;
    lastIdx  = find(Diff == 0, 1, 'first');
    measurements = regionprops(logical(Diff), 'Area');
    output = max([measurements.Area]);
    
    while BlankColumns(lastIdx)-BlankColumns(firstIdx) < output
        Diff (firstIdx:lastIdx) = 5;
        firstIdx = find(Diff == 1, 1, 'first');
        lastIdx  = find(Diff == 0, 1, 'first');
        if lastIdx < firstIdx
            Diff (lastIdx:firstIdx-1) = 5;
        end
    end
    
    firstIdx = BlankColumns(firstIdx);
    lastIdx = BlankColumns(lastIdx);
    
    if lastIdx - firstIdx > spaceSizeThreshold
        
        if lastIdx <= column/2
            RotatingBarBinary2ndSpaceSearch = RotatingBarBinaryTemp(last+1:end);
        else
            RotatingBarBinary2ndSpaceSearch = RotatingBarBinaryTemp(1:first-1);
        end
        
        if whitBackgroundFlag == 1
            % Background is white.
            BlankColumns = find(all(RotatingBarBinary2ndSpaceSearch==1));
            BlankColumnsShifted = [ BlankColumns(2:end) 0 ];
            
        else
            % Background is black.
            BlankColumns = find(all(RotatingBarBinary2ndSpaceSearch==0));
            BlankColumnsShifted = [ BlankColumns(2:end) 1 ];
            
        end
        
        Diff2ndSpace = BlankColumnsShifted - BlankColumns;
        firstIdx2ndSpace = find(Diff2ndSpace == 1, 1, 'first');
        Diff2ndSpace(Diff2ndSpace ~= 1 ) = 0;
        Diff2ndSpace(1:firstIdx2ndSpace-1 ) = 5;
        lastIdx2ndSpace  = find(Diff2ndSpace == 0, 1, 'first');
        measurements = regionprops(logical(Diff2ndSpace), 'Area');
        output = max([measurements.Area]);
        
        while BlankColumns(lastIdx2ndSpace)-BlankColumns(firstIdx2ndSpace) < output
            Diff2ndSpace (firstIdx2ndSpace:lastIdx2ndSpace) = 5;
            firstIdx2ndSpace = find(Diff2ndSpace == 1, 1, 'first');
            lastIdx2ndSpace  = find(Diff2ndSpace == 0, 1, 'first');
            if lastIdx2ndSpace < firstIdx2ndSpace
                Diff2ndSpace (lastIdx2ndSpace:firstIdx2ndSpace - 1) = 5;
            end
        end
        
        firstIdx2ndSpace = BlankColumns(firstIdx2ndSpace);
        lastIdx2ndSpace = BlankColumns(lastIdx2ndSpace);
        
        flag2ndSpace = 0;
        if lastIdx2ndSpace - firstIdx2ndSpace > spaceSizeThreshold
            flag2ndSpace = 1;
            if firstIdx < firstIdx2ndSpace
                startpt = lastIdx+1;
                endpt = firstIdx2ndSpace-1;
                % Correction for lastIdx
                lastIdx = lastIdx2ndSpace;
            else
                startpt = lastIdx2ndSpace+1;
                endpt = firstIdx-1; 
                % Correction for firstIdx
                firstIdx = firstIdx2ndSpace;
            end
        end

        if YPred_Direction == 'Right'
            % Arabic
            
            beforeBlankPart = RotatingBarBinary (: , lastIdx-10:end);
            afterBlankPart = RotatingBarBinary (: , 1:firstIdx+10 );
            
            beforeBlankPart2 = RotatingBarBinary2 (: , lastIdx-10:end);
            afterBlankPart2 = RotatingBarBinary2 (: , 1:firstIdx+10);
            
            beforeBlankPart3 = RotatingBarBinary3 (: , lastIdx-10:end);
            afterBlankPart3 = RotatingBarBinary3 (: , 1:firstIdx+10);
            
            beforeBlankPart4 = RotatingBarBinary4 (: , lastIdx-10:end);
            afterBlankPart4 = RotatingBarBinary4 (: , 1:firstIdx+10);
            
            beforeBlankPart5 = RotatingBarBinary5 (: , lastIdx-10:end);
            afterBlankPart5 = RotatingBarBinary5 (: , 1:firstIdx+10);
            
        else
            % English
            beforeBlankPart = RotatingBarBinary (: , 1:firstIdx+10);
            afterBlankPart = RotatingBarBinary (: , lastIdx-10:end);
            
            beforeBlankPart2 = RotatingBarBinary2 (: , 1:firstIdx+10);
            afterBlankPart2 = RotatingBarBinary2 (: , lastIdx-10:end);
            
            beforeBlankPart3 = RotatingBarBinary3 (: , 1:firstIdx+10);
            afterBlankPart3 = RotatingBarBinary3 (: , lastIdx-10:end);
            
            beforeBlankPart4 = RotatingBarBinary4 (: , 1:firstIdx+10);
            afterBlankPart4 = RotatingBarBinary4 (: , lastIdx-10:end);
            
            beforeBlankPart5 = RotatingBarBinary5 (: , 1:firstIdx+10);
            afterBlankPart5 = RotatingBarBinary5 (: , lastIdx-10:end);
        end
        
        if flag2ndSpace == 1
            fullnews = RotatingBarBinary   (: , startpt : endpt);
            fullnews2 = RotatingBarBinary2 (: , startpt : endpt);
            fullnews3 = RotatingBarBinary3 (: , startpt : endpt);
            fullnews4 = RotatingBarBinary4 (: , startpt : endpt);
            fullnews5 = RotatingBarBinary5 (: , startpt : endpt);
            
            cd (NewsDataP1_Key);
            
            % Using Otsu method to get A Threshold Selection from Gray-Level Histograms
            % Convert the grayscale image  to a binary image. The output image BW replaces all pixels in the input image with luminance greater than level with the value 1 (white) and replaces all other pixels with the value 0 (black)
            fullnews = imbinarize(fullnews);
            fullnews2 = imbinarize(fullnews2);
            fullnews3 = imbinarize(fullnews3);
            fullnews4 = imbinarize(fullnews4);
            fullnews5 = imbinarize(fullnews5);
            
            % Write the previous number of frame in order not to
            % overwrite files
            imwrite(fullnews,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_MID_FULL_News.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
            imwrite(~fullnews,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_MID_FULL_News_Inverted.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
            
            clearvars gatheredForSR gatheredForSR_inverted
            gatheredForSR(:,:,1) = fullnews;
            gatheredForSR(:,:,2) = fullnews2;
            gatheredForSR(:,:,3) = fullnews3;
            gatheredForSR(:,:,4) = fullnews4;
            gatheredForSR(:,:,5) = fullnews5;
            
            gatheredForSR_inverted(:,:,1) = ~fullnews;
            gatheredForSR_inverted(:,:,2) = ~fullnews2;
            gatheredForSR_inverted(:,:,3) = ~fullnews3;
            gatheredForSR_inverted(:,:,4) = ~fullnews4;
            gatheredForSR_inverted(:,:,5) = ~fullnews5;
            
            save (strcat(ChannelName,'_',ProgramName,'_',num2str(Frame_ID)) ,  'gatheredForSR' );
            
            save (strcat(ChannelName,'_',ProgramName,'_',num2str(Frame_ID),'_Inverted') ,  'gatheredForSR_inverted');
            
            % Apply Super Resolution ( can remove output parameters )
            [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , Frame_ID , typeOfSR);
            
            imwrite(HR,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_MID_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
            
            imwrite(HR_Inverted,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_MID_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
            
            % Save image(s) to word
            save2word ( ChannelName , ProgramName , Frame_ID , typeOfSR , '_Part1');
            
            clearvars gatheredForSR gatheredForSR_inverted
            
            cd ..
            cd NewsDataP1_Normal
            
        end
        
        spaceFoundflag = 1;
        
    end
    
    
    for i = 1 : numSeparator
        
        cd(SeparatorPath);
        
        thisSeparator = imread(SeparatorFiles(i).name);
        thisSeparator = thisSeparator(:,:,1,1);
        [ ~ , wSeparator] = size(thisSeparator);
        
        % Detect Feature Points
        separatorPoints = detectSURFFeatures(thisSeparator , 'MetricThreshold' , 500);
        
        RotatingBarBinaryPoints = detectSURFFeatures(RotatingBarBinary);
        
        % Extract Feature Descriptors
        [SeparatorFeatures, ~] = extractFeatures(thisSeparator, separatorPoints);
        [RotatingBarBinaryFeatures, RotatingBarBinaryPoints] = extractFeatures(RotatingBarBinary, RotatingBarBinaryPoints);

        
        % Find Putative Point Matches
        separatorPairs = matchFeatures(SeparatorFeatures, RotatingBarBinaryFeatures);
        
        % Locate the Object in the Scene Using Putative Matches
        matchedSeparatorPoints = separatorPoints(separatorPairs(:, 1), :);
        matchedRotatingBarBinaryPoints = RotatingBarBinaryPoints(separatorPairs(:, 2), :);
       
        
        if ~isempty(matchedRotatingBarBinaryPoints)
            
            % Avoid warning
            matchedRotatingBarBinaryPoints.Location(1)=floor( matchedRotatingBarBinaryPoints.Location(1));
            matchedSeparatorPoints.Location(1) = floor(matchedSeparatorPoints.Location(1));
            
            RotatingBarBinaryExtended = RotatingBarBinary(:,(matchedRotatingBarBinaryPoints.Location(1)+wSeparator):end);
            RotatingBarBinaryExtended2 = RotatingBarBinary2(:,(matchedRotatingBarBinaryPoints.Location(1)+wSeparator):end);
            RotatingBarBinaryExtended3 = RotatingBarBinary3(:,(matchedRotatingBarBinaryPoints.Location(1)+wSeparator):end);
            RotatingBarBinaryExtended4 = RotatingBarBinary4(:,(matchedRotatingBarBinaryPoints.Location(1)+wSeparator):end);
            RotatingBarBinaryExtended5 = RotatingBarBinary5(:,(matchedRotatingBarBinaryPoints.Location(1)+wSeparator):end);
            
            RotatingBarBinaryAfterSeparatorPartPoints = detectSURFFeatures(RotatingBarBinaryExtended);
            
            % Extract Feature Descriptors
            [RotatingBarBinaryAfterSeparatorPartFeatures, RotatingBarBinaryAfterSeparatorPartPoints] = extractFeatures(RotatingBarBinaryExtended, RotatingBarBinaryAfterSeparatorPartPoints);
            
            
            % Find Putative Point Matches
            separatorPairsAfterSeparatorPart = matchFeatures(SeparatorFeatures, RotatingBarBinaryAfterSeparatorPartFeatures);
            
            % Locate the Object in the Scene Using Putative Matches
            matched2ndSeparatorPoints = separatorPoints(separatorPairsAfterSeparatorPart(:, 1), :);
            matchedRotatingBarBinaryPoints2nd = RotatingBarBinaryAfterSeparatorPartPoints(separatorPairsAfterSeparatorPart(:, 2), :);

            flag2ndSeparator = 0;
            if ~isempty(matchedRotatingBarBinaryPoints2nd)
                flag2ndSeparator = 1;
                % Avoid warning
                matchedRotatingBarBinaryPoints2nd.Location(1)=floor( matchedRotatingBarBinaryPoints2nd.Location(1));
                matched2ndSeparatorPoints.Location(1) = floor(matched2ndSeparatorPoints.Location(1));
            end
            
            if YPred_Direction == 'Right'
                % Arabic
                if spaceFoundflag == 1
                    
                    if flag2ndSeparator == 0 && matchedRotatingBarBinaryPoints.Location(1) > firstIdx && matchedRotatingBarBinaryPoints.Location(1) > lastIdx
                        
                        beforeSepartorPart = RotatingBarBinary (: , (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1)) ):end);
                        afterSepartorPart = afterBlankPart;
                        
                        beforeSepartorPart2 = RotatingBarBinary2 (: , (matchedRotatingBarBinaryPoints.Location(1) +   (wSeparator-matchedSeparatorPoints.Location(1))  ):end);
                        afterSepartorPart2 = afterBlankPart2;
                        
                        beforeSepartorPart3 = RotatingBarBinary3 (: , (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1))   ):end);
                        afterSepartorPart3 = afterBlankPart3;
                        
                        beforeSepartorPart4 = RotatingBarBinary4 (: , (matchedRotatingBarBinaryPoints.Location(1) +   (wSeparator-matchedSeparatorPoints.Location(1))   ):end);
                        afterSepartorPart4 = afterBlankPart4;
                        
                        beforeSepartorPart5 = RotatingBarBinary5 (: , (matchedRotatingBarBinaryPoints.Location(1) +    (wSeparator-matchedSeparatorPoints.Location(1))  ):end);
                        afterSepartorPart5 = afterBlankPart5;
                        
                    elseif flag2ndSeparator == 0 &&  matchedRotatingBarBinaryPoints.Location(1) < firstIdx && matchedRotatingBarBinaryPoints.Location(1) < lastIdx

                        beforeSepartorPart = beforeBlankPart;
                        afterSepartorPart = RotatingBarBinary (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        
                        beforeSepartorPart2 = beforeBlankPart2;
                        afterSepartorPart2 = RotatingBarBinary2 (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        
                        beforeSepartorPart3 = beforeBlankPart3;
                        afterSepartorPart3 = RotatingBarBinary3 (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        
                        beforeSepartorPart4 = beforeBlankPart4;
                        afterSepartorPart4 = RotatingBarBinary4 (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        
                        beforeSepartorPart5 = beforeBlankPart5;
                        afterSepartorPart5 = RotatingBarBinary5 (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        
                    end
                    
                else
                    
                    if flag2ndSeparator == 0
                        
                        beforeSepartorPart = RotatingBarBinary (: , (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1)) ):end);
                        beforeSepartorPart2 = RotatingBarBinary2 (: , (matchedRotatingBarBinaryPoints.Location(1) +   (wSeparator-matchedSeparatorPoints.Location(1))  ):end);
                        beforeSepartorPart3 = RotatingBarBinary3 (: , (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1))   ):end);
                        beforeSepartorPart4 = RotatingBarBinary4 (: , (matchedRotatingBarBinaryPoints.Location(1) +   (wSeparator-matchedSeparatorPoints.Location(1))   ):end);
                        beforeSepartorPart5 = RotatingBarBinary5 (: , (matchedRotatingBarBinaryPoints.Location(1) +    (wSeparator-matchedSeparatorPoints.Location(1))  ):end);
                        
                    else
                        
                        beforeSepartorPart =   RotatingBarBinaryExtended (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +  (wSeparator-matched2ndSeparatorPoints.Location(1)) ):end);
                        beforeSepartorPart2 = RotatingBarBinaryExtended2 (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +   (wSeparator-matched2ndSeparatorPoints.Location(1))  ):end);
                        beforeSepartorPart3 = RotatingBarBinaryExtended3 (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +  (wSeparator-matched2ndSeparatorPoints.Location(1))   ):end);
                        beforeSepartorPart4 = RotatingBarBinaryExtended4 (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +   (wSeparator-matched2ndSeparatorPoints.Location(1))   ):end);
                        beforeSepartorPart5 = RotatingBarBinaryExtended5 (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +    (wSeparator-matched2ndSeparatorPoints.Location(1))  ):end);
                        
                    end
                    
                    afterSepartorPart = RotatingBarBinary   (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1))  ));
                    
                    afterSepartorPart2 = RotatingBarBinary2 (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1))  ));
                    
                    afterSepartorPart3 = RotatingBarBinary3 (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1))  ));
                    
                    afterSepartorPart4 = RotatingBarBinary4 (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1))  ));
                    
                    afterSepartorPart5 = RotatingBarBinary5 (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)) ));

                end
            else
                % English
                if spaceFoundflag == 1
                    if flag2ndSeparator == 0 &&  matchedRotatingBarBinaryPoints.Location(1) > firstIdx && matchedRotatingBarBinaryPoints.Location(1) > lastIdx
                        
                        beforeSepartorPart = beforeBlankPart;
                        afterSepartorPart = RotatingBarBinary (: , (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1)) ):end);
                        
                        beforeSepartorPart2 = beforeBlankPart2;
                        afterSepartorPart2 = RotatingBarBinary2 (: , (matchedRotatingBarBinaryPoints.Location(1) +   (wSeparator-matchedSeparatorPoints.Location(1))  ):end);
                        
                        beforeSepartorPart3 = beforeBlankPart3;
                        afterSepartorPart3 = RotatingBarBinary3 (: , (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1))   ):end);
                        
                        beforeSepartorPart4 = beforeBlankPart4;
                        afterSepartorPart4 = RotatingBarBinary4 (: , (matchedRotatingBarBinaryPoints.Location(1) +   (wSeparator-matchedSeparatorPoints.Location(1))   ):end);
                        
                        beforeSepartorPart5 = beforeBlankPart5;
                        afterSepartorPart5 = RotatingBarBinary5 (: , (matchedRotatingBarBinaryPoints.Location(1) +    (wSeparator-matchedSeparatorPoints.Location(1))  ):end);
                        
                    elseif flag2ndSeparator == 0 &&  matchedRotatingBarBinaryPoints.Location(1) < firstIdx && matchedRotatingBarBinaryPoints.Location(1) < lastIdx
                        
                        beforeSepartorPart = RotatingBarBinary (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        afterSepartorPart = beforeBlankPart;
                        
                        beforeSepartorPart2 = RotatingBarBinary2 (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        afterSepartorPart2 = beforeBlankPart2;
                        
                        beforeSepartorPart3 = RotatingBarBinary3 (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        afterSepartorPart3 = beforeBlankPart3;
                        
                        beforeSepartorPart4 = RotatingBarBinary4 (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        afterSepartorPart4 = beforeBlankPart4;
                        
                        beforeSepartorPart5 = RotatingBarBinary5 (: , 1:  (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)))  );
                        afterSepartorPart5 = beforeBlankPart5;
                        
                    end
                    
                else
                    
                    beforeSepartorPart = RotatingBarBinary (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1))  ));
                    
                    beforeSepartorPart2 = RotatingBarBinary2 (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1))  ));
                    
                    beforeSepartorPart3 = RotatingBarBinary3 (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1))  ));
                    
                    beforeSepartorPart4 = RotatingBarBinary4 (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1))  ));
                    
                    beforeSepartorPart5 = RotatingBarBinary5 (: , 1 : (matchedRotatingBarBinaryPoints.Location(1) -  (matchedSeparatorPoints.Location(1)) ));

                    if flag2ndSeparator == 0
                        
                        afterSepartorPart =   RotatingBarBinary (: , (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1)) ):end);
                        afterSepartorPart2 = RotatingBarBinary2 (: , (matchedRotatingBarBinaryPoints.Location(1) +   (wSeparator-matchedSeparatorPoints.Location(1))  ):end);
                        afterSepartorPart3 = RotatingBarBinary3 (: , (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1))   ):end);
                        afterSepartorPart4 = RotatingBarBinary4 (: , (matchedRotatingBarBinaryPoints.Location(1) +   (wSeparator-matchedSeparatorPoints.Location(1))   ):end);
                        afterSepartorPart5 = RotatingBarBinary5 (: , (matchedRotatingBarBinaryPoints.Location(1) +    (wSeparator-matchedSeparatorPoints.Location(1))  ):end);
              
                    else
                        
                        afterSepartorPart =   RotatingBarBinaryExtended (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +  (wSeparator-matched2ndSeparatorPoints.Location(1)) ):end);
                        afterSepartorPart2 = RotatingBarBinaryExtended2 (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +   (wSeparator-matched2ndSeparatorPoints.Location(1))  ):end);
                        afterSepartorPart3 = RotatingBarBinaryExtended3 (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +  (wSeparator-matched2ndSeparatorPoints.Location(1))   ):end);
                        afterSepartorPart4 = RotatingBarBinaryExtended4 (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +   (wSeparator-matched2ndSeparatorPoints.Location(1))   ):end);
                        afterSepartorPart5 = RotatingBarBinaryExtended5 (: , (matchedRotatingBarBinaryPoints2nd.Location(1) +    (wSeparator-matched2ndSeparatorPoints.Location(1))  ):end);
                   
                    end
                    
                end
            end
            
            
            if flag2ndSeparator ==1

                startpt2ndSep =  (matchedRotatingBarBinaryPoints.Location(1) +  (wSeparator-matchedSeparatorPoints.Location(1)) );
                
                columnsExt = size(RotatingBarBinaryExtended,2);
                diffColPixels = columns - columnsExt;
                endpt2ndSep = (matchedRotatingBarBinaryPoints2nd.Location(1) -matched2ndSeparatorPoints.Location(1) )+ diffColPixels;                
                
                fullnews = RotatingBarBinary   (: , startpt2ndSep : endpt2ndSep);
                fullnews2 = RotatingBarBinary2 (: , startpt2ndSep : endpt2ndSep);
                fullnews3 = RotatingBarBinary3 (: , startpt2ndSep : endpt2ndSep);
                fullnews4 = RotatingBarBinary4 (: , startpt2ndSep : endpt2ndSep);
                fullnews5 = RotatingBarBinary5 (: , startpt2ndSep : endpt2ndSep);
                
                cd (NewsDataP1_Key);
                
                % Using Otsu method to get A Threshold Selection from Gray-Level Histograms
                % Convert the grayscale image  to a binary image. The output image BW replaces all pixels in the input image with luminance greater than level with the value 1 (white) and replaces all other pixels with the value 0 (black)
                fullnews = imbinarize(fullnews);
                fullnews2 = imbinarize(fullnews2);
                fullnews3 = imbinarize(fullnews3);
                fullnews4 = imbinarize(fullnews4);
                fullnews5 = imbinarize(fullnews5);
                

                imwrite(fullnews,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_FULL_MID_News.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                imwrite(~fullnews,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_FULL_MID_News_Inverted.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                
                clearvars gatheredForSR gatheredForSR_inverted
                gatheredForSR(:,:,1) = fullnews;
                gatheredForSR(:,:,2) = fullnews2;
                gatheredForSR(:,:,3) = fullnews3;
                gatheredForSR(:,:,4) = fullnews4;
                gatheredForSR(:,:,5) = fullnews5;
                
                gatheredForSR_inverted(:,:,1) = ~fullnews;
                gatheredForSR_inverted(:,:,2) = ~fullnews2;
                gatheredForSR_inverted(:,:,3) = ~fullnews3;
                gatheredForSR_inverted(:,:,4) = ~fullnews4;
                gatheredForSR_inverted(:,:,5) = ~fullnews5;
                
                save (strcat(ChannelName,'_',ProgramName,'_',num2str(Frame_ID),'_MID') ,  'gatheredForSR' );
                
                save (strcat(ChannelName,'_',ProgramName,'_',num2str(Frame_ID),'_MID_Inverted') ,  'gatheredForSR_inverted');
                
                % Apply Super Resolution ( can remove output parameters )
                [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , Frame_ID , typeOfSR);
                
                imwrite(HR,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_MID_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                
                imwrite(HR_Inverted,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_MID_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
                
                % Save image(s) to word
                save2word ( ChannelName , ProgramName , Frame_ID , typeOfSR , '_Part1');
                
                clearvars gatheredForSR gatheredForSR_inverted
                
                cd ..
                cd NewsDataP1_Normal
            end
            
            fullnewsflag = 1;
            
            break;
            
        elseif spaceFoundflag == 1
            % Only space is found and considered as separator
            
            beforeSepartorPart = beforeBlankPart;
            afterSepartorPart =  afterBlankPart;
            
            beforeSepartorPart2 = beforeBlankPart;
            afterSepartorPart2 =  afterBlankPart;
            
            beforeSepartorPart3 = beforeBlankPart;
            afterSepartorPart3 =  afterBlankPart;
            
            beforeSepartorPart4 = beforeBlankPart;
            afterSepartorPart4 =  afterBlankPart;
            
            beforeSepartorPart5 = beforeBlankPart;
            afterSepartorPart5 =  afterBlankPart;
            
            fullnewsflag = 1;
            
        end
        
        cd(P1_FilesPath_Normal);
        
    end
    
    if fullnewsflag == 0
        
        if YPred_Direction == 'Right'
            % Arabic
            tiffFiles = dir(fullfile(P1_FilesPath_Normal,'\*.tiff*'));
            RotatingBar2 = imread(tiffFiles(Frame_ID+1).name);
            RotatingBarBinary2 = imbinarize(RotatingBar2);
            
            
            RotatingBar3 = imread(tiffFiles(Frame_ID+2).name);
            RotatingBarBinary3 = imbinarize(RotatingBar3);
            
            RotatingBar4 = imread(tiffFiles(Frame_ID+3).name);
            RotatingBarBinary4 = imbinarize(RotatingBar4);
            
            RotatingBar5 = imread(tiffFiles(Frame_ID+4).name);
            RotatingBarBinary5 = imbinarize(RotatingBar5);
            
            mergedRotatingBarBinary = cat(2,RotatingBarBinary,mergedRotatingBarBinary);
            mergedRotatingBarBinary = imbinarize(mergedRotatingBarBinary);
            mergedRotatingBarBinary2 = cat(2,RotatingBarBinary2,mergedRotatingBarBinary2);
            mergedRotatingBarBinary3 = cat(2,RotatingBarBinary3,mergedRotatingBarBinary3);
            mergedRotatingBarBinary4 = cat(2,RotatingBarBinary4,mergedRotatingBarBinary4);
            mergedRotatingBarBinary5 = cat(2,RotatingBarBinary5,mergedRotatingBarBinary5);
            
        else
            % English
            
            RotatingBar2 = imread(tiffFiles(Frame_ID+1).name);
            RotatingBarBinary2 = imbinarize(RotatingBar2);
            
            RotatingBar3 = imread(tiffFiles(Frame_ID+2).name);
            RotatingBarBinary3 = imbinarize(RotatingBar3);
            
            RotatingBar4 = imread(tiffFiles(Frame_ID+3).name);
            RotatingBarBinary4 = imbinarize(RotatingBar4);
            
            RotatingBar5 = imread(tiffFiles(Frame_ID+4).name);
            RotatingBarBinary5 = imbinarize(RotatingBar5);
            
            mergedRotatingBarBinary = cat(2,mergedRotatingBarBinary,RotatingBarBinary);
            mergedRotatingBarBinary = imbinarize(mergedRotatingBarBinary);
            mergedRotatingBarBinary2 = cat(2,mergedRotatingBarBinary2,RotatingBarBinary2);
            mergedRotatingBarBinary3 = cat(2,mergedRotatingBarBinary3,RotatingBarBinary3);
            mergedRotatingBarBinary4 = cat(2,mergedRotatingBarBinary4,RotatingBarBinary4);
            mergedRotatingBarBinary5 = cat(2,mergedRotatingBarBinary5,RotatingBarBinary5);
            
        end
        
        clearvars gatheredForSR gatheredForSR_inverted
        gatheredForSR(:,:,1) = mergedRotatingBarBinary;
        gatheredForSR(:,:,2) = mergedRotatingBarBinary2;
        gatheredForSR(:,:,3) = mergedRotatingBarBinary3;
        gatheredForSR(:,:,4) = mergedRotatingBarBinary4;
        gatheredForSR(:,:,5) = mergedRotatingBarBinary5;
        
        gatheredForSR_inverted(:,:,1) = ~mergedRotatingBarBinary;
        gatheredForSR_inverted(:,:,2) = ~mergedRotatingBarBinary2;
        gatheredForSR_inverted(:,:,3) = ~mergedRotatingBarBinary3;
        gatheredForSR_inverted(:,:,4) = ~mergedRotatingBarBinary4;
        gatheredForSR_inverted(:,:,5) = ~mergedRotatingBarBinary5;
        
        cd ..
        cd NewsDataP1_Key
        save (strcat(ChannelName,'_',ProgramName,'_',num2str(Frame_ID)) ,  'gatheredForSR' );
        
        save (strcat(ChannelName,'_',ProgramName,'_',num2str(Frame_ID),'_Inverted') ,  'gatheredForSR_inverted');
        
        % Apply Super Resolution ( can remove output parameters )
        [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , Frame_ID , typeOfSR);
        
        imwrite(HR,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
        
        imwrite(HR_Inverted,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
        
        % Save image(s) to word
        save2word ( ChannelName , ProgramName , Frame_ID , typeOfSR , '');
        
        clearvars gatheredForSR gatheredForSR_inverted
        cd ..
        cd NewsDataP1_Normal
        
    else
        numShiftedPixels = getShiftbet2Images(beforeSepartorPart, mergedRotatingBarBinary);
        
        if YPred_Direction == 'Right'
            % Arabic
            
            if numShiftedPixels ~= -1
                
                if strcmp(order , 'mid') == 1
                    fullnews = cat(2,beforeSepartorPart,mergedRotatingBarBinary(:,numShiftedPixels:end));
                    fullnews2 = cat(2,beforeSepartorPart2,mergedRotatingBarBinary2(:,numShiftedPixels:end));
                    fullnews3 = cat(2,beforeSepartorPart3,mergedRotatingBarBinary3(:,numShiftedPixels:end));
                    fullnews4 = cat(2,beforeSepartorPart4,mergedRotatingBarBinary4(:,numShiftedPixels:end));
                    fullnews5 = cat(2,beforeSepartorPart5,mergedRotatingBarBinary5(:,numShiftedPixels:end));
                elseif  strcmp( order , 'first') == 1
                    fullnews =  beforeSepartorPart;
                    fullnews2 = beforeSepartorPart2;
                    fullnews3 = beforeSepartorPart3;
                    fullnews4 = beforeSepartorPart4;
                    fullnews5 = beforeSepartorPart5;
                else
                    % Last
                    fullnews =   afterSepartorPart;
                    fullnews2 =  afterSepartorPart2;
                    fullnews3 =  afterSepartorPart3;
                    fullnews4 =  afterSepartorPart4;
                    fullnews5 =  afterSepartorPart5;
                end
            end
            
            mergedRotatingBarBinary = afterSepartorPart;
            mergedRotatingBarBinary2 = afterSepartorPart2;
            mergedRotatingBarBinary3 = afterSepartorPart3;
            mergedRotatingBarBinary4 = afterSepartorPart4;
            mergedRotatingBarBinary5 = afterSepartorPart5;
            
        else
            % English
            
            if numShiftedPixels ~= -1
                
                if strcmp(order , 'mid') == 1
                    fullnews = cat(2,mergedRotatingBarBinary,beforeSepartorPart(:,numShiftedPixels:end));
                    fullnews2 = cat(2,mergedRotatingBarBinary2,beforeSepartorPart2(:,numShiftedPixels:end));
                    fullnews3 = cat(2,mergedRotatingBarBinary3,beforeSepartorPart3(:,numShiftedPixels:end));
                    fullnews4 = cat(2,mergedRotatingBarBinary4,beforeSepartorPart4(:,numShiftedPixels:end));
                    fullnews5 = cat(2,mergedRotatingBarBinary5,beforeSepartorPart5(:,numShiftedPixels:end));
                elseif strcmp(order , 'first') == 1
                    fullnews =   afterSepartorPart;
                    fullnews2 =  afterSepartorPart2;
                    fullnews3 =  afterSepartorPart3;
                    fullnews4 =  afterSepartorPart4;
                    fullnews5 =  afterSepartorPart5;
                else
                    % Last
                    fullnews =  beforeSepartorPart;
                    fullnews2 = beforeSepartorPart2;
                    fullnews3 = beforeSepartorPart3;
                    fullnews4 = beforeSepartorPart4;
                    fullnews5 = beforeSepartorPart5;
                end
            end
            
            mergedRotatingBarBinary = afterSepartorPart;
            mergedRotatingBarBinary2 = afterSepartorPart2;
            mergedRotatingBarBinary3 = afterSepartorPart3;
            mergedRotatingBarBinary4 = afterSepartorPart4;
            mergedRotatingBarBinary5 = afterSepartorPart5;
            
        end
        
        if numShiftedPixels ~= -1
            cd (NewsDataP1_Key);
            
            % Using Otsu method to get A Threshold Selection from Gray-Level Histograms
            % Convert the grayscale image  to a binary image. The output image BW replaces all pixels in the input image with luminance greater than level with the value 1 (white) and replaces all other pixels with the value 0 (black)
            fullnews = imbinarize(fullnews);
            fullnews2 = imbinarize(fullnews2);
            fullnews3 = imbinarize(fullnews3);
            fullnews4 = imbinarize(fullnews4);
            fullnews5 = imbinarize(fullnews5);
            
            imwrite(fullnews,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_FULL_News.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
            imwrite(~fullnews,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_FULL_News_Inverted.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
            
            clearvars gatheredForSR gatheredForSR_inverted
            gatheredForSR(:,:,1) = fullnews;
            gatheredForSR(:,:,2) = fullnews2;
            gatheredForSR(:,:,3) = fullnews3;
            gatheredForSR(:,:,4) = fullnews4;
            gatheredForSR(:,:,5) = fullnews5;
            
            gatheredForSR_inverted(:,:,1) = ~fullnews;
            gatheredForSR_inverted(:,:,2) = ~fullnews2;
            gatheredForSR_inverted(:,:,3) = ~fullnews3;
            gatheredForSR_inverted(:,:,4) = ~fullnews4;
            gatheredForSR_inverted(:,:,5) = ~fullnews5;
            
            save (strcat(ChannelName,'_',ProgramName,'_',num2str(Frame_ID)) ,  'gatheredForSR' );
            
            save (strcat(ChannelName,'_',ProgramName,'_',num2str(Frame_ID),'_Inverted') ,  'gatheredForSR_inverted');
            
            % Apply Super Resolution ( can remove output parameters )
            [HR , HR_Inverted ] = ApplySuperResolution ( gatheredForSR , gatheredForSR_inverted , ChannelName , ProgramName , Frame_ID , typeOfSR);
            
            imwrite(HR,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
            
            imwrite(HR_Inverted,[NewsDataP1_Key,ChannelName,'_',ProgramName,'_',num2str(Frame_ID, '%.6d'),'_Inverted_SR.tiff'] , 'tiff' , 'Resolution' , [500 , 500] );
            
            % Save image(s) to word
            save2word ( ChannelName , ProgramName , Frame_ID , typeOfSR , '_Part1');
            
            clearvars gatheredForSR gatheredForSR_inverted
            
            cd ..
            cd NewsDataP1_Normal
            
        end
    end


    
function shiftValue = getShiftbet2Images(Img, shiftedImg )
% -------------------------------------------------------------------------
% Function 
% Inputs: 
%           Img = gray frame image
%           shiftedImg = gray shifted image
% 
%          
% Output: 
%           shiftValue = how many shift exists
% -------------------------------------------------------------------------
    global word_width 

    shiftValue = 1;
    %windowValue = 10;
    windowValue = 20;

    if isempty(shiftedImg)
    return;
    end

    corrValue = 0.5;
    s1 = size(shiftedImg,2);
    widthComparison = min(s1,word_width);
    endPixel = widthComparison - windowValue - 1;
    
    for i = 1 : endPixel
        
        try
            greatestCorrValue = corrMatching(Img(:,end-windowValue:end) , shiftedImg(:,i:i+windowValue));
            
            if greatestCorrValue > corrValue
                
                corrValue = greatestCorrValue;
                shiftValue = i + windowValue + 1;
                
            end
            
        catch
            errorFunction_getShiftbet2Image = 1
            shiftValue=-1;
            break;
        end
        
    end

    if corrValue < 0.8
        shiftValue = -1;
    end

function shiftValue = getRotatingShift(Img, shiftedImg , direction)
% -------------------------------------------------------------------------
% Function 
% Inputs: 
%           Img = gray frame image
%           shiftedImg = gray shifted image
%           direction = Left or Right
%          
% Output: 
%           shiftValue = how many shift exists
% -------------------------------------------------------------------------

shiftValue = 1;
windowValue = 30;
if isempty(shiftedImg)
    return;
end

if direction == 'Right'
    % Arabic
    for i = 1 : 300
        
        try
            if corrMatching(shiftedImg(:,end-windowValue:end) , Img(:,end-windowValue-i:end-i)) >= 0.97
                shiftValue=i;
                break;
            end
        catch
            errorFunction_getRotatingShift = 1
            break;
        end
        
    end
    
else
    % English
    for i = 1 : 300
        
        try
            if corrMatching(shiftedImg(:,1:windowValue) , Img(:,1+i:windowValue+i) ) >= 0.97
                shiftValue=i;
                break;
            end
        catch
            errorFunction_getRotatingShift = 1
            break;
        end
    end
end
    



function corrScore = corrMatching(frameGray, templateGray)
% -------------------------------------------------------------------------
% Function corrMatching: Template Matching using Correlation Coefficients
% Inputs: 
%           frameImg = gray frame image
%           templateImg = gray template image
% Output: 
%           corrScore = 2D matrix of correlation coefficients
% -------------------------------------------------------------------------


% 1. initialization
frameGray = double(frameGray);
templateGray = double(templateGray);

% 2. correlation calculation
frameMean = conv2(frameGray,ones(size(templateGray))./numel(templateGray),'same');
templateMean = mean(templateGray(:));
corrPartI = conv2(frameGray,fliplr(flipud(templateGray-templateMean)),'same')./numel(templateGray);
corrPartII = frameMean.*sum(templateGray(:)-templateMean);
stdFrame = sqrt(conv2(frameGray.^2,ones(size(templateGray))./numel(templateGray),'same')-frameMean.^2);
stdTemplate = std(templateGray(:));
corrScore = (corrPartI-corrPartII)./(stdFrame.*stdTemplate);

% 3. finding the Score
corrScore = max(corrScore(:));



% function [edge_magnitude, edge_orientation] = coloredges(im)
% %COLOREDGES Edges of a color image by the max gradient method.
% %   [MAGNITUDE, ORIENTATION] = COLOREDGES(IMAGE)
% %   Extracts the edges of a color image without converting it to grayscale.
% %
% %   Changes in color are detected even when the grayscale color of two
% %   pixels are the same. The edge strength is typically greater or equal to
% %   the magnitude obtained by simply filtering a grayscale image.
% %
% %   Optionally, the edge orientation can also be returned.
% %
% %   Example
% %   -------
% %   The image generated by the example code shows two edge types:
% %     White - edges found by both methods.
% %     Red - edges found only by the color method.
% %
% %   This clearly shows that a significant amount of information is lost by
% %   the standard method, but it is recovered with the gradient method.
% %
% %     figure, im = imread('peppers.png'); imshow(im)
% %
% %     %get color edges and normalize magnitude
% %     C = coloredges(im);
% %     C = C / max(C(:));
% %
% %     %get grayscale edges and normalize magnitude
% %     G_image = single(rgb2gray(im)) / 255;
% %     G = sqrt(imfilter(G_image, fspecial('sobel')').^2 + imfilter(G_image, fspecial('sobel')).^2);
% %     G = G / max(G(:));
% %
% %     %show comparison
% %     figure, imshow(uint8(255 * cat(3, C, G, G)))
% %
% %   Algorithm
% %   ---------
% %   The RGB color of each pixel is treated as a 3D vector, and the strength
% %   of the edge is the magnitude of the maximum gradient. This also works
% %   if the image is in any other (3-dimensional) color space. Direct
% %   formulas for the jacobian eigenvalues were used, so this function is
% %   vectorized and yields good results without sacrificing performance.
% %
% %   Author: Joo F. Henriques
% %
% 
% 	%J is the jacobian, its elements are the partial derivatives of r/g/b
% 	%with respect to x/y. the edge strength is the greatest eigenvalue of:
% 	% J'*J
% 	% =
% 	% [ rx,  gx,  bx ] * [ rx,  ry ]
% 	% [ ry,  gy,  by ]   [ gx,  gy ]
% 	% 	                 [ bx,  by ]
% 	% =
% 	% [ rx^2 + gx^2 + bx^2,   rx*ry + gx*gy + bx*by ]
% 	% [ rx*ry + gx*gy + bx*by,   ry^2 + gy^2 + by^2 ]
% 	% =
% 	% [ Jx, Jxy ]
% 	% [ Jxy, Jy ]
% 	
% 	%smoothed partial derivatives using sobel filter (could use any other)
% 	im = single(im) / 255;
% 	yfilter = fspecial('sobel');
% 	xfilter = yfilter';
% 	
% 	rx = imfilter(im(:,:,1), xfilter);
% 	gx = imfilter(im(:,:,2), xfilter);
% 	bx = imfilter(im(:,:,3), xfilter);
% 	
% 	ry = imfilter(im(:,:,1), yfilter);
% 	gy = imfilter(im(:,:,2), yfilter);
% 	by = imfilter(im(:,:,3), yfilter);
% 	
% 	Jx = rx.^2 + gx.^2 + bx.^2;
% 	Jy = ry.^2 + gy.^2 + by.^2;
% 	Jxy = rx.*ry + gx.*gy + bx.*by;
% 	
% 	%compute first (greatest) eigenvalue of 2x2 matrix J'*J.
% 	%note that the abs() is only needed because some values may be slightly
% 	%negative due to round-off error.
% 	D = sqrt(abs(Jx.^2 - 2*Jx.*Jy + Jy.^2 + 4*Jxy.^2));
% 	e1 = (Jx + Jy + D) / 2;
% 	%the 2nd eigenvalue would be:  e2 = (Jx + Jy - D) / 2;
% 
% 	edge_magnitude = sqrt(e1);
% 	
% 	if nargout > 1
% 		%compute edge orientation (from eigenvector tangent)
% 		edge_orientation = atan2(-Jxy, e1 - Jy);
% 	end
