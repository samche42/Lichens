##NB: ALL DATASETS MUST BE ORDERED THE SAME IN TERMS OF THE SAMPLE COLUMN!!!!!!!

################################################################################################
#
# #TAXONOMIC CONTIG CLASSIFCATION (COUNT, LENGTH AND COVERAGE)
#
################################################################################################

library(ggplot2)
library(reshape2)
library(ggh4x)

data = read.csv("Kingdom_contig_counts_with_metadata.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample","Superkingdom","Phylum","Class","Order","Family","Genus"))

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

data = read.csv("Kingdom_contig_length_with_metadata.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample","Superkingdom","Phylum","Class","Order","Family","Genus","lichendex.organism"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
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

data = read.csv("kingdom_coverage.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample","Superkingdom","Phylum","Class","Order","Family","Genus","lichendex.organism"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Sample <- factor(melted$Sample, levels = unique(melted$Sample))

ggplot() +
  geom_bar(data = melted,aes(x = Sample, y = value, fill = factor(variable, levels=c('Archaea','Bacteria','Unknown','Viruses','Eukaryota'))), stat = "identity", width = 1) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

###############################
#
# #Bacterial coverage BOXPLOTS PER FAMILY OF LICHENS
#
###############################
library(ggplot2)
library(reshape2)
library(ggh4x)
library(dplyr)

sub_melted = subset(melted, subset=(variable=="Bacteria"))

# Add a new column "mean_value" to sub_melted with the mean values
sub_melted <- sub_melted %>%
  group_by(Family) %>%
  mutate(mean_value = mean(value)) %>%
  ungroup()

ggplot(sub_melted, aes(x = reorder(Family, -mean_value), y = value, fill = Family)) + 
  geom_boxplot(colour = "black", position = position_dodge(1)) +
  geom_vline(xintercept = c(1.5, 2.5, 3.5), colour = "grey85", size = 1.2) +
  theme(legend.title = element_text(size = 12, face = "bold"), 
        legend.text = element_text(size = 10, face = "bold"), 
        legend.position = "right", 
        axis.text.x = element_text(face = "bold", colour = "black", size = 12, angle=90), 
        axis.text.y = element_text(face = "bold", size = 12, colour = "black"), 
        axis.title.y = element_text(face = "bold", size = 14, colour = "black"), 
        panel.background = element_blank(), 
        panel.border = element_rect(fill = NA, colour = "black"), 
        legend.key = element_blank())+
        guides(fill = FALSE)

################################################################################################
#
# #BACTERIAL PHYLUM CONTIG CLASSIFCATION (COVERAGE)
#
################################################################################################
library(ggplot2)
library(reshape2)
library(ggh4x)

data = read.csv("bacterial_broad_phyla_coverage.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample","Superkingdom","Phylum","Class","Order","Family","Genus","lichendex.organism"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
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

################################################################################################
#
# #EUKARYOTA PHYLUM CONTIG CLASSIFCATION (COVERAGE)
#
################################################################################################
library(ggplot2)
library(reshape2)
library(ggh4x)

data = read.csv("eukary_broad_phyla_coverage.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample","Superkingdom","Phylum","Class","Order","Family","Genus","lichendex.organism"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
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


################################################################################################
#
# #Number of BGCs per sample, colored by contig edge position, faceted by hierarchacal taxonomy
#
################################################################################################
library(ggplot2)
library(reshape2)
library(ggh4x)

data = read.csv("bacterial_bgc_contig_edge.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample","Lichen_Superkingdom","Lichen_Phylum","Lichen_Class","Lichen_Order","Lichen_Family","Lichen_Genus","lichendex.organism"))

melted$Lichen_Class <- factor(melted$Lichen_Class, levels = unique(melted$Lichen_Class))
melted$Lichen_Order <- factor(melted$Lichen_Order, levels = unique(melted$Lichen_Order))
melted$Lichen_Family <- factor(melted$Lichen_Family, levels = unique(melted$Lichen_Family))
melted$Sample <- factor(melted$Sample, levels = unique(melted$Sample))

ggplot() +
  geom_bar(data = melted,aes(x = Sample, y = value, fill = variable), stat = "identity", width = 1) +
  theme_bw() +
  facet_nested(. ~ Lichen_Class + Lichen_Order +  Lichen_Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

################################################################################################
#
# FULL BGC length per sample, coloured by type,  faceted by hierarchacal taxonomy
#
################################################################################################
library(ggplot2)
library(reshape2)
library(ggh4x)

data = read.csv("bacterial_BGC_types_edited.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample","Superkingdom","Phylum","Class","Order","Family","Genus","lichendex.organism"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Sample <- factor(melted$Sample, levels = unique(melted$Sample))

#Getting distinct colours
color = grDevices::colors()[grep('gr(a|e)y', grDevices::colors(), invert = T)]
custom_colors=sample(color, 11)

ggplot() +
  geom_bar(data = melted,aes(x = Sample, y =  value, fill = variable), stat = "identity", width = 1,position = position_stack(reverse = TRUE)) +
  scale_fill_manual(values = custom_colors) +
  theme_bw() +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(strip.text.x = element_text(angle = 90,size=5),
        panel.spacing=unit(0,"lines"),
        panel.background = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
