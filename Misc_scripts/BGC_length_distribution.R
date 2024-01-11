library(ggplot2)

data = read.csv("BGC_length_distribution.txt", header=TRUE, sep ="\t")

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
