
## Introduction to Notepad++ Plugin Development with fasm2

This guide provides an introduction to creating plugins for Notepad++ (targeting the latest versions) using the **fasm2** assembler. The goal is to mirror the standard C/C++ plugin interface documented by the Notepad++ project, adapting it for assembly development with minimal conceptual changes. We'll leverage fasm2's capabilities.

Plugins for Notepad++ are standard Win32 DLLs that export specific functions. Notepad++ loads these DLLs and interacts with them through these exported functions. This guide assumes you are using a fasm2 include file that provides default implementations for these exports if you don't define them yourself.


### Minimal Required Exported Functions

Notepad++ interacts with your plugin by calling these functions. You *must* export them by name from your DLL. Their implementation details are critical. Assuming `stdcall` calling convention (standard for Win32 API callbacks).

0.  **`_DllMainCRTStartup`**
    * **Purpose:** This is the *actual* low-level entry point function that the Windows loader calls when the DLL is loaded or unloaded.
    * **Signature:** `BOOL _DllMainCRTStartup(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID)`
    * **Default fasm2 Implementation (Typical Wrapper Behavior):**
        * When not explicitly defined, it simply returns TRUE.

1.  **`setInfo`**
    * **Purpose:** Called by Notepad++ shortly after loading the plugin to provide essential handles.
    * **Signature:** `void setInfo(NppData data)`
    * **Default fasm2 Implementation:**
        * When a custom `setInfo` proc is not defined, the `NppData` structure data is copied to the plugin's global variables. By dereferencing the data to individual variables `g_hNPP`, `g_hScintilla0`, and `g_hScintilla1` usage becomes simplied.

2.  **`getName`**
    * **Purpose:** Called by Notepad++ to retrieve the display name of your plugin, which appears in the Plugins menu, Plugin Admin, etc.
    * **Signature:** `const WCHAR* getName()`
    * **Default fasm2 Implementation:**
        * When a custom `getName` proc is not defined, the default implementation expects a constant, null-terminated **Unicode** string named `PluginNameW` to be defined in your plugin's data section. It returns the address of this string.
    ```asm
    PluginNameW du 'My Awesome fasm2 Plugin',0
    ```

3.  **`getFuncsArray`**
    * **Purpose:** Called by Notepad++ to retrieve the list of menu items (commands) your plugin adds to the Plugins menu.
    * **Signature:** `FuncItem* getFuncsArray(int* nbFunc)`
    * **Default fasm2 Implementation:**
        * Receives one argument: a pointer to an integer. `nbFunc` is an *output* parameter.
        * When a custom `getFuncsArray` proc is not defined, the code generated assume an array of `FuncItem` structures named `CommandItems`. Also, the `sizeof CommandItems` *must* resolve to the number of structures in the array.
            * Array `CommandItems` **must** be in writeable memory.
            * A `FuncItem` entry with a `NULL` (`0`) value for `_pFunc` will be displayed as a separator in the plugin menu - ignoring the structure.
            * Do not set the `_cmdID` field; Notepad++ assigns and manages these internally. Any value you set will be overwritten.
            * The `_pFunc` field (when not `NULL`) must point to a function taking no arguments and returning `void`.

4.  **`beNotified`**
    * **Purpose:** The primary callback for receiving notifications from Notepad++ and the Scintilla editor component about various events (file changes, buffer activation, shutdown, UI events, etc.).
    * **Signature:** `void beNotified(SCNotification* notifyCode)`
    * **Default fasm2 Implementation:**
        * When a custom `beNotified` proc is not defined, the default implementation typically does nothing and simply returns. You *must* provide your own implementation to react to any notifications.

5.  **`messageProc`**
    * **Purpose:** A generic message handling function allowing Notepad++ to send specific messages directly to your plugin, often for queries that require a direct response or actions outside the notification system.
    * **Signature:** `LRESULT messageProc(UINT Message, WPARAM wParam, LPARAM lParam)`
    * **Default fasm2 Implementation:**
        * When a custom `messageProc` proc is not defined, the default implementation typically returns `0`, indicating that the message was not handled. You need to implement this to respond to specific `NPPM_*` messages relevant to your plugin.

6.  **`isUnicode`**
    * **Purpose:** Historically used to indicate if the plugin communicated using Unicode strings. Modern Notepad++ is inherently Unicode.
    * **Signature:** `BOOL isUnicode()`
    * **Default fasm2 Implementation:**
        * When a custom `isUnicode` proc is not defined, the default implementation correctly returns `TRUE`, as required by current Notepad++ versions. Overriding this is generally unnecessary.
