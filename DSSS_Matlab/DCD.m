% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 直接序列扩频的差分相关检测(Differential Correlation Detector)
% 文件名称：DCD.m
% 版    本：V1.0
% 说    明：直扩的DCD解扩仿真过程;
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2025-1-1         Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 时域差分相关检测(Differential Correlation Detector)
close all; clear; clc;

%% 消息生成
bits=5;                         % 消息个数
mes=randi([0,1],1,bits);    
bimes=2*mes-1;                  % 单极性码转双极性,BPSK  

%% 差分编码
diffmes(1)=1;
for i=1:bits                    % 差分编码，只传输变化量，相位问题
    diffmes(i+1)=bimes(i)*diffmes(i);
end

%% 扩频码生成（使用m序列）
initial=[1 0 1 1 0 0];          % 6阶       
feedback=103;
m=mseq(initial,feedback,0);
L=length(m);                    % 取m序列长度
m=2*m-1;                        % 逻辑映射

%% 扩频
kmes=kron(diffmes,m);

%% 脉冲成型，上变频，信道，下变频，低通滤波

%% 解扩方法：时域差分相关检测
W=floor(L/4);
ex=[];

figure
hold on
for i=1:bits
    buf=kmes(1,1+(i-1)*L:(i+1)*L);      % 取出两个符号长度
    buf1=buf(1,1:L);                    % 分成两个符号
    buf2=buf(1,L+1:2*L);
    cor1=xcorr(buf1,m);                 % 分别做相关
    cor2=xcorr(buf2,m);
    cor=cor1.*cor2;                     % 相乘

    subplot(bits,1,i)                   % 作图  
    plot(cor)

    conj=cor(1,L-W:L+W);                % 选取判别窗口
    if(max(conj)>abs(min(conj)))        % 判断自相关峰值正负，解扩
        en(i)=1;
    else
        en(i)=-1;
    end
end

A=find(en~=bimes);
BER=length(A)/bits;
disp(['解码误码率：' num2str(BER)])

