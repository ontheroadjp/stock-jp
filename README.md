# Stock JP

## Overview

Stock JP is a shell script that allows users to search for information about Japanese stocks on various financial websites. Users can choose the stock they are interested in and select which financial website they want to view the information on. The script then opens the selected website in a web browser.

## Getting Started

To use Stock JP, simply download the `stock-jp.sh` script and make it executable. Then run the script with appropriate options to search for stock information. Note that after running `./stock-jp.sh --update`, you need to manually convert the downloaded `.xls` file to a `.csv` file.

## Operating Environment

Stock JP requires the following dependencies to be installed:

- Bash shell
- curl
- peco
- nkf
- column
- sed
- open (on macOS)

## Usage

```
Usage: stock-jp [OPTIONS] FILE

Search a security in stock market Tokyo@japan.

Options:
  -h, --help                      Show help
  -v, --version                   Show script version
      --update                    Update stock data 
      --verbose                   Print various logging information
```

## Example

Search for stock information and view it on Yahoo! Finance:

```
$ ./stock-jp.sh
```

Update stock data:

- Note: Manually convert the downloaded .xls file to .csv

```
$ ./stock-jp.sh --update
```
