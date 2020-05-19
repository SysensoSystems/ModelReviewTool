classdef reportViewClass < handle
    % Report table panel
    
    properties
        figH;
        tableH;
        editButtonH;
        removeButtonH;
        clearButtonH;
        exportButtonH;
        selectedRow = 1;
        jtable;
        modalTable;
        editFlag = false;
        rowToEdit;
    end
    properties
        mainPath
        imagePath
    end
    events
        EDIT_SELECTED;
    end
    
    methods
        function obj = reportViewClass(varargin)
            
            if isempty(varargin)
                obj.figH = figure();
            else
                obj.figH = varargin{1};
            end
            % Path setting
            filePath = which(mfilename('fullpath'));
            obj.mainPath = fileparts(fileparts(filePath));
            obj.imagePath = [obj.mainPath filesep 'local_images'];
            
            reportViewPanel = uipanel('parent',obj.figH,'Title','Report Table');
            %--------------------------------------------------------------
            tableFrame = uiflowcontainer('v0','Parent',reportViewPanel);
            set(tableFrame,'FlowDirection','TopDown');
            tableSubFrame = uiflowcontainer('v0','Parent',tableFrame);
            colNames = {'Title','Path','Reference Image','Classification','Comments'};
            data = {'','','','',''};
            [obj.tableH,~] = uitable('v0','Parent',tableSubFrame,'ColumnNames',colNames,'Data',data,'rowheight',100,'ColumnWidth',180);
            obj.jtable = obj.tableH.getTable();
            obj.modalTable = obj.jtable.getModel;
            obj.modalTable.removeRow(0);
            set(tableSubFrame,'HeightLimits',[inf,inf]);
            
            % Report view Button Frame
            reviewPanelButtonFrame = uiflowcontainer('v0','Parent',tableFrame);
            set(reviewPanelButtonFrame,'HeightLimits',[45,45]);
            leftEmptyH = uicontainer('Parent',reviewPanelButtonFrame);
            obj.editButtonH = uicontrol(reviewPanelButtonFrame,'Style','pushbutton','String','Edit');
            set(obj.editButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            obj.removeButtonH = uicontrol(reviewPanelButtonFrame,'Style','pushbutton','String','Remove');
            set(obj.removeButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            obj.clearButtonH = uicontrol(reviewPanelButtonFrame,'Style','pushbutton','String','Clear');
            set(obj.clearButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            obj.exportButtonH = uicontrol(reviewPanelButtonFrame,'Style','pushbutton','String','Export');
            set(obj.exportButtonH,'HeightLimits',[30,30],'WidthLimits',[50,50]);
            rightEmptyH = uicontainer('Parent',reviewPanelButtonFrame);
            
            % Setting Callbacks.
            set(obj.editButtonH,'CallBack',@(hObject,event)obj.editButton_Callback(hObject, event));
            set(obj.removeButtonH,'CallBack',@(hObject,event)obj.removeButton_Callback(hObject,event));
            set(obj.clearButtonH,'CallBack',@(hObject,event)obj.clearButton_Callback(hObject,event));
            set(obj.exportButtonH ,'CallBack',@(hObject,event)obj.exportButton_Callback(hObject,event));
            set(handle(obj.jtable,'callbackproperties'),'MousePressedCallback',{@obj.table_CellSelectionCallback,obj.tableH});
            
        end
        %------------------------------------------------------------------
        function obj = editButton_Callback(obj,hObject,eventData)
            % Helps to edit the current issue/row from the report table. It
            % generates an event, then even handler from the main gui
            % handles it.
            
            notify(obj,'EDIT_SELECTED');
        end
        %----------------------------------------------------------------------
        function obj = removeButton_Callback(obj,hObject,eventData)
            % Helps to remove the current issue/row in the report table
            
            tableData = cell(get(obj.tableH,'Data'));
            if isempty(tableData)
                return;
            end
            obj.modalTable.removeRow(obj.selectedRow-1);
        end
        %----------------------------------------------------------------------
        function obj = clearButton_Callback(obj,hObject,eventData)
            % Clears the entire report table
            
            for ind = obj.modalTable.getRowCount:-1:1
                obj.modalTable.removeRow(ind-1);
            end
        end
        %----------------------------------------------------------------------
        function obj = exportButton_Callback(obj,hObject,eventData)
            % Help to export the report table contents
            
            tableData = cell(get(obj.tableH,'Data'));
            columnNames = cell(get(obj.tableH,'columnnames'));
            buttonName = questdlg('Select File Type :','Export Type','.xls','.html','.pptx','.html');
            if isempty(buttonName)
                return;
            end
            exportData(buttonName,obj.imagePath,tableData,columnNames);
        end
        %----------------------------------------------------------------------
        function obj = table_CellSelectionCallback(obj,hObject,eventData,jtableH)
            % Helps to record the current issue/row from the report table
            
            tableData = cell(get(obj.tableH,'Data'));
            obj.selectedRow = hObject.SelectedRow+1;
            if isequal(hObject.SelectedColumn+1,3)
                imgName = tableData{obj.selectedRow,3};
                slashLocation = max(strfind(imgName,'\'))+1;
                dquoteLocation = max(strfind(imgName,'"'))-1;
                imgName = imgName(slashLocation:dquoteLocation);
                spaceLoc = min(strfind(imgName,'"'))-1;
                imgName = imgName(1:spaceLoc);
                if ~isempty(imgName)
                    fh = figure('Name',tableData{obj.selectedRow,1},'NumberTitle','off','menubar','none','toolbar','none');
                    imshow([obj.imagePath '\' imgName]);
                end
            elseif isequal(hObject.SelectedColumn+1,4)
                % TODO: Current clssification can be edited now. We have to handle this.
            end
        end
        %------------------------------------------------------------------
        function obj = tableAddCallback(obj,hObject,eventData,contentToAdd)
            % Callback used from the main gui to add the new issue to the
            % report table.
            
            tableData = cell(get(obj.tableH,'Data'));
            for ind = 1:size(tableData,1)
                if ~obj.editFlag
                    if strcmp(tableData{ind,1},contentToAdd{1})
                        warndlg(strcat('The title   ''',contentToAdd(1),'''   already exist in the table.'), 'Already Exist', 'modal');
                        return;
                    end
                end
            end
            filePath = [obj.imagePath '\' contentToAdd{3}];
            filePath = strrep(['file:' filePath],'/','/');
            contentToAdd{3} = ['<html><center><img src = "' filePath '" height="150" width="150">'];
            if obj.editFlag
                tableData(obj.rowToEdit,:) = contentToAdd;
                obj.editFlag = false;
            else
                if isempty(tableData)
                    tableData = contentToAdd;
                else
                    tableData = [cell(tableData); contentToAdd];
                end
            end
            setData(obj.tableH,tableData);
            numRows = obj.tableH.getNumRows;
            for ind = 0:numRows-1
                obj.tableH.setRowHeight(ind,100);
            end
        end
    end
end