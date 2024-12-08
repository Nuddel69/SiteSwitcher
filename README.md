# SiteSwitcher

A CLI tool for managing, building, and deploying static Vite applications to a local Apache server.

<!--toc:start-->

- [SiteSwitcher](#siteswitcher)
  - [Overview](#overview)
  - [Usage](#usage)
    - [Running the Script](#running-the-script)
    - [Main Menu Options](#main-menu-options)
  - [Configuration](#configuration)
    - [Required Directory Structure](#required-directory-structure)
    - [Constants](#constants)
  - [Dependencies](#dependencies)
  - [Installation](#installation)
    - [Making the Script Executable](#making-the-script-executable)
  - [Troubleshooting](#troubleshooting)
  <!--toc:end-->

## Overview

SiteSwitcher is a tool for handling multiple projects within a development environment, managing the update, build, and deployment processes for static sites. SiteSwitcher enables easy switching between projects, updating from remote repositories, building with npm, and deploying to a local Apache server.

This tool is intended for environments where multiple projects need to be managed on a single server, making it especially useful for developers managing multiple static websites.

## Usage

### Installation

Install the script by cloning the github repo:

```bash
git clone https://github.com/Nuddel69/SiteSwitcher.git && cd SiteSwitcher
```

### Running the Script

To execute the script, ensure it has the correct permissions and then run it directly:

```bash
chmod +x switcher.sh
./switcher.sh
```

### Main Menu Options

Upon launching, the SiteSwitcher script presents a main menu with the following options:

1. **Update the Current Project**: Updates the currently deployed project by pulling the latest code from the remote repository (if available), running `npm install` to install dependencies, and building the project with `npm run build`. The build output is then copied to the Apache server directory.
2. **Change Deployed Project**: Allows the user to select a different project from the list in the `TARGET_DIR`. After selecting, it will run the build and deployment steps.

3. **Add a New Project**: Prompts the user to enter a Git repository URL, clones it into the `TARGET_DIR`, and returns to the main menu. This option supports adding new projects from remote repositories for easy deployment.

4. **List Remote Branches**: Lists all branches for the currently deployed project (if it’s a Git repository), allowing the user to view available branches on the remote repository.

5. **Exit**: Exits the program.

## Configuration

SiteSwitcher requires the following directory structure and constants to be correctly set up.

### Required Directory Structure

1. **`TARGET_DIR`**: This is the main directory where all your projects are stored. Each project should have its own subdirectory within `TARGET_DIR`.

2. **`SITE_ROOT`**: This directory serves as the root location for deployment. The build output of each selected project will be copied here, effectively deploying the site.

Example structure:

```
/home/user/sites/
├── project1/
├── project2/
└── .current_deployed
/home/user/site/
```

### Constants

The following constants should be set within the script to define target and deployment directories:

- `TARGET_DIR`: Points to the location of all project directories.
- `SITE_ROOT`: Defines the Apache server’s root directory where builds are deployed.
- `.current_deployed`: A hidden file in `TARGET_DIR` that stores the name of the currently deployed project.

## Dependencies

SiteSwitcher relies on several system-level tools and packages. Ensure these are installed and accessible in your environment:

1. **Git**: Required for cloning and updating projects stored in remote repositories.
   - Install Git: `sudo apt install git`
2. **Node.js and npm**: Required for building the Vite projects. SiteSwitcher uses `npm install` to handle dependencies and `npm run build` to build the project.

   - Install Node.js and npm: `sudo apt install nodejs npm`

3. **Apache**: SiteSwitcher deploys projects to an Apache server by copying built files to `SITE_ROOT`.
   - Install Apache: `sudo apt install apache2`
   - Configure a server. See the [official docs](https://httpd.apache.org/docs/2.0/) for more info.

## Troubleshooting

1. **Git Update Failures**: If the Git pull fails during an update, the script will prompt you to continue or cancel the deployment. Ensure that:

   - The network connection is stable.
   - Correct permissions are set on `TARGET_DIR`.
   - Git is correctly installed and accessible.

2. **Build Errors**: If the `npm run build` step fails, make sure that:

   - All dependencies in `package.json` are compatible with your environment.
   - Node.js and npm are up-to-date.
   - If the error persists, try clearing the `node_modules` folder and rerunning `npm install`.

3. **Deployment Issues**: If files don’t appear in `SITE_ROOT`, check that:
   - Apache is installed and configured to serve files from `SITE_ROOT`.
   - Correct permissions are set on `SITE_ROOT`.
   - There are no conflicts between projects sharing `SITE_ROOT`.

---
