if (!require(devtools)) library(devtools)
install_github("madlogos/recharts")
library(recharts)
# install.packages("htmlwidgets")
library(htmlwidgets)

rm(list = ls())

data = read.csv("Migration.csv")

# 为了创建弦图，我们需要一个矩阵，其中行和列都是唯一的地区名称，值为迁移数量
# 提取地区名称作为扇区的顺序
regions <- unique(c(data$source, data$destination))

# pops66的值用于确定扇区的大小
pops66_values <- data$pops66

# 创建邻接矩阵，行和列为目的地，值表示从不同来源地的迁移数量
adjacency_matrix <- matrix(0, nrow = length(regions), ncol = length(regions))
rownames(adjacency_matrix) <- regions
colnames(adjacency_matrix) <- regions

for (i in 1:nrow(data)) {
  src <- data$source[i]
  dest <- data$destination[i]
  migrants <- data$migrants[i]
  adjacency_matrix[src, dest] <- migrants
}

# 将邻接矩阵转换为数据框
adjacency_df <- as.data.frame(adjacency_matrix)

# 添加地区名称作为新的列
rownames(adjacency_df) = NULL
names_df <- data.frame(Name = regions)
adjacency_df_with_names <- cbind(names_df,adjacency_df)
knitr::kable(adjacency_df_with_names, align=c('lllllllllll'))

# 打印结果
# print(adjacency_df_with_names)

p=echartr(adjacency_df_with_names, Name,c(PEI,NS,NB,QUE,ONT,MAN,SASK,ALTA,BC,NFLD), 
        type='chord', subtype='ribbon + asc + descsub + hidelab + scaletext')%>% 
  #设置题目
  setTitle('加拿大1966年迁徙图','From d3.js',pos = 5) %>% 
  #设置工具栏
  set_toolbox(pos = 3)%>%
  setTheme('helianthus')
p
output_path = file.path(getwd(),"和弦图可视化设计.html")
saveWidget(p,output_path,selfcontained = TRUE)

  
  