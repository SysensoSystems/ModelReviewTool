classdef editViewClass < handle
    % Editor panel components to create a new issue in the report or edit
    % an exiting issue.
    
    properties
        figH;
        titleEditH;
        gcsPathEditH;
        gcsButtonH;
        imagePathEditH;
        browseRadioButtonH;
        screenCaptureRadioButtonH;
        browseButtonH;
        snipButtonH;
        print_buttonH;
        pasteButtonH;
        classificationMenuH;
        commentsEditH;
        editLayoutAddButtonH;
        editLayoutClearButtonH;
        imageAxes;
        bottomEmpty1H;
        axesFrame;
    end
    properties
        mainPath
        imagePath
    end
    events
        ADD_SELECTED;
    end
    
    methods
        function obj = editViewClass(varargin)
            
            if isempty(varargin)
                obj.figH = figure();
            else
                obj.figH = varargin{1};
            end
            
            % Path setting
            filePath = which(mfilename('fullpath'));
            obj.mainPath = fileparts(fileparts(filePath));
            obj.imagePath = [obj.mainPath filesep 'local_images'];
            
            editPanel = uipanel('parent',obj.figH,'Title','Issue Editor');
            %--------------------------------------------------------------
            % Issue editor components
            editMainPanel = uiflowcontainer('v0','Parent',editPanel);
            set(editMainPanel,'FlowDirection','TopDown');
            issueEditPanel = uiflowcontainer('v0','Parent',editMainPanel);
            set(issueEditPanel,'FlowDirection','TopDown');
            set(issueEditPanel,'HeightLimits',[inf,inf]);
            
            % Title Block
            titleLayout = uiflowcontainer('v0','Parent',issueEditPanel);
            set(titleLayout,'HeightLimits',[40,40]);
            title_textH = uicontrol(titleLayout,'Style','text','String','Title');
            set(title_textH,'HeightLimits',[30,30],'WidthLimits',[50,70]);
            obj.titleEditH = uicontrol('Parent',titleLayout,'Style','edit','String',' ');
            set(obj.titleEditH,'HeightLimits',[30,30],'WidthLimits',[60,inf]);
            
            % Path selection of currunt system.
            pathSelectionLayout = uiflowcontainer('v0','Parent',issueEditPanel);
            set(pathSelectionLayout,'HeightLimits',[40,40]);
            gcs_textH = uicontrol(pathSelectionLayout,'Style','text','String','Path');
            set(gcs_textH,'HeightLimits',[30,30],'WidthLimits',[50,70]);
            obj.gcsPathEditH = uicontrol('Parent',pathSelectionLayout,'Style','edit','String',' ');
            set(obj.gcsPathEditH,'HeightLimits',[30,30],'WidthLimits',[60,inf]);
            gcsButtonH = uicontrol(pathSelectionLayout,'Style','pushbutton','String','GCS');
            set(gcsButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            
            % Image selection.
            imageSelectionModeLayout = uiflowcontainer('v0','Parent',issueEditPanel);
            set(imageSelectionModeLayout,'HeightLimits',[30,80]);
            screenCapturePanel = uipanel(imageSelectionModeLayout);
            browseButtonPanel = uipanel(imageSelectionModeLayout);
            
            screenCaptureRadioButtonPanel = uiflowcontainer('v0','Parent',screenCapturePanel);
            obj.screenCaptureRadioButtonH = uicontrol(screenCaptureRadioButtonPanel,'Style','radiobutton','String','Screen Capture','value',1);
            set(obj.screenCaptureRadioButtonH,'HeightLimits',[30,30],'WidthLimits',[75,100]);
            screenCaptureButtonPanel = uiflowcontainer('Parent',screenCaptureRadioButtonPanel);
            obj.print_buttonH = uicontrol(screenCaptureButtonPanel,'Style','pushbutton','String','Print');
            set(obj.print_buttonH,'HeightLimits',[30,30],'WidthLimits',[10,50]);
            obj.snipButtonH = uicontrol(screenCaptureButtonPanel,'Style','pushbutton','String','Snip');
            set(obj.snipButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            imageSelect_text1H = uicontrol(screenCaptureButtonPanel,'Style','checkbox','String','&','Cdata',nan(1,1,3));
            set(imageSelect_text1H,'HeightLimits',[inf,inf],'WidthLimits',[20,20]);
            obj.pasteButtonH = uicontrol(screenCaptureButtonPanel,'Style','pushbutton','String','Paste');
            set(obj.pasteButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            set(screenCaptureRadioButtonPanel,'FlowDirection','topdown');
            
            browseButtonContainer = uiflowcontainer('v0','Parent',browseButtonPanel);
            obj.browseRadioButtonH = uicontrol(browseButtonContainer,'Style','radiobutton','String','Browse','value',0);
            set(obj.browseRadioButtonH,'HeightLimits',[30,30],'WidthLimits',[150,150]);
            browseButtonPanel = uicontainer(browseButtonContainer);
            browseButtons = uiflowcontainer('v0','Parent',browseButtonPanel);
            obj.imagePathEditH = uicontrol(browseButtons,'Style','edit','String',' ','Enable','off');
            set(obj.imagePathEditH,'HeightLimits',[30,30],'WidthLimits',[50,inf]);
            obj.browseButtonH = uicontrol(browseButtons,'Style','pushbutton','String','Browse');
            set(obj.browseButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            set(browseButtonContainer,'FlowDirection','topdown');
            
            % Axes to display images
            obj.axesFrame = uiflowcontainer('v0','Parent',issueEditPanel);
            set(obj.axesFrame,'HeightLimits',[inf,inf]);
            obj.imageAxes = axes('Parent',obj.axesFrame,'XColor','none','YColor','none');
            set(obj.imageAxes,'xticklabel',{[]});
            set(obj.imageAxes,'yticklabel',{[]});
            set(obj.imageAxes,'zticklabel',{[]});
            
            % Adding context menu to paste the image
            obj.imageAxes.UIContextMenu = uicontextmenu(gcf,'Tag','ImageContextMenu');
            uimenu(obj.imageAxes.UIContextMenu,'Label','paste','Tag','paste','Separator','off','Callback',@(hObject,event)obj.pasteCallback(hObject,event));
            
            % Issue classification selection.
            classificationSelectionLayout = uiflowcontainer('v0','Parent',issueEditPanel);
            set(classificationSelectionLayout,'HeightLimits',[40,40]);
            emptyH = uicontainer('Parent',classificationSelectionLayout);
            set(emptyH,'HeightLimits',[30,30],'WidthLimits',[inf,10]);
            classificationSelect_textH = uicontrol(classificationSelectionLayout,'Style','text','String','Classification');
            set(classificationSelect_textH,'HeightLimits',[30,30],'WidthLimits',[75,75]);
            obj.classificationMenuH = uicontrol(classificationSelectionLayout,'Style','popupmenu','String',{'Error','Warning','Info'});
            set(obj.classificationMenuH,'HeightLimits',[30,30],'WidthLimits',[200,200]);
            
            % Comments block.
            commentsLayout = uiflowcontainer('v0','Parent',issueEditPanel);
            set(commentsLayout,'HeightLimits',[100,100]);
            emptyH = uicontainer('Parent',commentsLayout);
            set(emptyH,'HeightLimits',[30,30],'WidthLimits',[inf,10]);
            comments_textH = uicontrol(commentsLayout,'Style','text','String','Comments');
            set(comments_textH,'HeightLimits',[30,30],'WidthLimits',[75,75]);
            obj.commentsEditH = uicontrol('Parent',commentsLayout,'Style','edit','HorizontalAlignment','left','String',' ');
            set(obj.commentsEditH,'Max',3,'Min',1);
            
            % Button Frame.
            editLayoutButtonFrame = uiflowcontainer('v0','Parent',editMainPanel);
            set(editLayoutButtonFrame,'HeightLimits',[45,45]);
            leftEmptyH = uicontainer('Parent',editLayoutButtonFrame);
            obj.editLayoutAddButtonH = uicontrol(editLayoutButtonFrame,'Style','pushbutton','String','Add');
            set(obj.editLayoutAddButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            obj.editLayoutClearButtonH = uicontrol(editLayoutButtonFrame,'Style','pushbutton','String','Clear');
            set(obj.editLayoutClearButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            rightEmptyH = uicontainer('Parent',editLayoutButtonFrame);
            
            %--------------------------------------------------------------
            % Setting Callbacks.
            set(obj.snipButtonH,'CallBack',@(hObject,event)obj.snip_button_Callback(hObject,event));
            set(obj.print_buttonH,'CallBack',@(hObject,event)obj.print_button_Callback(hObject,event));
            set(obj.browseButtonH,'CallBack',@(hObject,event)obj.browse_button_Callback(hObject,event));
            set(gcsButtonH,'CallBack',@(hObject,event)obj.gcs_button_Callback(hObject,event));
            set(obj.editLayoutAddButtonH,'CallBack',@(hObject,event)obj.editLayoutAdd_button_Callback(hObject,event));
            set(obj.browseRadioButtonH,'CallBack',@(hObject,event)obj.browse_radioButton_Callback(hObject,event));
            set(obj.screenCaptureRadioButtonH,'CallBack',@(hObject,event)obj.screenCapture_radioButton_Callback(hObject,event));
            set(obj.pasteButtonH,'CallBack',@(hObject,event)obj.pasteCallback(hObject,event));
            set(obj.editLayoutClearButtonH,'CallBack',@(hObject,event)obj.editLayoutClear_button_Callback(hObject,event));
            
        end
        %------------------------------------------------------------------
        % Function definitions.
        function obj = screenCapture_radioButton_Callback(obj,hObject,eventData)
            % ScreenCapture choice selection for the image file
            
            set(obj.browseRadioButtonH,'value',0);
            set(obj.snipButtonH,'enable','on');
            set(obj.print_buttonH,'enable','on');
            set(obj.pasteButtonH,'enable','on');
            set(obj.imagePathEditH,'enable','off');
            set(obj.browseButtonH,'enable','off');
        end
        %------------------------------------------------------------------
        function obj = snip_button_Callback(obj,hObject,eventData)
            % Launches the snipping tool to capture images
            
            % Use the 'SnippingTool.exe'.
            system('SnippingTool.exe &');
        end
        %------------------------------------------------------------------
        function obj = print_button_Callback(obj,hObject,eventData)
            % Used for printing the current view of the model
            
            if isempty(gcs)
                warndlg('No model is found');
                return;
            else
                tempName = char(datetime);
                tempName = [tempName(isstrprop(tempName,'alphanum')), '.png'];
                print(['-s' gcs],'-djpeg',[obj.imagePath '\'  tempName]);
                imageData = imread([obj.imagePath '\'  tempName]);
                set(obj.imagePathEditH,'String',tempName);
                imshow(imageData,'parent',obj.imageAxes);
            end
        end
        %------------------------------------------------------------------
        function obj = pasteCallback(obj,src,evt)
            % Helps to paste the clipboard image. USed as callback for the
            % paste button and the uicontextmenu.
            
            imgData = imclipboard('paste');
            if isempty(imgData)
                warndlg('No image data in clipboard','No image found','modal');
                return;
            end
            tempName = char(datetime);
            tempName = [tempName(isstrprop(tempName,'alphanum')), '.png'];
            set(obj.imagePathEditH,'String',tempName);
            tempName = [obj.imagePath '\' tempName];
            imwrite(imgData,tempName);
            imshow(imgData,'parent',obj.imageAxes);
        end
        %------------------------------------------------------------------
        function obj = browse_radioButton_Callback(obj,hObject,eventData)
            % Browsing choice selection for the image file
            
            set(obj.imagePathEditH,'enable','on');
            set(obj.browseButtonH,'enable','on');
            set(obj.screenCaptureRadioButtonH,'value',0);
            set(obj.snipButtonH,'enable','off');
            set(obj.print_buttonH,'enable','off');
            set(obj.pasteButtonH,'enable','off');
        end
        %------------------------------------------------------------------
        function obj = browse_button_Callback(obj,hObject,eventData)
            % Browse the exisitng image file
            
            [imageName, imagePath] = uigetfile({'*.png';'*.jpeg';'*.jpg';'*.gif';},'Pick a file');
            if imageName == 0
                return;
            end
            set(obj.imagePathEditH,'String',imageName);
            imgData = imread([obj.imagePath '\' imageName]);
            imwrite(imgData,[obj.imagePath '\' imageName]);
            imshow([obj.imagePath '\' imageName],'parent',obj.imageAxes);
        end
        %------------------------------------------------------------------
        function obj = gcs_button_Callback(obj,hObject,eventData)
            % GCS Button Callback.
            
            set(obj.gcsPathEditH,'String',gcs);
        end
        %------------------------------------------------------------------
        function obj = editLayoutAdd_button_Callback(obj,hObject,eventData)
            % Adds the current issue to the report table. It generates an
            % event, then even handler from the main gui handles it.
            
            notify(obj,'ADD_SELECTED');
            set(obj.editLayoutAddButtonH,'String','Add');
        end
        %------------------------------------------------------------------
        function obj = editLayoutClear_button_Callback(obj,hObject,eventData)
            % Clear the current issue
            
            set(obj.titleEditH,'String','');
            set(obj.gcsPathEditH,'String','');
            set(obj.imagePathEditH,'String','');
            set(obj.classificationMenuH,'Value',1);
            set(obj.commentsEditH,'String','');
            set(obj.browseRadioButtonH,'Value',1);
            set(obj.screenCaptureRadioButtonH,'Value',0);
            imshow('parent',obj.imageAxes,[1 1]);
        end
        %------------------------------------------------------------------
        function obj = tableEditCallback(obj,hObject,eventData,curruntRow)
            % Callback to edit a row item in the report table. This
            % callback triggered from the main gui.
            
            imgName = curruntRow{3};
            slashLocation = max(strfind(imgName,'\'))+1;
            dquoteLocation = max(strfind(imgName,'"'))-1;
            imgName = imgName(slashLocation:dquoteLocation);
            spaceLoc = min(strfind(imgName,'"'))-1;
            imgName = imgName(1:spaceLoc);
            set(obj.titleEditH,'String',curruntRow{1});
            set(obj.gcsPathEditH,'String',curruntRow{2});
            set(obj.imagePathEditH,'String',imgName);
            imshow([obj.imagePath '\' imgName],'parent',obj.imageAxes);
            classificationString = get(obj.classificationMenuH,'String');
            classificationValue = find(strcmp(classificationString,curruntRow{4}));
            if isempty(classificationValue)
                classificationValue = 1;
            end
            set(obj.classificationMenuH,'Value',classificationValue);
            set(obj.commentsEditH,'String',curruntRow{5});
        end
    end
end
