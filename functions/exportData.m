function exportData(exportType,imagePath,tableData,columnNames)
% Helps to export the review report into html/xls/ppt format. It uses
% external tools html_table and exportToPPTX.

if strcmp(exportType,'.xls')
    [filename, pathname] = uiputfile({'*.xlsx;';'*.xls';'*.*'},'Save as','Untitled.xlsx');
    if isequal(filename,0)
        return;
    end
    xlFilePath = strcat(pathname,filename);
    warning('off','MATLAB:xlswrite:AddSheet');
    fileData = tableData;
    for ii = 1:size(tableData,1)
        fileData{ii,3} = '';
    end
    xlswrite(xlFilePath,[columnNames';fileData],'ReviewReport');
    % Add images in xls file and resize row and column.
    excelObj = actxserver('Excel.Application');
    excelObj.Visible = 0;
    excelObj.Application.DisplayAlerts = 0;
    workbookObj = excelObj.Workbooks.Open(xlFilePath);
    sheetObj = workbookObj.ActiveSheet;
    shapeObj = sheetObj.Shapes;
    sheetObj.Range('A1').EntireColumn.ColumnWidth = '20';
    sheetObj.Range('B1').EntireColumn.ColumnWidth = '50';
    sheetObj.Range('C1').EntireColumn.ColumnWidth = '50';
    sheetObj.Range('D1').EntireColumn.ColumnWidth = '15';
    sheetObj.Range('E1').EntireColumn.ColumnWidth = '50';
    for ii = 1:size(tableData,1)
        imgName = tableData{ii,3};
        slashLocation = max(strfind(imgName,'\'))+1;
        dquoteLocation = max(strfind(imgName,'"'))-1;
        imgName = imgName(slashLocation:dquoteLocation);
        spaceLoc = min(strfind(imgName,'"'))-1;
        imgName = imgName(1:spaceLoc);
        imgPath = [imagePath '\' imgName];
        rangeObj = sheetObj.Range(['C' num2str(ii+1)]);
        rangeObj.Select;
        left = rangeObj.Left;
        top = rangeObj.Top;
        rangeObj.RowHeight = 100;
        shapeObj.AddPicture(imgPath,1,1,left,top,100,100);
    end
    % Delete the default sheets
    workSheets = workbookObj.sheets;
    idx = 1;
    sheetIdx = 1;
    numSheets = workSheets.Count;
    while sheetIdx <= numSheets
        sheetName = workSheets.Item(idx).Name(1:end-1);
        if ~isempty(strmatch(sheetName,'Sheet'))
            workSheets.Item(idx).Delete;
        else
            idx = idx + 1;
        end
        sheetIdx = sheetIdx + 1;
    end
    % Save the file with the given file name, close Excel
    workbookObj.Save;
    workbookObj.Close;
    excelObj.Quit;
elseif strcmp(exportType,'.html')
    [filename, pathname] = uiputfile({'*.html;''*.*'},'Save as','Untitled.html');
    if isequal(filename,0)
        return;
    end
    htmlData = columnNames';
    for ii = 1:size(tableData,1)
        imgName = tableData{ii,3};
        slashLocation = max(strfind(imgName,'\'))+1;
        dquoteLocation = max(strfind(imgName,'"'))-1;
        imgName = imgName(slashLocation:dquoteLocation);
        spaceLoc = min(strfind(imgName,'"'))-1;
        imgName = imgName(1:spaceLoc);
        imgPath = [imagePath '\' imgName];
        base64Data = base64file(imgPath);
        tableData{ii,3} = ['<html><center><img src="data:image/jpg;base64,' base64Data '" height="150" width="150">'];
        htmlData = [htmlData;tableData(ii,:)];
    end
    html_table(htmlData,[pathname filename]);
elseif strcmp(exportType,'.pptx')
    % PPT report can be improved by adding a template.
    [filename, pathname] = uiputfile({'*.pptx;''*.*'},'Save as','Untitled.pptx');
    if isequal(filename,0)
        return;
    end
    % Close if any ppt file if it opened for writing.
    pptStatus = exportToPPTX('query');
    if ~isempty(pptStatus)
        exportToPPTX('close');
    end
    % Start with a new presentation
    exportToPPTX('new');
    for ii = 1:size(tableData,1)
        imgName = tableData{ii,3};
        slashLocation = max(strfind(imgName,'\'))+1;
        dquoteLocation = max(strfind(imgName,'"'))-1;
        imgName = imgName(slashLocation:dquoteLocation);
        spaceLoc = min(strfind(imgName,'"'))-1;
        imgName = imgName(1:spaceLoc);
        imgPath = [imagePath '\' imgName];
        exportToPPTX('addslide');
        exportToPPTX('addpicture',char(imgPath),'Scale','maxfixed');
        tableData{ii,3} = '';
        tableText = [strcat('Title : ',tableData{ii,1}) char(10)];
        tableText = [tableText strcat('Path : ',tableData{ii,2}) char(10)];
        tableText = [tableText strcat('Classification : ',tableData{ii,4}) char(10)];
        tableText = [tableText strcat('Comments : ',tableData{ii,5}) char(10)];
        exportToPPTX('addtext',tableText);
    end
    exportToPPTX('saveandclose',[pathname filename]);
end

end