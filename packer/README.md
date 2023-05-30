# oci-quickstart-template
Packer is a tool provided by Hashicorp that allows you to automate creation of your machine images.

## Setup

The `packer` binary can be installed from [here](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli). While it is not strictly required, the [OCI builder](https://developer.hashicorp.com/packer/plugins/builders/oracle/oci) for `packer` looks at the [config file](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File) for the OCI SDK/CLI by default.
These instructions assume you have the CLI installed. The OCI CLI can be installed from [here](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
and set up by following these [instructions](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#configfile).
If it is not installed you will see errors for undefined variables in later steps.


## Instructions
1. Clone the oci-quickstart-template repository:
```
git clone https://github.com/oracle-quickstart/oci-quickstart-template.git
cd oci-quickstart-template/packer
```
2. Before we can build the image, we must create network components in our tenancy
for an instance (or VM) to exist in. If you don't already have a VCN, log in to your tenancy and go to *Menu -> Networking -> Virtual Cloud Network -> Start VCN Wizard*. Default values should be fine.
[Follow the Networking Quickstart to create a network](https://docs.cloud.oracle.com/en-us/iaas/Content/Network/Tasks/quickstartnetworking.htm)

3. Modify `env_vars.sh` and fill it with appropriate values from your tenancy. [See below](#how-to-determine-variables) for instructions on ways to obtain these values. Note, these
values are the ones that are specific to your tenancy.
```
export PACKER_availibilty_domain=""
export PACKER_compartment_ocid=""
export PACKER_subnet_ocid=""
export PACKER_my_secret=""
```
4. Source the ```env_vars.sh``` file modified above:
```
source env_vars.sh
```

5. Validate the packer file:
```
packer validate template.pkr.hcl
The configuration is valid.
```

6. Create the image:
```
packer build template.pkr.hcl   

oracle-oci.builder_vm: output will be in this color.

==> oracle-oci.builder_vm: Creating temporary ssh key for instance...
==> oracle-oci.builder_vm: Creating instance...
==> oracle-oci.builder_vm: Created instance (ocid1.instance.oc1.iad.anuwcljsugt6wmqca77wn3bb77nefpsgpuqnjsk4hglf2r563ymxeg4hfdbq).
==> oracle-oci.builder_vm: Waiting for instance to enter 'RUNNING' state...
==> oracle-oci.builder_vm: Instance 'RUNNING'.
[...]
==> oracle-oci.builder_vm: Created image (ocid1.image.oc1.iad.aaaaaaaagwmrt5k7rdg4od4kp3n3lbowphexjrvhlysczlk2bqzjcrtmaidq).
==> oracle-oci.builder_vm: Terminating instance (ocid1.instance.oc1.iad.anuwcljsugt6wmqca77wn3bb77nefpsgpuqnjsk4hglf2r563ymxeg4hfdbq)...
==> oracle-oci.builder_vm: Terminated instance.
Build 'oracle-oci.builder_vm' finished after 4 minutes 43 seconds.

==> Wait completed after 4 minutes 43 seconds

==> Builds finished. The artifacts of successful builds are:
--> oracle-oci.builder_vm: An image was created: 'mybuild-VM.Standard.E4.Flex-20230525181128' (OCID: ocid1.image.oc1.iad.aaaaaaaagwmrt5k7rdg4od4kp3n3lbowphexjrvhlysczlk2bqzjcrtmaidq) in region 'us-ashburn-1'
```

7. Done! Check you tenancy for the resulting image under *Menu -> Compute -> Custom Images*.
You now have a custom image based on OL 8 built from `template.pkr.hcl` with the
name `${var.imgprefix}-${var.shape}-${local.timestamp}`


## Variables, Provisioners, and Changing the Build

### Variables
This repo and example template have variables defined in 3 places:
  - The default CLI config implicitly.
  - Tenancy specific variables in `env_vars.sh`
  - Non-tenancy specific variables in `template.pkr.hcl`

Note, the variable `my_secret` is not required but is just an example of passing
a secret to the provisioners in the template. It and references to it can be removed. It was defined as an env var to discourage committing it's value.

The variables in the template can be changed there or overridden. For example when
testing your build you may want to skip the actual image creation, just run:
`packer build --var skip_image=true template.pkr.hcl`

### Provisioners
The file `template.pkr.hcl` contains 4 example provisioners:
 - An inline shell example that echo's some strings and touches a file.
 - A shell example that copies `installer.sh` to the instance and runs it.
 - A file provisioner example that copies this readme to the instance and names it `test_file`.
 - A shell provisioner that runs the `oci-image-cleanup` command.

The `oci-image-cleanup` is part of the [oci-utils](https://github.com/oracle/oci-utils)
package. It clears ssh keys, logs, etc.

### Changing the Build

All the 4 provisioners are just examples. You can edit them to install whatever applications are required or remove them. However, running the cleanup script is a best practice as it removes existing ssh keys and resets cloud-init so that instances booted from your custom image behave as if this is their first boot.

_**However, you must run the cleanup script**_ if using this template to build an image for [OCI Marketplace](https://docs.oracle.com/en-us/iaas/Content/partner-portal/partner-portal_gs-what_s_oracle_cloud_marketplace_partner_portal.htm), if you do not the image will not pass validation.

Other provisioners, like a [local shell](https://developer.hashicorp.com/packer/docs/provisioners/shell-local) provisioner or an [ansible](https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible) provisioner can be added.

---

## How to Determine Variables

![Cloud Shell](images/cloudshell.png)

Users will need to log into their tenancy to find the required information for setting the environment variables. One helpful tool is the Cloud Shell feature that can be accessed from the users tenancy homepage. By typing the commands below into the cloudshell terminal, users can get the required key/value pairs. The following direct link will open will the users tenancy and open a Cloud Shell embedded terminal:

  https://cloud.oracle.com/?cloudshell=true

<details><summary>PACKER_availibilty_domain</summary><p>

The list of Availibility Domains available to a tenancy can be obtained using the following command:
```
$> oci iam availability-domain list | jq -r '.data[].name'
IYfK:US-ASHBURN-AD-1
IYfK:US-ASHBURN-AD-2
IYfK:US-ASHBURN-AD-3
```
</p></details>


<details><summary>PACKER_compartment_ocid</summary><p>

The list of Compartment names and corresponding ocids available to a tenancy can be listed using the following command:
```
$> oci iam compartment list |  jq -r '.data[] | .name + " = " + .id'
TestCompartment = ocid1.compartment.oc1..aaaaaaaay6xopmxqb6oz52m3hdcinhknyagicj6764xx2cotffzpvolhwcsq
```
See the [Compartments](https://cloud.oracle.com/identity/compartments) page for a list of compartments in this tenancy. Click "Create Compartment" or click an existing Compartment to get the ocid.

![ScreenShot](images/comp_ocid.png)

</p></details>

<details><summary>PACKER_subnet_ocid</summary><p>

See the Virtual Cloud Networks page for a list of networks in this tenancy. Click "Networking Quickstart" or click an existing network to get the ocid.

*IMPORTANT: The ocid MUST be for the Public Subnet*

![ScreenShot](images/public_network.png)

</p></details>


<details><summary>base_image_ocid</summary>
<p>

The list of platform image names and corresponding ocids available to a tenancy can be listed using the following command:
```
$> oci compute image list -c <insert_compartment_ocid_here> | jq -r '.data[] | ."display-name" + " = " + ."id"'
Windows-Server-2016-Standard-Edition-VM-Gen2-2020.03.16-0 = ocid1.image.oc1.iad.aaaaaaaaafrffa5esbcbcmkqappz37wjkrwh4uzpcmuixx4bcnyi4ljqmeya
Oracle-Linux-7.7-2020.03.23-0 = ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvt4jz4vc47qoc2ec4anha
Canonical-Ubuntu-18.04-2020.03.17-0 = ocid1.image.oc1.iad.aaaaaaaa7bcrfylytqnbsqcd6jwhp2o4m6wj4lxufo3bmijnkdbfr37wu6oa
[...]
```
A complete list of Base Images available within OCI can be seen on the [OCI All Image Families](https://docs.cloud.oracle.com/en-us/iaas/images/) page. (Click under "Read More" to get the Image ocid for a particular Image and Region.)
</p>
</details>


<details><summary>shape</summary><p>

The list of Compute Shapes available to a tenancy can be listed using the following command:
```
$> oci compute shape list -c <insert_compartment_ocid_here> | jq -r '.data[].shape'
VM.Standard2.1
VM.Standard2.2
[...]
```
The list of available Compute Shapes is determined by the Service Limits of the tenancy. See the Tenancy Details page under *Service Limits -> + Compute* for the list of Compute Shapes available to your tenancy. Additional Compute Shapes can be requested by clicking the "Request a service limit increase" link on the *Tenanacy Details* page.

The complete list of Compute Shapes available within OCI can also be seen on the [OCI Compute Shapes](https://docs.cloud.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm) listings page.
</p></details>




<details><summary>ssh_username</summary><p>

Oracle Linux ssh user is ```opc```

CentOS ssh user is ```opc```

Ubuntu ssh user is ```ubuntu```
</p></details>
