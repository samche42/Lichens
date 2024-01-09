library(ggplot2)
library(reshape2)
library(ggh4x)
library(dplyr)

data = read.csv("bacterial_boxplot_data.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("Sample_name","Superkingdom","Phylum","Class","Order","Family","Genus","Species"))

melted$Class <- factor(melted$Class, levels = unique(melted$Class))
melted$Order <- factor(melted$Order, levels = unique(melted$Order))
melted$Family <- factor(melted$Family, levels = unique(melted$Family))
melted$Genus <- factor(melted$Genus, levels = unique(melted$Genus))
melted$Sample_name <- factor(melted$Sample_name, levels = unique(melted$Sample_name))

############
#
#BOX PLOT PER LICHEN FAMILY
#
############

family_counts <- melted %>%
  group_by(Family) %>%
  summarise(count = n_distinct(Sample_name))

family_count_map <- setNames(family_counts$count, family_counts$Family)

get_family_count <- function(family) {
  count <- family_count_map[as.character(family)]
  return(paste(family, sprintf("(n=%d)", count)))
}

# Boxplot
family_boxplot = ggplot(melted, aes(x = Family, y = value, fill = Order)) + 
  geom_boxplot(colour = "black", position = position_dodge(1)) +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(legend.title = element_text(size = 6, face = "bold"), 
        strip.text.x = element_text(angle = 90, size = 5),
        panel.spacing = unit(0, "lines"),
        legend.text = element_text(size = 10, face = "bold"), 
        legend.position = "right", 
        axis.text.x = element_text(face = "bold", colour = "black", size = 6, angle = 90), 
        axis.text.y = element_text(face = "bold", size = 6, colour = "black"), 
        axis.title.y = element_text(face = "bold", size = 6, colour = "black"), 
        panel.background = element_blank(), 
        panel.border = element_rect(fill = NA, colour = "black"), 
        legend.key = element_blank()) + 
  labs(x = "", y = "Abundance") +
  scale_x_discrete(labels = get_family_count) +
  guides(fill = FALSE)

family_boxplot

############
#
#BOX PLOT PER LICHEN GENUS
#
############

genus_counts <- melted %>%
  group_by(Genus) %>%
  summarise(count = n_distinct(Sample_name))

genus_count_map <- setNames(genus_counts$count, genus_counts$Genus)

get_family_count <- function(genus) {
  count <- genus_count_map[as.character(genus)]
  return(paste(genus, sprintf("(n=%d)", count)))
}

# Boxplot
genus_boxplot = ggplot(melted, aes(x = Genus, y = value, fill = Order)) + 
  geom_boxplot(colour = "black", position = position_dodge(1)) +
  facet_nested(. ~ Class + Order +  Family, scales = "free", space = "free") +
  theme(legend.title = element_text(size = 6, face = "bold"), 
        strip.text.x = element_text(angle = 90, size = 5),
        panel.spacing = unit(0, "lines"),
        legend.text = element_text(size = 10, face = "bold"), 
        legend.position = "right", 
        axis.text.x = element_text(face = "bold", colour = "black", size = 6, angle = 90), 
        axis.text.y = element_text(face = "bold", size = 6, colour = "black"), 
        axis.title.y = element_text(face = "bold", size = 6, colour = "black"), 
        panel.background = element_blank(), 
        panel.border = element_rect(fill = NA, colour = "black"), 
        legend.key = element_blank()) + 
  labs(x = "", y = "Abundance") +
  scale_x_discrete(labels = get_genus_count) +
  guides(fill = FALSE)

genus_boxplot
