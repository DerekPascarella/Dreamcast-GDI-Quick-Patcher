# Dreamcast GDI Quick Patcher
A utility for easily applying region-free and VGA patches to a Dreamcast GDI.

It accepts TOSEC-style GDIs as input, with support for 2352 bytes per sector BIN data tracks and 2048 bytes per sector ISO data tracks.

## Current Version
Dreamcast GDI Quick Patcher is currently at version [1.1](https://github.com/DerekPascarella/Dreamcast-GDI-Quick-Patcher/releases/download/1.1/gdi_quick_patcher.exe).

## Changelog
- **Version 1.1 (2024-10-09)**
    - Added ability to choose between region-free/VGA patching, or both.
    - Refactored and optimized code.
- **Version 1.0 (2024-10-08)**
    - Initial release.

## Usage
Drag a `.gdi` file onto `gdi_quick_patcher.exe`.

![Usage](https://github.com/DerekPascarella/Dreamcast-GDI-Quick-Patcher/blob/main/drag.gif?raw=true)

Alternatively, use PowerShell or Command Prompt to execute the utility and pass the full path of the `.gdi` as the first argument.

```
gdi_quick_patcher.exe Z:\path\to\disc.gdi
```

Next, the user is prompted to choose which patches to apply (i.e., region-free, VGA, or both).

![Selecting Patches](https://github.com/DerekPascarella/Dreamcast-GDI-Quick-Patcher/blob/main/use.gif?raw=true)
