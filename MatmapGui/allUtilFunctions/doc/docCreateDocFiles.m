function docCreateDocFiles
% function docCreateDocFiles()
% 
% DESCRIPTION
% This function scans through all directories and bundles the help descriptions (such as
% this one) into one file per directory. As long as there is a complete description of the
% m-file in the first comment block, the function will be listed in the documentation.
% A general overview of the funcions in a directory is given in a README.txt file. The 
% latter is included in the documentation as well.
%
% INPUT -
%
% OUTPUT -
%
% SEE ALSO -

global Program;

if isempty(Program),
    msgError('Please start the program first',5);
end

ProgramPath = Program.Path;
ProgramName = Program.Name;

% First read the directory, as the program generates a help file for each directory

olddir = pwd;
cd(ProgramPath);

dirnames = {};
docnames = {};
htmlnames = {};

dr = dir;						% obtain directory contents
for p = 3:length(dr),					% skip . and ..
    if dr(p).isdir == 1,					% consider only directories
        dirnames{end+1} = dr(p).name;			% put the name in the list
    end
end    

if exist('./doc/DOCUMENTATION.txt','file'),
    dirnames{end+1} = 'referenceindex';
    
    fid = fopen('./doc/DOCUMENTATION.txt','r');   % the index page content
    index = char(fread(fid))';
    fclose(fid);
end

dirnames =  sort(dirnames);

for p=1:length(dirnames),
    docnames{end+1} = [dirnames{p} '.doc'];		% generate a bunch of filenames as well
    htmlnames{end+1} = [dirnames{p} '.html'];    % generate an html  filename    
end

fid = fopen('doclink.template','r');
linktemp = char(fread(fid))';
fclose(fid);
    
links = [];
for q=1:length(dirnames),
    if (strcmp('referenceindex',dirnames{q})), continue; end
    newlink = [linktemp sprintf('\n')];
    newlink = strrep(newlink,'{[LINK]}',sprintf('%s - Contents of the %s directory',upper(dirnames{q}),dirnames{q}));
    newlink = strrep(newlink,'{[DESTINATION]}',[htmlnames{q}]);
    links = [links newlink];
end    
    
      
for p=1:length(dirnames),
    
    if strcmp(dirnames{p},'referenceindex'),
        doc = index;        
    else    
    
    cd(dirnames{p});
    refcnt = 1;
    
    doc = [sprintf('<big><big> Documentation for the %s directory </big></big><br>',upper(dirnames{p}))];    
    doc = [doc sprintf('Contents: automaticly generated doucmentation <br>')];
    doc = [doc sprintf('Filename: %s <br>',docnames{p})];
    doc = [doc sprintf('Creation date: %s <br>',date)];
    doc = [doc '<br><br> <big><big> Contents </big></big> <br>' ];
    
    helpfile = '';
    if exist('./README.txt','file'),
        helpfile = 'README.txt';
        doc = [doc sprintf('<a href="#ref%d">General Description</a><br>',refcnt)];
        refcnt = refcnt + 1;
    end

    mfiles = {};    
    dr = dir('*.m');						% get all m-files
    for q = 1:length(dr),
        mfiles{end+1} = dr(q).name;				% find all m-files in this directory
    end
    
    mfiles = sort(mfiles);
    
    for q=1:length(mfiles),
        doc = [doc sprintf('<a href="#ref%d">%s</a><br>',refcnt,mfiles{q}(1:(end-2)))];		% fill out the contents
        refcnt = refcnt + 1;
    end
    
    doc = [doc sprintf('<br><br>')];					% generate some space
    
    refcnt = 1;
    
    if ~isempty(helpfile),
        fid = fopen('README.txt','r');
        readmetext = char(fread(fid))';
        fclose(fid);
        doc = [doc sprintf('<a name="ref%d"></a><big><big>General Description</big></big><br><pre>',refcnt) readmetext sprintf('</pre>')];
        refcnt = refcnt + 1;    
    end
    
    for q=1:length(mfiles),
        helpstring = help(mfiles{q});
        doc = [doc sprintf('<a name="ref%d"></a>',refcnt) '<br><big><big>' mfiles{q}(1:(end-2)) '</big></big><br><br><pre>' helpstring '</pre>'];
        refcnt = refcnt + 1;    
    end    
    
    cd('..');
    end

    cd('doc')
    
    fid = fopen(docnames{p},'w');
    fprintf(fid,'%s',doc);
    fclose(fid);

    % generate an html-fileas well
    
    html = [];
    fid = fopen('doc.template','r');
    html = char(fread(fid))';
    fclose(fid);

    
    doc = strrep(doc,sprintf('\n '),sprintf('\n&nbsp;'));

    title = sprintf('MATMAP/%s',upper(dirnames{p}));
    html = strrep(html,'{[DOCTITLE]}',title);
    html = strrep(html,'{[DATE]}',date);
    html = strrep(html,'{[LINKS]}',links);
    html = strrep(html,'{[DOCUMENTATION]}',doc);
    
    fid = fopen(htmlnames{p},'w');
    fprintf(fid,'%s',html);
    fclose(fid);
    cd('..')
end    
   
 
if isunix,
    cd('doc');
    !cp *.html *.jpg /mom/u/jeroen/public_html/matmap
end
   
cd(olddir);    

return

