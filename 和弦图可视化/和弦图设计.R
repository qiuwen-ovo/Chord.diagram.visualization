# 两个包自己用Rstudio直接安装就好
# install.packages("statnet")
# install.packages("circlize")
# install.packages("plotly")
library(statnet)
library(circlize)
library(plotly)
# devtools::install_github("mattflor/chorddiag")
library(chorddiag)


rm(list=ls())

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

# 根据pops66的值调整每个扇区的相对大小
# 首先标准化pops66的值
max_pops66 <- max(pops66_values)
min_pops66 <- min(pops66_values)
normalized_pops66 <- (pops66_values - min_pops66) / (max_pops66 - min_pops66)

# 将标准化后的pops66值转换为扇区的高度，这里我们简单地使用一个固定的比例因子
sector_height <- normalized_pops66 * 0.1 # 可以根据需要调整比例因子

# 设置circos参数，包括track.height，这里我们使用pops66的值来确定
circos.par(track.height = sector_height)
ninecol = c("#A6CEE3FF","#1F78B4FF", "#B2DF8AFF", "#33A02CFF", "#FB9A99FF", "#E31A1CFF", "#FDBF6FFF", "#FF7F00FF","#CAB2D6FF","#B15928FF")


# 创建弦图，指定order参数以确保扇区的顺序与regions匹配
chordDiagram(
  adjacency_matrix,
  transparency = 0.5,
  link.lwd = adjacency_matrix * 0.1, # 弦的粗细与迁移数量成比例
  grid.col= ninecol,
  annotationTrack = c("name","grid"),
  order = regions, # 扇区的顺序与regions一致
  directional = 1, # 设置弦图的方向性
  diffHeight = 0.02 # 设置弦图的高度差异
)

#动态和弦图
chorddiag(
  adjacency_matrix, 
  #选择颜色组
  groupColors = ninecol,
  #选择是否添加外围标签
  showTicks = FALSE,
  #数字和弦淡入淡出程度
  fadeLevel = 0.1,
  #是否显示标签栏(默认true)
  showTooltips = TRUE,
  #单位设置
  tooltipUnit="人",
  #要在标签栏显示的字符串，默认为三角形
  tooltipGroupConnector = "->",
  #组件距离，数字表示度数
  groupPadding = 5
)

circos.clear()

# 保存图形
# pdf("chord_diagram.pdf")
# chordDiagram(chord_data, ...)
# dev.off()


