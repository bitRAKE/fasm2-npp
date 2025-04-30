
## Introduction to PerFileWrap for Notepad++

**What is it?**

PerFileWrap is a simple plugin for Notepad++ that changes how the "Word Wrap" feature behaves.

**The Problem:**

Normally, when you turn "Word Wrap" on or off (`View -> Word Wrap`), Notepad++ applies that setting to *all* the files you have open. If you want wrap enabled for one file but disabled for another, you have to keep switching the setting back and forth globally.

**The Solution:**

This plugin makes Notepad++ remember the Word Wrap setting **individually for each file**. You can set one file to wrap text and another file to not wrap text, and Notepad++ will remember your choice for each file as you switch between tabs.

**Features:**

* Remembers the `View -> Word Wrap` setting on a per-file basis.
* Updates the checkmark next to `View -> Word Wrap` automatically when you switch files to show the *current* file's setting.
* Adds an option in the Plugins menu (`Plugins -> PerFileWrap -> Enable Per-File Wrap`) that allows you to easily turn the plugin's special behavior on or off without restarting Notepad++.

## Installation Instructions

Follow these steps carefully to install the plugin:

1.  **Get the Correct Plugin File:** You need the compiled plugin file, which will likely be named `PerFileWrap.dll`.

2.  **Find Notepad++ Installation Folder:** You need to locate where Notepad++ is installed on your computer. Common locations are:
    * 64-bit: `C:\Program Files\Notepad++`
    * *Easy way to find it:* Right-click on your Notepad++ shortcut (on the Desktop or Start Menu), click `Properties`, then click the `Open File Location` button.

3.  **Open the `plugins` Folder:** Inside the Notepad++ installation folder, find and open the folder named `plugins`.

4.  **Create Plugin Folder:** Inside the `plugins` folder, create a **new folder** named exactly: `PerFileWrap` -- same as the `DLL` name.

5.  **Copy the Plugin DLL:** Copy the `PerFileWrap.dll` file and paste it **inside** the `PerFileWrap` folder you just created.
    * The final location should look something like: `C:\Program Files\Notepad++\plugins\PerFileWrap\PerFileWrap.dll`

6.  **Restart Notepad++:** Close Notepad++ completely (make sure all its windows are closed) and then open it again.

7.  **Verify Installation:** Click on the `Plugins` menu in Notepad++. You should now see an entry named `PerFileWrap`. Inside that, you'll find the `Enable Per-File Wrap` option. If you see this, the plugin is installed!

## Usage

* To turn the per-file wrap behavior on or off, go to `Plugins -> PerFileWrap` and click `Enable Per-File Wrap`. A checkmark next to it means the plugin is active.
* When the plugin is **enabled** (checkmark is visible), the `View -> Word Wrap` menu item will now only affect the file you are currently viewing. Notepad++ will remember this setting when you switch to other files and back again.
* When the plugin is **disabled** (no checkmark), Notepad++ will go back to its default behavior where `View -> Word Wrap` affects all open files globally.

## Uninstallation

1.  Close Notepad++ completely.
2.  Go back to your Notepad++ installation folder, then into the `plugins` folder.
3.  Delete the entire `PerFileWrap` folder (which contains the `PerFileWrap.dll` file).
4.  Start Notepad++ again. The plugin will be gone.
