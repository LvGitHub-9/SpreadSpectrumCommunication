% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 直接序列扩频DSSS
% 文件名称：DSSS.m
% 版    本：V1.0
% 说    明：直扩完整仿真过程，bit数少时可以看解扩峰，bit数多时看误码率；
%           修改信噪比可以看误码率变化，目前没有做BER随SNR变化的图；
%           可以查看信号的频谱，扩频方式对频谱没有太大要求
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2024-12-27       Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 直接序列扩频
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

%% 直接扩频
kmes=kron(bimes,m);             % 克罗内克积

%% 脉冲成型
% 假设我需要的通信速率是200bps，一秒接收200个消息bit，就是5ms一个bit
% 假设发送频率48kHz，一秒发送48000个符号
% 根据发送频率，5ms可以发送48k*5ms=240个符号
% 扩频方式，一个消息bit长度是63
% 每个符号需要重复发送240/63=3.81，向上取整是4次
% 如果设置bits=200，脉冲成型长度为4，rmes的长度为50.4K，差不多一秒发完
rect=4;
rmes=rectpulse(kmes,rect);

%% 参数
fc=6e3;                         % 载波频率6kHz
fb=4e3;                         % 带宽4kHz
fs=48e3;                        % 采样频率48kHz
ts=1/fs;                        % 时域采样间隔
T=length(rmes)/fs;              % 发送时间
t=0:ts:T-ts;                    % 时域时间点
df=fs/length(t);                % 频率间隔
f=-fs/2:df:fs/2-df;             % 频域频率点

%% 上变频
mmes=rmes.*cos(2*pi*fc*t);      % 调制

%% 信道
% 不加信道
% ymes=rmes;

% 加AWGN信道
SNR=0;                          % 信噪比
ymes=awgn(kmes,SNR);

%% 下变频
dmmes=mmes.*cos(2*pi*fc*t);     % 解调

%% 低通滤波
Delay = 32;                     % 32阶滤波器
fircoef = fir1(2*Delay,fb/fs);
lpf = filter(fircoef,1,[dmmes zeros(1,Delay)]);
fmes = lpf(Delay+1:end);

%% 时域相关解扩
en=zeros(1,bits);               % 存储解扩序列
ex=[];                          % 存储自相关后的序列
W=floor(L/4);                   % 选取自相关峰值窗口的长度
buf=zeros(1,L);                 % 存储一个符号长度
conj=zeros(1,2*W);              % 在自相关函数中选取峰值窗口
                                % 用于判断峰值正负
                          
for i=1:bits
    sym=fmes(1,1+(i-1)*L*rect:i*L*rect);        % 取出一个符号长度
    for ii=1:L                                  % 解脉冲成型
        buf(ii)=sum(sym(1,1+(ii-1)*rect:ii*rect));
    end
    cor=xcorr(buf,m);               % 做自相关
    conj=cor(1,L-W:L+W);            % 选取自相关窗口
    ex=[ex cor];                    % 保存自相关函数
    if(max(conj)>abs(min(conj)))    % 判断自相关峰值正负，解扩
        en(i)=1;
    else
        en(i)=0;
    end
end

%% 误码率
A=find(en~=mes);                % 计算误码率
BER=length(A)/bits;
disp(['解码误码率：',num2str(BER)])

%% 作图
figure
subplot(3,1,1)
stem(mes)
title('消息序列');
axis([0.5 0.5+bits 0 1]);
subplot(3,1,2)
plot(kmes)
axis([0 length(kmes) -1 1]);
title('扩频序列');
subplot(3,1,3)
plot(ex)
title('解扩自相关峰值');
axis([0 length(ex) -L L]);

%% 查看频谱
% %% 脉冲成型频谱
% rmes_fft=fft(rmes)/fs;
% figure
% subplot(2,1,1);
% plot(t,rmes);title('rmes');
% title('脉冲成型信号');
% subplot(2,1,2);
% plot(f,fftshift(rmes_fft));title('rmes_fft');
% title('脉冲成型频谱');
% 
% %% 上变频频谱
% mes_fft=fft(mmes)/fs;
% figure
% subplot(2,1,1);
% plot(t,mmes);title('mmes');
% title('上变频信号');
% subplot(2,1,2);
% plot(f,fftshift(mes_fft));title('mes_fft');
% title('上变频频谱');
% 
% %% 下变频频谱
% mes_fft=fft(dmmes)/fs;
% figure
% subplot(2,1,1);
% plot(t,dmmes);title('dmmes');
% title('下变频信号');
% subplot(2,1,2);
% plot(f,fftshift(mes_fft));title('mes_fft');
% title('下变频频谱');
% 
% %% 低通滤波频谱
% mes_fft=fft(fmes)/fs;
% figure
% subplot(2,1,1);
% plot(t,fmes);title('fmes');
% title('低通滤波信号');
% subplot(2,1,2);
% plot(f,fftshift(mes_fft));title('mes_fft');
% title('低通滤波频谱');