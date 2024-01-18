library(ggplot2)
library(viridis)
library(reshape2)
 
data = read.csv(file = "BGC_tax_per_sample.txt", header=T, sep="\t")
melted = melt(data, id = c("Family")) 
melted$log1p_value = log1p(melted$value)

#Heatmap of raw counts
ggplot(data = melted, mapping = aes(x = variable, y = Family, fill = value),fill = "transparent") +
geom_tile() +
xlab(label = "BGC family") +
ylab(label = "Sample family") +
scale_fill_viridis_c(option="magma", direction=-1) +
theme(axis.text.y = element_text(size=8, color="black"), 
axis.text.x = element_text(angle=90, hjust=1, size=8, color="black"), 
axis.title.x =element_text(size=8, color="black"), 
axis.title.y =element_text(size=8, color ="black"),
panel.background = element_rect(fill = "transparent"),
plot.background = element_rect(fill = "transparent"), 
panel.grid.major = element_blank(),
panel.grid.minor = element_blank())

#Heatmap of counts transformed by log1p
ggplot(data = melted, mapping = aes(x = variable, y = Family, fill = log1p_value),fill = "transparent") +
geom_tile() +
xlab(label = "BGC family") +
ylab(label = "Sample family") +
scale_fill_viridis_c(option="magma", direction=-1) +
theme(axis.text.y = element_text(size=8, color="black"), 
axis.text.x = element_text(angle=90, hjust=1, size=8, color="black"), 
axis.title.x =element_text(size=8, color="black"), 
axis.title.y =element_text(size=8, color ="black"),
panel.background = element_rect(fill = "transparent"),
plot.background = element_rect(fill = "transparent"), 
panel.grid.major = element_blank(),
panel.grid.minor = element_blank())
