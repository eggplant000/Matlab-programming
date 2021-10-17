
clc;
clear;

St = load("Stock.txt");

Date = St(:,1);
Day = St(:,2);
T_Vol = St(:,3)/10000; %trading volume (주)
T_Val = St(:,4); %trading value (억원)



%% 회귀분석
% log(Y) = α + β1*X1 + β2*X2 + β3*X3 + β4*X4 + β5*X5

n = size(St,1);

y = log(T_Val);
X = [ones(n,1) Day==3 Day==4 Day==5 Day==6 T_Vol];

b = inv(X'*X)*X'*y;
r = y - X*b;
s2 = r'*r/(n-size(X,2));
var_b = inv(X'*X)*s2;
se_b = sqrt(diag(var_b));

TSS = (y-mean(y))'*(y-mean(y));
RSS = r'*r;

R2 = 1-RSS/TSS
b

plot(y)
hold on
plot(X*b,'color','red')


%% F-test
% H0: beta1 = beta2 = beta3 = beta4 = 0 / H1: Not H0
% n이 크기때문에 통계량이 F분포를 이용하여 검정한다.
% F=((RSS_R-RSS_U)/J)/(RSS_U/(n-k)) ~ F(J,n-k)
% alpha = 0.05

% restricted model: Y = α + β5*X5
% unrestricted model: Y = α + β1*X1 + β2*X2 + β3*X3 + β4*X4 +β5*X5

n = size(St,1);

y = log(T_Val);
X = [ones(n,1) T_Vol];

b = inv(X'*X)*X'*y;
r = y - X*b;

TSS = (y-mean(y))'*(y-mean(y));
RSS_R = r'*r;

F = ((RSS_R - RSS)/4)/(RSS/(n-6));

F > finv(0.95,4,n-6)

% beta1~4까지 중 적어도 하나의 beta는 유의하다.
% 요일에 따른 효과가 있다.


%% t-test
% H0: beta = 0 / H1: beta != 0
% n이 크기때문에 정규분포를 이용하여 검정한다.
% t=beta_hat/se_hat(beta_hat) ~ N(0,1)
% 4개의 beta에 대해 모두 검정한다
% alpha = 0.05

t = (b-0)./se_b

t(2:end-1,1) > norminv(0.975)

% X2~X5 변수들은 유의하다고 할 수 있다.




