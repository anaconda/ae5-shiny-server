# Adding Shiny Server support to AE5.6 (WIP)

This repository allows AE5 customers to install [Shiny
Server](https://github.com/rstudio/shiny-server) and use it within
AE5. The approach used here tried to follow a similiar approach as used
to install [RStudio](https://github.com/Anaconda-Platform/ae5-rstudio).

Auxiliary tools such as RStudio, VSCode, or Zeppelin are installed into
a shared volume provisioned just for this purpose. If Shiny Server is
the first tool being installed, those instructions will need to be
followed first. See the document
[TOOLS.md](https://github.com/Anaconda-Platform/ae5-rstudio/blob/master/TOOLS.md)
for more details, and make sure that work is completed before proceeding
with the instructions here.

## Installation

We have broken the installation process into the following steps:

1. Set the tool volume to read-write. (5.5.1 only).
2. Launch the Shiny Server installation project.
3. Obtain the Shiny Server server binaries.
4. Run the installation script.


### Step 1. Set the tool volume to read-write (5.5.1)

These instructions are identical to the Step 1 [instructions
here](https://github.com/Anaconda-Platform/ae5-rstudio#step-1-set-the-tool-volume-to-read-write-551)

***5.5.2+:*** skip this step and proceed directly to step 2.

1. Edit the `anaconda-platform.yml` ConfigMap. On Gravity clusters,
   this is most easily performed in the Ops Center.
2. Search for the `/tools:` volume specification.
3. Change `readOnly: true` to `readOnly: false`.
4. Save the changed ConfigMap. If possible, *leave the editor open*;
   you will be making more changes here in Step 5 and Step 7. 
5. Open a terminal window with `kubectl` access to the cluster,
   and restart the workspace pod:

   ```
   kubectl get pods | grep ap-workspace | cut -d ' ' -f 1 | xargs kubectl delete pod
   ```

6. Monitor the new workspace pod using `kubectl get pods` and
   wait for it to stabilize. *Leave this terminal window open
   as well*, as you will use it in Step 5 and Step 

### Step 2. Launch the Shiny Server installer project

As mentioned above, installation will proceed from within a standard
AE5 session. So to begin the process, we complete the following steps:

1. ***5.5.2+:*** log into AE5 as the 
   storage manager user, typically `anaconda-enterprise`.
   This is the user that is given read-write access to the
   `/tools` volume.
2. Download the installer project and save it to the machine
   from which you are accessing AE5. A link is provided
   in the top section of this document.
3. In a new browser window, log into AE5, and use the
   "Create+ / Upload Project" dialog to upload the Shiny Server
   Installation project archive that has been provided to you.
4. We recommend using the JupyterLab editor for this project. To
   change this, click on the project's name to be taken to the settings
   page, change the Default Editor, and Save.
5. Launch a session for this project.


### Step 3. Obtain the Shiny Server binaries

The files we need to install Shiny Server are RPM files hosted on the
site `download3.rstudio.org`, and these must be pulled into the project
session.  Below are three different methods for accomplishing this.

[ TODO: ONLY ONE METHOD CURRENTLY DESCRIBED ]

#### Downloading Shiny Server directly from AE5

If your cluster has a direct connection to the internet, this is
definitely the best approach.

1. Launch a terminal window in the session created in Step 2.
2. If you need to set proxy variables manually in order to
   access the internet, do so now.
3. Run the command `bash download_shiny_server.sh`

If the script completes successfully, you will have the binaries
you need to proceed to step 4. The output of the script will
look something like this:

```
+-----------------------------+
| AE5 Shiny Server Downloader |
+-----------------------------+
- Target version: 1.5.20.1002
- Downloading into the data directory
- Downloading CentOS7 RPM file to data/ss-centos7.rpm
- URL: https://download3.rstudio.org/centos7/x86_64/shiny-server-1.5.20.1002-x86_64.rpm
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 65.6M  100 65.6M    0     0  98.9M      0 --:--:-- --:--:-- --:--:-- 98.9M
- Verifying data/ss-centos7.rpm
+------------------------+
The Shiny Server binaries have been downloaded.
You may now proceed with the installation step.
See the README.md file for more details.
+------------------------+
```

### Step 4. Run the installation script

Once the file `ss-centos7.rpm` is in place, the actual installation can proceed.

1. Launch a terminal window, or return to an existing one.
2. If you have previously installed content into `/tools/shiny-server`,
   remove it now. The script will not proceed if there is any
   content in that directory. For simplicity, you can remove
   the entire directory; e.g., `rm -r /tools/shiny-server`.
3. Run the command `bash install_shiny_server.sh`. Before performing
   any modifications, the script verifies that all of its
   prerequisites are met.

### Step 5. Usage

In your AE5 project, add `ae5_shiny_server` to the `packages` list and
`jlstevens` to the `channels` list. Then when this package is installed,
you will have access to the `ae5_shiny_server` command which you can use
in a `unix` command.

Here is a simple example of a suitable `anaconda-project.yml`:


```yaml
name: Example

description: Example that runs Shiny server in an R environment

packages:
  - r-base
  - r-argparse
  - r-shiny
  - ae5_shiny_server

platforms:
  - linux-64
  
commands:
  default:
    unix: shiny_server

env_specs:
  default: {}
  
channels:
  - r
  - jlstevens
```

For more information about the `shiny_server` command, run `shiny_server
--help` in the terminal.