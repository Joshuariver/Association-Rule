# Transaction data in R
# source: https://m.blog.naver.com/PostView.nhn?blogId=leedk1110&logNo=220785911828&proxyReferer=http:%2F%2F203.233.19.219%2F

library(arulesViz) 



data("Groceries") 

Groceries

class(Groceries)

# Groceries데이터는 'arules' package에 있는 

# 9835행 169열로 이루어진 transactions class의 데이터 임을 알 수 있습니다.
# * transactions class : 1과 0으로 이루어져 있는 데이터에서 0이 훨씬 많을 때(spase format - 희소 형태의 데이터). 
# 즉, 의미 없는 정보가 많고 크기가 커서 데이터를 처리하기 힘들 때 transactions class로 처리 한다고 합니다.

?Groceries

# Groceries 데이터는 한달동안 팔린 식품 데이터 입니다.
# 총 9835명의 어떤 물품을 샀는지에 대한 데이터 이며, 169개의 식품이 있습니다.

summary(Groceries)

# Summary를 통해 보면, 가장 많이 팔린 식품은 whole milk이며 두번째는 other vegetales, 그 다음은 rolls/buns순 입니다.
# 그 밑에 element는 식품 1개를 구매한 사람이 2159명, 2개를 구매한 사람이 1643명 ... 입니다.
# 제일 밑에 label, level1 2 는 식품의 범주가 점차 커짐을 나타낸 것입니다.
# 예를들어, franfurter는 소시지의 한 종류이며 sausage는 fanfuter를 포함하고 있고,
# meat and sausage는 sausage를 포함하고 있습니다.
# 즉, labels < level2 < level1의 관계를 나타내는 것입니다.




inspect(Groceries[1:10])

# transactions데이터는 일반 데이터처럼 그냥 이름이나 head(data)와 같은 형태로 볼 수 없고,
# 'inspect'라는 함수를 통해서 볼 수 있습니다.

# 1번 사람은 citrus fruit, semi-finished bread, margarine, read soups를 구매했으며,
# 2번 사람은 tropical fruit, yogrut, coffee를 구매했다는 데이터 입니다.
# 저 데이터를 dafa frame화 해보면 
# 9835행, 169열로 이루어져 있으며, 행은 사람 수, 열은 식품으로 이루어져 있습니다.
# 1번 행은 1번 사람이 구매한 품목에는 1이, 아닌 품목에는 0으로 구성되어 있습니다.
# 즉, n번째 행은 n번째 사람이 구매한 품목에는 1이, 아닌 품목에는 0으로 구성되어 있습니다.



itemFrequency(Groceries) 

# 그렇다면 각 식품이 얼마나 판매되었는지 상대도수를 통해 확인해 보겠습니다.


itemFrequency(Groceries, type='absolute') 

# type = 'absolute'를 추가해 주면 상대도수가 아닌 그냥 도수로 확인 할 수 있습니다.


itemFrequencyPlot(Groceries, type='absolute') 

# 이번엔 각 품목이 얼마나 판매되었는지를 한 눈에 알아 보기 쉽도록 plot을 그려보겠습니다.
#plot으로 


itemFrequencyPlot(Groceries, topN=20, type='absolute') 

# 품목이 너무 많아 알아보기 쉽지 않으므로, 상위 20개 품목만 알아보겠습니다.




# 이제 본격적으로 matrix, data frame, list를 transactions class로 변형해 보겠습니다.
# 1. 먼저 matrix 데이터를 transactions class로 변형시켜 보겠습니다.
# 0과 1로만 이루어진 5행 5열 matrix를 만들고
# 행이름은 ti1~ti5, 열 이름은 a~e 로 주겠습니다.
# 행은 1번부터 5번 사람이라는 의미이며, 열은 a부터 e까지의 식품을 의미하는 것 입니다.

mtx <- matrix(c(1,1,1,0,0,
                
                1,1,1,1,0,
                
                0,0,1,1,0,
                
                0,1,0,1,1,
                
                0,0,0,1,0), ncol=5, byrow=T)

rownames(mtx) <- paste0("ti",1:5)

colnames(mtx) <- letters[1:5]

mtx

# 즉, 1번 사람은 a, b, c 품목을 구매했으며, 3번 사람은 c와 d를 구매했음을 나타내는 데이터 입니다.


str(mtx)

class(mtx)


# numeric으로 이루어진 matrix데이터임을 알 수 있습니다.
# 이제, 위 matrix데이터를 transactions데이터로 변환시켜 보겠습니다.

mtx.trans <- as(mtx, 'transactions')   

mtx.trans

summary(mtx.trans)


# 원래 matrix였던 데이터가 5행 5열의 transactions 데이터로 변환된 것을 알 수 있습니다.
# 가장 많이 팔린 품목은 d이며, 1개의 품목만 산 사람은 1명, 2개도 1명, 3개는 두면, 4개는 한명임을 알 수 있습니다.
# 위 데이터는 level을 따로 지정해 주지 않았으므로 label만 나타나 있습니다.

inspect(mtx.trans)


# inspect를 통해 보았을 때, 품목과 사람이 잘 정리되어 있습니다.



# 2. 다음은 data frame을 transactions class로 변환시켜 보겠습니다.
# 
# 먼저 원래 만들었던 matrix데이터를 data frame으로 변환시키고, transaction으로 변환시켜 보겠습니다.

df <- as.data.frame(mtx)

df.trans <- as(df,"transactions") 

str(df)  


# 이렇게 바로 transaction으로 변환시켜 주려고 하면 에러가 나는 것을 알 수 있습니다.

# 왜냐하면 data frame이 numeric 타입으로 이루어져 있기 때문입니다.

# 따라서 transactions 데이터로 변환시켜 주기 위해 각 행을 logical타입으로 변환시켜 주겠습니다.



df <- as.data.frame(sapply(df,as.logical)) 

str(df)


# data frame을 logical로 변환한 다음
# transactions데이터로 변환하면 오류가 나지 않고 잘 변환 됩니다.


df.trans <- as(df,'transactions')  

df.trans

summary(df.trans)


inspect(df.trans)


# 3. 마지막으로 list형식을 transactions class로 변환시켜 보겠습니다.

# 1번 사람은 a,b,c를, 2번 사람은 a,d를 ... 구매 했다는 의미의 list를 만들어 줍니다.



list <- list(tr1=c("a","b","c"),
             
             tr2=c("a","d"),
             
             tr3=c("b","e"),
             
             tr4=c("a","d","e"),
             
             tr5=c("b","c","d"))

list


# 이제 위 list를 transactions로 변환시켜 줍니다.


list.trans <- as(list,'transactions')

list.trans

summary(list.trans)


inspect(list.trans)


# matrix와 data frame과 list 형식을 어떻게 transactions으로 변환시켜주는지 알아보았습니다.
# 이제 마지막에 만든 list로 변환시켜준 trasactions 데이터로
# 좀더 자세히 알아보겠습니다.

# 원래 데이터에서 어떤 성분을 불러올 때 '$' 로 불러왔다면,
# transactions데이터에서는 '@' 로 불러옵니다.

# list.trans에서 data를 불러오겠습니다.

list.trans@data


# 위에서 볼 수 있듯이 0과 1로 이루어진 spars Matrix(희소행렬) 임을 알 수 있습니다.


# 다음으로 transaction데이터가 어떤 품목으로 이루어져 있는지 'itemInfo'로 알아보겠습니다.

list.trans@itemInfo

# 위 데이터는 a,b,c,d,e 품목으로 이루어 짐을 알 수 있습니다.


# 그렇다면 Groceris 데이터는 어떤 데이터로 이루어져있으며, 어떤 품목이 있는지 알아보겠습니다.

Groceries@data 


Groceries@itemInfo  


# 위에서 볼 수 있듯이
# labels에서는 가장 작은 단위, level2에서는 그 다음, level1에서는 가장 큰 단위로 구성되어 있음을 알 수 있습니다.
#  이번엔 위 Goceries 데이터 처럼 list.trans 데이터에도 level을 추가해 보겠습니다. 
# 먼저 '음료, 햄버거, 피자' 로 이루어진 level1을 만들어 주고, itemInfo에 연결시켜 주겠습니다.

level1 <- c("음료","음료","햄버거","햄버거","피자")
list.trans@itemInfo <- cbind(list.trans@itemInfo,level1)
list.trans@itemInfo
inspect(list.trans)

# 다음에, labels였던 a-e 품목을 위에 만들어 놓은 level1에 맞게 레벨을 업! 시켜주겠습니다.

list.trans2 <- aggregate(list.trans, 'level1')

list.trans2
inspect(list.trans2)


# 마지막으로 위 데이터를 보기 좋게 이미지화 시켜보겠습니다.

image(list.trans2) 
