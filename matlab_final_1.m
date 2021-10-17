

clc;
clear;

% 시가총액이 가장 높은 주식들의 일별 종가 (2015.01.02~2020.06.24)
% Date 삼성전자 SK하이닉스 네이버 셀트리온 LG화학
SP = load("SP.txt"); 
SP_5 = SP(:,2:6);

Agg_val = [3152045,620986,448439,428433,358609];


%% 각 주식의 기대수익률과 Volatility (1년)

Return = log(SP_5(2:end,:))-log(SP_5(1:end-1,:));

Mean_Rtn = mean(Return);
SD = std(Return);

Y_Return = (Mean_Rtn - (SD.^2)/2) * 252;
Vola = SD .* sqrt(252);

Rst = [Y_Return' Vola']


%% 1년 기대수익률이 20퍼센트 이상이면서 공매도가 존재하지 않는 포트폴리오 구하기

min_std = 0.4; % 기대수익률 조건 계산을 위해 필요한 초기 표준편차값(1년)을 설정

Aeq = ones(1,5);
beq = 1;
lb = zeros(5,1);
ub = [];

%%

[Opt_wgt, min_std, exitflag, ~] ...
    = fmincon(@(x) std(Return*x)*sqrt(252), ones(5,1) * 1/5, ...
    -Mean_Rtn, -0.2/252-(min_std^2)/(2*252), ...
    Aeq, beq, lb, ub);  

min_std % 0.2357 : 1년의 표준편차 % 초기값을 가치가중 포트폴리오로해도 동일한 결과


%% 결과

Rst = zeros(3,2);

Y_Return = (Mean_Rtn * Opt_wgt - (min_std.^2)/(2*252)) * 252; % 1년 기대수익률

Rst(1,:) = [Y_Return min_std]

Opt_wgt



%% 가치가중 포트폴리오와 동일 가중치 포트폴리오 결과와의 비교
%% 기대수익률과 Volatility

Val_wgt = (Agg_val/sum(Agg_val))';
Val_Rtn = Return * Val_wgt;

Mean = mean(Val_Rtn);
SD = std(Val_Rtn);

Y_Return = (Mean - (SD.^2)/2) * 252;
Vola = SD * sqrt(252);

Rst(2,:) = [Y_Return' Vola'];


Eq_wgt = ones(5,1) * 1/5 ;
Eq_Rtn = Return * Eq_wgt;

Mean = mean(Eq_Rtn);
SD = std(Eq_Rtn);

Y_Return = (Mean - (SD.^2)/2) * 252;
Vola = SD .* sqrt(252);

Rst(3,:) = [Y_Return Vola]



%% 99% VAR를 최소화하는 포트폴리오 구하기 (시뮬레이션)

rng(20200625);

Aeq = ones(1,5);
beq = 1;
lb = zeros(5,1);
ub = [];


[Opt_wgt, VAR, exitflag, ~] ...
    = fmincon(@(x) Sim_VAR(10000,x,Return, 252, 99), ones(5,1) * 1/5, ...
    [], [], Aeq, beq, lb, ub);  

VAR
Opt_wgt

% 2779 (만원)
% Opt_wht =
%    0.3780
%    0.0009
%    0.2175
%    0.1800
%    0.2236

%% 99% VAR를 최소화하는 포트폴리오 구하기 (모형)

Aeq = ones(1,5);
beq = 1;
lb = zeros(5,1);
ub = [];

[Opt_wgt, VAR, exitflag, ~] ...
    = fmincon(@(x) MB_VAR(10000,x,Return, 252, 99), ones(5,1) * 1/5, ...
    [], [], Aeq, beq, lb, ub);  

VAR
Opt_wgt

% 4978 (만원)
% Opt_wht =
%    0.4103
%    0.0689
%    0.2625
%    0.1049
%    0.1534


