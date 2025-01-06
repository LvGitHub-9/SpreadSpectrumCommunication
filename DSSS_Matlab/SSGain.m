%% 扩频增益研究
close all; clear; clc;

%% 消息生成
bits=8;                         % 消息个数
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

%% 参数
fc=6e3;                         % 载波频率6kHz
fb=4e3;                         % 带宽4kHz
fs=48e3;                        % 采样频率48kHz
ts=1/fs;                        % 时域采样间隔

%% 原始信号频谱
rect=240;
bimes=rectpulse(bimes,rect);

T=length(bimes)/fs;             % 发送时间
t=0:ts:T-ts;                    % 时域时间点
df=fs/length(t);                % 频率间隔
f=-fs/2:df:fs/2-df;             % 频域频率点

% bbmes=bimes.*cos(2*pi*fc*t);
bbmes_fft=fft(bimes)/fs;

figure
subplot(2,1,1);
plot(t,bimes);title('bimes');
title('原始信号');
subplot(2,1,2);
plot(f,fftshift(bbmes_fft));title('bbmes_fft');
title('原始信号频谱');

%% 扩频信号频谱
rect=240;
kmes=rectpulse(kmes,rect);

T=length(kmes)/fs;              % 发送时间
t=0:ts:T-ts;                    % 时域时间点
df=fs/length(t);                % 频率间隔
f=-fs/2:df:fs/2-df;             % 频域频率点

ssmes_fft=fft(kmes)/fs;

figure
subplot(2,1,1);
plot(t,kmes);title('kmes');
title('扩频信号');
subplot(2,1,2);
plot(f,fftshift(ssmes_fft));title('ssmes_fft');
title('扩频信号频谱');

