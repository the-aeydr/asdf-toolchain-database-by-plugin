#!/usr/bin/env bash
set -euo pipefail

## ------------
## Constants

curl_opts=(-sSL)
: ${VERBOSE:=""} # Verbosity

## ------------
## Filesystems

plugin_dir="$(dirname "$(dirname "$current_script_path")")"
tool_name="$(basename $plugin_dir)"
tools_dir="$plugin_dir/tools/$tool_name"

## ------------
## ASDF Interface

list_all_versions() {
  # List all available versions of the tool for
  # installation 

  list_tool_versions "$tools_dir"
}

download_release() {
  # Download the toolchain release for a given version.
  #
  # Based on the tool, version, platform and architecture, a file
  # defining where to retrieve the file will be selected. This will
  # then be used to download the release.
  #
  # Requires the following tools:
  # - sha256sum
  # - curl
  # - zip (if image is zip)
  local version
  version="$1"

  if ! command -v sha256sum &> /dev/null
  then
      echo "asdf-plugin-toolchains requires sha256sum to be installed"
      exit 55
  fi

  local -r platform="$(get_platform)"
  local -r arch="$(get_arch)"
  local -r toolfile="$(get_http_file "$version" "$platform" "$arch")"
  log "Reading toolchain data from $toolfile"

  local -r http_url="$(read_url_from_file "$toolfile")"
  local -r sha256="$(read_sha256_from_file "$toolfile")"
  local -r flags="$(read_flags_from_file "$toolfile")"
  local -r filename="$ASDF_DOWNLOAD_PATH/$(basename "$http_url")"
  log "Downloading $tool_name for $version from $http_url"
  curl "${curl_opts[@]}" -o "$filename" -C - "$http_url" || fail "Could not download $http_url"

  log "Downloaded file to $filename, checking for $sha256"
  echo "$sha256 $filename" | sha256sum --check --quiet

  if tar tf "$filename" 2> /dev/null 1>&2; then
    log "Extracting package $filename as tar with flags [$flags]"
    tar -x$(verbose)f "$filename" -C "$ASDF_DOWNLOAD_PATH" $flags || fail "Could not extract $filename"
  else
    log "Checking if unzip is installed and accessible in PATH"
    if ! command -v unzip &> /dev/null
    then
        echo "asdf-plugin-toolchains requires unzip to be installed for zip packages"
        exit 75
    fi
    log "Extracting package $filename as zip"
    unzip -q "$filename" -d "$ASDF_DOWNLOAD_PATH"
  fi
  rm "$filename"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$tool_name supports release installs only"
  fi

  (
    mkdir -p "$install_path" 2>&1 &> /dev/null
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

    local tool_cmd
    tool_cmd="$(echo "$tool_name" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$tool_name $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $tool_name $version."
  )
}

## ------------
## Utilities

read_url_from_file() {
  local toolfile
  toolfile="$1"

  echo "$(awk -F "=" '/http_url/ {print $2}' "${toolfile}")"
}

read_sha256_from_file() {
  local toolfile
  toolfile="$1"

  echo "$(awk -F "=" '/sha256/ {print $2}' "${toolfile}")"
}

read_flags_from_file() {
  local toolfile
  toolfile="$1"

  echo "$(awk -F "=" '/flags/ {$1=""; print $0;}' "${toolfile}")"
}

# List all of the version directories for a given tool directory
get_http_file() {
  local version platform arch
  version="$1"
  platform="$2"
  arch="$3"

  echo "$plugin_dir/tools/$tool_name/$version/$platform/$arch/http.ini"
}

# List all of the version directories for a given tool directory
list_tool_versions() {
  local directory
  directory="$1"

  ls -d "$directory"/*/ | xargs -L1 basename
}

# Retrieve the operating system for the current machine
get_platform() {
  local -r kernel="$(uname -s)"
  if [[ ${OSTYPE} == "msys" || ${kernel} == "CYGWIN"* || ${kernel} == "MINGW"* ]]; then
    echo windows
  else
    uname | tr '[:upper:]' '[:lower:]'
  fi
}

# Retrieve the system architecture for the current machine
#
# This can be overwritten by the use of `ASDF_OVERWRITE_ARCH_{tool}`
get_arch() {
  local -r machine="$(uname -m)"
  local -r upper_toolname=$(echo "${tool_name//-/_}" | tr '[:lower:]' '[:upper:]')
  local -r tool_specific_arch_override="ASDF_OVERWRITE_ARCH_${upper_toolname}"

  OVERWRITE_ARCH=${!tool_specific_arch_override:-${ASDF_OVERWRITE_ARCH:-"false"}}
  if [[ ${OVERWRITE_ARCH} != "false" ]]; then
    echo "${OVERWRITE_ARCH}"
  elif [[ ${machine} == "arm64" ]] || [[ ${machine} == "aarch64" ]]; then
    echo "arm64"
  elif [[ ${machine} == *"arm"* ]] || [[ ${machine} == *"aarch"* ]]; then
    echo "arm"
  elif [[ ${machine} == *"386"* ]]; then
    echo "386"
  else
    echo "amd64"
  fi
}

# Sort a list of semantic versions
#
# Typically used with pipes, such as `list_versions | sort_versions`
sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

## ------------
## Log Operations

fail() {
  echo -e "asdf-$tool_name: $*"
  exit 1
}

log() {
    if [[ $VERBOSE -gt 0 ]]; then
        echo "[asdf]: $@"
    fi
}

verbose() {
    if [[ $VERBOSE -gt 1 ]]; then
        echo "v"
    else
        echo ""
    fi
}