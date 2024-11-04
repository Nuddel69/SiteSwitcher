#!/bin/bash

YELLOW="\033[1;33m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

TARGET_DIR="$HOME/sites"
SITE_ROOT="$HOME/site"
CURRENT_DEPLOY_FILE="$TARGET_DIR/.current_deployed"

function main_menu() {
  clear
  printf "${CYAN}--- Main Menu ---${RESET}\n"
  if [[ -f "$CURRENT_DEPLOY_FILE" ]]; then
    current_deployed=$(cat "$CURRENT_DEPLOY_FILE")
    printf "${GREEN}Current deployed project: ${current_deployed##*/}${RESET}\n"
  else
    printf "${YELLOW}No project is currently deployed.${RESET}\n"
    current_deployed=""
  fi

  printf "1. Update the currently deployed project\n"
  printf "2. Change the deployed project\n"
  printf "3. Add a new project by cloning a Git repository\n"
  printf "4. List remote branches (for the deployed project)\n"
  printf "5. Exit\n"

  printf "${YELLOW}Enter your choice: ${RESET}"
  read -r main_choice

  case $main_choice in
  1)
    if [[ -z "$current_deployed" ]]; then
      printf "${RED}No project is currently deployed.${RESET}\n"
      sleep 2
      main_menu
    else
      deploy_project "$current_deployed"
    fi
    ;;
  2)
    select_directory
    ;;
  3)
    clone_new_project
    ;;
  4)
    list_remote_branches
    ;;
  5)
    printf "${CYAN}Goodbye!${RESET}\n"
    exit 0
    ;;
  *)
    printf "${RED}Invalid option. Try again.${RESET}\n"
    sleep 2
    main_menu
    ;;
  esac
}

function select_directory() {
  clear
  printf "${CYAN}--- Select a Project Directory ---${RESET}\n"

  dirs=($(find "$TARGET_DIR" -maxdepth 1 -mindepth 1 -type d))
  if [[ ${#dirs[@]} -eq 0 ]]; then
    printf "${YELLOW}No directories found in $TARGET_DIR.${RESET}\n"
    return
  fi

  for i in "${!dirs[@]}"; do
    printf "${GREEN}$((i + 1)). ${dirs[$i]##*/}${RESET}\n"
  done

  printf "${YELLOW}Enter the number of your choice: ${RESET}"
  read -r choice

  if [[ "$choice" -ge 1 && "$choice" -le ${#dirs[@]} ]]; then
    selected_dir="${dirs[$((choice - 1))]}"
    deploy_project "$selected_dir"
  else
    printf "${RED}Invalid selection. Returning to main menu.${RESET}\n"
    sleep 2
    main_menu
  fi
}

function clone_new_project() {
  printf "${YELLOW}Enter the Git repository URL to clone: ${RESET}"
  read -r git_url

  if [[ -z "$git_url" ]]; then
    printf "${RED}No URL provided. Returning to main menu.${RESET}\n"
    sleep 2
    main_menu
  fi

  cd "$TARGET_DIR" || exit 1
  if git clone "$git_url"; then
    new_project_name=$(basename "$git_url" .git)
    new_project_dir="$TARGET_DIR/$new_project_name"
    printf "${GREEN}Project cloned successfully!${RESET}\n"
    deploy_project "$new_project_dir"
  else
    printf "${RED}Failed to clone the repository. Check the URL and try again.${RESET}\n"
    sleep 2
    main_menu
  fi
}

function deploy_project() {
  local wd="$1"
  printf "${CYAN}Deploying project: ${wd##*/}${RESET}\n"

  cd "$wd" || {
    printf "${RED}Failed to navigate to $wd.${RESET}\n"
    exit 1
  }

  if [[ -d .git ]]; then
    printf "${YELLOW}Pulling latest updates from git...${RESET}\n"
    if ! git pull; then
      printf "${RED}Git pull failed.${RESET}\n"
      printf "${YELLOW}Do you want to continue with the deployment anyway? (y/n): ${RESET}"
      read -r continue_choice
      if [[ "$continue_choice" != "y" ]]; then
        printf "${RED}Deployment aborted.${RESET}\n"
        sleep 2
        main_menu
      fi
    else
      printf "${GREEN}Git pull successful.${RESET}\n"
    fi
  fi

  printf "${YELLOW}Installing dependencies...${RESET}\n"
  if npm install; then
    printf "${GREEN}Dependencies installed successfully.${RESET}\n"
  else
    printf "${RED}npm install failed.${RESET}\n"
    exit 1
  fi

  printf "${YELLOW}Building the project...${RESET}\n"
  if npm run build; then
    printf "${GREEN}Build succeeded.${RESET}\n"
  else
    printf "${RED}Build failed. Please check the error log above.${RESET}\n"
    exit 1
  fi

  printf "${YELLOW}Clearing ${SITE_ROOT}...${RESET}\n"
  rm -rf ${SITE_ROOT}/*

  printf "${YELLOW}Copying build files to ${SITE_ROOT}...${RESET}\n"
  if cp -r dist/* "$SITE_ROOT"; then
    printf "${GREEN}Files copied successfully to $SITE_ROOT.${RESET}\n"
    printf "%s" "$wd" >"$CURRENT_DEPLOY_FILE" # Update current deployment only if successful
  else
    printf "${RED}Failed to copy files to $SITE_ROOT.${RESET}\n"
    exit 1
  fi

  printf "${CYAN}Deployment completed successfully!${RESET}\n"
}

function list_remote_branches() {
  if [[ -f "$CURRENT_DEPLOY_FILE" ]]; then
    current_deployed=$(cat "$CURRENT_DEPLOY_FILE")
    cd "$current_deployed" || {
      printf "${RED}Cannot access current project directory.${RESET}\n"
      return
    }

    if [[ -d .git ]]; then
      printf "${YELLOW}Fetching remote branches...${RESET}\n"
      git fetch --all
      printf "${GREEN}Available branches:${RESET}\n"
      git branch -r | sed 's/origin\///'
    else
      printf "${RED}The currently deployed project is not a Git repository.${RESET}\n"
    fi
  else
    printf "${RED}No project is currently deployed.${RESET}\n"
  fi
  printf "${YELLOW}Press Enter to return to the main menu.${RESET}"
  read -r
  main_menu
}

main_menu
