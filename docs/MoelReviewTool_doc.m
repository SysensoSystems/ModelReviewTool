%% *|ModelReviewTool|*
%
% ModelReviewTool will be useful to manually review the Simulink model and to
% generate the review report in html/xls/ppt formats.
%
% Developed by: Sysenso Systems, https://sysenso.com/
%
% Contact: contactus@sysenso.com
%
% Version:
% 1.0 - Initial Version.
%
%
% *|Usage Information|*
%%
%
% * Open the Simulink model that has to be reviewed. To launch the tool, type the following command in the MATLAB command window >> ModelReviewTool
%
% <<\images\\path.png>>
%
%
%%
% * It has two important panels.
%
% # Issue Editor - To create/edit an issue
% # Report Table - List of review items created
%
% <<\images\\panels.png>>
%
%%
%
% * Issue Editor Panel - Every issue will have a title, reference system path, reference image, issue type, additional comments.
%
% <<\images\\editor.png>>
%
% # Title - Issue will be identified by its title. Hence it should be unique.
% # Path - System path where the issue is noted. Use GCS button to get the current system path.
% # Reference Image - Issue can be better explained by an image with color and text markings. Use any one approach to get the image 1.snipping tool image editor 2.printing a snapshot of the model 3.browsing an existing image.
% # Classification - Issue can be classified as Error/Warning/Info
% # Comments - Any additional comments to give more explanation.
%

%%
%
% * Report Table - It holds all the review issues in a table. Issues can be edited directly in this table or it can be moved to 'Issue Editor' to update it.
%
% <<\images\\reporttable.png>>
%
%%
%
% * Review report can be exported into XLS/HTML/PPT formats.
%
% <<\images\\export.png>>
%
% * HTML
%
% <<\images\\html_report.png>>
%
% * XLS
%
% <<\images\\xls_report.png>>
%
% * PPT
%
% <<\images\\ppt_report.png>>
%
%%
%
% * During the review process, the intermediate report can be stored in a specific file format(.mrt) for this tool. This can be loaded anytime and then the review can be continued.
%
% <<\images\\process.png>>
%
%%
%
% * |Courtesy: This tool uses the following file-exchange submissions. We thank the respective authors.|
%
% # base64img - https://in.mathworks.com/matlabcentral/fileexchange/24514-base64-image-encoder
% # exportToPPTX - https://in.mathworks.com/matlabcentral/fileexchange/40277-exporttopptx
% # html_table - https://in.mathworks.com/matlabcentral/fileexchange/25078-html-table-writer
% # imclipboard - https://in.mathworks.com/matlabcentral/fileexchange/28708-imclipboard
%

%%
% *Note: This tool is a prototype. Please share your comments and contact us if you are interested in updating the features further.* 
%