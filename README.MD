# Powershell find and delete duplicate files

>Attention! This script deletes files! Use only at your own risk! I do not take any responsibility! Only use the script if you understand what it is doing. 

## how to use

There are two scripts. The first one is  ``getInventur.ps1``. The script ask you for folder to scan, and make an inventur of Files with MD5 cheksum. The inventure is then stored on ``.\All-Files-With-Hashes.csv``. On second csv names ``.\All-Duplicate-Files.csv`` you find all duplicate files. 

```powershell
.\getInventur.ps1
```

The second script ``.\deleteDuplicateFiles.ps1`` open a form where you can choose options.

1. check
    + checks the All-Duplicate-Files.csv and mark the files to delete on several options
        + selsect by createdate
        + select by last write date
        + select (leve) only the first findet file

2. move
    + ask you for the Backupfolder and move the tiles selected to delete in this folder

3. delete
    + delete your to delete selected files 
        + into recycle-bin
        + permanent (not implement yet)

3. delete empty folder
    + scan selected folder for empty subfolder and delete them into recycle bin



```powershell
.\deleteDuplicateFiles.ps1
```


>it is strongly recomendet to make a Backup first!

``
2021.04.03 (c) Vitaly Ruhl
``