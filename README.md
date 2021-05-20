# final_biastools

Biastools.sh implements a simulation pipeline that is tailored to perform a paired-end simulation of chr21 reads for individual NA12878. It simulates
to a coverage of 30x. It gets the 1000 Genomes VCF and extracts the VCF for individual NA12878. It creates a HET site VCF by filtering for HETs. It also
retrieves the reference genome fasta and extracts the chr21 reference genome specifically. Then, it uses bcftools consensus to generate haplotype FASTA files which are inputted into mason_simulator to create simulated reads in FASTQ files. Then, alignment is performed using Bowtie2. The resulting SAM files are sorted,
merged, and intersected with the HET site VCF. The last step in this pipeline implements the summ_allelic functionality by calling the reference bias script and giving it the HET site VCF, reference genome FASTA, and the final SAM alignment file. 

Single_end_biastools.sh is the same script as above modified to do single-end alignment. 

*For both pipelines above, the names of output files as well as coverage have to be manually adjusted when simulating for anything besides chr21. My goal is
to make this script turn into one that is more automated and time-efficient in the future.

ref_bi.py is the reference bias script which produces a reference bias statistics file given the following parameters: a sorted SAM file with alignments
of simulated reads, a VCF file of all the HET sites, and the input FASTA file. This program works by using the HET site VCF file to identify the position
of each HET site as well as the REF and ALT alleles at that position. It then goes through the SAM file and 1) determines if a read intersects with a HET
site and if it does, it keeps track of the allele at the HET site position in that read. Finally, once both the VCF and SAM files are processed (the 
aforementioned data is stored in arrays), the program loops through each HET site and calculates reference bias as REF/(REF+ALT). Since simulated data preserves
haplotype-origin information, which is stored in the RG-tag in the input SAM file, this program also calculates read distribution as (# reads from reference 
haplotype)/(total # reads overlapping HET site). The final output from this program is a tab-delimited file containing the reference bias metric, counts of REF,
ALT, GAP, and other alleles, as well as the total number of reads overlapping each HET site, the total mapQ sum for the reads overlapping the HET site, and the
fraction of reads with low MAPQ. For simulated data where haplotype information is provided, it additionally outputs the read distribution metric. This program
is the basis for the Biastools summ_allelic function. 

indel_realignment.sh runs Octopus on the final SAM file generated from running biastools.sh. It also calls realignment.py to create the final merged, sorted,
and indexed BAM file following indel realignment. Then, it calls the reference bias script to produce the new reference bias statistics file after indel
realignment.

realignment.py implements a python script which allows for realigned BAM files from Octopus to be merged with the original BAM file in such a way that we do not
repeat alignments. The final BAM file only contains reads that were realigned and are located in the realigned BAM file or reads that were not realigned and are in
the original BAM file. Again, the names of input and output files have to be manually changed when running this script. 

ref_bi_graphs.ipynb is a Jupyter notebook that traces through our entire "pipeline" in generating plots. First, it creates the reference bias histogram using the
bias statistics file following indel realignment. Then, it creates a splatter plot of highly biased HET sites. Then, it produces a plot which color codes the HET
sites based on whether they are an indel artifact or not (if new reference bias calculation of REF/(REF+ALT+GAP) is no longer highly biased). Then, it creates a 
splatter plot with the indel artifacts removed entirely. Then, it surveys the bias statistics file before indel realignment and removes sites that were unbiased
prior to indel realignment. Finally, it produces the last splatter plot with the final set of HET sites color coded based on the fraction of overlapping reads with
low mapQ and it outputs the chart of all such sites that are shown in the final splatter plot. The 2 inputs to this program are 1) the reference bias statistics file after indel realignment and 2) the reference bias statistics file before indel realignment.
