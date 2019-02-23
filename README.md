# Working with CDO (climate data operators)

Here I'm going to describe how to work with **CDO** if you work with *CMIP5* climatic data

The intention with this info (and scripts) is to provide a basic understanding of how you can use **CDO** to speed-up your **netCDF** file data manipulation. 

[More info go directly to the Max Planck Institute CDO website](https://code.mpimet.mpg.de/projects/cdo/)

[CMIP5 climatic data](https://esgf-node.llnl.gov/projects/esgf-llnl/)

If you work on a **MacOS** Platform this guide is for you. For others operative systems go to:

[Windows](https://code.mpimet.mpg.de/projects/cdo/wiki/Win32)

[Linux](https://code.mpimet.mpg.de/projects/cdo/wiki/Linux_Platform)

Please contact [Isaac Brito-Morales](i.britomorales@uq.edu.au) if you want to use these scripts, or to provide feed-back.

### Installation Process 

#### MacPorts

I couldn't install **CDO** from `homebrew` so I followed the instruction and downloaded **MacPorts**. **MacPorts** is an open-source community initiative to design an easy-to-use system for compiling, installing, and upgrading the command-line on the Mac operating system. 

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

  `cd ~/download/data/` (where my netCDF file is located).
  Check if your file is there with
  `ls -lthr` 
  and then type `ncview EN.4.2.1.f.analysis.g10.196001.nc` to use ncview 

### Using CDO

#### Regridding with CDO

See the [Github repo](https://github.com/IsaakBM/CDO-climate-data-operators-) to access all files.

If you want to regrid and interpolate a **netCDF** file with **CDO**, the easiest way (for me) is create a standard grid with the argument `griddes`.

  Using the `EN.4.2.1.f.analysis.g10.196001.nc` (which has a 1º of spatial resolution) I will create a standard of 1ºx 1º. In the terminal type:
  
  `cdo griddes EN.4.2.1.f.analysis.g10.196001.nc > EN4_grid.gr`
  
  Now you have a new file in your directory called `EN4_grid.gr`. Type `vi EN4_grid.gr` in the terminal to explore your new grid. 
  
  To regrid a **netCDF** file using **CDO** you will have to use the argument `remapbil`, which is the stands for bilinear interpolation. In the   terminal type: 
  
  `cdo remapbil,EN4_grid.gr, EN.4.2.1.f.analysis.g10.196001.nc EN.4.2.1.f.analysis.g10.196001_regrid.nc`
  
  With the first part of the code (`cdo remapbil,EN4_grid.gr,`) you are telling **CDO** to remap your input file using a a bilinear interpolation   based on a standard grid file (previous `EN4_grid.gr`). The second part is your input file that you want to regrid (`EN.4.2.1.f.analysis.g10.196001.nc`) and your *new* regrided file (or output file  = `EN.4.2.1.f.analysis.g10.196001_regrid.nc`)

  **NOTE: In this example I'm regridding the same file, but you can repit the same process for any input file**

#### CDO with multiple input files

The previous "regridding process" works fine if you have one or two **netCDF** files. However, if you have multiple **netCDF** files (which is the most cases of CMIP5 climatic models) the best way to do it is to write a simple *shell* script to iterate the same process for every file.

  Look the components of the shell file `cdo_rg.sh` from the [Github repo](https://github.com/IsaakBM/CDO-climate-data-operators-) 
  
  If you have problems to run the script open the terminal and type: 
  
  `chmod +x cdo_rg.sh`
  
#### CDO annual means, min, max

  `cdo yearmean` calculates the *annual mean* of a monthly data input **netCDF** file
  
  `cdo yearmin` calculates the *annual min* of a monthly data input **netCDF** file
  
  `cdo yearmax` calculates the *annual max* of a monthly data input **netCDF** file
  
  `cdo mergetime` [in progress]

  **NOTE: you can repeat the same process described above for multiple files. See the [Github repo](https://github.com/IsaakBM/CDO-climate-data-operators-) to access the scripts.**
  
  
  





