# autoindex_php_script_assimilator

## What is it?
Did you ever wanted to download directory hosted via http://autoindex.sourceforge.net/
Now you can do it easily with possibility to continue later and without hassle.

## Requirements
There are some prerequisities:
* You need Ruby (tested on ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-darwin14])
* You need `wget` installed
* gem install mechanize

## Usage
```
ruby autoindex_php_script_assimilator.rb "http://pliki.majselbaum.pl/index.php?dir=" "http://pliki.poczytajmimako.pl/index.php?dir="
```
