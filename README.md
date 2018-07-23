# R package {bigreadr}

Read large text files based on splitting + `data.table::fread`


## Command 'split'

Splitting is the strategy used by this package to read large text files.
For splitting, system command 'split' is used. 
This command should be available by default on Unix-like systems.

For Windows users, you can [download CoreUtils](https://sourceforge.net/projects/gnuwin32/files/coreutils/5.3.0/coreutils-5.3.0.exe/download) (and install it) to get a similar command.
Then, you'll have to supply the path to this command as argument `split` in functions of this package.
For example, on my Windows computer, this command is installed there: `C:\\Program Files (x86)\\GnuWin32/bin/split.exe`.
