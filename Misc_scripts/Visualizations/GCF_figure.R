library(ggplot2)
library(viridis)
library(reshape2)

##########################################
#
# FULL HEATMAP (PRESENCE/ABSENCE)
#
##########################################

data = read.csv(file = "GCF_heatmap_data_presence_absence.txt", header=T, sep="\t")

melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample_name <- factor(melted$Sample_name, levels = unique(melted$Sample_name))

subset <- melted[melted$value == "Yes", ] #Reduces elements that need deleting when prettying up in Illustrator

ggplot(data = subset, mapping = aes(x = variable, y = Sample_name, fill = value),fill = "transparent") +
geom_tile() +
xlab(label = "GCF") +
ylab(label = "Sample")


##########################################
#
# MINIMAP OF GCFS IN ATLEAST 5% OF SAMPLES
#
##########################################

data = read.csv(file = "GCF_minimap_data.txt", header=T, sep="\t")

melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample_name <- factor(melted$Sample_name, levels = unique(melted$Sample_name))

#Heatmap of raw counts
ggplot(data = melted, mapping = aes(x = variable, y = Sample_name, fill = value),fill = "transparent") +
geom_tile() +
xlab(label = "GCF") +
ylab(label = "Sample") +
scale_fill_viridis_c(option="plasma", direction=-1) +
theme(axis.text.y = element_text(size=2, color="black"), 
axis.text.x = element_text(angle=90, hjust=1, size=2, color="black"), 
axis.title.x =element_text(size=2, color="black"), 
axis.title.y =element_text(size=2, color ="black"),
panel.background = element_rect(fill = "transparent"),
plot.background = element_rect(fill = "transparent"), 
panel.grid.major = element_blank(),
panel.grid.minor = element_blank())

##########################################
#
# MINIMAP STACKED BARPLOT
#
##########################################

data = read.csv("minimap_barplot.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Minimap"))
melted$Minimap <- factor(melted$Minimap, levels = unique(melted$Minimap))

ggplot() +
  geom_bar(data = melted,aes(x = Minimap, y = value, fill = variable), stat = "identity", width = 0.95) +
  theme_bw() +
  theme(strip.text.x = element_text(angle = 90,size=5),
        axis.title.x=element_blank(),
        axis.text.x=element_text(angle = 90),
        axis.ticks.x=element_blank())
