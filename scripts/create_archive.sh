#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <compression_type (gz, bz2, zip, xz, or 7z)> <archive_name> <file1> [file2 ...]"
  exit 1
fi

# Read the first argument as the compression type
compression_type=$1
shift

# Read the second argument as the archive name
archive_name=$1
shift

# Read the rest of the arguments as the files to compress
files_to_compress="$@"

# Function to create tar.gz archive
create_tar_gz() {
  tar -czvf "$archive_name.tar.gz" $files_to_compress
}

# Function to create tar.bz2 archive
create_tar_bz2() {
  tar -cjvf "$archive_name.tar.bz2" $files_to_compress
}

# Function to create zip archive
create_zip() {
  zip "$archive_name.zip" $files_to_compress
}

# Function to create xz archive
create_tar_xz() {
  tar -cJvf "$archive_name.tar.xz" $files_to_compress
}

# Function to create 7zip archive
create_7z() {
  7z a "$archive_name.7z" $files_to_compress
}

# Create the archive based on the specified compression type
case "$compression_type" in
  gz)
    create_tar_gz
    ;;
  bz2)
    create_tar_bz2
    ;;
  zip)
    create_zip
    ;;
  xz)
    create_tar_xz
    ;;
  7z)
    create_7z
    ;;
  *)
    echo "Unsupported compression type: $compression_type"
    echo "Supported types: gz, bz2, zip, xz, 7z"
    exit 1
    ;;
esac

# Check the status of the last command and output an appropriate message
if [ $? -eq 0 ]; then
  echo "Archive $archive_name created successfully!"
else
  echo "Error: Failed to create archive $archive_name."
  exit 1
fi
