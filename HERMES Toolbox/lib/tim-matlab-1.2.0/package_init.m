function command = package_init(filePath)

packageName = regexpi(...
    filePath, ...
    '+(TIM_.*)', ...
    'tokens', 'once');

command = '';
if ~isempty(packageName)
    command = ['import ', packageName{1}, '.*;'];
end
