# oci-quickstart-template

The [Oracle Cloud Infrastructure (OCI) Quick Start](https://github.com/oracle-quickstart?q=oci-quickstart) is a collection of examples that allow Oracle Cloud Infrastructure users to get a quick start deploying advanced infrastructure on OCI.

The oci-quickstart-template repository contains the template that can be used for accelerating the construction of quickstarts that runs from local Terraform CLI and OCI Resource Manager.

Simple is a sample application that deploys a standalone virtual machine from the Oracle Cloud Infrastructure Marketplace.

This repo is under active development.  Building open source software is a community effort.  We're excited to engage with the community building this.

## How this project is organized

Each application is stored on its own top level folder.

Within the simple application project there are 3 modules:

- [simple-cli](simple-cli): launch a simple VM that subscribes to a Marketplace Image running from Terraform CLI.
- [simple-orm](simple-orm): Responsible for packaging the simple-cli module in OCI [Resource Manager Stack](https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Tasks/managingstacksandjobs.htm) format.
- [terraform-modules](terraform-modules): contains a list of re-usable terraform modules for managing infrastructure resources like vcn, subnets, security, etc.

## Prerequisites

First off we'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/oracle/oci-quickstart-prerequisites).

## Deploying Simple

Detailed instructions for deploying Simple on Oracle Cloud Infrastructure can be found in the [simple](./simple/README.md) space.

