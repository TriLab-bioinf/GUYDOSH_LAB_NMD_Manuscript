# Identification of translation events that drive nonsense-mediated mRNA decay reveals  functional roles for noncoding RNAs

## David J. Young<sup>1</sup>, Yuejun Wang<sup>1,2</sup>, and Nicholas R. Guydosh<sup>1*</sup>

1: Laboratory of Biochemistry and Genetics

2: TriLab Bioinformatics Group

National Institute of Diabetes and Digestive and Kidney Diseases, National Institutes of Health, Bethesda, MD 20892 USA

*Corresponding author: nicholas.guydosh@nih.gov (lead contact)


## RNAseq pipeline:
### 1- Download the RNAseq pipeline by running the following command in your WD:
```
git clone https://github.com/TriLab-bioinf/GUYDOSH_LAB_NMD_Manuscript.git 

cd GUYDOSH_LAB_NMD_Manuscript
```

### 2- Copy Biowulf Snakemake profile in your RNAseq_pipeline directory
```
git clone https://github.com/NIH-HPC/snakemake_profile.git
```

### 4- Copy Biowulf Snakemake profile in RNAseq_pipeline/config directory
```
# Download the biowulf snakemake profile from GitHub
git clone https://github.com/NIH-HPC/snakemake_profile.git

# Move nakemake_profile into the config directory
mv snakemake_profile ./config/
```

