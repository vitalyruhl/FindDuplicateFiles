

<p align="center">
  <br />
  <a title="Intouch-Language" href="https://github.com/vitalyruhl/intouch-language"><img src="https://raw.githubusercontent.com/vitalyruhl/FindDuplicateFiles/master/images/logo.png" alt="Vivil - Vitaly Ruhl Logo" width="10%" /></a>
</p>


# Powershell script to find and/or delete duplicate files

>**Attention! This script can deletes files! Use only at your own risk! Only use the script if you understand what it is doing.** 

## how to use

There are two scripts. The first one is  ``getInventur.ps1``. The script ask you for folder to scan, and make an inventur of Files with MD5 cheksum. The inventure is then stored on ``.\All-Files-With-Hashes.csv``. On second csv names ``.\All-Duplicate-Files.csv`` you find all duplicate files. 

```powershell
.\getInventur.ps1
```

The second script ``.\deleteDuplicateFiles.ps1`` open a form where you can choose some options.

1. check
    + checks the All-Duplicate-Files.csv and mark the files to delete on several options
        + selsect by createdate
        + select by last write date
        + select (leve) only the first findet file

2. move
    + it ask you for the Backupfolder, and move the files selected to delete in this folder with Folder-Structure

3. delete
    + remove your to delete selected files 
        + into recycle-bin
        + permanent (not implement yet - todo)

3. delete empty folder
    + scan selected folder for empty subfolder and delete them into recycle bin

```powershell
.\deleteDuplicateFiles.ps1
```


>**it is strongly recomendet to make a Backup first!**

- - -

<table align="center" width="100%" border="0" bgcolor:=#3f3f3f>
  <tr>
    <td align="center" width="100%" border="0" >
      <form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
      <input type="hidden" name="cmd" value="_s-xclick" />
      <input type="hidden" name="hosted_button_id" value="Q3XSPVFAPSKMJ" />
      <input type="image" src="https://www.paypalobjects.com/de_DE/DE/i/btn/btn_donateCC_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Spenden mit dem PayPal-Button" />
      <img alt="" border="0" src="https://www.paypal.com/de_DE/i/scr/pixel.gif" width="1" height="1" />
      </form>
    </td>
    <td align="center" width="100%" border="0" >
      <a href="https://www.patreon.com/bePatron?u=53385633" data-patreon-widget-type="become-patron-button">Become a Patron!</a><script async src="https://c6.patreon.com/becomePatronButton.bundle.js"></script>
    </td>
  </tr>
</table>

- - - 

``
2021.04.04 (c) Vitaly Ruhl
``