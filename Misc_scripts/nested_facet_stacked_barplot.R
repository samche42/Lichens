##NB: ALL DATASETS MUST BE ORDERED THE SAME IN TERMS OF THE SAMPLE COLUMN!!!!!!!

################################################################################################
#
# #TAXONOMIC SUPERKINGDOM CONTIG CLASSIFICATION (COUNT, LENGTH AND COVERAGE)
#
################################################################################################

library(ggplot2)
library(reshape2)
library(ggh4x)

########
#COUNTS
########

data = read.csv("Kingdom_contig_counts_with_metadata.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample <- factor(melted$Sample, levels = unique(melted$Sample))

ggplot() +
  geom_bar(data = melted,aes(x = Sample, y = value, fill = variable), stat = "identity", width = 1) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

########
#LENGTHS
########

data = read.csv("Kingdom_contig_length_with_metadata.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample <- factor(melted$Sample, levels = unique(melted$Sample))

ggplot() +
  geom_bar(data = melted,aes(x = Sample, y = value, fill = variable), stat = "identity", width = 1) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

########
#ABUND
########

data = read.csv("Kingdom_contig_abundance_with_metadata.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample <- factor(melted$Sample, levels = unique(melted$Sample))

ggplot() +
  geom_bar(data = melted,aes(x = Sample, y = value, fill = factor(variable, levels=c('Archaea','Bacteria','Unclassified','Viruses','Eukaryota'))), stat = "identity", width = 1) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())+
        guides(fill = guide_legend(title = ''))

########
#ABUND - 3000 and UP ONLY
########

data = read.csv("Superkingdom_contig_abundances_3000bp_and_up_with_metadata.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample_name <- factor(melted$Sample_name, levels = unique(melted$Sample_name))

ggplot() +
  geom_bar(data = melted,aes(x = Sample_name, y = value, fill = factor(variable, levels=c('Bacteria','Archaea','Unclassified','Viruses','Eukaryota'))), stat = "identity", width = 1) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())+
        guides(fill = guide_legend(title = ''))

################################################################################################
#
# #BACTERIAL PHYLUM CONTIG CLASSIFCATION (COVERAGE)
#
################################################################################################
library(ggplot2)
library(reshape2)
library(ggh4x)

data = read.csv("Bacteria_phyla_abundances_over_3000bp_with_metadata.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Sample_name <- factor(melted$Sample_name, levels = unique(melted$Sample_name))

ggplot() +
  geom_bar(data = melted,aes(x = Sample_name, y = value, fill = variable), stat = "identity", width = 1) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

################################################################################################
#
# #EUKARYOTA PHYLUM CONTIG CLASSIFCATION (COVERAGE)
#
################################################################################################
library(ggplot2)
library(reshape2)
library(ggh4x)

data = read.csv("Eukary_phyla_abundances_over_3000bp_with_metadata.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Sample_name <- factor(melted$Sample_name, levels = unique(melted$Sample_name))

# Define your pastel colors
my_pastel_palette <- c("#FEBFB3", "#E5D8BD", "#FFD966", "#A2C8EC", "#C9BAF8", "#C7EFCF", "#FFB7B2", "#FF9AA2", "#EAD1DC", "#B5B2CC", "#D4C4E5")

ggplot() +
  geom_bar(data = melted, aes(x = Sample_name,y = value,fill = factor(variable,levels = c('Ascomycota', 'Basidiomycota', 'Mucoromycota', 'Chlorophyta', 'Streptophyta','Arthropoda', 'Nematoda', 'Euglenozoa', 'Chordata', 'Unclassified', 'Others'))), stat = "identity", width = 1) +
  scale_fill_manual(values = my_pastel_palette) +  
  theme_bw() +
  facet_nested(. ~ Class + Order + Family, scales = "free", space = "free") +
  theme(
    strip.text.x = element_text(angle = 90, size = 5),
    panel.spacing = unit(0, "lines"),
    panel.background = element_blank(),
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  ) +
  guides(fill = guide_legend(title = ''))

################################################################################################
#
# FULL BGC length per sample, coloured by type,  faceted by hierarchacal taxonomy
#
################################################################################################

###################
##Contig edge BGCs
###################

library(ggplot2)
library(reshape2)
library(ggh4x)

data = read.csv("Contig_edge_BGC_counts.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample_name <- factor(melted$Sample_name, levels = unique(melted$Sample_name))

#Getting distinct colours
color = grDevices::colors()[grep('gr(a|e)y', grDevices::colors(), invert = T)]
custom_colors=sample(color, 11)

ggplot() +
  geom_bar(data = melted,aes(x = Sample_name, y =  value, fill = variable), stat = "identity", width = 1,position = position_stack(reverse = TRUE)) +
  scale_fill_manual(values = custom_colors) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

###################
##Complete BGCs
###################

data = read.csv("Complete_BGC_counts.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample_name <- factor(melted$Sample_name, levels = unique(melted$Sample_name))

#Getting distinct colours
color = grDevices::colors()[grep('gr(a|e)y', grDevices::colors(), invert = T)]
custom_colors=sample(color, 11)

ggplot() +
  geom_bar(data = melted,aes(x = Sample_name, y =  value, fill = variable), stat = "identity", width = 1,position = position_stack(reverse = TRUE)) +
  scale_fill_manual(values = custom_colors) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
