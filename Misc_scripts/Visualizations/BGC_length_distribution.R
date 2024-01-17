#############
# BACTERIAL
#############

library(ggplot2)

data = read.csv("Bacterial_BGC_length_distribution.txt", header=TRUE, sep ="\t")

order_levels <- c("terpene","T3PKS","NRPS","NRPS-like","T1PKS","RRE-containing","arylpolyene","hserlactone","phosphonate","redox-cofactor","RiPP-like","betalactone","NRPS_T1PKS hybrid","NAPAA","lassopeptide","NRPS-like_T1PKS hybrid","hglE-KS","NRPS_NRPS-like hybrid","thioamitides","ranthipeptide","Other")

data$BGC_type <- factor(data$BGC_type, levels = order_levels)

ggplot(subset(data, Contig_edge == "YES"), aes(x = BGC_type, y = BGC_length, fill = BGC_type)) +
  geom_boxplot(colour = "black", position = position_dodge(1), show.legend = FALSE) +
  scale_fill_manual(values = scales::hue_pal()(length(order_levels))) +
  labs(x = "BGC Type", y = "BGC Length")+
  theme(axis.text.x = element_text(angle = 90))

ggplot(subset(data, Contig_edge == "NO"), aes(x = BGC_type, y = BGC_length, fill = BGC_type)) +
  geom_boxplot(colour = "black", position = position_dodge(1), show.legend = FALSE) +
  scale_fill_manual(values = scales::hue_pal()(length(order_levels))) +
  labs(x = "BGC Type", y = "BGC Length")+
  theme(axis.text.x = element_text(angle = 90))

#############
# FUNGAL
#############

library(ggplot2)

data = read.csv("BGC_length_distribution.txt", header=TRUE, sep ="\t")

order_levels <- c("T1PKS","NRPS-like","terpene","NRPS","NRPS_T1PKS hybrid","T3PKS","indole","NRPS-like_T1PKS hybrid","T1PKS_T3PKS hybrid","T1PKS_indole hybrid","NRPS_NRPS-like hybrid","T1PKS_terpene hybrid","betalactone","siderophore","NRPS_indole hybrid","fungal-RiPP","NRPS_T1PKS_terpene hybrid","NRPS-like_betalactone hybrid","NRPS_NRPS-like_T1PKS hybrid","NRPS-like_T1PKS_terpene hybrid","Other")

data$BGC_type <- factor(data$BGC_type, levels = order_levels)

ggplot(subset(data, Contig_edge == "YES"), aes(x = BGC_type, y = BGC_length, fill = BGC_type)) +
  geom_boxplot(colour = "black", show.legend = FALSE) +
  scale_fill_manual(values = scales::hue_pal()(length(order_levels))) +
  labs(x = "BGC Type", y = "BGC Length") +
  theme(axis.text.x = element_text(angle = 90)) +
  coord_cartesian(ylim = c(0, 150000)) +
  scale_y_continuous(breaks = seq(0, 150000, by = 25000))

ggplot(subset(data, Contig_edge == "NO"), aes(x = BGC_type, y = BGC_length, fill = BGC_type)) +
  geom_boxplot(colour = "black", show.legend = FALSE) +
  scale_fill_manual(values = scales::hue_pal()(length(order_levels))) +
  labs(x = "BGC Type", y = "BGC Length") +
  theme(axis.text.x = element_text(angle = 90)) +
  coord_cartesian(ylim = c(0, 150000)) +
  scale_y_continuous(breaks = seq(0, 150000, by = 25000))
