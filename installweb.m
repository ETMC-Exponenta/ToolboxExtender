% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
instURL = 'https://api.github.com/repos/ETMC-Exponenta/ToolboxExtender/releases/latest';
[~, instName] = fileparts(instURL);
instRes = webread(instURL);
fprintf('Downloading %s %s\n', instName, instRes.name);
websave(instRes.assets.name, instRes.assets.browser_download_url);
disp('Installing...')
matlab.addons.install(instRes.assets.name);
clear instURL instRes instName
disp('Installation complete!')
% Add post-install commands below