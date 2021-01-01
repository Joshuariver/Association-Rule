# [R 연관규칙 (Association Rule)] R arules package로 연관규칙 분석하기
# 출처: https://rfriend.tistory.com/tag/DataFrame을 transactions format 으로 변환하기 [R, Python 분석과 프로그래밍의 친구 (by R Friend)]
# https://rfriend.tistory.com/tag/DataFrame%EC%9D%84%20transactions%20format%20%EC%9C%BC%EB%A1%9C%20%EB%B3%80%ED%99%98%ED%95%98%EA%B8%B0

# 1. arules package 설치 및 library(arules)로 로딩

library(arules)


# 2. 데이터 확보 및 탐색

data("Epub")
help(Epub)

summary(Epub)

# data(Epub)로 로딩하고 summary(Epub)로 데이터셋 요약정보를 살펴보겠습니다. 

# - sparse format 형식으로 저장된 itemMatrix의 거래(transactions) 데이터셋이며,

# - 15,729개의 행(즉, 거래)과 936개의 열(items)으로 구성되어 있습니다.

# - 밀도(density)가 0.1758755% 라고 되어 있는데요, 전체 15729*936개의 cell 중에서 0.1758% 의 cell에 거래가 발생해서 
# 숫자가 차 있다는 뜻입니다. (일부 책벌레 애독자가 한꺼번에 다수의 책을 사고, 대부분의 독자는 item 1개나 2개 단품 위주로 
# 샀기 때문에 이렇게 밀도가 낮겠지요?)

# - 'most frequent items' 는 거래 빈도가 가장 많은 top 5의 품목명과 거래빈도를 제시해주고 있습니다.
# (doc_11d 가 356회 거래 빈도 발생으로 1위) 

# - 'element (itemset/transaction) length distribution' 은 하나의 거래 장바구니(즉, row 1개별로)에 품목(item)의 개수별로 
# 몇 번의 거래가 있었는지를 나타냅니다.

# (장바구니에 item 1개 짜리 단품만 거래한 경우가 11,615건으로서 가장 많고, item 2개 거래는 2,189건이군요)

# - 마지막에 item 정보의 label 형식과 transaction ID, TimeStamp 정보의 format 예시가 나옵니다.




# 참고로, R을 분석에 많이 사용해본 분이라면 dataframe 형식의 데이터셋을 많이 사용해보셨을 텐데요, 연관규칙분석에서 
# 사용할 itemMatrix in sparse format 형식의 데이터셋과 비교해보면 아래와 같이 차이가 있습니다.  
# 위에서 Epub 데이터셋의 density가 0.1758%로서 item별 matrix cell의 거의 대부분이 숭숭 비어있다고 했는데요, 
# 비어있는 cell까지 모두 저장하려면 메모리 비효율이 발생하므로 cell의 차있는 부분(즉, 거래발생 항목, nonzero elements)에 
# 대해서만 효율적으로 데이터를 저장해놓는 방식이 itemMatrix in sparse format 형식입니다. 저장 효율이 좋아지는 대신 
# 반대급부로 access하는 것이나 저장구조는 좀 복잡해집니다.   

# (행렬의 대부분의 cell이 '0'이면 sparse matrix 라고 하며, 그 반대는 dense matrix 라고 합니다.)

# csv 파일을 dataframe 으로 업로드할 때 read.csv() 함수를 사용하는 것처럼, transaction 데이터를 연관규칙분석을 위해 
# sparse format의 itemMatrix로 업로드하기 위해서는 read.transactions("dataset.csv") 함수를 사용합니다.


## check itemsets in sparse matrix

inspect(Epub[1:10])


## support per item: itemFrequency()
itemFrequency(Epub[ , 1:10])


# itemFrequencyPlot(dataset, support = xx) 함수를 이용해서 지지도 1% 이상의 item에 대해 막대그래프를 그려보겠습니다.

## item frequency plot : itemFrequentPlot()
itemFrequencyPlot(Epub, support = 0.01, main = "item frequency plot above support 1%")


# 이번에는 itemFrequencyPlot(dataset, topN = xx) 함수를 사용해서 support 상위 30개의 막대그래프를 그려보겠습니다. 
# support 1등 item이 'doc_11d'이고 2~2.5% 사이로군요. 30등 tiem은 'doc_3ec'이고 support가 약 1% 이네요.

## item frequency plot top 30 : itemFrequencyPlot(,topN)
itemFrequencyPlot(Epub, topN = 30, main = "support top 30 items")


# 아래는 image()함수와 sample()함수를 이용해서 500개의 무작위 샘플을 가지고 matrix diagram을 그려본 것입니다.  
# 그림의 점들은 거래가 발생한 item을 의미합니다. 이 그림만 봐서는 어떤 패턴이 있는지 알기가 어렵지요? ^^' 
 

# matrix diagram : image()
image(sample(Epub, 500, replace = FALSE), main = "matrix diagram")


# 3. 연관규칙 분석 (association rule analysis)

# arules 패키지의 apriori() 함수를 이용해서 연관규칙을 분석해보겠습니다.
# parameter 에 list로 minimum support, minimum confidence, minimum length 를 지정해주면 이를 충족시키지 못하는 superset에 
# 대해서는 pruning 을 해서 빠르게 연관규칙을 찾아줍니다.


# 그런데, 아래 예시에서는 minumum support = 0.01 로 했더니 기준이 너무 높았던지 연관규칙이 '0'개 나왔네요.


## association rule analysis : apriori()
Epub_rule <- apriori(data = Epub, 
                     parameter = list(support = 0.01,
                                      confidence = 0.20,
                                      minlen = 2))

Epub_rule

# minumum support 기준을 0.001 로 낮추어서 다시 한번 분석을 해보겠습니다. 
# 아래처럼 결과가 나왔습니다.  연관규칙 분석은 기본 개념과 결과를 해석할 줄 알면 분석툴로 분석하는 것은 이처럼 매우 쉽습니다. 
# (컴퓨터는 연산해야할 일이 엄청 많지만요...)

# re-setting minimum support from 0.01 to 0.001
Epub_rule_2 <- apriori(data = Epub, 
                       parameter = list(support = 0.001,
                                        confidence = 0.20,
                                        minlen = 2))


Epub_rule_2


# 4. 연관규칙 조회 및 평가

# 연관규칙을 Epub_rule 이라는 객체에 저장을 해두었으므로, summary() 함수를 써서 연관규칙에 대해 개략적으로 
# 파악을 해보면 아래와 같습니다. 

# 62개 rule이 2개 item으로 이루어져 있고, 3개 rule은 3개 item으로 구성되있군요. 지지도(support), 신뢰도(confidence), 
# 향상도(lift)에 대한 기초통계량도 같이 제시가 되었는데요, 향상도 최소값이 11.19로서 전반적으로 꽤 높군요.


summary(Epub_rule_2)



# 연관규칙을 평가하기 위해 개별 규칙(rule)을 inspect()함수를 사용해서 살펴보겠습니다.  아래 결과에 1~20개의 rule을 제시했는데요, 
# lhs : Left-hand side, rhs : Right-hand side 를 의미합니다.



# inspection of 1~20 association rules : inspect()
inspect(Epub_rule_2[1:20])


# 위처럼 주욱 나열을 해놓으면 rule이 수백, 수천개가 되면 일일이 눈으로 보고 평가하기가 쉽지가 않습니다.  
# 봐야할 rule이 많을 때는 sort() 함수를 써서 분석가가 보고자하는 기준에 맞게 by 매개변수로 정렬을 하여 
# 우선순위를 뒤서 보면 유용합니다.  아래 예는 lift 를 기준으로 상위 20개 연관규칙을 정렬해보았습니다.  매우 유용하지요?!!
  
  
  
# sorting association rules by lift : sort( , by = "lift")
inspect(sort(Epub_rule_2, by = "lift")[1:20])


# 아래는 정렬 기준을 '지지도(support)'로 해서 top 20 연관규칙을 뽑아본 것입니다.  편하고 좋지요?!
  
  
# sorting association rules by support : sort(, by = "support")
inspect(sort(Epub_rule_2, by = "support")[1:20])


# 또 하나 유용한 tip이 있다면 subset() 함수를 써서 관심이 있는 item이 포함된 연관규칙만 선별해서 보는 방법입니다.  subset()함수를 이용해 연관규칙에서 "doc_72f"나 "doc_4ac"를 포함하는 규칙을 선별하는 방법은 아래와 같습니다.





# subset of association rules : subset()
rule_interest <- subset(Epub_rule_2, items %in% c("doc_72f", "doc_4ac"))
inspect(rule_interest)


# 위에서는 사용한 %in% (select itemsets matching any given item) 조건은 적어도 하나의 제품이라도 존재하면 
# 연관규칙을 indexing해온다는 뜻입니다.  이에 반해 %pin% (partial matching) 는 부분 일치만 하더라도, %ain% 
# (select only itemsets matching all given item) 는 완전한 일치를 할 때만 indexing을 하게 됩니다. 


# 아래에 item 이름에 부분적으로라도 "60e"라는 철자가 들어가 있는 item이 들어가 있는 연관규칙을 부분집합으로 indexing해오는 
# 예를 들어보겠습니다.  이 기능도 꽤 유용하겠지요?
  
  
# partial subset : %pin%
rule_interest_pin <- subset(Epub_rule_2, items %pin% c("60e"))
inspect(rule_interest_pin)



## 5. 연관규칙의 시각화 : arulesViz package


# arulesViz package를 사용해서 연관규칙을 시각화해보겠습니다.

# 


# Scatter plot for association rules 
# install.packages("arulesViz")
library(arulesViz)


# scatter plot of association rules
plot(Epub_rule_2)


# Grouped matrix for assocation rules
# grouped matrix for association rules
plot(sort(Epub_rule_2, by = "support")[1:20], method = "grouped")


# * 65개 rule을 모두 그리니깐 너무 작게 나와서 support 기준 상위 20개만 선별해서 그렸음





# Network Graph for assocation rules
# 참고로 아래 그래프의 원은 item element가 아니라 {item} → {item} 연관규칙의 지지도(support)를 나타냅니다. 
# 지지도에 따라 원의 크기가 비례합니다. 색깔은 향상도(Lift)를 나타냅니다. 색깔이 진할수록 향상도가 높습니다. 
# 그런데 화살표(from lhs to rhs)가 그려지다 말아서 그래프가 영... 어색합니다. -_-???
  
  
# Graph for association rules
plot(Epub_rule_2, method = "graph", control = list(type="items"))


# 위의 65개 연관규칙 그래프의 라벨 글자 크기(label font size, default = 1)를 줄이고, 화살표 크기(arrow size, default = 1)도 
# 조금 잘게 해보겠습니다.   네트워크 그래프 그릴 때 사용하는 igraph 패키지의 파라미터 설정 방법을 사용하면 됩니다. 
# 위의 그래프보다는 아주 조금 더 나은거 같기는 한데요, 많이 좋아보인다는 느낌은 안드네요. ^^;; 
#  (그래프 그릴 때마다 위치가 조금씩 달라지므로 제가 화면 캡쳐해놓은 거랑은 아마 다르게 그려질 거예요)





# changing font size(vertex.label.cex), arrow 
plot(Epub_rule_2, method = "graph", 
     control = list(type="items"), 
     vertex.label.cex = 0.7, 
     edge.arrow.size = 0.3,
     edge.arrow.width = 2)


# 연관규칙 그래프 시각화를 좀더 이쁘게 하려면 연관규칙 개수를 20개 이내로 줄여주면 됩니다. 
# 아래는 연관규칙 55~65번째 (11개 규칙) 만 선별해서 type = "items" 로 그려본 것인데요, 
# label 글자 크기나 화살표 등이 전혀 거슬리지 않고 자연스럽지요?
  
  
  
#  [ 그림 1]  Graph-based visualization with item and rules as vertices

plot(Epub_rule_2[55:65], method = "graph", control = list(type="items"))



# type = "itemsets" 으로 설정을 해주면 아래의 그래프 처럼 "item-set" (가령, {doc_6e8, doc_6e9}, {doc_6e7, doc_6e9} 
# 처럼 여러개 item 들이 들어 있는 바구니) 끼리의 연관규칙 관계를 시각화해줍니다. 

# 화살표 두께(width) : item-set 간 연관규칙 지지도(support)에 비례하여 커짐
# 화살표 색깔(color) : item-set 간 연관규칙 향상도(lift)에 비례하여 진해짐
# type = "items" (위의 [그림1]) 일 때와 type = "itemsets" (아래의 [그림 2]) 일때의 동그라미로 표시해 둔 부분을 유심히 비교해서 살펴보시면 서로 연관규칙을 어떻게 표현하는 것인지 이해할 수 있을 것입니다. 서로 장단점이 있지요? 
  
  
  
  
 #   [ 그림 2]  Graph-based visualization with item-sets as vertices

plot(Epub_rule_2[55:65], method="graph", control=list(type="itemsets"))


# 6. 연관규칙을 CSV 파일로 저장



# 마지막으로 write() 함수를 사용해서 분석한 연관규칙을 CSV 파일로 저장해보겠습니다.  
# 나중에 엑셀로 불러다가 후속 분석/작업하는데 필요할 수도 있겠지요?  
# file = "경로" 지정할 때 경로구분표시가 '\'가 아니라 '/' 로 해주어야 하는 것에 주의하시기 바랍니다. 
# Windows 탐색기의 경로 그대로 복사해다가 붙이면 경로구분표시가 '\' 되어 있어서 오류납니다.

 
# saving in CSV format : write()
write(Epub_rule_2, 
      file = "data/Epub_rule.csv", 
      sep = ",", 
      quote = TRUE, 
      row.names = FALSE)

# 마지막으로 as() 함수를 이용하여 연관규칙을 데이터프레임(dataframe) 구조로 변환해서 저장해보겠습니다.  
# 연관규칙이 데이터프레임으로 되어있으면 다른 분석할 때 가져다 쓰기에 편하겠지요?



# transforming into dataframe
Epub_rule_df <- as(Epub_rule_2, "data.frame")

str(Epub_rule_df)


# 데이터프레임으로 만들었으니 이전 포스팅에서 배웠던 IS(Interest-Support) Measure 와 교차지지도(cross support) 
# 흥미측도를 생성할 수 있습니다.  R arules 패키지에서 자동으로 생성해주는 것은 지지도(support), 신뢰도(confidence), 
# 향상도(lift) 3개뿐이다 보니 IS측도나 교차지지도는 직접 코딩해서 계산해줘야 합니다. 


# 아래 예시는 IS 기준으로 내림차순한 다음에 IS측도 상위 10개만 indexing한 것입니다.  
# (교차지지도는 최소지지도, 최대지지도 구해서 나눠줘야 하는 복잡함이 있으므로 패쓰... ^^; )



# IS(Interest-Support) measure = sqrt(lift(A,B)*support(A,B))
Epub_rule_df <- transform(Epub_rule_df, IS = sqrt(lift*support))
Epub_rule_df[order(-Epub_rule_df$IS), ][1:10, ]


