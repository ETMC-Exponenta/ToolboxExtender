# Toolbox Updater

Improve your custom toolbox and develop process with one-file Updater class

## Updater functionality

Updater class will add to your custom addon:

- feature to check the latest version on GitHub
- feature to automatically download and install the latest version

## Developer functionality

At the same time Updater class provide you with functions for easy:

- update toolbox project file version and build .mltbx
- commit and push project to GitHub
- create tag with version number and push it to GitHub

## Examples of usage Toolbox Updater

- [MATLAB WEB API](https://github.com/ETMC-Exponenta/MATLAB-WEB-API)

# Installation

Download and run **Toolbox-Updater.mltbx**

# How to add Updater to your custom toolbox project

- In toolbox project directory create toolbox project file (.prj)
- Upload your project to GitHub
- Run command
``` MATLAB
ToolboxUpdater.init
```
- This will add to project directory: Updater class **...Updater.m**, **ToolboxConfig.xml** with project and Updater info, **dev_on.m** script to activate developer tools
- Add **dev_on.m** to excluded files of your project

# How to use Updater functionality

Create object of your **...Updater.m** class
``` MATLAB
tu = ToolboxUpdater
```
Check internet connection
``` MATLAB
onl = tu.isonline
```
Check installed and latest version
``` MATLAB
tu.ver
```
Check update is available
```
upd = tu.isupdate
```
Update to latest version
``` MATLAB
tu.update
```
Use this functions in your toolbox to provide automatic update check and install.

# How to use Developer functionality

Run **dev_on.m** script
``` MATLAB
dev_on
```
Build .mltbx of specified version, commit, push to GitHub and create tag
``` MATLAB
dev.deploy('0.0.1')
```
Create from tag new release on GitHub page and **attach .mltbx file to it** 