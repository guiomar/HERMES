function grouping = nchooseki ( total, remain, iteration )
% Gets the ith grouping vector for k elements chosen from a set of size k.

% Creates the Pascal's matrix to obtain the n-choose-k values.
matrix = pascal ( total );

% If the iteration is above the number of combinations, exits.
if iteration > matrix ( total + 1 - remain, remain + 1 )
    grouping = [];
    return
end

% Reserves memory.
grouping = false ( 1, total );
lag = 0;

% Evaluates each set to determine the group.
for item = 1: total
    
    % If there are not remaining items, exits.
    if remain == 0, return, end
    
    % n-choose-k defines the number of items set to 1.
    limit = matrix ( total - item + 1 - remain + 1, remain - 1 + 1 );
    
    % If the iteration is below the limit, sets the element to 1.
    if iteration - lag <= limit
        grouping ( item ) = true;
        
        % One item was placed, so decreases the remain.
        remain = remain - 1;
        
    % Otherwise keeps the element as 0 and increases the lag.
    else
        lag = lag + limit;
    end
end