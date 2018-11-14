# Toolbox Updater

Improve your custom toolbox and develop process with one-file Updater class

File Exchange: [Toolbox Updater](https://www.mathworks.com/matlabcentral/fileexchange/69126)

## Updater functionality

Updater class will add to your custom addon:

- feature to check the latest version on GitHub
- feature to automatically download and install the latest version

## Developer functionality

At the same time Updater class provide you with functions for easy:

- update toolbox project file version and build .mltbx
- commit and push project to GitHub
- create tag with version number and push it to GitHub

## Requirements

- MATLAB **R2018b** or newer
- Installed **Git** (for Developer functionality)
- **Public** toolbox project on GitHub

## Examples of Toolbox Updater usage

- [MATLAB WEB API](https://github.com/ETMC-Exponenta/MATLAB-WEB-API)
- [MATLAB Course for Educators](https://github.com/ETMC-Exponenta/MATLAB-Course-for-Educators)
- (send me your examples)

# Installation

Download and run [**Toolbox-Updater.mltbx**](https://github.com/ETMC-Exponenta/ToolboxUpdater/raw/master/Toolbox-Updater.mltbx)

# How to update installed Toolbox Updater itself

Check installed and latest version
```MATLAB
ToolboxUpdater.version
```
Update to the latest version if available
```MATLAB
ToolboxUpdater.upd
```

# How to add Updater to your custom toolbox project

1. In toolbox project directory create toolbox project file (.prj)
2. Upload your project to GitHub
3. Run command
```MATLAB
ToolboxUpdater.init
```
4. This will add to project directory: Updater class **...Updater.m**, **ToolboxConfig.xml** with project and Updater info, **dev_on.m** script to activate developer tools
5. Manually add **dev_on.m** to excluded files of your project

# How to use Updater functionality

Create object of your **...Updater.m** class
```MATLAB
tu = ToolboxUpdater
```
Check internet connection
```MATLAB
onl = tu.isonline
```
Check installed and latest version
```MATLAB
tu.ver
```
Check update is available
```
upd = tu.isupdate
```
Update to latest version
```MATLAB
tu.update
```
Use this functions in your toolbox to provide automatic update check and install.

# How to use Developer functionality

Run **dev_on.m** script
```MATLAB
dev_on
```
Build toolbox (app) file of specified version (for test)
```MATLAB
dev.build('0.0.1')
```
Build toolbox (app) file of specified version, commit, push to GitHub and create tag
```MATLAB
dev.deploy('0.0.1')
```
Then create from tag new release on GitHub page and **attach toolbox (app) file to it**.

If you've made mistake: delete specified tag from GitHub
```MATLAB
dev.untag('0.0.1')
```
