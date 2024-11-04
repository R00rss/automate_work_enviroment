#!/bin/bash

# Obtener el directorio en el que se encuentra el script
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

# Cargar archivo de configuración de repositorios
source "$SCRIPT_DIR/repositories.env"

# Función para clonar un repositorio
clone_repo() {
  local repo_url=$1
  local branch=$2
  echo "Cloning $repo_url"
  echo "With branch $branch"
  git clone "$repo_url" --branch "$branch"
}

# Función para seleccionar el directorio de destino
select_path() {
  read -p "Select a path: " path
  echo "Path selected: $path"
  # Check if path exists
  if [ -d "$path" ]; then
    echo "Path already exists"
    echo "Do you want to overwrite it? (y/n)"
    read -p "(y/n): " answer
    if [ "$answer" != "y" ]; then
      echo "Bye"
      exit 0
    fi
    rm -rf "$path"
    mkdir "$path"
  else
    mkdir "$path"
  fi
}

# Función para listar y seleccionar una rama
get_branch_selected() {
  local selected_branch=""
  local repo_url=$1

  echo >&2 "Available branches:"
  local branches=($(git ls-remote --heads "$repo_url" | awk '{print $2}' | sed 's|refs/heads/||'))

  for i in "${!branches[@]}"; do
    echo >&2 "$((i + 1))) ${branches[$i]}"
  done

  read -p "Select a branch by number: " branch_number
  selected_branch="${branches[$((branch_number - 1))]}"
  echo "$selected_branch"
}

# Función principal del programa
init_enviroment() {
  echo "1) Download Frontend"
  echo "2) Download Backend"
  echo "3) Both"
  echo "4) Exit"

  read -p "Select an option 1, 2, 3 or 4: " option

  case $option in
  1)
    branch=$(get_branch_selected "$url_repo_frontend")
    echo "Branch selected: $branch"
    clone_repo "$url_repo_frontend" "$branch"
    ;;
  2)
    branch=$(get_branch_selected "$url_repo_backend")
    echo "Branch selected: $branch"
    clone_repo "$url_repo_backend" "$branch"
    ;;
  3)
    branch=$(get_branch_selected "$url_repo_frontend")
    echo "Branch selected: $branch"
    clone_repo "$url_repo_frontend" "$branch"
    branch=$(get_branch_selected "$url_repo_backend")
    echo "Branch selected: $branch"
    clone_repo "$url_repo_backend" "$branch"
    ;;
  *)
    echo "Bye"
    exit 0
    ;;
  esac
}

# Ejecutar el menú
init_enviroment
