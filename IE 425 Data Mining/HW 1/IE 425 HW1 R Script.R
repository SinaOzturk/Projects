install.packages("kernlab")
install.packages("caTools")
install.packages("rpart.plot")
library(tree)
library(rpart)
library(rpart.plot)
library(caTools)
data("spam", package = "kernlab")

set.seed(1000)
split = sample.split(spam$type, SplitRatio = 0.7)
spamtr = subset(spam, split == TRUE)
spamte = subset(spam, split == FALSE)


## Answer for A:
spam_ratios = summary(spam$type)
spam_ratio_overall = spam_ratios[2] / sum(spam_ratios[1,])
spam_ratio_overall = as.numeric(spam_ratio_overall)
spam_ratio_overall
# overall spam ratio is 0.3940
training_spam_ratios = summary(spamtr$type)
spam_ratio_training = training_spam_ratios[2] / sum(training_spam_ratios)
# training set spam ratio is 0.39398
testspamratios = summary(spamte$type)
spam_ratio_test = testspamratios[2] / sum(testspamratios)
# test set spam ratio is 0.3942


## Answer for B (tree)
largest.tree = tree(type~.,data=spamtr, mincut=1, minsize=2, mindev = 0)
tree.summary = summary(largest.tree)
tree.summary$size

## Answer for B (rpart)
largest.rpart.tree = rpart(type~., data = spamtr,method = "class", control = rpart.control(minbucket = 1,minsplit = 2, cp = 0))

nsplit.largest.rpart = max(largest.rpart.tree$cptable[,"nsplit"])
leaf.node.largest.rpart = nsplit.largest.rpart + 1  
leaf.node.largest.rpart


## Answer for C (rpart)
pred.largest.rpart.tree = predict(largest.rpart.tree,newdata=spamte,type="class")
table.max.rpart = table(spamte$type, pred.largest.rpart.tree)

error_rate_max_rpart = (table.max.rpart[1,2] + table.max.rpart[2,1]) / sum(table.max.rpart) 
error_rate_max_rpart

false_positive_max_rpart = table.max.rpart[1,2] / sum(table.max.rpart[1,])
false_positive_max_rpart

false_negative_max_rpart = table_max_rpart[2,1] / sum(table_max_rpart[2,])
false_negative_max_rpart


## Answer for C (tree)
pred_largest_with_tree = predict(largest.tree, newdata = spamte, type = "class")
table_max_tree = table(spamte$type, pred_largest_with_tree)
table_max_tree

error_rate_max_tree = (table_max_tree[1,2] + table_max_tree[2,1]) / sum(table_max_tree)
error_rate_max_tree

false_positive_max_tree = table_max_tree[1,2] / sum(table_max_tree[1,])
false_positive_max_tree

false_negative_max_tree = table_max_tree[2,1] / sum(table_max_tree[2,])
false_negative_max_tree

##Answer for D (tree)

set.seed(1000)
cv.spam = cv.tree(largest.tree, K=10)
cv.spam

plot(cv.spam, pch=21, bg=5, type="p", cex=1.5)
cv.spam$dev
#most of them are equal at 1853.903 but we choose the one who will give us the smallest tree which is  100th value 
bestsize = cv.spam$size[100]
bestsize
opttree_tree = prune.tree(largest.tree, best = bestsize)
plot(opttree_tree)
summary(opttree_tree)


## Answer for E (tree)

pred_opttree_with_tree = predict(opttree_tree, newdata = spamte, type = "class")
table_opttree_tree = table(spamte$type, pred_opttree_with_tree)
table_opttree_tree

error_rate_opttree_tree = (table_opttree_tree[1,2] + table_opttree_tree[2,1]) / sum(table_opttree_tree)
error_rate_opttree_tree
table_opttree_tree[1,]

false_positive_opt_tree = table_opttree_tree[1,2] / sum(table_opttree_tree[1,])
false_positive_opt_tree

false_negative_opt_tree = table_opttree_tree[2,1] / sum(table_opttree_tree[2,])
false_negative_opt_tree


## Answer for D (rpart)

printcp(largest.rpart.tree)
dminerrorindex = which.min(largest.rpart.tree$cptable[,"xerror"])
acceptablexerror = largest.rpart.tree$cptable[minerrorindex,"xerror"] + largest.rpart.tree$cptable[minerrorindex,"xstd"]  
acceptablexerror
## Now, while we want to decrease nsplit number our acceptable error should be higher than decided xerror.
## We conclude that 16th index which has 31 nsplit, can be our optimal tree depend on above constraints.
opt_index = 16
cp_opt = largest.rpart.tree$cptable[opt_index, "CP"]
cp_opt
opttree_rpart = prune.rpart(tree = largest.rpart.tree,cp = cp_opt)
prp(opttree_rpart)

max(opttree_rpart$cptable[,"nsplit"])


## Answer for E (tree)

pred_opttree_with_rpart = predict(opttree_rpart,newdata = spamte, type = "class")
table_opttree_rpart = table(spamte$type, pred_opttree_with_rpart)
table_opttree_rpart

error_rate_opttree_rpart = (table_opttree_rpart[1,2] + table_opttree_rpart[2,1]) / sum(table_opttree_rpart)
error_rate_opttree_rpart

false_positive_opt_rpart = table_opttree_rpart[1,2] / sum(table_opttree_rpart[1,])
false_positive_opt_rpart

false_negative_opt_rpart = table_opttree_rpart[2,1] / sum(table_opttree_rpart[2,])
false_negative_opt_rpart

