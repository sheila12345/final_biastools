import pysam

qnames = set()  # read names go here
octopus_bam = pysam.AlignmentFile("final.bt2.sorted.het.realigned.bam")
output_bam = pysam.AlignmentFile("merged.realigned.het.bam", "w", template=octopus_bam)


#goes through realigned bam and 1) adds read name to set and 2) writes alignment to output bam
count_from_octopus = 0
for b in octopus_bam.fetch(until_eof=True):
    output_bam.write(b)
    count_from_octopus += 1
    qnames.add(b.query_name)

print("added ", count_from_octopus, " reads to bam from octopus\n")
octopus_bam.close()

count_from_original = 0
original_bam = pysam.AlignmentFile("bt2.sorted.het.bam")
for b in original_bam.fetch(until_eof=True):
    if b.query_name not in qnames:
        output_bam.write(b)
        count_from_original += 1

print("added ", count_from_original, " reads to bam form original \n")

print("added ", count_from_octopus+count_from_original, " reads TOTAL to bam\n")

original_bam.close()
output_bam.close()
