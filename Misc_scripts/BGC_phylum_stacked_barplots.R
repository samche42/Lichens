#############
# BACTERIAL
#############

library(ggplot2)
library(dplyr)

data <- read.csv("Bacterial_BGC_taxonomy.txt", header = TRUE, sep = "\t")

count <- data %>%
  group_by(Contig_edge, BGC_type, Phylum) %>%
  summarise(Count = n())

order_levels <- c("terpene","T3PKS","NRPS","NRPS-like","T1PKS","RRE-containing","arylpolyene","hserlactone","phosphonate","redox-cofactor","RiPP-like","betalactone","NRPS_T1PKS hybrid","NAPAA","lassopeptide","NRPS-like_T1PKS hybrid","hglE-KS","NRPS_NRPS-like hybrid","thioamitides","ranthipeptide","Other")

count$BGC_type <- factor(count$BGC_type, levels = order_levels)

# Order Phyla by abundance in descending order
phylum_order <- count %>%
  group_by(Phylum) %>%
  summarise(total_count = sum(Count)) %>%
  arrange(desc(total_count)) %>%
  pull(Phylum)

count$Phylum <- factor(count$Phylum, levels = phylum_order)

ggplot(subset(count, Contig_edge == "YES"), aes(x = BGC_type, y = Count, fill = Phylum)) +
  geom_col(width = 0.7) +
  labs(x = "BGC Type", y = "Count") +
  theme(axis.text.x = element_text(angle = 90))

ggplot(subset(count, Contig_edge == "NO"), aes(x = BGC_type, y = Count, fill = Phylum)) +
  geom_col(width = 0.7) +
  labs(x = "BGC Type", y = "Count") +
  theme(axis.text.x = element_text(angle = 90))
