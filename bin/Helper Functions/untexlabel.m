function newstr = untexlabel(str)
% UNTEXLABEL Produces a TeX format from a character string
%    Build a string which used with a TeX interpreter
%    shows exactly the string as it is.
%
%    If str is a one row string, UNTEXLABEL returns a one row string.
%
%    If str is a multiple row string, UNTEXLABEL is applied to each row,
%    and the vertical concatenation is returned (see strvcat).
%
%    If str is a cell array of strings, UNTEXLABEL returns a cell array of
%    the same size, each containing the correspondant result.
%
%    Example:
%
%    >> untexlabel('c:\matlab\temp\')
%    ans =
%    c:\\matlab\\temp\\
%
%    See also TEXLABEL (matlab function)


%   $Author: Giuseppe Ridino' $
%   $Revision: 2.1 $  $Date: 08-Jul-2004 23:46:16 $


% initialize output
newstr = '';
if ~isempty(str),
	if isa(str,'char'),
        newstr = untexlabel_local(str);
	elseif iscellstr(str),
		elements = prod(size(str));
		newstr = cell(size(str));
		for index=1:elements,
			newstr{index} = untexlabel_local(str{index});
		end
	else,
		error('Argument must be a char array or a cell array of strings.')
	end
end


% ########################################################
function newstr = untexlabel_local(str)
% this is for a multiple string line
newstr = '';
for index = 1:size(str,1),
    newstr = strvcat(newstr,untexstring(str(index,:)));
end


% ########################################################
function newstr = untexstring(str)
% this is for a single string line
newstr = '';
if ~isempty(str),
	% get '^' index
	index1 = find(str=='^');
	% get '_' index
	index2 = find(str=='_');
	% get '\' index
	index3 = find(str=='\');
	% merge all index
	index_end   = [sort([index1,index2,index3]-1) length(str)];
	index_begin = [1,index_end(1:end-1)+1];
	% build new string
	for counter = 1:length(index_end)-1,
		tok = str(index_begin(counter):index_end(counter));
		newstr = strcat(newstr,tok,'\');
	end
	% add end of str
	counter = length(index_end);
	tok = str(index_begin(counter):index_end(counter));
	newstr = strcat(newstr,tok);
end
