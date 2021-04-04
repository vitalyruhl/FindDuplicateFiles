<p align="center">
  <br />
  <a title="Intouch-Language" href="https://github.com/vitalyruhl/FindDuplicateFiles"><img src="https://raw.githubusercontent.com/vitalyruhl/FindDuplicateFiles/master/images/logo.jpg" alt="Vivil - Vitaly Ruhl Logo" width="30%" /></a>
</p>

# Powershell script to find and/or delete duplicate files

> Explizit in Windows Powershell - it allow you run the script on all modern windows computer, withot installing/import anything.

> **Attention! This script can deletes files! Use only at your own risk! Only use the script if you understand what it is doing.**

## how to use

There are two scripts. The first one is `getInventur.ps1`. The script ask you for folder to scan, and make an inventur of Files with MD5 cheksum. The inventure is then stored on `.\All-Files-With-Hashes.csv`. On second csv names `.\All-Duplicate-Files.csv` you find all duplicate files.

---

in first use, you need allow scriptececution by policy.
run Powershel as Administrator, and type:

```powershell
set-executionpolicy remotesigned
```

---

Start the script -> go to the script folder and type:

```powershell
.\getInventur.ps1
```

---

The second script `.\deleteDuplicateFiles.ps1` open a form where you can choose some options.

1. check

   - checks the All-Duplicate-Files.csv and mark the files to delete on several options
     - selsect by createdate
     - select by last write date
     - select (leve) only the first findet file

2. move

   - it ask you for the Backupfolder, and move the files selected to delete in this folder with Folder-Structure

3. delete

   - remove your to delete selected files
     - into recycle-bin
     - permanent (not implement yet - todo)

4. delete empty folder
   - scan selected folder for empty subfolder and delete them into recycle bin

```powershell
.\deleteDuplicateFiles.ps1
```

> **it is strongly recomendet to make a Backup first!**

---


## Donate

<table align="center" width="100%" border="0" bgcolor:=#3f3f3f>
  <tr>
    <td align="center" width="100%" border="0" >
    
i       f you prefer a one-time donation:
      <form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
      <input type="hidden" name="cmd" value="_s-xclick" />
      <input type="hidden" name="hosted_button_id" value="Q3XSPVFAPSKMJ" />
      <input type="image" src="https://www.paypalobjects.com/de_DE/DE/i/btn/btn_donateCC_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Spenden mit dem PayPal-Button" />
      <img alt="Paypal" border="0" src="https://www.paypal.com/de_DE/i/scr/pixel.gif" width="1" height="1" />
      </form>
    </td>
    <td align="center" width="100%" border="0" >  
        Become a patron, by simply clicking on this button (**very appreciated!**):
        [![](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/join/6555448/checkout?ru=undefined)
    </td>
  </tr>
</table>

---
## Copyright
`2021.04.04 (c) Vitaly Ruhl`

License: GNU General Public License v3.0