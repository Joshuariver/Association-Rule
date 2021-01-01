


# 연관규칙 분석을 위해 transactions format으로 데이터를 변환하는 방법에 대한 질문이 자주 있어서 아래와 같이 데이터 유형별로 
# 예를 들어 정리하였습니다. 참고하세요.


##==== [참고] List를 transactons format 으로 변환하기 ====


##------------------------------------------
## List -> transactions 자료로 변환
##------------------------------------------
# transaction list
tr_list <- list(c("a", "b"),
                c("a", "c"),
                c("b", "c", "d"), 
                c("a", "e"), 
                c("c", "d", "e"))
# set transaction names
names(tr_list) <- paste("tr", c(1:5), sep = "_")
tr_list


tr <- as(tr_list, "transactions")
tr
summary(tr)



##==== [참고] Matrix를 transactions format 으로 변환하기 ====



##-------------------------------------------
## Matrix -> transactions 자료로 변환
##-------------------------------------------
tr_matrix <- matrix(c(1, 1, 0, 0, 0, 
                      1, 0, 1, 0, 0, 
                      0, 1 , 1, 1, 0, 
                      1, 0, 0, 0, 1, 
                      0, 0, 1, 1, 1), 
                    ncol = 5)
# set dim names
dimnames(tr_matrix) <- list(c("a", "b", "c", "d", "e"),
                            paste("tr", c(1:5), sep = "_"))
tr_matrix


# coerce into transactions
tr2 <- as(tr_matrix, "transactions")
tr2

summary(tr2)




##==== [참고] DataFrame을 transactions format 으로 변환하기 ( 1 ) ====


##------------------------------------------------
## data.frame -> transactions 자료로 변환
##------------------------------------------------
tr_dataframe <- data.frame(
  age = as.factor(c("30대", "20대", "30대", "40대", "10대")), 
  grade = as.factor(c("A", "B", "A", "A", "C")))

# coerce into transactions
tr3 <- as(tr_dataframe, "transactions")

tr3


summary(tr3)



##==== [참고] DataFrame을 transactions format 으로 변환하기 ( 2 ) =====





## as(split([dadaframe[,"itemID"], dataframe[,"transactionID"]), "transactions") 함수
##-- making data.frame
transactionID <- c(rep("tr1", 3), rep("tr2", 4))
itemID <- c("item1", "item2", "item3", "item1", "item2", "item4", "item5")
tr_df <- data.frame(transactionID, itemID)
str(tr_df)

## converting data.frame to transactions format
tr <- as(split(tr_df[,"itemID"], tr_df[,"transactionID"]), "transactions")
inspect(tr)




