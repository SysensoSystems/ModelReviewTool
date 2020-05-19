classdef ModelReviewTool < handle
    % ModelReviewTool will be useful to manually review the Simulink model
    % and to generate the review report in html/xls/ppt formats.
    %
    % It has two important panels.
    % Issue Editor - To create/edit a issue
    % Report Table - List of review items created
    %
    % During the review process, the intermediate report can be stored in a
    % specific file format(.mrt) for this tool. This can be loaded anytime
    % and then the review can be continued.
    %
    % Syntax: To launch the tool, add the entire ModelReviewTool folder into MATLAB path.
    % Then, type the following command in the MATLAB command window.
    % >> ModelReviewTool
    %
    % Developed by: Sysenso Systems, https://sysenso.com/
    % Contact: contactus@sysenso.com
    %
    % Version:
    % 1.0 - Initial Version.
    %
    properties(Hidden)
        figH;
        imageAxes;
        editViewObj;
        reportViewObj;
        imageViewObj;
        fileMenu;
        loadMenuItem;
        xlsMenuItem;
        pptMenuItem;
        htmlMenuItem;
        saveMenuItem;
        printMenu;
        docMenu
        toolbarHandle;
        saveToolH;
        openToolH;
    end
    properties(Hidden)
        mainPath
        imagePath
    end
    
    methods
        function obj = ModelReviewTool
            % Constructor for the ModelReviewTool.
            % It consists two sub classes/components.
            % editViewClass - editor panel componenets.
            % reportViewClass - report table componenets
            
            % Main figure
            obj.figH = figure('Name','Model Review Tool','numberTitle','off','Units','pixels');
            % Menubar customization.
            set(obj.figH, 'MenuBar', 'none','ToolBar','none');
            screenSize = get(0,'screensize');
            set(obj.figH,'Position',[0.14*screenSize(3) 0.2*screenSize(4) 0.72*screenSize(3) 0.6*screenSize(4)]);
            movegui(obj.figH,'center');
            obj.fileMenu = uimenu(obj.figH,'Label','File');
            obj.printMenu = uimenu(obj.figH,'Label','Export');
            obj.loadMenuItem = uimenu(obj.fileMenu,'Label','Load');
            obj.xlsMenuItem = uimenu(obj.printMenu,'Label','xls');
            obj.pptMenuItem = uimenu(obj.printMenu,'Label','ppt');
            obj.htmlMenuItem = uimenu(obj.printMenu,'Label','html');
            obj.saveMenuItem = uimenu(obj.fileMenu,'Label','Save');
            obj.docMenu = uimenu(obj.figH,'Label','Doc');
            
            % Path setting
            filePath = which(mfilename('fullpath'));
            obj.mainPath = fileparts(filePath);
            obj.imagePath = [obj.mainPath filesep 'local_images'];
            
            % Toolbar customization.
            obj.toolbarHandle = uitoolbar(obj.figH);
            tempImage = imread([obj.mainPath '\toolbar_images\openimg.PNG']);
            obj.openToolH = uipushtool(obj.toolbarHandle,'CData',tempImage);
            set(obj.openToolH,'ClickedCallback',@(hObject,event)obj.loadMenuItem_Callback(hObject,event));
            tempImage = imread([obj.mainPath '\toolbar_images\saveimg.PNG']);
            obj.saveToolH = uipushtool(obj.toolbarHandle,'CData',tempImage);
            set(obj.saveToolH,'ClickedCallback',@(hObject,event)obj.saveMenuItem_Callback(hObject,event));
            mainLayout = uigridcontainer('v0','Parent',obj.figH,'margin',1);
            set(mainLayout,'GridSize',[1,2]);
            set(mainLayout,'HorizontalWeight',[3,7]);
            
            % Report View
            warning('off','MATLAB:uiflowcontainer:MigratingFunction');
            editViewLayout = uiflowcontainer('v0','Parent',mainLayout);
            obj.editViewObj = editViewClass(editViewLayout);
            
            % Edit view
            reportViewLayout = uiflowcontainer('v0','Parent',mainLayout);
            obj.reportViewObj = reportViewClass(reportViewLayout);
            editButtonL = addlistener(obj.reportViewObj,'EDIT_SELECTED',@(hObject,event)obj.edit_button_callback(hObject,event));
            addButtonL = addlistener(obj.editViewObj,'ADD_SELECTED',@(hObject,event)obj.add_button_callback(hObject,event));
            
            % Setting callbacks.
            set(obj.figH,'CloseRequestFcn',@(hObject,event)obj.guiClose_Callback(hObject,event));
            set(obj.saveMenuItem,'CallBack',@(hObject,event)obj.saveMenuItem_Callback(hObject,event));
            set(obj.loadMenuItem,'CallBack',@(hObject,event)obj.loadMenuItem_Callback(hObject,event));
            set(obj.xlsMenuItem,'Tag','.xls','CallBack',@(hObject,event)obj.exportMenu_Callback(hObject,event));
            set(obj.pptMenuItem,'Tag','.ppt','CallBack',@(hObject,event)obj.exportMenu_Callback(hObject,event));
            set(obj.htmlMenuItem,'Tag','.html','CallBack',@(hObject,event)obj.exportMenu_Callback(hObject,event));
            set(obj.docMenu,'CallBack',@(hObject,event)obj.docMenu_Callback(hObject,event));
            
        end
        %------------------------------------------------------------------
        function obj = edit_button_callback(obj,src,event)
            % Edit button callback. This allows the user to edit the
            % current row in the report.
            
            tableData = cell(get(obj.reportViewObj.tableH,'Data'));
            if isempty(tableData)
                return;
            end
            obj.reportViewObj.editFlag = true;
            obj.reportViewObj.rowToEdit = obj.reportViewObj.selectedRow;
            set(obj.editViewObj.editLayoutAddButtonH,'String','Update');
            obj.editViewObj.tableEditCallback(src,event,tableData(obj.reportViewObj.selectedRow,:));
            
        end
        %------------------------------------------------------------------
        function obj = add_button_callback(obj,src,event)
            % Add button callback. Helps to add the entries from the edit
            % panel to the report table.
            
            titleText = get(obj.editViewObj.titleEditH,'String');
            currentPath = get(obj.editViewObj.gcsPathEditH,'String');
            currentImage = get(obj.editViewObj.imagePathEditH,'String');
            currentClassificationValue = get(obj.editViewObj.classificationMenuH,'Value');
            classificationString = get(obj.editViewObj.classificationMenuH,'String');
            currentClassificationString = classificationString(currentClassificationValue);
            currentComment = get(obj.editViewObj.commentsEditH,'String');
            if isempty(titleText)
                warndlg('Enter the title','Title Empty', 'modal');
                return;
            end
            currentData = [titleText;currentPath;currentImage;currentClassificationString;currentComment]';
            obj.reportViewObj.tableAddCallback(src,event,currentData);
            
        end
        %------------------------------------------------------------------
        function obj = saveMenuItem_Callback(obj,src,evt)
            % Saves the current report in a intermeditory format .mrt
            
            tableData = cell(get(obj.reportViewObj.tableH,'Data'));
            if isempty(tableData)
                msgbox('No review data to save!')
            else
                [filename, pathname] = uiputfile({'*.mrt;'},'Save as','Untitled.mrt');
                if isequal(filename,0)
                    return;
                end
                for rowInd = 1:size(tableData,1)
                    imgName = tableData{rowInd,3};
                    slashLocation = max(strfind(imgName,'\'))+1;
                    dquoteLocation = max(strfind(imgName,'"'))-1;
                    imgName = imgName(slashLocation:dquoteLocation);
                    spaceLoc = min(strfind(imgName,'"'))-1;
                    imgName = imgName(1:spaceLoc);
                    imgData = imread([obj.imagePath '\' imgName]);
                    tableData{rowInd,3} = imgData;
                end
                save([pathname filename],'tableData');
            end
        end
        %------------------------------------------------------------------
        function obj = loadMenuItem_Callback(obj,src,evt)
            % Loads the .mrt report back to the tool
            
            tableData = cell(get(obj.reportViewObj.tableH,'Data'));
            if ~isempty(tableData)
                buttonName = questdlg('Loading a new MRT file will erase the current report table. Do you want to proceed?', ...
                    'Loading MRT file', ...
                    'Yes', 'No', 'No');
                if isempty(buttonName) || strcmpi(buttonName,'No')
                    return;
                end
            end
            [filename, pathname] = uigetfile({'*.mrt;'},'Select the MRT file');
            if isequal(filename,0)
                return;
            end
            fileData = load([pathname filename],'-mat');
            tableData = fileData.tableData;
            for rowInd = 1:size(tableData,1)
                tempName = char(datetime);
                tempName = [tempName(isstrprop(tempName,'alphanum')) num2str(rowInd) '.png'];
                tempName = [obj.imagePath '\' tempName];
                imwrite(tableData{rowInd,3},tempName);
                filePath = strrep(['file:' tempName],'/','/');
                tableData{rowInd,3} = ['<html><img src= "' filePath '" height="110" width="120"></html>'];
            end
            % Do the array assignments in a reverse order, to avoid java
            % array dimension related error.
            for rowInd = size(tableData,1):-1:1
                for colInd = size(tableData,2):-1:1
                    jtableData(rowInd,colInd) = java.lang.String(tableData{rowInd,colInd});
                end
            end
            set(obj.reportViewObj.tableH,'Data',jtableData);
        end
        %------------------------------------------------------------------
        function obj = guiClose_Callback(obj,src,evt)
            % Handling the GUI close activities.
            
            % Clearing the local images.
            if ~isempty(path)
                tempDir = dir(fullfile(obj.imagePath,'*.*'));
                for ii = 1:length(tempDir)
                    currentFile = fullfile(obj.imagePath, tempDir(ii).name);
                    if ~isdir(currentFile) && ~(strcmp(currentFile,[obj.imagePath '\' 'readme.txt']))
                        delete(currentFile);
                    end
                end
            end
            delete(obj.figH);
        end
        %------------------------------------------------------------------
        function obj = exportMenu_Callback(obj,src,evt)
            % Export menu callback function
            
            tableData = cell(get(obj.reportViewObj.tableH,'Data'));
            columnNames = cell(get(obj.reportViewObj.tableH,'columnnames'));
            buttonName = get(src,'Tag');
            exportData(buttonName,obj.imagePath,tableData,columnNames);
        end
        %------------------------------------------------------------------
        function obj = docMenu_Callback(obj,src,evt)
            % Document menu callback function
            
            open([obj.mainPath '\docs\MoelReviewTool_doc.pdf']);
        end
        %------------------------------------------------------------------
        function disp(obj)
            % Helsp to avoid showing the GUI handles
            
            disp('ModelReviewTool');
        end
    end
end
