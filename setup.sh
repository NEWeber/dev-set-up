#!/bin/bash

set -euo pipefail

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}"

timestamp() {
  date +"%Y%m%d%H%M%S"
}

log() {
  printf '[setup] %s\n' "$1"
}

prompt_email() {
  local env_var_name="$1"
  local config_path="$2"
  local prompt_message="$3"

  local configured_email=""
  configured_email="$(git config --file "${config_path}" user.email 2>/dev/null || true)"

  local env_email="${!env_var_name:-}"
  if [[ -n "${env_email}" ]]; then
    printf '%s' "${env_email}"
    return 0
  fi

  if [[ -n "${configured_email}" ]]; then
    printf '%s' "${configured_email}"
    return 0
  fi

  if [[ ! -t 0 ]]; then
    log "${env_var_name} is required in non-interactive mode"
    exit 1
  fi

  local input_email=""
  while [[ -z "${input_email}" ]]; do
    read -r -p "${prompt_message}" input_email
  done

  printf '%s' "${input_email}"
}

backup_file() {
  local destination="$1"
  local backup="${destination}.bak.$(timestamp)"
  if [[ -d "${destination}" && ! -L "${destination}" ]]; then
    cp -R "${destination}" "${backup}"
  else
    cp "${destination}" "${backup}"
  fi
  log "Backed up ${destination} -> ${backup}"
}

copy_if_needed() {
  local source="$1"
  local destination="$2"
  local label="$3"

  if [[ ! -f "${source}" ]]; then
    log "Missing ${label} source file: ${source}"
    return 1
  fi

  if [[ -f "${destination}" ]]; then
    if cmp -s "${source}" "${destination}"; then
      log "Skipping ${label}; already up to date at ${destination}"
      return 0
    fi

    if [[ "${FORCE}" == "true" ]]; then
      backup_file "${destination}"
      cp "${source}" "${destination}"
      log "Updated ${label} at ${destination}"
    else
      log "Skipping ${label}; ${destination} already exists (use --force to overwrite)"
    fi
    return 0
  fi

  if [[ -L "${destination}" ]]; then
    if [[ "${FORCE}" == "true" ]]; then
      rm "${destination}"
      cp "${source}" "${destination}"
      log "Replaced symlink for ${label} at ${destination}"
    else
      log "Skipping ${label}; ${destination} is a symlink (use --force to replace)"
    fi
    return 0
  fi

  cp "${source}" "${destination}"
  log "Installed ${label} at ${destination}"
}

install_extensions() {
  local extension_file="$1"

  if ! command -v code >/dev/null 2>&1; then
    log "Skipping VS Code extensions; 'code' command is not available"
    return 0
  fi

  if [[ ! -f "${extension_file}" ]]; then
    log "Skipping VS Code extensions; list not found at ${extension_file}"
    return 0
  fi

  local installed_extensions
  installed_extensions="$(code --list-extensions || true)"

  while IFS= read -r extension || [[ -n "${extension}" ]]; do
    if [[ -z "${extension}" ]]; then
      continue
    fi

    if grep -Fxq "${extension}" <<< "${installed_extensions}"; then
      log "Skipping VS Code extension ${extension}; already installed"
      continue
    fi

    log "Installing VS Code extension ${extension}"
    code --install-extension "${extension}"
  done < "${extension_file}"
}

install_templated_gitconfig() {
  local template_path="$1"
  local destination_path="$2"
  local placeholder="$3"
  local email_value="$4"
  local label="$5"
  local escaped_email="${email_value//&/\\&}"
  escaped_email="${escaped_email//\//\\/}"
  local escaped_placeholder="${placeholder//\//\\/}"

  local temp_file
  temp_file="$(mktemp)"
  sed "s/${escaped_placeholder}/${escaped_email}/g" "${template_path}" > "${temp_file}"
  copy_if_needed "${temp_file}" "${destination_path}" "${label}"
  rm -f "${temp_file}"
}

link_path() {
  local source_path="$1"
  local destination_path="$2"
  local label="$3"

  if [[ ! -e "${source_path}" ]]; then
    log "Missing ${label} source path: ${source_path}"
    return 1
  fi

  mkdir -p "$(dirname "${destination_path}")"

  if [[ -L "${destination_path}" ]]; then
    local target
    target="$(readlink "${destination_path}")"
    if [[ "${target}" == "${source_path}" ]]; then
      log "Skipping ${label}; symlink already points to ${source_path}"
      return 0
    fi

    if [[ "${FORCE}" == "true" ]]; then
      rm "${destination_path}"
      ln -s "${source_path}" "${destination_path}"
      log "Updated ${label} symlink at ${destination_path}"
    else
      log "Skipping ${label}; symlink points elsewhere (use --force to replace)"
    fi
    return 0
  fi

  if [[ -e "${destination_path}" ]]; then
    if [[ "${FORCE}" == "true" ]]; then
      backup_file "${destination_path}"
      rm -rf "${destination_path}"
      ln -s "${source_path}" "${destination_path}"
      log "Linked ${label} at ${destination_path}"
    else
      log "Skipping ${label}; ${destination_path} already exists (use --force to replace)"
    fi
    return 0
  fi

  ln -s "${source_path}" "${destination_path}"
  log "Linked ${label} at ${destination_path}"
}

copy_if_needed "${REPO_ROOT}/git/.gitconfig" "${HOME}/.gitconfig" "main git config"
WORK_EMAIL_VALUE="$(prompt_email "WORK_EMAIL" "${HOME}/.gitconfig-work" "Enter your work email for ~/.gitconfig-work: ")"
install_templated_gitconfig "${REPO_ROOT}/git/.gitconfig-work" "${HOME}/.gitconfig-work" "__WORK_EMAIL__" "${WORK_EMAIL_VALUE}" "work git config"
PERSONAL_EMAIL_VALUE="$(prompt_email "PERSONAL_EMAIL" "${HOME}/.gitconfig-personal" "Enter your personal email for ~/.gitconfig-personal: ")"
install_templated_gitconfig "${REPO_ROOT}/git/.gitconfig-personal" "${HOME}/.gitconfig-personal" "__PERSONAL_EMAIL__" "${PERSONAL_EMAIL_VALUE}" "personal git config"
copy_if_needed "${REPO_ROOT}/bash/.bashrc" "${HOME}/.bashrc" "bash config"
link_path "${REPO_ROOT}/nvim" "${HOME}/.config/nvim" "nvim config"
link_path "${REPO_ROOT}/tmux/tmux.conf" "${HOME}/.config/tmux/tmux.conf" "tmux config"
link_path "${REPO_ROOT}/starship/starship.toml" "${HOME}/.config/starship.toml" "starship config"
mkdir -p "${HOME}/code"
copy_if_needed "${REPO_ROOT}/tmux/tmux-startup.sh" "${HOME}/code/tmux-startup.sh" "tmux startup script"
chmod +x "${HOME}/code/tmux-startup.sh"
copy_if_needed "${REPO_ROOT}/tmux/tmux-startup.config.example.sh" "${HOME}/code/tmux-startup.config.sh" "tmux startup config"

install_extensions "${REPO_ROOT}/vscode/vscode-extensions.txt"

log "Setup complete"
