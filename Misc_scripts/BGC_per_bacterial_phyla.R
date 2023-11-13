library(ggplot2)
library(reshape2)

data = read.csv("BGCs_per_bacterial_phyla.txt", header=TRUE, sep ="\t")
melted = melt(data, id = c("BGC"))

ggplot() +
  geom_bar(data = melted,aes(x = variable, y = value, fill=BGC), stat = "identity", width = 1) +
  theme_bw() +
  facet_wrap(~BGC,ncol = 1, scales = "free")