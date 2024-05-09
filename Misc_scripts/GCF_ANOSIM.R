library(vegan)

############
# ALL
############

all_data = read.csv("ANOSIM_input.txt", header=TRUE, sep ="\t")
all_data[is.na(all_data)] <- 0

#Find unique groups in data
groups = unique(all_data[c("Genus")])
group_list = as.list(groups$Genus)

# Create an empty data frame to store results
result_df <- data.frame(Genus1 = character(), Genus2 = character(), Rvalue = numeric(), Pvalue = numeric(), stringsAsFactors = FALSE)

for (i in group_list) {
	for (j in group_list) {
	if (i==j) next
	sub_df1 = subset(all_data, subset=(Genus==i))
	sub_df2 = subset(all_data, subset=(Genus==j))
	sub_df = rbind(sub_df1, sub_df2)
	nums = sub_df[,9:ncol(sub_df)]
	nums_matrix = as.matrix(nums)
	set.seed(123)
	ano = anosim(nums_matrix, sub_df$Genus, distance = "bray", permutations = 9999)
	Rvalue = ano$statistic
	pvalue = ano$signif
	result_df <- rbind(result_df, data.frame(Genus1 = i, Genus2 = j, Rvalue = Rvalue, Pvalue = pvalue))
	}
}

write.table(result_df, "ANOSIM_results_Genus.txt", sep = "\t", row.names = FALSE)


############
# BACTERIAL
############

all_data = read.csv("bacterial_GCF_ANOSIM_input.txt", header=TRUE, sep ="\t")
all_data[is.na(all_data)] <- 0

#Find unique groups in data
groups = unique(all_data[c("Genus")])
group_list = as.list(groups$Genus)

# Create an empty data frame to store results
result_df <- data.frame(Genus1 = character(), Genus2 = character(), Rvalue = numeric(), Pvalue = numeric(), stringsAsFactors = FALSE)

for (i in group_list) {
	for (j in group_list) {
	if (i==j) next
	sub_df1 = subset(all_data, subset=(Genus==i))
	sub_df2 = subset(all_data, subset=(Genus==j))
	sub_df = rbind(sub_df1, sub_df2)
	nums = sub_df[,9:ncol(sub_df)]
	nums_matrix = as.matrix(nums)
	set.seed(123)
	ano = anosim(nums_matrix, sub_df$Genus, distance = "bray", permutations = 9999)
	Rvalue = ano$statistic
	pvalue = ano$signif
	result_df <- rbind(result_df, data.frame(Genus1 = i, Genus2 = j, Rvalue = Rvalue, Pvalue = pvalue))
	}
}

write.table(result_df, "bacterial_GCF_ANOSIM_results_Genus.txt", sep = "\t", row.names = FALSE)

############
# FUNGAL
############

all_data = read.csv("fungal_GCF_ANOSIM_input.txt", header=TRUE, sep ="\t")
all_data[is.na(all_data)] <- 0

#Find unique groups in data
groups = unique(all_data[c("Genus")])
group_list = as.list(groups$Genus)

# Create an empty data frame to store results
result_df <- data.frame(Genus1 = character(), Genus2 = character(), Rvalue = numeric(), Pvalue = numeric(), stringsAsFactors = FALSE)

for (i in group_list) {
	for (j in group_list) {
	if (i==j) next
	sub_df1 = subset(all_data, subset=(Genus==i))
	sub_df2 = subset(all_data, subset=(Genus==j))
	sub_df = rbind(sub_df1, sub_df2)
	nums = sub_df[,9:ncol(sub_df)]
	nums_matrix = as.matrix(nums)
	set.seed(123)
	ano = anosim(nums_matrix, sub_df$Genus, distance = "bray", permutations = 9999)
	Rvalue = ano$statistic
	pvalue = ano$signif
	result_df <- rbind(result_df, data.frame(Genus1 = i, Genus2 = j, Rvalue = Rvalue, Pvalue = pvalue))
	}
}

write.table(result_df, "fungal_GCF_ANOSIM_results_Genus.txt", sep = "\t", row.names = FALSE)
