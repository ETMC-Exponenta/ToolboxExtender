instURL = 'https://api.github.com/repos/ETMC-Exponenta/ToolboxExtender';
[~, instName] = fileparts(instURL);
instRes = webread(instURL + "/releases/latest");
fprintf('Downloading %s %s\n', instName, instRes.name);
websave(instRes.assets.name, instRes.assets.browser_download_url);
open(instRes.assets.name)
clear instURL instRes instName