function grammar_spell_check(dir_or_filename,merge_split_or_dual,SafeMode)
% Split .m files in code and comments, so you can check spelling in Word.
%
% Usage:
% This script will read a .m file or all .m files in a folder and split
% them into a code part and a comment part. The comment part may still
% contain some code. After the split, you can more easily use a program
% like Microsoft Word to check your comments/function help for spelling
% errors or even grammatical errors. The checked files will be put back on
% a line by line basis, so make sure not to remove or add any lines.
%
% Syntax:
% grammar_spell_check(dir_or_filename)
% grammar_spell_check(dir_or_filename,merge_split_or_dual)
% grammar_spell_check(dir_or_filename,merge_split_or_dual,SafeMode)
%
% dir_or_filename is assumed to be a file if it doesn't end with the file
% separator as returned by filesep.
% merge_split_or_dual [optional] 1 is for merging only, 2 is for splitting
% only, 3 [default] is for dual mode (split, wait for button press, merge).
% Merging removes the part files. Splitting also produces a backup file.
% Set SafeMode to true to keep a backup file of your .m files after
% merging. By default, this is set to false.
%
% Compatibility:
% Matlab: written under R2016b, but should work on all releases
% Octave: tested on 4.2.0, but should work on all releases
% OS:     written on Windows (64bit), should work for Mac/Unix
%
% Version: 1.0
% Date:    2017-04-04
% Author:  H.J. Wisselink
% Email=  'h_j_wisselink*alumnus_utwente_nl';
% Real_email = regexprep(Email,{'*','_'},{'@','.'})

%Find out the mode, and set the default to the dual mode.
if ~exist('merge_split_or_dual','var'),merge_split_or_dual=3;end
if ~exist('SafeMode','var'),SafeMode=false;end

%Build a file list
if ~strcmp(dir_or_filename(end),filesep)
    %If the last character is not the file separator, dir_or_filename is a
    %file, not a folder name.
    filelist={dir_or_filename};
else
    temp_list=dir([dir_or_filename filesep '*.m']);
    filelist=strcat(repmat({dir_or_filename},length(temp_list),1),...
        repmat({filesep},length(temp_list),1),...
        {temp_list.name}');
end

if merge_split_or_dual==2 || merge_split_or_dual==3
    %Split all the files (and make a backup)
    cellfun(@split_helper,filelist)
end

%If merge_split_or_dual==3 (the dual mode), pause execution of this code to
%give the user the time to open the text files with Word and check grammar
%and spelling.

if merge_split_or_dual==3
    q_options={'Merge','Exit'};
    choice = questdlg(['You can now review the .txt files in Word.'...
        ' You can either merge the files back to .m-files, or stop'...
        ' execution of this code.'],...
        'Split complete.',...
        q_options{1},q_options{2},q_options{1});
    choice = find(ismember(q_options,choice));
    if choice==2
        return
    end
end

if merge_split_or_dual==1 || merge_split_or_dual==3
    %Merge code and comment files, if in SafeMode, keep the backup of the
    %original .m-file, otherwise, delete it.
    cellfun(@merge_helper,filelist,repmat({SafeMode},length(filelist),1))
end
end

function split_helper(filename)
%Append .spellcheckbackup to the .m file in order to create a backup. If
%that file already exists, delete it.
%After that, put all comments in one file, and the code in another. These
%will be put back on a line by line basis, so you should not remove any
%empty lines or make new ones.

copyfile(filename,[filename '.spellcheckbackup'])
%Read the character stream to find out if \r should be used.
fid=fopen([filename '.spellcheckbackup']);
A=fread(fid);fclose(fid);
CRLF=logical(sum(A==13));

%Everything after the first ... or % will be included in the .txt, all
%other characters (including the ... or %) will be in the .code file.

fid1=fopen(filename,'r');
fid2=fopen([filename '.txt'],'w');
fid3=fopen([filename '.code'],'w');

%Something like textscan may be much more efficient, but it will remove
%empty lines.
while ~feof(fid1)
    original_line=fgetl(fid1);
    [code,comment]=separate_line(original_line);
    if CRLF
        fprintf(fid2,'%s\r\n',comment);
        fprintf(fid3,'%s\r\n',code);
    else
        fprintf(fid2,'%s\n',comment);
        fprintf(fid3,'%s\n',code);
    end
end

fclose(fid1);
fclose(fid2);
fclose(fid3);
end
function [code,comment]=separate_line(line)
% Separate the line in a code part and a comment part.
%
% Because parsing can be very complicated by lines like the example
% below, this script will only do a first approximation. This may
% be greatly improved in a later version to avoid code showing up
% in the comment part.

%Example of a difficult line to parse:
%[65*ones(5,1)' 'h, this line give''s me a %h1t of a headache...'];

%To make this an easy first attempt, the line will be split after
%the first ... that occurs, and if that isn't in the line, after
%the first %. This is because the % sign is used much more often in
%code than ... will be used in a string, so the latter is more
%reliable as end-of-code flag.

idx=strfind(line,'...');
if ~isempty(idx)
    idx=idx(1)+2;
else
    idx=strfind(line,'%');
    if ~isempty(idx)
        idx=idx(1);
    else
        idx=length(line);
    end
end

code=line(1:idx);
line(1:idx)=[];
comment=line;
end

function merge_helper(filename,SafeMode)
%Put the code and comments back together and overwrite the .m file.

%Read the character stream to find out if \r should be used.
fid=fopen([filename '.spellcheckbackup']);
A=fread(fid);fclose(fid);
CRLF=logical(sum(A==13));

%Open the files
fid1=fopen(filename,'w');
fid2=fopen([filename '.txt'],'r');
fid3=fopen([filename '.code'],'r');

while ~feof(fid3)
    code=fgetl(fid3);%read the code
    comment=fgetl(fid2);%read the comments
    if CRLF
        fprintf(fid1,'%s\r\n',[code comment]);%write out
    else
        fprintf(fid1,'%s\n',[code comment]);%write out
    end
end
fclose(fid1);
fclose(fid2);
fclose(fid3);
delete([filename '.txt'],[filename '.code']);

if ~SafeMode
    delete([filename '.spellcheckbackup']);
end
end
