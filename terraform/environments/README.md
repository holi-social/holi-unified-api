# Terraform definitions for unified api

This folder contains definitions that are used to deploy the unified api.

## Feature Environments

We want to be able to deploy an environment for a feature branch.

We are using terraform workspaces (named after git branches) for this. All infrastructure definitions in this folder are named relatively to the workspace. Therefore, on a workspace, we create/modify infrastructure only for the specific feature environment, without changing any infrastructure from other feature environments. Thereby, we achieve environments per branch, bootstrappable and destroyable via CI.