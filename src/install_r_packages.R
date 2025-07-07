#!/usr/bin/env Rscript

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Require at least one package argument
if (length(args) == 0) {
  cat("Error: No packages specified.\n")
  cat("Usage: Rscript install_r_packages.R package1 [package2 ...]\n")
  quit(status = 1)
}

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

packages <- args
cat("Installing specified packages:", paste(packages, collapse = ", "), "\n")

# Install packages if not present
for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg)
  } else {
    cat(pkg, "already installed\n")
  }
}

cat("Done!\n")
