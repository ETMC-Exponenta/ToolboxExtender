function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
dev = %%DEVCLASS%%;
dev.test('', false);
% Post-install commands
cd('..');
ext = %%EXTCLASS%%;
ext.doc;
% Add your post-install commands below