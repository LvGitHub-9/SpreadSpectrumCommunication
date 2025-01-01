% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 直接序列扩频的差分能量检测(Differential Energy Detector)
% 文件名称：DED.m
% 版    本：V1.0
% 说    明：直扩的DED解扩仿真过程，用时域和频域两种差分能量检测方式实现
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2024-12-27       Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 差分能量检测(Differential Energy Detector)
close all; clear; clc;

%% 消息生成
bits=8;                         % 消息个数
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

% 以下解扩方法选择一种执行，不要全部执行
% 以下解扩方法选择一种执行，不要全部执行
% 以下解扩方法选择一种执行，不要全部执行
% 以下解扩方法选择一种执行，不要全部执行
% 以下解扩方法选择一种执行，不要全部执行

%% 解扩方法1：时域差分能量检测
PN1=[m,m];                      % [1,1]
PN2=[m,-m];                     % [1,-1]
W=floor(L/4);
ex=[];

figure
hold on
for i=1:bits
    buf=kmes(1,1+(i-1)*L:(i+1)*L);      % 取出两个符号长度
    cor1=xcorr(buf,PN1);                % 做自相关
    cor2=xcorr(buf,PN2);
    
    subplot(2,bits,i)                   % 作图  
    plot(cor1)
    subplot(2,bits,i+bits)
    plot(cor2)

    conj1=cor1(1,2*L-W:2*L+W);          % 选取自相关窗口
    conj2=cor2(1,2*L-W:2*L+W);          % 选取自相关窗口

    if(max(conj1)>max(conj2))    % 判断自相关峰值正负，解扩
        en(i)=1;
    else
        en(i)=-1;
    end
end

A=find(en~=bimes);
BER=length(A)/bits;
disp(['解码误码率：' num2str(BER)])

%% 解扩方法2：频域差分能量检测
W=floor(L/4);
PN1=[m,m];
PN2=[m,-m];
iPN1=fft(fliplr(PN1));              % 频域副本
iPN2=fft(fliplr(PN2));

figure    
hold on
for i=1:bits
    buf=kmes(1,1+(i-1)*L:(i+1)*L);  
    ibuf=fft(buf);                      % 接收信号做FFT
    ien1=iPN1.*ibuf;                    % 频域相乘
    ien2=iPN2.*ibuf;
    
    Pncor1=ifft(ien1);                  % iFFT
    Pncor2=ifft(ien2);

    subplot(2,bits,i)                   % 作图
    plot(Pncor1)
    axis([1 126 -2*L 2*L])
    subplot(2,bits,i+bits)
    plot(Pncor2)
    axis([1 126 -2*L 2*L])

    cor1=(Pncor1(1,L-W:L+W)).^2;      % 选窗口求相关峰
    cor2=(Pncor2(1,L-W:L+W)).^2;

    if(max(abs(cor1))>max(abs(cor2)))
        en(i)=1;
    else
        en(i)=-1;
    end
end

A=find(en~=bimes);
BER=length(A)/bits;
disp(['解码误码率：' num2str(BER)])
