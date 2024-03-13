library(ggplot2)
library(reshape2)
library(ggh4x)

########
#COUNTS
########

data = read.csv("bin_counts.txt", header=TRUE, sep ="\t")
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
#PHYLA (MED AND HIGH ONLY)
########

data = read.csv("bin_phyla_counts.txt", header=TRUE, sep ="\t")
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
