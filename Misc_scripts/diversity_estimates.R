library(vegan)
library(ggplot2)
library(grid)
library(reshape2)

#Read in data, isolate only numerical data and convert numerical data to matrix
data =read.csv("phyla_abundance.txt", header=TRUE, sep="\t")
values = data[,7:ncol(data)]
values_matrix = as.matrix(values)

#Calculate shannon diversity, store results and create header for stored results
shan = diversity(values_matrix, index="shannon")
shan.scores = as.data.frame(scores(shan))
colnames(shan.scores) = c('Shannon')

#Let's have a quick peek at the data
head(shan.scores)

#Calculate simpson diversity, store results and create header for stored results
simp = diversity(values_matrix, index="simpson")
simp.scores = as.data.frame(scores(simp))
colnames(simp.scores) = c('Simpson')

#Let's have a quick peek at the data
head(simp.scores)

#Create new dataframe with metadata (take first two columns from original input data)
scores_df <- data[c(1,2,3,4,5,6)]

#Add in shannon and simpson diversity scores (copy and paste data columns from diversity calculations)
scores_df$Shannon = shan.scores$Shannon
scores_df$Simpson = simp.scores$Simpson

scores_df$Class <- factor(scores_df$Class, levels = unique(scores_df$Class))
scores_df$Order <- factor(scores_df$Order, levels = unique(scores_df$Order))
scores_df$Family <- factor(scores_df$Family, levels = unique(scores_df$Family))
scores_df$Sample <- factor(scores_df$Sample, levels = unique(scores_df$Sample))

#Let's have a quick peek at the data
head(scores_df)

box_data = melt(scores_df, id = c("Sample","Superkingdom","Phylum","Class","Order","Family")) #Melt data according to treatment type
sub_box = subset(box_data,variable !='Sample') #Remove redundant data
sub_box$value = as.numeric(as.character(sub_box$value)) #Convert data from strings to numbers

sub_box$Class <- factor(sub_box$Class, levels = unique(sub_box$Class))
sub_box$Order <- factor(sub_box$Order, levels = unique(sub_box$Order))
sub_box$Family <- factor(sub_box$Family, levels = unique(sub_box$Family))
sub_box$Sample <- factor(sub_box$Sample, levels = unique(sub_box$Sample))

#Let's have a quick peek at the data
head(sub_box)

#Plot diversity box plots
box_plot = ggplot(sub_box, aes(x = Family, y = value, fill = NULL)) + 
     geom_boxplot(colour = "black", position = position_dodge(1)) +
     facet_nested(. ~ variable + Class + Order +  Family, scales = "free", space = "free") +
     theme(legend.title = element_text(size = 2, face = "bold"), 
     strip.text.x = element_text(angle = 90,size=5),
     panel.spacing=unit(0,"lines"),
     legend.text = element_text(size = 10, face = "bold"), legend.position = "right", 
     axis.text.x = element_text(face = "bold",colour = "black", size = 2, angle=90), 
     axis.text.y = element_text(face = "bold", size = 2, colour = "black"), 
     axis.title.y = element_text(face = "bold", size = 2, colour = "black"), 
     panel.background = element_blank(), 
     panel.border = element_rect(fill = NA, colour = "black"), 
     legend.key=element_blank()) + 
     labs(x= "", y = "Diversity score", fill = "Sample_family")+
     guides(fill = FALSE)

box_plot
