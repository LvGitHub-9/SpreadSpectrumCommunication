% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 扩频通信频谱变化
% 文件名称：SpectrumChanges.m
% 版    本：V1.0
% 说    明：省略掉脉冲成型、上下变频与信道过程，仅研究扩频与解扩
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2025-1-6         Lv.      修改脉冲成型部分
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 扩频通信频谱变化
close all; clear; clc;

%% 消息生成
bits=10;                        % 消息个数
mes=randi([0,1],1,bits);    
bimes=2*mes-1;                  % 单极性码转双极性,BPSK  

%% 扩频码生成（使用m序列）
initial=[1 0 1 1 0 0];          % 6阶       
feedback=103;
m=mseq(initial,feedback,0);
L=length(m);                    % 取m序列长度
m=2*m-1;                        % 逻辑映射

%% 扩频
kmes=kron(bimes,m);             % 克罗内克积
bmes=rectpulse(bimes,L);        % 信号等长

%% 参数
fc=6e3;                         % 载波频率6kHz
fb=4e3;                         % 带宽4kHz
fs=48e3;                        % 采样频率48kHz
ts=1/fs;                        % 时域采样间隔

%% 省去脉冲成型

%% 原始信号与扩频信号频谱
T=length(kmes)/fs;             % 发送时间
t=0:ts:T-ts;                    % 时域时间点
df=fs/length(t);                % 频率间隔
f=-fs/2:df:fs/2-df;             % 频域频率点

kmes_fft=fft(kmes)/fs;        % 各自求ft
bmes_fft=fft(bmes)/fs;

figure
subplot(2,2,1);
plot(t,bmes);title('bmes');
title('原始信号');
subplot(2,2,3);
plot(f,fftshift(bmes_fft));title('bmes_fft');
title('原始信号频谱');

subplot(2,2,2);
plot(t,kmes);title('kmes');
title('扩频信号');
subplot(2,2,4);
plot(f,fftshift(kmes_fft));title('kmes_fft');
title('扩频信号频谱');

%% 脉冲成型
% 假设带宽为4-8kHz，基带信号带宽为2kHz，码片长度为1/2kHz=0.5ms
% 信号发送频率为48kHz，0.5ms能够发送0.5ms*48kHz=24个符号
% 即一个码片(chip)长度为24
% 脉冲成型大小影响码片时间，进而影响带宽
rect=24;
rkmes=rectpulse(kmes,rect);
rbmes=rectpulse(bmes,rect);

%% 脉冲成型后原始信号与扩频信号频谱
T=length(rkmes)/fs;             % 发送时间
t=0:ts:T-ts;                    % 时域时间点
df=fs/length(t);                % 频率间隔
f=-fs/2:df:fs/2-df;             % 频域频率点

rkmes_fft=fft(rkmes)/fs;        % 各自求ft
rbmes_fft=fft(rbmes)/fs;

figure
subplot(2,2,1);
plot(t,rbmes);title('rbmes');
title('脉冲成型后原始信号');
subplot(2,2,3);
plot(f,fftshift(rbmes_fft));title('rbmes_fft');
title('脉冲成型后原始信号频谱');

subplot(2,2,2);
plot(t,rkmes);title('rkmes');
title('脉冲成型后扩频信号');
subplot(2,2,4);
plot(f,fftshift(rkmes_fft));title('rkmes_fft');
title('脉冲成型后扩频信号频谱');




