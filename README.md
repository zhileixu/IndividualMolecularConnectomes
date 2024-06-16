##
IndividualMolecularConnectomes

Date June/16th/2024

E-mail: zhileixu@163.com

##
This repository provides code to reproduce the findings of the article entitled "Mapping Individual Molecular Connectomes in Alzheimer’s Disease" by Xu et al.

##
AHBAprocessed Folder:

Please download the ROIxGene_aparcaseg_RNAseq.mat file from https://doi.org/10.6084/m9.figshare.6852911, and put it in this folder.


##
Code Folder:

Matlab and R scripts used to reproduce the findings of the article.

##
ConnectomeClassification Folder:

The TauConnectomeContribution.mat file contains each connection’s contribution to the discrimination of three diagnostic groups using individual tau connectome.

##
ConnectomeTranscriptome Folder:

The ContributionTau.mat file contains each gene’s contribution to predicting the susceptibilities of individual tau connectome.

##
GSEA Folder:

Please download the gmt file from http://download.baderlab.org/EM_Genesets/, and put it in this folder.

##
IndividualTauConnectome_ADNI Folder:

TRUE Individual Tau Connectome generated by the script Step1_GetIndividualMolecularConnectome.m using TRUE Tau-PET data from ADNI.

##
NullPETData Folder:

NULL PET data used to test the code.

##
PredefinedStagingModels Folder:

Composite brain region label of predifined staging models provided by previous studies.