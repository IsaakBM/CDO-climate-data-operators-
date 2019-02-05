# Working with CDO (climate data operators)

Here I'm going to describe how to work with **CDO** if you work with *CMIP5* climatic data

The intention with this info (and scripts) is to provide a basic undersantig of how you can use **CDO** to speed-up your **netCDF** file data manipulation. 

[More info go directly to the Max Planck Institute CDO website](https://code.mpimet.mpg.de/projects/cdo/)

If you work on a **MacOS** Platform this guide is for you. For others operative systems go to:

[Windows](https://code.mpimet.mpg.de/projects/cdo/wiki/Win32)

[Linux](https://code.mpimet.mpg.de/projects/cdo/wiki/Linux_Platform)



### Installation Process 

#### MacPorts

I couldn't install **CDO** from `homebrew` so I followed the instruction and downloaded MacPorts. **MacPorts** is an open-source community initiative to design an easy-to-use system for compiling, installing, and upgrading the command-line on the Mac operating system. 

[MacPorts website](https://www.macports.org/index.php)

[MacPorts download](https://www.macports.org/install.php)

After the installation (if you have admin rights) open the terminal and type:

  `port install cdo`

If you don't have admin rights, open the terminal and type:

  `sudo port install cdo` and write your password

#### Ncview: a netCDF visual browser

Browsing and browsing, I found a quick visual browser that allows you to explore **netCDF** files very easily: `ncview` 

[Ncview info here](http://meteora.ucsd.edu/~pierce/ncview_home_page.html)

To install **ncview**, open the terminal and type:

  `port ncview`
  
To use `ncview` open the terminal and type:

  `cd /download/data/` (where my netCDF file is located).
  Check if your file it is there with
  `ls -lthr` 
  and then type `ncview EN.4.2.1.f.analysis.g10.196001.nc` to use ncview 

### Using CDO

**Lets get started**



