function temp_fname = generate_temp_filename(root_fname, seq_len)
%% This function generates a temp filename by appending a timestamp and a 
%  sequence of random letters to the root filename given as input argument 
%  The timestamp follows ISO 8601 format as 'yyyy-mm-dd_HH-MM-SS'
%
% ARGUMENTS:
%        root_fname  -- a string with the root filename 
%        seq_len     -- an integer. The length of a string with a random 
%                       sequence of characters appended to root_fname
%
% OUTPUT: 
%        temp_fname -- a string with the temporary/pseudorandom filename
%                      built as strcat(root_fname, '_', timestamp_str, '_', random_str)
%
% REQUIRES: 
%        none
%
% USAGE:
%{
    root_fname = 'my_temp_file';
    temp_fname = generate_temp_filename(root_fname, 3);
%}
%
% AUTHOR: 
%        Paula Sanz-Leon, QIMR Berghofer, 2019-
% TODO: may need to give the format ending (eg, txt, mat, ) as input cause 
%       some functions need that bit

if nargin < 2
    seq_len = 4; 
end
  
timestamp_str = datestr(now, 'yyyy-mm-dd_HH-MM-SS-FFF');
random_str    = random_char_seq(seq_len);
temp_fname    = strcat(root_fname, '_', timestamp_str, '_', random_str);

end % function generate_temp_filename()


function char_seq = random_char_seq(seq_len)

    alphabet = strcat('A':'Z', 'a':'z');
    char_seq = alphabet(randi(numel(alphabet), [seq_len, 1]));
    
end % function generate char_seq()
