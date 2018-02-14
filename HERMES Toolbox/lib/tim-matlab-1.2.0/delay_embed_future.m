% DELAY_EMBED_FUTURE
% Future of a delay-embedded signal.
%
% Y = delay_embed_future(X, dt)
%
% where
%
% X is a signal before delay-embedding.
%
% DT is the embedding delay.

% Description: Future of a delay-embedded signal
% Documentation: delay_embed.txt

function Y = delay_embed_future(X, dt)

if nargin < 2 || isempty(dt), dt = 1; end

% Deal with the case of multiple input signals.

if iscell(X),
    Y = cell(size(X));
    for i = 1:length(X)
        Y{i} = delay_embed_future(X{i}, dt);
    end
    return;
end

if dt < 1,
    error('dt must be a positive integer.');
end

Y = X(:, dt + 1 : end);
